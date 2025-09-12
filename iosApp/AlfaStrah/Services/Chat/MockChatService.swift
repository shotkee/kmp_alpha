//
//  MockChatService.swift
//  AlfaStrah
//
//  Created by vit on 11.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy
import SDWebImage

public class MockChatService: ChatService {
    var baseUrl: URL?
    
    var historyWasEmpty = false
        
    // MARK: - Mock Fields
    private var lastOperatorRating: Int?
    
    private let testImageUrl = URL(string: "https://www.gstatic.com/webp/gallery/4.jpg")
    
    private let messageWithAttachment = CascanaChatReceiveMessage(
        id: UUID().uuidString,
        username: "Operator",
        text: nil,
        date: Date(),
        direction: .fromServer,
        attachments: {
            guard let imageUrl = URL(string: "https://www.gstatic.com/webp/gallery/4.jpg")
            else { return [] }
            
            return [
                CascanaChatAttachment(
                    url: imageUrl,
                    filename: "image",
                    state: .local(nil)
                )
            ]
        }(),
        type: .text,
        status: .delivered
    )
    
    private(set) var messages: [Message] = []
    private var lastMessage: Message?
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
            
    // MARK: - Subscriptions
    private var stateUpdateSubscriptions: Subscriptions<ChatServiceState> = Subscriptions()
    private var operatorIsTypingUpdateSubscriptions: Subscriptions<Bool> = Subscriptions()
    private var nonFatalErrorsSubscriptions: Subscriptions<Error> = Subscriptions()
    private var messagesSubscripionts: Subscriptions<Void> = Subscriptions()
	private var operatorScoreSubsciptions: Subscriptions<Void> = Subscriptions()
    
    init() {
        currentOperator = CascanaChatOperator(
			name: "Current Operator",
			senderId: UUID().uuidString,
			requestId: UUID().uuidString
		)
        
        messages = [
            CascanaChatReceiveMessage(
                id: UUID().uuidString,
                username: "User",
                text: "nice picture!",
                date: Date(),
                direction: .toServer,
                replyTo: CascanaChatReplyMessage(from: messageWithAttachment),
                type: .text,
                status: .delivered
            ),
            messageWithAttachment,
            CascanaChatReceiveMessage(
                id: UUID().uuidString,
                username: "User",
                text: "Hi",
                date: Date(),
                direction: .toServer,
                type: .text,
                status: .delivered
            ),
            CascanaChatReceiveMessage(
                id: UUID().uuidString,
                username: "Operator",
                text: "Hello!",
                date: Date(),
                direction: .fromServer,
                type: .text
            )
        ]
        lastMessage = messages.first
    }
    
    // MARK: - ChatService protocol implementation
    var currentOperator: Operator?
    
    private(set) var serviceState: ChatServiceState = .disabled {
        didSet {
            self.stateUpdateSubscriptions.fire(self.serviceState)
        }
    }

    func getMessageIndex(by id: String) -> Int? {
        return nil
    }
        
    func startNewChatService() {
        serviceState = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            guard let self = self
            else { return }
            
            self.serviceState = .started
            self.serviceState = .chatting(.chatting)
        }
    }
	
	func subscribeChatOperatorScore(listener: @escaping () -> Void) -> Subscription {
		return operatorScoreSubsciptions.add(listener)
	}
	    
    func subscribeForServiceStateUpdates(listener: @escaping (ChatServiceState) -> Void) -> Subscription {
        return stateUpdateSubscriptions.add(listener)
    }
    
    func subscribeForOperatorIsTypingUpdates(listener: @escaping (Bool) -> Void) -> Subscription {
        return operatorIsTypingUpdateSubscriptions.add(listener)
    }
    
    func subscribeForNonFatalErrors(listener: @escaping (Error) -> Void) -> Subscription {
        return nonFatalErrorsSubscriptions.add(listener)
    }
    
    func subscribeChatMessagesChanged(listener: @escaping () -> Void) -> Subscription {
        return messagesSubscripionts.add(listener)
    }
	
	private var chatOperatorScoreResultSubscriptions: Subscriptions<Bool> = Subscriptions()
	func subscribeChatOperatorScoreResult(listener: @escaping (Bool) -> Void) -> Subscription {
		chatOperatorScoreResultSubscriptions.add(listener)
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
	) {}
    
    func getLastRatingOperatorWith(id: String?) -> Int? {
        return lastOperatorRating
    }
    
    func updatePushToken(_ token: String) {}
    
    func send(message: String) {
        let msg = CascanaChatSendMessage(
            id: UUID().uuidString,
            text: message
        )
        
        var receiveMessage = CascanaChatReceiveMessage(from: msg)
                
        self.lastMessage = receiveMessage
        
        deliverMessage(receiveMessage)
    }
    
    private func updateMessage(with message: CascanaChatReceiveMessage) {}
    
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
        
        self.lastMessage = sendReceiveMessage
        
        deliverMessage(sendReceiveMessage)
    }
    
    func delete(message: Message, completionHandler: DeleteMessageCompletionHandler?) {
        completionHandler?.onFailure(messageID: message.getID(), error: .unknown)
    }
    
    func search(by text: String, completion: @escaping (Result<ChatSearchResponse, AlfastrahError>) -> Void) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }
    
    func edit(message: Message, newText: String, completionHandler: EditMessageCompletionHandler?) {
        completionHandler?.onFailure(messageID: message.getID(), error: .unknown)
    }
    
    func sendChatBotHint(button: KeyboardButton, message: Message, completionHandler: SendKeyboardRequestCompletionHandler?) {}
    
    func send(attachment: Attachment, completionHandler: SendFileCompletionHandler?) {
        guard let imageUrl = testImageUrl
        else { return }
        
        var messageWithAttachment = CascanaChatSendMessage(id: UUID().uuidString)
        
        let attachmentFilename: String
        if let filename = attachment.originalName {
            attachmentFilename = filename
        } else {
            attachmentFilename = attachment.filename
        }
        
		messageWithAttachment.attachments = [CascanaChatAttachment(url: imageUrl, filename: attachmentFilename, state: .local(nil))]
        
        let receiveMessage = CascanaChatReceiveMessage(from: messageWithAttachment)
        
        self.lastMessage = receiveMessage
        
        deliverMessage(receiveMessage)
    }
    
    private func deliverMessage(_ message: CascanaChatReceiveMessage) {
        var temp = message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            guard let self = self
            else { return }
            
            temp.status = .delivered
            
            self.updateMessage(with: temp)
        }
    }
    
    func getNextMessages(completion: @escaping (GetMessagesResponse) -> Void) {}
    
    func setChatRead(_ unreadMessages: [Message]) {}
    
    func getMessages(to searchResultDate: Date, completion: @escaping () -> Void) {}
    
    func insert(_ message: Message, at index: Int) {}
    
    func remove(at index: Int) {}
    
    func removeAllMessages() {}
    
    func update(_ message: Message, at index: Int) {}
	
	func send(attachment: Attachment, completion: @escaping (Result<Attachment, ChatServiceError>) -> Void) {}
	
	func cancelAttachmentOperation(for message: Message, with state: AttachmentState) {}
	
	func openAttachment(for message: Message, from: UIViewController) {}
	
	func downloadAttachment(for message: Message) {}
	
	func cachedImage(for url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) -> SDWebImageCombinedOperation? { return nil }
	
	func retryAttachmentOperation(for message: Message) {}
	
	func fileAttachment(for message: Message) -> FileAttachment? { return FileAttachment(filename: "", url: URL(fileURLWithPath: ""))}
	
	func isImageCached(for url: URL) -> Bool { return false }
	
	func saveLastVisibleScoreRequestMessageId(_ id: String) {}
}
