//
//  CascanaChatService.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy
import SwiftSignalRClient
import FirebaseMessaging
import SDWebImage

// swiftlint:disable all
public class CascanaChatService: NSObject,
								 HubConnectionDelegate,
								 ChatService,
								 URLSessionDataDelegate,
								 URLSessionDownloadDelegate {
    private let rest: FullRestClient
    private let logger: TaggedLogger?
    private let userSessionService: UserSessionService
    private let accountService: AccountService
    private let analyticsService: AnalyticsService
    private let notificationsService: NotificationsService
    private let attachmentService: AttachmentService
    private let applicationSettingsService: ApplicationSettingsService
    private let endpointsService: EndpointsService
	private let insurancesService: InsurancesService
    private let http: Http
    
    var baseUrl: URL?
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var chatServerUrl: URL?
    private var webSocketUrl: URL?
    
    private var fcmToken: String?
    private var account: Account?
    
    private var chatRest: FullRestClient?
    private var refreshRest: FullRestClient?
    private let chatAuthorizer = ChatRequestAutorizer()
    
    private var historyPreviousPageStartMessage: CascanaChatReceiveMessage?
    private var previousHistoryMessage: CascanaChatReceiveMessage?
    private var lastMessage: Message?
        
    private var userInfoDictionary: [String: Any?]?
    
    private let additionalInfo: [String: Any?] = [
        "app_platform": "iOS",
        "build_type": "app_store",
        "app_version": AppInfoService.applicationShortVersion,
        "build_version": AppInfoService.buildVersion
    ]
    
    private(set) var messages: [Message] = []
    
    private var refreshSessionIndex = 0
    private let refreshSessionTryLimit = 5
        
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private var cancellable = CancellableNetworkTaskContainer()
        
    private var chatMessagesSubsciptions: Subscriptions<Void> = Subscriptions()
    func subscribeChatMessagesChanged(listener: @escaping () -> Void) -> Subscription {
        chatMessagesSubsciptions.add(listener)
    }
		
    init(
        rest: FullRestClient,
        logger: TaggedLogger?,
        accountService: AccountService,
        userSessionService: UserSessionService,
        applicationSettingsService: ApplicationSettingsService,
        notificationsService: NotificationsService,
        attachmentService: AttachmentService,
        analyticsService: AnalyticsService,
        endpointsService: EndpointsService,
		insurancesService: InsurancesService,
        http: Http,
        baseUrl: URL? = nil,
		store: Store
    ) {
        self.rest = rest
        self.logger = logger
        self.userSessionService = userSessionService
        self.accountService = accountService
        self.applicationSettingsService = applicationSettingsService
        self.notificationsService = notificationsService
        self.attachmentService = attachmentService
        self.analyticsService = analyticsService
        self.endpointsService = endpointsService
        self.http = http
        self.baseUrl = baseUrl
		self.insurancesService = insurancesService
		self.store = store
		
		super.init()
                
        userSessionService.subscribeSession { [weak self] _ in
            guard let self
            else { return }
            
            self.chatSession = nil
            self.startNewChatService()
        }.disposed(by: disposeBag)
        
        chatAuthorizer.sessionSubscription = subscribeChatSessionUpdate(listener: chatAuthorizer.sessionListener)
        
        self.chatSession = applicationSettingsService.chatSession
        self.chatAuthorizer.session = self.chatSession
        
        chatSessionSubscriptions.fire(chatSession)
		
		loadFileEntries()
		
		self.currentOperator = cachedCurrentOperator()
    }
    
    func getMessages() -> [Message] {
        return messages
    }
    
    func getMessageIndex(by id: String) -> Int? {
        return messages.firstIndex(where: { $0.getID() == id })
    }
    
    private var chatSessionSubscriptions: Subscriptions<CascanaChatSession?> = Subscriptions()
    
    func subscribeChatSessionUpdate(listener: @escaping (_ session: CascanaChatSession?) -> Void) -> Subscription {
        return chatSessionSubscriptions.add(listener)
    }
	
	private var chatOperatorScoreChangedSubscriptions: Subscriptions<Void> = Subscriptions()
	func subscribeChatOperatorScore(listener: @escaping () -> Void) -> Subscription {
		chatOperatorScoreChangedSubscriptions.add(listener)
	}
	
	private var chatOperatorScoreResultSubscriptions: Subscriptions<Bool> = Subscriptions()
	func subscribeChatOperatorScoreResult(listener: @escaping (Bool) -> Void) -> Subscription {
		chatOperatorScoreResultSubscriptions.add(listener)
	}
    
    // MARK: - Cascana
    private var connection: HubConnection?
        
    private func stopChatService() {
        cancellable.cancel()
        connection?.stop()
        connection = nil
    
        historyPreviousPageStartMessage = nil
        previousHistoryMessage = nil
        lastMessage = nil
        historyWasEmpty = false

		currentOperator = nil

        onOperatorTypingStateChanged(isTyping: false)
        
        messages.removeAll()
    }
    
    // MARK: - SignalR: Common
    private enum RoomEvent: String, Codable {
        case typingStarted = "TypingStarted"
        case typingFinished = "TypingFinished"
        case participantConnected = "ParticipantConnected"
        case participantDisconnected = "ParticipantDisconnected"
        case pageRedirect = "PageRedirect"
        case attachmentUploadError = "AttachmentUploadError"
        case rawText = "RawText"
    }
    
    private func addConnectionMethods() {
        addMethod(method: .message, handler: handleMessages)
        addMethod(method: .roomNotFound, handler: handleRoomNotFound)
        addMethod(method: .complete, handler: handleComplete)
        addMethod(method: .roomEvent, handler: handleRoomEvent)
        addMethod(method: .failure, handler: handleFailure)
        addMethod(method: .statusUpdate, handler: handleStatusUpdate)
        addMethod(method: .history, handler: handleHistory)
        addMethod(method: .rate, handler: handleRate)
        addMethod(method: .keyboard, handler: handleKeyboard)
        addMethod(method: .deleteFromOperator, handler: handleDeleteFromOperator)
        addMethod(method: .editFromOperator, handler: handleEditFromOperator)
    }
    
    // MARK: - SignalR: Receive
    private enum ReceiveMethod: String {
        case message = "ReceiveMessage"
        case history = "ReceiveHistoryMessage"
        case editFromOperator = "ReceiveEditMessageRequest"
        case deleteFromOperator = "ReceiveDeleteMessageRequest"
        case rate = "ReceiveRateRequest"
        case keyboard = "ReceiveTemplateKeyboard"
        case roomEvent = "ReceiveRoomEvent"
        case roomNotFound = "RoomNotFound"
        case failure = "FailureOperation"
        case complete = "CreateRoomComplete"
        case statusUpdate = "MessageStatusUpdate"
    }

    private func addMethod<T: Decodable>(
        method: ReceiveMethod,
        handler: @escaping (_ arg: T) -> Void
    ) {
        connection?.on(
            method: method.rawValue,
            callback: handler
        )
    }
    
    private func addMethod<T1: Decodable, T2: Decodable>(
        method: ReceiveMethod,
        handler: @escaping (_ arg1: T1, _ arg2: T2) -> Void
    ) {
        connection?.on(
            method: method.rawValue,
            callback: handler
        )
    }
    
    private func handleMessages(_ messages: [CascanaChatReceiveMessage]) {
        guard !messages.isEmpty
        else { return }
		
        for message in messages {
            guard let direction = message.direction,
				  message.type != .scoreRequest
            else { continue }
			
			removeScoreMessage()
			
			if message.isBroadcast == false,
			   message.getSenderId() != nil {
				saveCurrentOperatorIfNeeded(from: message)
			}
						            
            switch direction {
                case .fromServer:
                    if let oldVersionMessage = self.messages.first(where: { $0.getID() == message.id }) as? CascanaChatReceiveMessage {
                        var messageWithNewStatus = oldVersionMessage
                        messageWithNewStatus.status = .delivered
                        update(message: oldVersionMessage, to: messageWithNewStatus)
                    } else {
                        add(message, after: lastMessage)
                        setChatRead([message])
                    }
                    lastMessage = message
                case .toServer:
                    continue
                case .unknown:
                    continue
            }
        }
        
        chatMessagesSubsciptions.fire(())
    }
	
	@discardableResult private func saveCurrentOperatorIfNeeded(from: Message) -> Bool {
		guard from.getRequestId() != nil
		else { return false }
		
		let chatOperator = CascanaChatOperator(
			name: from.getSenderName(),
			senderId: from.getSenderId(),
			requestId: from.getRequestId()
		)
		
		if chatOperator.getSenderId() == nil { // on scoreRequest with single requestId field
			self.currentOperator = chatOperator
			return true
		}
		
		if let currentOperator = self.currentOperator {
			if currentOperator.getSenderId() != chatOperator.getSenderId() {
				self.currentOperator = chatOperator
				
				return true
			}
		} else {
			self.currentOperator = chatOperator
			return true
		}
		
		return false
	}
	
	private func cachedCurrentOperator() -> CascanaChatOperator? {
		var cachedOperator: CascanaChatOperator?
		
		try? store.read { transaction in
			cachedOperator = try transaction.select().first
		}
		
		if let cachedOperator {
			logger?.warning("operator \(cachedOperator.getName()) loaded from store with sender id \(cachedOperator.getSenderId()) and score: \(cachedOperator.getRate())")
		}
		
		return cachedOperator
	}
	
	func saveLastVisibleScoreRequestMessageId(_ id: String) {
		applicationSettingsService.lastVisibleScoreRequestMessageId = id
	}
	
    private func add(_ newMessage: Message, after previousMessage: Message?) {
        var inserted = false
        
        if let previousMessage = previousMessage {
            for (index, message) in messages.enumerated() {
                if previousMessage.isEqual(to: message) {
					// set state for document attachment
					messages.insert(newMessage, at: (index == messages.endIndex) ? index : (index + 1))
					inserted = true
					
                    break
                }
            }
        }
        
        if !inserted {
            messages.insert(newMessage, at: 0)
        }
    }
	
	private func updateAttachmentStateIfNeeded(for newMessage: Message) {
		if let attachmentUrl = newMessage.getData()?.getAttachment()?.getFileInfo().getURL() {
			if let fileEntry = fileEntries.first(where: { $0.remoteUrlPathBase64Encoded == attachmentUrl.absoluteString.data(using: .utf8)?.base64EncodedString() }) {
				if var newMessage = (newMessage as? CascanaChatReceiveMessage) {
					if localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).exists {
						let localUrl = localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).url
						let size = localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).sizeBytes
						
						if size != 0 {
							newMessage.attachments?[safe: 0]?.state = .local(size)
							newMessage.attachments?[safe: 0]?.update(
								fileInfo: CascanaFileInfo(url: localUrl, filename: fileEntry.filename, size: size)
							)
						} else { // this is error condition - previous file manager document write operation was failed
							localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).remove()
							newMessage.attachments?[safe: 0]?.state = .remote(nil)
							newMessage.attachments?[safe: 0]?.update(
								fileInfo: CascanaFileInfo(url: nil, filename: fileEntry.filename, size: nil)
							)
						}
					} else { // we have no cache for this document in message
						newMessage.attachments?[safe: 0]?.state = .remote(nil)
						newMessage.attachments?[safe: 0]?.update(
							fileInfo: CascanaFileInfo(url: nil, filename: fileEntry.filename, size: nil)
						)
					}
				}
			}
		}
	}
    
    private func update(message oldVersion: Message, to newVersion: Message) {
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == oldVersion.getID() {
                messages[messageIndex] = newVersion
                break
            }
        }
    }
    
    private func remove(_ message: Message) {
        if let deletedMessageIndex = messages.firstIndex(where: { $0.getID() == message.getID() }) {
            messages.remove(at: deletedMessageIndex)
            lastMessage = messages.last
        }
    }
	
    private func handleHistory(_ messages: [CascanaChatReceiveMessage]) {
        if messages.isEmpty {
            historyWasEmpty = true // history was fully loaded
            return
        }
		
        for receivedHistoryMessage in messages {
            var message = receivedHistoryMessage
    
			updateAttachmentStateIfNeeded(for: message)
			
			if message.getKeyboard() != nil {
				message.keyboardState = message.getID() == messages.first?.getID()
					? .pending
					: .canceled
			}
            
            if lastMessage == nil {
                lastMessage = message
            }
            
            if historyPreviousPageStartMessage?.date == nil {
                historyPreviousPageStartMessage = message
                
				if historyMessageCanBeAddedToFeed(message) {
					add(message, after: nil)
				}
                
                previousHistoryMessage = message
                continue
            }
            
            if let startDate = historyPreviousPageStartMessage?.date,
               let messageDate = message.date,
               messageDate < startDate {
                historyPreviousPageStartMessage = message
				if historyMessageCanBeAddedToFeed(message) {
					add(message, after: nil)
				}
            } else {
				if historyMessageCanBeAddedToFeed(message) {
					add(message, after: previousHistoryMessage)
				}
                previousHistoryMessage = message
                lastMessage = message
            }
        }
		
		func addScoreMessageToFeed(_ scoreRequestMessage: Message) {
			if self.messages.last?.getID() != scoreRequestMessage.getID() {
				self.messages.append(scoreRequestMessage)
			}
		}
		
		if let scoreRequestMessage = self.lastMessage,
		   scoreRequestMessage.getType() == .scoreRequest,
		   scoreRequestMessage.getRequestId() != nil { // not show rating cell after install
			saveCurrentOperatorIfNeeded(from: scoreRequestMessage)
			
			if applicationSettingsService.lastVisibleScoreRequestMessageId == scoreRequestMessage.getID() {
				if !applicationSettingsService.pinCodeScreenWasShownAfterChatScoreRequest {
					addScoreMessageToFeed(scoreRequestMessage)
				}
			} else {
				addScoreMessageToFeed(scoreRequestMessage)
				applicationSettingsService.pinCodeScreenWasShownAfterChatScoreRequest = false
			}
		}
		
        chatMessagesSubsciptions.fire(())
    }
	
	private func removeScoreMessage() {
		if self.messages.last?.getType() == .scoreRequest {
			self.messages.removeLast()
		}
		self.lastMessage = self.messages.last
	}
	
	private func historyMessageCanBeAddedToFeed(_ message: CascanaChatReceiveMessage) -> Bool {
		switch message.type {
			case .buttons, .text:
				return true
			case .score, .scoreRequest, .none:
				return false
		}
	}
    
    private func handleDeleteFromOperator(_ request: CascanaChatDeleteMessageFromOperatorRequest) {
        if let messageIndex = messages.firstIndex(where: { $0.getID() == request.id }) {
            messages.remove(at: messageIndex)
            lastMessage = messages.last
        }
    }
    
    private func handleEditFromOperator(_ request: CascanaChatEditMessageFromOperatorRequest) {
        if let oldVersionMessageIndex = messages.firstIndex(where: { $0.getID() == request.messageId}),
           var newVersionMessage = messages[oldVersionMessageIndex] as? CascanaChatReceiveMessage {
            
            newVersionMessage.text = request.text
            newVersionMessage.attachments = nil
            newVersionMessage.type = request.type
            newVersionMessage.isHtml = request.isHtml
            
            self.messages[oldVersionMessageIndex] = newVersionMessage
        }
    }
        
    private func handleRoomNotFound(_ emptyResponse: CascanaChatEmptyResponse) {
        logger?.debug("Cascana chat room not found")
    }
    
    private func handleComplete(_ emptyResponse: CascanaChatEmptyResponse) {
        logger?.debug("Cascana chat room creation complete")
    }
    
    private func handleRoomEvent(_ roomEvent: RoomEvent, _ operatorName: String?) {
        self.logger?.debug("Cascana chat room event: \(roomEvent) from \(String(describing: operatorName))")
                
        switch roomEvent {
            case .typingStarted:
                onOperatorTypingStateChanged(isTyping: true)
            case .typingFinished:
                onOperatorTypingStateChanged(isTyping: false)
            case .attachmentUploadError:
                handleNotFatalError()
			case .participantDisconnected:
				onOperatorTypingStateChanged(isTyping: false)
			case .participantConnected, .pageRedirect, .rawText:
				break
        }
    }
    
    private func handleFailure(_ description: String) {
        logger?.debug("Cascana chat failure: \(description) ")
        // to conformance with ChatService protocol
        handleNotFatalError()
    }
    
    private func handleStatusUpdate(_ status: CascanaChatMessageStatus, _ messageId: String) {
        logger?.debug("Cascana message with id \(messageId), status update: \(status) ")
        
        if let oldVersionMessage = messages.first(where: { $0.getID() == messageId}) as? CascanaChatReceiveMessage {
            var newVersionMessage = oldVersionMessage
            
            switch status {
                case .delivered, .errorSending, .read, .readyToSent, .registered, .undefined, .errorCommon:
                    newVersionMessage.status = status
                    
                    update(message: oldVersionMessage, to: newVersionMessage)
					
                case .sent:
                    if oldVersionMessage.status == .deletePending {
                        remove(oldVersionMessage)
                    } else if oldVersionMessage.status == .editPending {
                        if let newText = oldVersionMessage.newText {    // if newText nil or empty - do we need delete this message?
                            newVersionMessage.text = oldVersionMessage.newText
                        }
                        newVersionMessage.newText = nil
                        newVersionMessage.status = status
                        
                        update(message: oldVersionMessage, to: newVersionMessage)
                    }
                    
                case .deletePending, .editPending:
                    break
                    
            }
        }
    }
    
    private func handleRate(_ scoreRequestMessage: CascanaChatReceiveMessage) {
		logger?.debug("rate operator \(scoreRequestMessage.getSenderName()) by ReceiveRateRequest:\nrequest id \(scoreRequestMessage.requestId)\nsender id \(scoreRequestMessage.senderId)")
		        
		self.messages.append(scoreRequestMessage)
		chatMessagesSubsciptions.fire(())
    }

    private func updateMessage(with message: CascanaChatReceiveMessage) {
        if let oldVersionMessage = self.messages.first(where: { $0.getID() == message.id }) {
            update(message: oldVersionMessage, to: message)
            chatMessagesSubsciptions.fire(())
        }
    }
    
    private func onOperatorTypingStateChanged(isTyping: Bool) {
        operatorIsTypingUpdateSubscriptions.fire(isTyping)
    }
            
    private func handleKeyboard(_ keyboardMessage: CascanaChatReceiveMessage, _ timestamp: String) {
        logger?.debug("Keyboard message received with id \(keyboardMessage.id)")
        guard let buttons = keyboardMessage.buttons,
              !buttons.isEmpty,
              keyboardMessage.direction == .fromServer,
              keyboardMessage.type == .buttons
        else { return }
        
        var keyboardMessage = keyboardMessage
        keyboardMessage.keyboardState = .pending
        
        add(keyboardMessage, after: lastMessage)
        chatMessagesSubsciptions.fire(())
        
        lastMessage = keyboardMessage
    }
        
    // MARK: - SignalR: Transmit
    private enum TransmitMethod: String {
        case createRoom = "CreateRoomInit"
        case message = "SendMessageToChat"
        case history = "GetMessagesHistory"
        case roomEvent = "SendRoomEvent"
        case status = "SendMessageStatus"
        case statuses = "SendMessageStatuses"
        case createRoomWithDetails = "CreateRoomWithDetails"
        case deleteMessage = "SendDeleteMessageToChat"
        case editMessage = "SendEditMessageToChat"
    }
    
    private func createRoom(completion: @escaping (Result<Void?, AlfastrahError>) -> Void) {
        connection?.invoke(method: TransmitMethod.createRoom.rawValue, "", "", "") { error in
            if let error = error {
                completion(.failure(.error(error)))
				self.analyticsSendError(errorContent: error.localizedDescription)
                return
            }
            completion(.success(nil))
        }
    }
    
    private func createRoomWithDetails(completion: @escaping (Result<Void?, AlfastrahError>) -> Void) {
        let null: String? = nil
        
        refreshFcmToken { result in
            switch result {
                case .success(let fcmToken):
                    self.connection?.invoke(
                        method: TransmitMethod.createRoomWithDetails.rawValue,
                        self.account?.firstName,  // next parameters filled for compability with android
                        null,
                        null,
                        fcmToken,
                        "iOS",
                        null,       // device name
                        "Safari"
                    ) { error in
                        if let error = error {
                            completion(.failure(.error(error)))
							self.analyticsSendError(errorContent: error.localizedDescription)
                            return
                        }
                        completion(.success(nil))
                    }
					
                case .failure(let error):
                    completion(.failure(.error(error)))
					self.analyticsSendError(errorContent: error.localizedDescription)
					
            }
        }
    }
            
    private func send(message: CascanaChatSendMessage, completion: @escaping (Result<Void?, AlfastrahError>) -> Void) {
		removeScoreMessage()
		
        var sendMessage = message
        if let userInfoDictionary = self.userInfoDictionary,
           let hash = userInfoDictionary["hash"] as? String,
           let userInfo = userInfoDictionary["user_info"],
           let fields = userInfoDictionary["fields"],
           let userInfoData = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
           let userInfoDataString = String(data: userInfoData, encoding: .utf8),
           let fieldsData = try? JSONSerialization.data(withJSONObject: fields, options: []),
		   let fieldsDataString = String(data: fieldsData, encoding: .utf8) {

            var parameters: [String: String?] = [:]
            parameters["hash"] = hash
            parameters["user_info"] = userInfoDataString
            parameters["fields"] = fieldsDataString
            
            sendMessage.parameters = parameters
        }
        
        sendMessage.contactPoint = Constants.sendMessageContactPoint
        
        connection?.invoke(method: TransmitMethod.message.rawValue, sendMessage) { error in
            if let error = error {
                completion(.failure(.error(error)))
				self.analyticsSendError(errorContent: error.localizedDescription)
				
                return
            }
            completion(.success(nil))
        }
    }
    
    private func history(
        messagesCount: Int?,
        from startDate: Date,
        to endDate: Date?,
        completion: @escaping (Result<Void?, AlfastrahError>) -> Void
    ) {
        let fromDateString = dateFormatter.string(from: startDate)
        
        connection?.invoke(method: TransmitMethod.history.rawValue, messagesCount, fromDateString, Optional<String>.none) { error in
            if let error = error {
                completion(.failure(.error(error)))
				self.analyticsSendError(errorContent: error.localizedDescription)
                return
            }
            completion(.success(nil))
        }
    }
    
    private func setReadStatus(
        for messages: [Message],
        completion: @escaping (Result<Void?, AlfastrahError>) -> Void
    ) {
        let readStatusRequests = messages.map { CascanaChatChangeMessageStatusRequest(messageId: $0.getID(), status: .read) }
        
        connection?.invoke(method: TransmitMethod.statuses.rawValue, readStatusRequests) { error in
            if let error = error {
                completion(.failure(.error(error)))
				self.analyticsSendError(errorContent: error.localizedDescription)
                return
            }
            completion(.success(nil))
        }
    }
    
    private func deleteMessage(with messageId: String, completion: @escaping (Result<Void?, AlfastrahError>) -> Void) {
        connection?.invoke(
            method: TransmitMethod.deleteMessage.rawValue,
            CascanaChatDeleteMessageRequest(id: messageId)
        ) { error in
            if let error = error {
                completion(.failure(.error(error)))
				self.analyticsSendError(errorContent: error.localizedDescription)
                return
            }
            completion(.success(nil))
        }
    }
    
    private func editMessage(
        with messageId: String,
        text: String,
        attachment: CascanaChatAttachment? = nil,
        completion: @escaping (Result<Void?, AlfastrahError>) -> Void
    ) {
        var attahments: [CascanaChatAttachment]?
        
        if let attachment = attachment {
            attahments = [attachment]
        }
        
        connection?.invoke(
            method: TransmitMethod.editMessage.rawValue,
            CascanaChatEditMessageRequest(
                id: messageId,
                text: text,
                attachments: attahments
            )
        ) { error in
            if let error = error {
                completion(.failure(.error(error)))
				self.analyticsSendError(errorContent: error.localizedDescription)
		
                return
            }
            completion(.success(nil))
        }
    }
    
    // MARK: - Service
    var historyWasEmpty: Bool = false
	private var historyWillLoadFirstPage = false
    
    // MARK: - Cascana variables
    private var stateUpdateSubscriptions: Subscriptions<ChatServiceState> = Subscriptions()
    private var operatorIsTypingUpdateSubscriptions: Subscriptions<Bool> = Subscriptions()
    private var nonFatalErrorsSubscriptions: Subscriptions<Error> = Subscriptions()
    
    // MARK: - Chat protocol methods
	var currentOperator: Operator? {
		didSet {
			guard currentOperator?.getSenderId() != oldValue?.getSenderId()
			else { return }
			
			self.chatOperatorScoreChangedSubscriptions.fire(())
			
			if let cascanaCurrentOperator = currentOperator as? CascanaChatOperator {
				logger?.warning("operator \(cascanaCurrentOperator.getName()) saved to store with sender id \(cascanaCurrentOperator.getSenderId()) and score: \(cascanaCurrentOperator.getRate())")
				
				try? self.store.write { transaction in
					try transaction.delete(type: CascanaChatOperator.self)
					try transaction.insert(cascanaCurrentOperator)
				}
			}
		}
	}
    
    private(set) var serviceState: ChatServiceState = .disabled {
        didSet {
            stateUpdateSubscriptions.fire(serviceState)
        }
    }
    
    func startNewChatService() {
        stopChatService()
        
        serviceState = .loading
        
        refreshSessionIndex = 0
        
        var lastError: AlfastrahError?
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        accountService.getAccount(useCache: true) { result in
            dispatchGroup.leave()
            switch result {
                case .success(let account):
                    self.account = account
					
                case .failure(let error):
					self.analyticsSendError(errorContent: error.localizedDescription)
                    self.account = nil
					
            }
        }
        
        dispatchGroup.enter()
        endpointsService.endpoints { result in
            dispatchGroup.leave()
            switch result {
                case .success(let endpoints):
                    let chatServerBasePath = endpoints.cascanaChatServiceDomain
                    self.chatServerUrl = URL(string: "https://\(chatServerBasePath)")
                    self.webSocketUrl = URL(string: "wss://\(chatServerBasePath)/CEC.Frontend.FrontMessageSender/hubReceiveMessageFromBack")

                case .failure(let error):
                    self.logger?.debug("Endpoints request endpoints: \(error)")
                    lastError = error
					self.analyticsSendError(errorContent: error.localizedDescription)
					
            }
        }
            
        dispatchGroup.notify(queue: .main) {
            if let error = lastError {
                self.serviceState = .unknownError(error)
				self.analyticsSendError(errorContent: error.localizedDescription)
				
                return
            }
            
            guard let chatServerUrl = self.chatServerUrl,
                  self.webSocketUrl != nil
            else {
                self.serviceState = .fatalError(.unknown)
				self.analyticsSendError(errorContent: ChatServiceState.fatalError(.unknown).description)
				
                return
            }
            
            let queue = DispatchQueue.global(qos: .default)
            
            let chatRest = AlfastrahRestClient(
                http: self.http,
                baseURL: chatServerUrl,
                workQueue: queue,
                completionQueue: .main,
                requestAuthorizer: self.chatAuthorizer
            )

            let refreshRest = AlfastrahRestClient(
                http: self.http,
                baseURL: chatServerUrl,
                workQueue: queue,
                completionQueue: .main,
                requestAuthorizer: nil
            )
            
            self.chatRest = chatRest
            self.chatAuthorizer.refreshRest = refreshRest
            self.chatAuthorizer.middleRest = self.rest
            
            if self.accountService.isDemo {
                self.serviceState = .demoMode
                self.stopChatService()
                return
            }
            
            if let chatSession = self.chatSession {
                self.handleNewChatSession(chatSession)
            } else {
                self.refreshChatSession { result in
                    switch result {
                        case .success(let session):
                            self.handleNewChatSession(session)
							
                        case .failure(let error):
                            self.serviceState = .accessError(error)
							self.analyticsSendError(errorContent: error.localizedDescription)
							
                    }
                }
            }
        }
    }
    
    private func handleNewChatSession(_ session: CascanaChatSession) {
        stopChatService()

        self.chatSession = session
                        
        if !self.accountService.isAuthorized { // anonymous chat session
            self.logger?.debug("Cascana anonynous chat session start")
            self.createConnection(from: session)
            return
        }
        
        self.userAuthJson { result in
            switch result {
                case .success(let json):
                    
                    guard let userInfo = json.string,
                          !userInfo.isEmpty,
                          var userInfoDictionary = try? JSONSerialization.jsonObject(with: Data(userInfo.utf8)) as? [String: Any]
                    else {
                        self.serviceState = .emptyUserInfo
                        return
                    }
                                                  
                    userInfoDictionary["user_info"] = self.additionalInfo
                    
                    self.userInfoDictionary = userInfoDictionary
                                        
                    self.logger?.debug("Cascana user info received from server: \(self.userInfoDictionary)")
                    
                    self.createConnection(from: session)
					
                case .failure(let error):
                    self.logger?.debug("Cascana refresh session: \(error)")
					self.analyticsSendError(errorContent: error.localizedDescription)
					
                    if !error.isCanceled {
                        self.serviceState = .networkError(error)
                    }
					
            }
        }
    }
    
    private func createConnection(from session: CascanaChatSession) {
        guard let webSocketUrl = self.webSocketUrl,
              var urlComponents = URLComponents(url: webSocketUrl, resolvingAgainstBaseURL: true)
        else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "access_token", value: session.accessToken)
        ]
        
        guard let url = urlComponents.url
        else { return }
        
        connection = HubConnectionBuilder(url: url)
            .withHubConnectionDelegate(delegate: self)
			.withLogging(minLogLevel: .error)
            .build()
        
        addConnectionMethods()

        connection?.start()
    }

    func subscribeForServiceStateUpdates(listener: @escaping (ChatServiceState) -> Void) -> Subscription {
        return stateUpdateSubscriptions.add(listener)
    }
    
    func subscribeForOperatorIsTypingUpdates(listener: @escaping (_ isTyping: Bool) -> Void) -> Subscription {
        return operatorIsTypingUpdateSubscriptions.add(listener)
    }
    
    func subscribeForNonFatalErrors(listener: @escaping (Error) -> Void) -> Subscription {
        return nonFatalErrorsSubscriptions.add(listener)
    }
    
    func isChat(remoteNotification: UNNotification) -> Bool {
        return false
    }
    
    func rateOperatorWith(
		requestId: String,
		comment: String?,
		byRating rating: Int,
		senderId: String?,
		completionHandler: RateOperatorCompletionHandler?
	) {
		guard let rateRequestId = self.currentOperator?.getRequestId()
        else { return }
        
        rateCurrentOperator(
            requestId: rateRequestId,
            rate: rating,
            comment: comment,
            senderId: senderId
        ) { result in
            self.serviceState = .chatting(.chatting)
            switch result {
                case .success:
                    completionHandler?.onSuccess()
					
					if let currentOperator = self.currentOperator {
						currentOperator.setRate(rating)
					}
					
                case .failure(let error):
                    self.handleNotFatalError(error)
					completionHandler?.onFailure(error: error)
					
            }
        }
    }
    
    func getLastRatingOperatorWith(id: String?) -> Int? { return nil }
    func updatePushToken(_ token: String) {}
    
    func send(message: String) {
        let msg = CascanaChatSendMessage(
            id: UUID().uuidString,
            text: message
        )
        
        let receiveMessage = CascanaChatReceiveMessage(from: msg)
        
        add(receiveMessage, after: lastMessage)
        
        lastMessage = receiveMessage
        
        chatMessagesSubsciptions.fire(())
        
        send(message: msg) { result in
            switch result {
                case .success: // calling after message status update was fired
                    self.logger?.debug("Cascana chat send message \(msg.id)")
                    
                case .failure:
                    // retry to send? or remove?
                    self.logger?.debug("Cascana chat send message is failed")
            }
        }
    }
    
    func reply(with message: String, to repliedMessage: Message) {
        guard let replyReceiveMessage = repliedMessage as? CascanaChatReceiveMessage
        else { return }
        
        let reply = CascanaChatReplyMessage(from: replyReceiveMessage)
        
        var msg = CascanaChatSendMessage(
            id: UUID().uuidString,
            text: message
        )
        msg.reply = reply
        
        var sendReceiveMessage = CascanaChatReceiveMessage(from: msg)
        sendReceiveMessage.replyTo = reply
        
        add(sendReceiveMessage, after: lastMessage)
        lastMessage = sendReceiveMessage
        
        chatMessagesSubsciptions.fire(())
        
        send(message: msg) { result in
            switch result {
                case .success: // calling after message status update was fired
                    self.logger?.debug("Cascana chat send message \(msg.id)")
                case .failure:
                    // retry to send? or remove?
                    self.logger?.debug("Cascana chat send message is failed")
            }
        }

    }
    
    func delete(message: Message, completionHandler: DeleteMessageCompletionHandler?) {
        if let messageIndex = self.messages.firstIndex(where: { $0.getID() == message.getID() }) {
            if let message = self.messages[safe: messageIndex] as? CascanaChatReceiveMessage {
                var messageWithPendingDelete = message
                messageWithPendingDelete.status = .deletePending
                
                self.messages[messageIndex] = messageWithPendingDelete
            } 
            
            deleteMessage(with: message.getID()) { result in
                switch result {
                    case .success:
                        completionHandler?.onSuccess(messageID: message.getID())
                        self.chatMessagesSubsciptions.fire(())
                    case .failure:
                        completionHandler?.onFailure(messageID: message.getID(), error: .unknown)
                }
            }
        } else {
            completionHandler?.onFailure(messageID: message.getID(), error: .messageNotFound)
        }
    }
    
    func edit(message: Message, newText: String, completionHandler: EditMessageCompletionHandler?) {
        guard !newText.isEmpty
        else { return }
        
        if let messageIndex = self.messages.firstIndex(where: { $0.getID() == message.getID() }) {
            if let message = self.messages[safe: messageIndex] as? CascanaChatReceiveMessage {
                var messageWithPendingEdit = message
                messageWithPendingEdit.status = .editPending
                messageWithPendingEdit.newText = newText
                self.messages[messageIndex] = messageWithPendingEdit
            }
        
            editMessage(
                with: message.getID(),
                text: newText
            ) { result in
                switch result {
                    case .success:
                        completionHandler?.onSuccess(messageID: message.getID())
                        self.chatMessagesSubsciptions.fire(())
                    case .failure:
                        completionHandler?.onFailure(messageID: message.getID(), error: .unknown)
                }
            }
        } else {
            completionHandler?.onFailure(messageID: message.getID(), error: .unknown)
        }
    }
        
    func sendChatBotHint(button: KeyboardButton, message: Message, completionHandler: SendKeyboardRequestCompletionHandler?) {
        guard let reveiveMessage = message as? CascanaChatReceiveMessage,
              let selectedButton = button as? CascanaChatKeyButton,
              let buttons = reveiveMessage.buttons,
              buttons.contains(selectedButton)
        else { return }
        
        var messageWithSelectedButton = CascanaChatSendMessage(id: UUID().uuidString)
        messageWithSelectedButton.parameters = [
            "payload": selectedButton.payload,
            "url": selectedButton.url?.path
        ]
        
        messageWithSelectedButton.text = selectedButton.text
        
        let messageWithSelectedButtonReceiveMessage = CascanaChatReceiveMessage(from: messageWithSelectedButton)
        
        add(messageWithSelectedButtonReceiveMessage, after: lastMessage)
        lastMessage = messageWithSelectedButtonReceiveMessage
        
        chatMessagesSubsciptions.fire(())
        
        send(message: messageWithSelectedButton) { result in
            var completeKeyboardMessage = reveiveMessage
            completeKeyboardMessage.keyboardState = .canceled
            self.updateMessage(with: completeKeyboardMessage)
            switch result {
                case .success:
                    self.logger?.debug("Cascana chat send keyboard selected button \(messageWithSelectedButton.id)")
                    completionHandler?.onSuccess(messageID: messageWithSelectedButton.getID())
                case .failure:
                    self.logger?.debug("Cascana chat send keyboard selected button is failed")
                    completionHandler?.onFailure(messageID: messageWithSelectedButton.getID(), error: .unknown)
            }
        }
	}
    
	private lazy var urlSession = createUrlSession()
	private lazy var sdImageCacheManager = createImageCacheManager()
		
	private typealias QueueOperationHandler = (Int, AttachmentState) -> Void
	private var uploadsQueue: [URLSessionTask: (Message, QueueOperationHandler)] = [:]
	private var downloadsQueue: [URLSessionTask: (Message, QueueOperationHandler)] = [:]
	
	private var attachmentsStateSubscriptions: Subscriptions<(Int, AttachmentState)> = Subscriptions()
	func subscribeAttachmentChanged(listener: @escaping (Int, AttachmentState) -> Void) -> Subscription {
		attachmentsStateSubscriptions.add(listener)
	}
	    
    func send(attachment: Attachment, completion: @escaping (Result<Attachment, ChatServiceError>) -> Void) {
        var messageWithAttachment = CascanaChatSendMessage(id: UUID().uuidString)
        
		let attachmentFilename = attachment.url.filename
		
        let multipartResult = multipartEncode(
            fileUrl: attachment.url,
            parameters: [
                "file": attachmentFilename
            ]
        )
        
        guard let chatRest = self.chatRest,
              let (serializedUrl, serializedContentType) = multipartResult.value,
              FileManager.default.fileExistsAtURL(serializedUrl)
        else {
            let error = AlfastrahError.api(
                .init(
                    httpCode: 999,
                    internalCode: 999,
                    title: NSLocalizedString("common_error_title", comment: ""),
                    message: NSLocalizedString("common_error_something_went_wrong_tile", comment: "")
                )
            )
            logger?.debug("Cascana chat send image error: \(error)")
            serviceState = .unknownError(error)
			
			self.analyticsSendError(errorContent: error.localizedDescription)
			
            return
        }
        
        var request = chatAuthorizer.authorize(
            request: .init(
                url: chatRest.baseURL.appendingPathComponent("/CEC.FileManagerService/api/Uploaded/file")
            )
        )
        
        request.httpMethod = "POST"
        request.addValue(
            serializedContentType,
            forHTTPHeaderField: "Content-Type"
        )
		
		// send message to chat
		let cascanaAttachment = CascanaChatAttachment(url: attachment.url, filename: attachmentFilename, state: .uploading(0, nil))
		messageWithAttachment.attachments = [cascanaAttachment]
		let receiveMessage = CascanaChatReceiveMessage(from: messageWithAttachment)
		add(receiveMessage, after: lastMessage)
		self.lastMessage = receiveMessage
				
		let task = urlSession.uploadTask(with: request, fromFile: serializedUrl) { data, response, error in
			func handleAttachmentError(_ error: ChatServiceError) {
				let cascanaAttachment = CascanaChatAttachment(url: attachment.url, filename: attachmentFilename, state: .retry(error.displayValue, nil))
				messageWithAttachment.attachments = [cascanaAttachment]
				let receiveMessage = CascanaChatReceiveMessage(from: messageWithAttachment)
				self.updateMessage(with: receiveMessage)
			}
			
			DispatchQueue.main.async {
				if let error = error {
					self.analyticsSendError(errorContent: error.localizedDescription)
					
					if let error = error as? URLError,
					   error.code == URLError.cancelled {
						// mute callback
						handleAttachmentError(.upload)
						
						self.remove(messageWithAttachment)
						self.chatMessagesSubsciptions.fire(())
						
						completion(.failure(.upload))
					} else {
						if let response = response as? HTTPURLResponse,
						   response.statusCode == ApiErrorKind.invalidAccessToken.rawValue {
							
							if self.refreshSessionIndex >= self.refreshSessionTryLimit {
								self.refreshSessionIndex = 0
								
								handleAttachmentError(.upload)
								completion(.failure(.upload))
								return
							}
							
							self.refreshSessionIndex += 1
							self.chatAuthorizer.refresh { result in
								handleAttachmentError(.upload)
								
								switch result {
									case .success:
										self.remove(messageWithAttachment)
										self.send(attachment: attachment, completion: completion)
									case .failure:
										self.analyticsSendError(errorContent: error.localizedDescription)
										completion(.failure(.upload))
								}
							}
						} else {
							handleAttachmentError(.upload)
							
							self.logger?.debug("Cascana chat send attachment error: \(error)")
							self.serviceState = .unknownError(error)
							
							self.refreshSessionIndex = 0
							
							completion(.failure(.upload))
						}
					}
				} else if let data = data,
						  let url = URL(string: String(data: data, encoding: .utf8) ?? "") {
					self.refreshSessionIndex = 0
					
					var fileSizeInBytes: Int64?
					
					if !attachment.url.isImageFile {
						if let fileEntry = self.saveFile(
							from: attachment.url,
							for: url,
							with: attachmentFilename
						) {
							fileSizeInBytes = self.localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).sizeBytes
							
							if fileSizeInBytes == 0 {
								self.localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).remove()
								handleAttachmentError(.upload)
								
								self.logger?.warning(
									"""
									Cascana chat save uploaded attachment failed \n
									file id: \(fileEntry.id) \n
									remoteUrlPathBase64Encoded \(fileEntry.remoteUrlPathBase64Encoded) \n
									local file url: \(attachment.url) \n
									remote url: \(url) \n
									"""
								)
							}
						}
					}
					
					let cascanaAttachment = CascanaChatAttachment(url: url, filename: attachmentFilename, state: .local(fileSizeInBytes))
					messageWithAttachment.attachments = [cascanaAttachment]
					let receiveMessage = CascanaChatReceiveMessage(from: messageWithAttachment)
					self.updateMessage(with: receiveMessage)
					
					self.send(message: messageWithAttachment) { result in
						switch result {
							case .success:
								self.logger?.debug("Cascana chat send message \(messageWithAttachment.id)")
								completion(.success(attachment))
							case .failure:
								self.logger?.debug("Cascana chat send message is failed")
								handleAttachmentError(.upload)
								completion(.failure(.upload))
						}
					}
				} else {
					handleAttachmentError(.upload)
					completion(.failure(.upload))
					self.analyticsSendError(errorContent: SendFileError.unknown.displayValue ?? "")
				}
			}
		}
		
		task.resume()
		
		let taskHandler: QueueOperationHandler = { taskId, state in
			if taskId == task.taskIdentifier {
				cascanaAttachment.state = state
			}
		}
		
		uploadsQueue[task] = (messageWithAttachment, taskHandler)
		
		chatMessagesSubsciptions.fire(())
    }
										 									 	
	private func createUrlSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
		
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForRequest = 300
		
		configuration.requestCachePolicy = .returnCacheDataElseLoad
		configuration.sessionSendsLaunchEvents = true
		configuration.allowsCellularAccess = true
		// wait for optimal conditions to perform the transfer, such as when the device is plugged in or connected to Wi-Fi
		configuration.isDiscretionary = true
        
		let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		
        return session
    }
	
	func cancelAttachmentOperation(for message: Message, with state: AttachmentState) {
		switch state {
			case .downloading:
				DispatchQueue.main.async {
					if let queueEntry = self.downloadsQueue.first(where: {
						$0.value.0.getID() == message.getID()
					}) {
						queueEntry.key.cancel()
					}
				}
			case .uploading:
				DispatchQueue.main.async {
					if let queueEntry = self.uploadsQueue.first(where: {
						$0.value.0.getID() == message.getID()
					}) {
						queueEntry.key.cancel()
					}
				}
			case .local, .remote, .retry:
				break
		}
	}
	
	func openAttachment(for message: Message, from: UIViewController) {
		DispatchQueue.main.async {
			if let cascanaAttachment = message.getData()?.getAttachment() as? CascanaChatAttachment,
			   let fileEntry = self.fileEntries.first(where: {
				   $0.remoteUrlPathBase64Encoded == cascanaAttachment.url?.absoluteString.data(using: .utf8)?.base64EncodedString()
			   }) {
				let fileStorage = self.localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded)
				
				if fileStorage.exists {
					LocalDocumentViewer.open(
						fileStorage.url,
						from: from,
						uti: cascanaAttachment.uti ?? "com.adobe.pdf", /// default uttype forces DocumentInteractionController presents content as unknown document
						name: fileEntry.filename
					)
				}
			}
		}
	}
	
	func downloadAttachment(for message: Message) {
		if let message = messages.first(where: { $0.getID() == message.getID() }) as? CascanaChatReceiveMessage,
		   message.attachments?[safe: 0] != nil {
			download(for: message) { _ in }
		}
	}
	
	private func download(for message: CascanaChatReceiveMessage, completion: @escaping (Result<CascanaChatAttachment, ChatServiceError>) -> Void) {
		guard let attachment = message.attachments?.first,
			  let attachmentUrl = attachment.url
		else { return }
				
		attachment.state = .downloading(0, nil)
		
		let request = URLRequest(url: attachmentUrl.appendingPathComponent(attachment.filename, isDirectory: false))
				
		let task = urlSession.downloadTask(with: request)
		
		task.resume()
		
		let taskHandler: QueueOperationHandler = { taskId, state in
			if taskId == task.taskIdentifier {
				attachment.state = state
			}
		}
		
		downloadsQueue[task] = (message, taskHandler)
	}
	
	func retryAttachmentOperation(for message: Message) {
		if let fileAttachment = fileAttachment(for: message) {
			remove(message)
			send(attachment: fileAttachment) { _ in }
		} else {
			if let message = message as? CascanaChatReceiveMessage {
				download(for: message) { _ in }
			}
		}
	}
	
	func fileAttachment(for message: Message) -> FileAttachment? {
		if let message = messages.first(where: { $0.getID() == message.getID() }) as? CascanaChatReceiveMessage,
		   let cascanaChatAttachment = message.attachments?[safe: 0],
		   let url = cascanaChatAttachment.url {
			if FileManager.default.fileExists(atPath: url.path) {
				return FileAttachment(originalName: cascanaChatAttachment.filename, filename: cascanaChatAttachment.filename, url: url)
			} else {
				return nil
			}
		}
		
		return nil
	}
	
	// MARK: - URLSessionDelegate
	public func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didSendBodyData bytesSent: Int64,
		totalBytesSent: Int64,
		totalBytesExpectedToSend: Int64
	) {
		if let taskHandler = self.uploadsQueue[task]?.1 {
			DispatchQueue.main.async {
				taskHandler(task.taskIdentifier, .uploading(task.progress.fractionCompleted, totalBytesExpectedToSend))
			}
		}
	}
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let downloaQueueEntry = self.downloadsQueue.first(where: {
			$0.key === task
		}) {
			self.downloadsQueue[task] = nil
			
			DispatchQueue.main.async {
				downloaQueueEntry.value.1(downloaQueueEntry.key.taskIdentifier, .retry("", nil))
			}
		} else if let uploadQueueEntry = self.downloadsQueue.first(where: {
			$0.key === task
		}) {
			self.uploadsQueue[task] = nil
			
			DispatchQueue.main.async {
				uploadQueueEntry.value.1(uploadQueueEntry.key.taskIdentifier, .retry("", nil))
			}
		}
	}
	
	// MARK: - URLSessionDownloadDelegate
	public func urlSession(
		_ session: URLSession,
		downloadTask: URLSessionDownloadTask,
		didWriteData bytesWritten: Int64,
		totalBytesWritten: Int64,
		totalBytesExpectedToWrite: Int64
	) {
		if let taskHandler = self.downloadsQueue[downloadTask]?.1 {
			DispatchQueue.main.async {
				let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
				taskHandler(downloadTask.taskIdentifier, .downloading(progress, totalBytesExpectedToWrite))
			}
		}
	}
	
	public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		func handleAttachmentError(_ error: ChatServiceError) {
			if let taskHandler = self.downloadsQueue[downloadTask]?.1 {
				DispatchQueue.main.async {
					taskHandler(downloadTask.taskIdentifier, .retry(error.displayValue, nil))
				}
			}
		}
		
		let response = downloadTask.response
		let error = downloadTask.error
		
		if error != nil {
			handleAttachmentError(.download)
		} else {
			if let response = response as? HTTPURLResponse {
				switch response.statusCode {
					case 200:
						if let remoteUrl = response.url,
						   let taskHandler = self.downloadsQueue[downloadTask]?.1,
						   let url = URL(string: String(remoteUrl.deletingLastPathComponent().absoluteString.dropLast())) {
							
							var fileSizeInBytes: Int64?
							
							if let fileEntry = self.saveFile(
								from: location,
								for: url,
								with: remoteUrl.lastPathComponent
							) {
								fileSizeInBytes = localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).sizeBytes
								
								if fileSizeInBytes == 0 {
									localFileStore(fileEntry.id, fileEntry.remoteUrlPathBase64Encoded).remove()
									handleAttachmentError(.download)
									
									self.logger?.warning(
										"""
										Cascana chat save downloaded attachment failed \n
										file id: \(fileEntry.id) \n
										remoteUrlPathBase64Encoded \(fileEntry.remoteUrlPathBase64Encoded) \n
										local file url: \(location) \n
										remote url: \(url) \n
										"""
									)
								} else {
									DispatchQueue.main.async {
										taskHandler(downloadTask.taskIdentifier, .local(fileSizeInBytes))
									}
								}
							}
						}
					default:
						handleAttachmentError(.download)
				}
			}
		}
		
		downloadsQueue[downloadTask] = nil
	}
	
	// MARK: - Upload encode
    private func multipartEncode(
        fileUrl: URL,
        parameters: [String: String]
    ) -> Result<(url: URL, contentType: String), AttachmentTransferError> {
        let filename = "\(UUID().uuidString).\(fileUrl.pathExtension)"
        let serializer = MultipartFileSerializer()
        let serializerResult = serializer.serializeToFile(
            file: .init(
                parameterName: "file",
                filename: filename,
                contentType: "application/octet-stream",
                dataFileUrl: fileUrl
            ),
            parameters: parameters
        )
        return serializerResult.map { ($0, serializer.contentType) }
    }
	
    // MARK: - Implementation
    private var chatSession: CascanaChatSession? {
        didSet {
            // save to settings
            if oldValue != chatSession {
                chatSessionSubscriptions.fire(chatSession)
                applicationSettingsService.chatSession = chatSession
                logger?.debug("Cascana chat session updated")
            }
        }
    }
	
	func getNextMessages(completion: @escaping (GetMessagesResponse) -> Void) {
		history(messagesCount: Constants.pageRowCount, from: historyPreviousPageStartMessage?.date ?? Date(), to: nil) { _ in }
	}
	
	func getMessages(to searchResultDate: Date, completion: @escaping () -> Void) {
		let eldestMessageInFeedDate = historyPreviousPageStartMessage?.date ?? Date()
		
		history(messagesCount: nil, from: eldestMessageInFeedDate, to: searchResultDate) { _ in
			completion()
		}
	}
	
	func setChatRead(_ unreadMessages: [Message]) {
		setReadStatus(for: unreadMessages) { _ in }
	}
    
    // MARK: - REST
    private func refreshChatSession(completion: @escaping (Result<CascanaChatSession, AlfastrahError>) -> Void) {
        let task = rest.read(
            path: "api/account/cascana",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: CascanaChatSessionTransformer()),
            completion: mapCompletion { result in
                self.cancellable = CancellableNetworkTaskContainer()
                switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error ):
						self.analyticsSendError(errorContent: error.localizedDescription)
                        completion(.failure(error))
                }
            }
        )
        cancellable.addCancellables([ task ])
    }
        
    private func chatThemes(depthLevel: Int = 0,  completion: @escaping (Result<[CascanaChatTheme], AlfastrahError>) -> Void) {
        chatRest?.read(
            path: "api/Themes",
            id: nil,
            parameters: [ "depthLevel": "\(depthLevel)" ],
            headers: [:],
            responseTransformer: ArrayTransformer(transformer: CascanaChatThemeTransformer()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let themes):
                        completion(.success(themes))
						
                    case .failure(let error ):
						self.analyticsSendError(errorContent: error.localizedDescription)
                        completion(.failure(error))
						
                }
            }
        )
    }
    
    private func rateCurrentOperator(
        requestId: String,
        rate: Int,
        comment: String? = nil,
        senderId: String? = nil,
        completion: @escaping (Result<Void?, AlfastrahError>) -> Void
    ) {
        chatRest?.create(
            path: "/CEC.FeedbackRegisterService/api/evaluations",
            id: nil,
            object: CascanaChatOperatorRateRequest(
                requestId: requestId,
                rate: rate,
                comment: comment,
                senderId: senderId
            ),
            headers: [:],
            requestTransformer: CascanaChatOperatorRateRequestTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion { result in
                switch result {
                    case .success:
                        completion(.success(()))
						
                    case .failure(let error ):
						self.analyticsSendError(errorContent: error.localizedDescription)
                        completion(.failure(error))
						
                }
            }
        )
    }
    
    // MARK: - Error handling
    private func handleNotFatalError(_ error: Error? = nil) {
        if let error = error {
			analyticsSendError(errorContent: error.localizedDescription)
			
            self.nonFatalErrorsSubscriptions.fire(error)
        } else {
            self.nonFatalErrorsSubscriptions.fire(
                AlfastrahError.api(
                    .init(
                        httpCode: 999,
                        internalCode: 999,
                        title: NSLocalizedString("common_error_title", comment: ""),
                        message: NSLocalizedString("common_error_something_went_wrong_tile", comment: "")
                    )
                )
            )
			
			analyticsSendError(errorContent: NSLocalizedString("common_error_something_went_wrong_tile", comment: ""))
        }
    }
    
    // MARK: - Cascana HubConnectionDelegate
    public func connectionDidOpen(hubConnection: HubConnection) {
        refreshSessionIndex = 0
        
        logger?.debug("Cascana chat connection did open")
        removeAllMessages()
        
        chatMessagesSubsciptions.fire(())
        
        serviceState = .started
        createRoomWithDetails { result in
            switch result {
                case .success:
                    self.logger?.debug("Cascana chat room intialized")
                    self.serviceState = .chatting(.chatting)
					self.history(
						messagesCount: Constants.pageRowCount,
						from: self.historyPreviousPageStartMessage?.date ?? Date(), to: nil
					) { _ in
						self.logger?.debug("Cascana history first page loaded")						
					}

                case .failure(let error):
                    self.logger?.debug(String(describing: error))
                    self.serviceState = .sessionError(error)
					self.analyticsSendError(errorContent: error.localizedDescription)
					
            }
        }
    }
    
    public func connectionDidFailToOpen(error: Error) {
        logger?.debug("Cascana chat open did fail")
        
        if refreshSessionIndex >= refreshSessionTryLimit {
            serviceState = .fatalError(.unknown)
            refreshSessionIndex = 0
            
            return
        }
        
        refreshSessionIndex += 1
        
        chatAuthorizer.refresh { result in
            switch result {
                case .success:
                    guard let session = self.chatAuthorizer.session
                    else { return }
                    
                    self.chatSession = session
                    self.handleNewChatSession(session)
                    
                case .failure(let refreshError):
					self.analyticsSendError(errorContent: refreshError.localizedDescription)
                    self.serviceState = .sessionError(error)
					
            }
        }
    }
    
    public func connectionDidClose(error: Error?) {
		logger?.debug("Cascana chat connection did close with \(error?.localizedDescription)")
        if let error = error {
			self.analyticsSendError(errorContent: error.localizedDescription)
            serviceState = .unknownError(error)
        }
        
        switch serviceState {
            case .chatting: // operator terminate session
                serviceState = .logout
            case .started, .logout, .loading, .demoMode,
                .emptyUserInfo, .fatalError, .accessError,
                .unknownError, .sessionError, .networkError, .disabled:
                break
        }
    }
    
    private func userAuthJson(completion: @escaping (Result<Json, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/account/webim",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "webim_visitor", transformer: JsonTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func search(by text: String, completion: @escaping (Result<ChatSearchResponse, AlfastrahError>) -> Void) {
        search(
            by: text,
            phrase: nil,
            resultTextAfterString: nil,
            resultTextBeforeSting: nil,
            highlightAll: nil,
            maxSelectionsCount: nil,
            maxWordsInSelectionCount: nil,
            selectionsDelimeterString: nil,
            maxResultsCount: nil,
            completion: completion
        )
    }
        
    private func search(
        by text: String,
        phrase: Bool?,
        resultTextAfterString: String?,
        resultTextBeforeSting: String?,
        highlightAll: Bool?,
        maxSelectionsCount: Int?,
        maxWordsInSelectionCount: Int?,
        selectionsDelimeterString: String?,
        maxResultsCount: Int?,
        completion: @escaping (Result<ChatSearchResponse, AlfastrahError>) -> Void
    ) {
        guard let chatRest
        else { return }
        
        var parameters: [String: String] = [
            "Query": text
        ]
        
        if let phrase {
            parameters["Phrase"] = String(phrase)
        }
        
        if let resultTextAfterString {
            parameters["StartSel"] = resultTextAfterString
        }
        
        if let resultTextBeforeSting {
            parameters["StopSel"] = resultTextBeforeSting
        }
        
        if let highlightAll {
            parameters["HighlightAll"] = String(highlightAll)
        }
        
        if let maxSelectionsCount {
            parameters["MaxFragments"] = String(maxSelectionsCount)
        }
        
        if let maxWordsInSelectionCount {
            parameters["MaxWords"] = String(maxWordsInSelectionCount)
        }
        
        if let selectionsDelimeterString {
            parameters["FragmentDelimiter"] = selectionsDelimeterString
        }
        
        if let maxResultsCount {
            parameters["Limit"] = String(maxResultsCount)
        }
        
        let task = chatRest.read(
            path: "CEC.Frontend.FrontMessageSender/api/History/SearchByText",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ChatSearchResponseTransformer(),
            completion: mapCompletion { result in
                self.cancellable = CancellableNetworkTaskContainer()
                switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error ):
						self.analyticsSendError(errorContent: error.localizedDescription)
                        completion(.failure(error))
                }
            }
        )
        
        cancellable.addCancellables([ task ])
    }
    
    func refreshFcmToken(completion: @escaping (Result<String?, Error>) -> Void) {
        if let fcmToken = self.fcmToken {
            completion(.success(fcmToken))
        } else {
            Messaging.messaging().token {
                token, error in
                
                if let error {
                    self.fcmToken = nil
                    self.logger?.warning("Error fetching FCM registration token: \(error)")
					self.analyticsSendError(errorContent: error.localizedDescription)
                    completion(.failure(error))
                } else if let token {
                    self.fcmToken = token
                    completion(.success(token))
                }
            }
        }
    }
            
    private func removeAllMessages() {
        messages.removeAll()
    }
	
	// MARK: - Chat Files
	private let store: Store
	
	private var fileEntries: [ChatFileEntry] = [] {
		didSet {
			try? self.store.write { transaction in
				try transaction.delete(type: ChatFileEntry.self)
				try transaction.upsert(fileEntries)
			}
		}
	}
	
	// MARK: - Files Operations
	@discardableResult private func saveFile(
		from localUrl: URL,
		for remoteUrl: URL,
		with filename: String
	) -> ChatFileEntry? {
		guard let expirationDate = Calendar.current.date(byAdding: .day, value: Constants.fileCacheExpirationIntervalInDays, to: Date()),
			  let data = remoteUrl.absoluteString.data(using: .utf8)
		else { return nil }
		
		let id = UUID().uuidString
		
		let remoteId = data.base64EncodedString()
		
		// save to local storage
		localFileStore(id, remoteId).copy(from: localUrl) { _ in }
		// save files to cache
		let fileEntry = ChatFileEntry(
			id: id,
			remoteUrlPathBase64Encoded: remoteId,
			filename: filename,
			expirationDate: expirationDate
		)
	
		fileEntries.append(fileEntry)
		
		return fileEntry
	}
	
	// MARK: - Files Cache
	private func cachedFileEntries() -> [ChatFileEntry]? {
		var fileEntries: [ChatFileEntry] = []
		
		try? store.read { transaction in
			fileEntries = try transaction.select()
		}
		
		return fileEntries
	}
	
	private func loadFileEntries() {
		guard let fileEntries = cachedFileEntries()
		else { return }
				
		let now = Date()
		
		var fileEntriesToDelete: [ChatFileEntry] = []
		
		for fileEntry in fileEntries {
			if fileEntry.expirationDate < now {
				let directory = fileEntry.id
				
				localFileStore(directory, fileEntry.remoteUrlPathBase64Encoded).remove()
				fileEntriesToDelete.append(fileEntry)
			}
		}
		
		self.fileEntries = fileEntries.filter{ !fileEntriesToDelete.contains($0) }
	}
	
	// MARK: - Local Files Storage
	private let filesLocalStorageDirectory = Storage.documentsDirectory.appendingPathComponent(
		Constants.filesLocalStorageDirectoryName,
		isDirectory: true
	)
	
	private func localFileStore(_ directory: String, _ file: String) -> SimpleAttachmentStore {
		SimpleAttachmentStore(
			directory: filesLocalStorageDirectory.appendingPathComponent(directory, isDirectory: true),
			name: file
		)
	}
	
	// MARK: - SDWebImage Custom Cache
	private func createImageCacheManager() -> SDWebImageManager {
		let cache = SDImageCache(namespace: "chat")
		cache.config.maxDiskAge = Double(60 * 60 * 24 * Constants.fileCacheExpirationIntervalInDays)

		return SDWebImageManager(cache: cache, loader: SDWebImageDownloader.shared)
	}
	
	@discardableResult func cachedImage(for url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) -> SDWebImageCombinedOperation? {
		return sdImageCacheManager.loadImage(
			with: url,
			options: .highPriority,
			progress: nil,
			completed: { image, _, error, _, _, _ in
				if let error {
					completion(.failure(error))
					return
				}
				
				completion(.success(image))
			}
		)
	}
	
	func isImageCached(for url: URL) -> Bool {
		return sdImageCacheManager.cacheKey(for: url) != nil
	}
	
    private struct Constants {
        static let pageRowCount = 32
        static let sendMessageContactPoint = "Мобильное приложение"
		static let filesLocalStorageDirectoryName = "chat_local"
		static let fileCacheExpirationIntervalInDays = 14
    }
	
	private func analyticsSendError(errorContent: String) {
		let userId = (userInfoDictionary?["fields"] as? [String: Any])?["id"]
		
		let userIdString = userId == nil ? "anonymous" : userId
		
		if let analyticsData = analyticsData(from: insurancesService.cachedShortInsurances(forced: true), for: .health) {
			self.analyticsService.track(
				event: AnalyticsEvent.App.chatError,
				properties: [
					"anonymous": !accountService.isAuthorized,
					"user_id": userIdString,
					"content": errorContent
				],
				userProfileProperties: analyticsData.analyticsUserProfileProperties
			)
		}
	}
}
// swiftlint:enable file_length
