//
//  CommonVoipService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy
import VoxImplantSDK
import CallKit

class CommonVoipService: NSObject,
                         VoipService,
                         VIClientSessionDelegate,
                         VICallDelegate {
    private let rest: FullRestClient
    private let alertPresenter: AlertPresenter
    private let logger: TaggedLogger?
    
    private(set) var availability: VoipServiceAvailability = .disconnected {
        didSet {
            guard availability != oldValue
            else { return }

            notifyAvailabilitySubscribers()
        }
    }
    private let availabilitySubscriptions: Subscriptions<VoipServiceAvailability> = Subscriptions()
    
    private var currentVoipCall: VoipCall?
    
    private var cancellable: CancellableNetworkTaskContainer?

    init(
        rest: FullRestClient,
        alertPresenter: AlertPresenter,
        logger: TaggedLogger?
    ) {
        self.rest = rest
        self.alertPresenter = alertPresenter
        self.logger = logger
    }

    func subscribeForAvailability(_ callback: @escaping AvailabilityCallback) -> Subscription {
        availabilitySubscriptions.add(callback)
    }

    func call(_ voipCall: VoipCall) {
        currentVoipCall = voipCall
        
        switch voipCall.type {
            case .voxImplant(data: let data):
                createClientAndConnectWithVoxImplant(data: data)
				
            case .none:
                break
        }
    }

    func muteCall(_ mute: Bool) {
        guard let currentVoipCall
        else { return }
        
        switch currentVoipCall.type {
            case .voxImplant:
                voxImplantMuteCall(mute)
				
            case .none:
                break
        }
    }

    func send(digit: String) {
        switch digit {
            case "*":
                send(number: 10)
                
            case "#":
                send(number: 11)
                
            default:
                let stringArray = digit.components(separatedBy: CharacterSet.decimalDigits.inverted)
                
                for item in stringArray {
                    if let number = Int32(item) {
                         send(number: number)
                    }
                }
        }
    }

	private func send(number: Int32) {
		guard let currentVoipCall
		else { return }
		
		switch currentVoipCall.type {
			case .voxImplant:
				outgoingCall?.sendDTMF(String(number))
				
			case .none:
				break
		}
	}
	
    func endCall() {
        guard availability != .pendingDisconnect,
              availability != .disconnected
        else { return }
        
        // so we cannot predict at what stage of voip call establishing user will call this method
        // this can happen both on methods that we can cancel and on methods that we cannot (voximp
        // internal chain of connection sequence before func call(_ call: VICall, didConnectWithHeaders headers: [AnyHashable: Any]?))
        // taking this fact into account, we expect a successful connection and only then call voxImplantEndCall() method if needed
        
        cancellable?.cancel()
        availability = .pendingDisconnect
        
        guard let currentVoipCall
        else { return }
        
        switch currentVoipCall.type {
            case .voxImplant:
                voxImplantEndCall()
            case .none:
                break
        }
    }

    private func notifyAvailabilitySubscribers() {
        availabilitySubscriptions.fire(availability)
    }
    
    // MARK: - VIClientSessionDelegate
    private var client: VIClient?
    private var oneTimeKey: String?
    private var outgoingCall: VICall?
    
    private func createClientAndConnectWithVoxImplant(data: VoxImplantCallData) {
        client = VIClient(delegateQueue: DispatchQueue.main)
        client?.sessionDelegate = self
        client?.connect()
        availability = .connected
    }
    
    func clientSessionDidConnect(_ client: VIClient) {
        guard let currentVoipCall,
              let client = self.client,
              case let .voxImplant(data: data) = currentVoipCall.type
        else { return }
                
        client.requestOneTimeKey(withUser: data.usernameForOneTimeLoginKey) { oneTimeKey, error  in
            if error != nil {
                self.logger?.debug("\(String(describing: error))")
                
                self.availability = .disconnected
                return
            }
            
            guard let oneTimeKey
            else {
                self.logger?.debug("one time key returned from vox implant service is nil")
                self.availability = .disconnected
                return
            }
            
            self.voxImplantAccessToken(
                username: data.usernameForOneTimeLoginKey,
                oneTimeKey: oneTimeKey
            ) { result in
                switch result {
                    case .success(let oneTimeKey):
                        client.login(
                            withUser: data.from,
                            oneTimeKey: oneTimeKey,
                            success: { displayName, authParams in
                                self.logger?.debug("\(displayName)")
                                self.logger?.debug("\(String(describing: authParams))")
                                
                                let settings = VICallSettings()
                                settings.videoFlags = .videoFlags(receiveVideo: false, sendVideo: false)
                                settings.extraHeaders = data.headers.reduce([String: String]()) { dict, header -> [String: String] in
                                    var dict = dict
                                    dict[header.title] = header.value
                                    return dict
                                }
                                
                                self.outgoingCall = client.call(data.destination, settings: settings)
                                self.outgoingCall?.add(self)
                                
                                self.outgoingCall?.start()
                            },
                            failure: { error in
                                self.logger?.debug("\(error)")
                                self.availability = .disconnected
                                self.handleError(with: error.localizedDescription)
                            }
                        )
                    case .failure(let error):
                        self.logger?.debug("\(error)")
                        self.availability = .disconnected
                        
                        self.handleAlfastrahError(error)
                }
            }
        }
    }
    
    func client(_ client: VIClient, sessionDidFailConnectWithError error: Error) {
        logger?.debug("\(error)")
        availability = .disconnected
        
        // since error.localizedDescription returns only english version
        handleError(with: NSLocalizedString("common_error_unknown_error", comment: ""))
    }
    
    func call(_ call: VICall, didConnectWithHeaders headers: [AnyHashable: Any]?) {
        switch availability {
            case .connected:
                logger?.debug("Call connected")
                availability = .speaking
            case .disconnected, .pendingDisconnect:
                logger?.debug("Call was ended by user before connection was establish")
                voxImplantEndCall()
                cancellable?.cancel()
            case .speaking:
                break
        }
    }

    func call(_ call: VICall, didDisconnectWithHeaders headers: [AnyHashable: Any]?, answeredElsewhere: NSNumber) {
        logger?.debug("Call disconnected")
        availability = .disconnected
    }

    func call(_ call: VICall, didFailWithError error: Error, headers: [AnyHashable: Any]?) {
        logger?.debug("Call failed, \(error.localizedDescription)")
        availability = .disconnected
        handleError(with: error.localizedDescription)
    }
    
    func clientSessionDidDisconnect(_ client: VIClient) {
        availability = .disconnected
    }
    
    private func voxImplantEndCall() {
        outgoingCall?.hangup(withHeaders: nil)
    }
    
    private func voxImplantMuteCall(_ mute: Bool) {
		outgoingCall?.sendAudio = !mute
	}
    
    private func voxImplantAccessToken(
        username: String,
        oneTimeKey: String,
        completion: @escaping (Result<String, AlfastrahError>) -> Void
    ) {
        let object: [String: String] = [
            "username": username,
            "login_key": oneTimeKey
        ]
        
        self.cancellable = CancellableNetworkTaskContainer()
        let task = rest.create(
            path: "api/voximplant/init",
            id: nil,
            object: object,
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(key: "token", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error ):
                        completion(.failure(error))
                        
                        self.handleAlfastrahError(error)
                }
            }
        )
        cancellable?.addCancellables([ task ])
    }
    
    func microphonePermission(completion: @escaping (Result<Void, VoipServiceError>) -> Void) {
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        
        switch audioSession.recordPermission {
            case .granted:
                completion(.success(()))
            case .denied:
                completion(.failure(.notAvailable))
            case .undetermined:
                audioSession.requestRecordPermission { granted in
                    if granted {
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    }
                }
            @unknown default:
                completion(.failure(.unknown))
        }
    }
    
    private func handleError(with description: String?) {
        alertPresenter.show(alert: ErrorNotificationAlert(
            error: nil,
            text: description ?? NSLocalizedString("common_error_unknown_error", comment: ""),
            combined: true,
            action: nil
        ))
        
        endCall()
        availability = .disconnected
    }
    
    private func handleAlfastrahError(_ error: AlfastrahError) {
        if case .network(let networkError) = error {
            if networkError.isUnreachableError {
                handleError(with: NSLocalizedString("no_internet_connection", comment: ""))
            } else {
                if let displayValue = error.displayValue {
                    handleError(with: displayValue)
                } else {
                    handleError(with: error.localizedDescription)
                }
            }
        } else {
            handleError(with: error.localizedDescription)
        }
    }
}
