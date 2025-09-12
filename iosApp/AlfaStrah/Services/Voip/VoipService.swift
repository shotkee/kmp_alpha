//
//  VoipService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

enum VoipServiceAvailability {
    case connected
    case speaking
    case pendingDisconnect
    case disconnected
}

enum VoipServiceError: Error {
    case unknown
    case notAvailable
    case failed
    case error(Error)
}

protocol VoipService {
    typealias AvailabilityCallback = (_ availability: VoipServiceAvailability) -> Void

    var availability: VoipServiceAvailability { get }

    func subscribeForAvailability(_ callback: @escaping AvailabilityCallback) -> Subscription

    func call(_ voipCall: VoipCall)
    func muteCall(_ mute: Bool)
    func send(digit: String)
    func endCall()
    func microphonePermission(completion: @escaping (Result<Void, VoipServiceError>) -> Void)
}
