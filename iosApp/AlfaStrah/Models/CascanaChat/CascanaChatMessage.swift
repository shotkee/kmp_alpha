//
//  CascanaChatMessage.swift
//  AlfaStrah
//
//  Created by vit on 20.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import MobileCoreServices

struct CascanaChatSendMessage: Codable, Message {
    let id: String
    var text: String?
    var attachments: [CascanaChatAttachment]?
    var contactPoint: String?
    var parameters: [String: String?]?
    var reply: CascanaChatReplyMessage?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case text = "text"
        case attachments = "attachments"
        case contactPoint = "contactPoint"
        case additionalParameters = "additionalParameters"
        case replyToMessage = "replyToMessage"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(contactPoint, forKey: .contactPoint)
        try container.encode(parameters, forKey: .additionalParameters)
        try container.encode(reply, forKey: .replyToMessage)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String?.self, forKey: .text)
        attachments = try container.decode([CascanaChatAttachment]?.self, forKey: .attachments)
        contactPoint = try container.decode(String?.self, forKey: .contactPoint)
        parameters = try container.decode([String: String?]?.self, forKey: .additionalParameters)
        reply = try container.decode(CascanaChatReplyMessage?.self, forKey: .replyToMessage)
    }
    
    init(
        id: String,
        text: String? = nil,
        attachments: [CascanaChatAttachment]? = nil,
        contactPoint: String? = nil,
        parameters: [String: String]? = nil,
        reply: CascanaChatReplyMessage? = nil
    ) {
        self.id = id
        self.text = text
        self.attachments = attachments
        self.contactPoint = contactPoint
        self.parameters = parameters
        self.reply = reply
    }
    
    // MARK: - Webim message protocol
    func getRawData() -> [String: Any?]? {
        return nil
    }
    
    func getData() -> MessageData? {
        nil
    }
    
    func getID() -> String {
        return id
    }
    
    func getServerSideID() -> String? {
        return id
    }
    
    func getCurrentChatID() -> String? {
        return nil
    }
    
    func getKeyboard() -> Keyboard? {
        return nil
    }
    
    func getKeyboardRequest() -> KeyboardRequest? {
        return nil
    }
    
    func getOperatorID() -> String? {
        return nil
    }
    
    func getQuote() -> Quote? {
        return nil
    }
    
    func getSticker() -> Sticker? {
        return nil
    }
    
    func getSenderAvatarFullURL() -> URL? {
        return nil
    }
    
    func getSenderName() -> String {
        return ""
    }
    
    func getSendStatus() -> MessageSendStatus {
        return .sending
    }
    
    func getText() -> String {
        return text ?? ""
    }
    
    func getTime() -> Date {
        return Date()
    }
    
    func getType() -> MessageType {
        return .visitorMessage
    }
    
    func isEqual(to message: Message) -> Bool {
        return self.getID() == message.getID()
    }
    
    func isReadByOperator() -> Bool {
        return false
    }
    
    func canBeEdited() -> Bool {
        switch getType() {
            case .visitorMessage:
                return true
                
            case
                .stickerVisitor,
                .fileFromVisitor,
                .fileFromOperator,
                .scoreRequest,
                .score,
                .keyboardResponse,
                .operatorBusy,
                .operatorMessage,
                .contactInformationRequest,
                .keyboard,
				.unknown:
                return false
                
        }
    }
    
    func canBeDeleted() -> Bool {
        switch getType() {
            case .visitorMessage, .stickerVisitor, .fileFromVisitor:
                return true

            case
                .fileFromOperator,
                .scoreRequest,
                .score,
                .keyboardResponse,
                .operatorBusy,
                .operatorMessage,
                .contactInformationRequest,
                .keyboard,
				.unknown:
                return false

        }
    }
    
    func canBeReplied() -> Bool {
        return false
    }
    
    func isEdited() -> Bool {
        return false
    }
    
    func canVisitorReact() -> Bool {
        return false
    }
    
    func getVisitorReaction() -> String? {
        return nil
    }
    
    func canVisitorChangeReaction() -> Bool {
        return false
    }
	
	func getRequestId() -> String? {
		return nil
	}
	
	func getSenderId() -> String? {
		return nil
	}
}

struct CascanaFileInfo: FileInfo {
    let url: URL?
    let filename: String
	var size: Int64?

    func getContentType() -> String? {
        return nil
    }
    
    func getFileName() -> String {
        return filename
    }
    
    func getImageInfo() -> ImageInfo? {
        return nil
    }
    
    func getSize() -> Int64? {
        return size
    }
    
    func getGuid() -> String? {
        return nil
    }
    
    func getURL() -> URL? {
        return url
    }
}

final class CascanaChatAttachment: Codable, MessageAttachment {
	let url: URL?
    let filename: String
	var fileInfo: CascanaFileInfo
	
	var mimeType: String? {
		if let url,
		   let mimeType = mimeTypeForPath(url: url) {
			return mimeType
		}
		
		if let mimeType = mimeTypeForFilename(self.filename) {
			return mimeType
		}
		
		return nil
	}
	
	var uti: String? {
		if let url,
		   let uti = utiForPath(url: url) {
			return uti
		}
		
		if let uti = utiForFilename(self.filename) {
			return uti
		}
		
		return nil
	}
	
	var state: AttachmentState {
		didSet {
			stateChanged?(state)
		}
	}
	
	var stateChanged: ((AttachmentState) -> Void)?
	
	func addAttachmentStateObserver(_ listener: @escaping (AttachmentState) -> Void) {
		stateChanged = listener
	}
	
	func deleteAttachmentStateObserver() {
		stateChanged = nil
	}
	
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case url = "attachmentUrl"
        case filename = "fileName"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url?.path, forKey: .url)
        try container.encode(filename, forKey: .filename)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(string: urlString)
        filename = try container.decode(String.self, forKey: .filename)
		fileInfo = CascanaFileInfo(url: url, filename: filename, size: url?.resourceSize())
        state = .remote(url?.resourceSize())
    }
    
	init(url: URL, filename: String, state: AttachmentState) {
        self.url = url
        self.filename = filename
        self.state = state
        self.fileInfo = CascanaFileInfo(url: url, filename: filename, size: url.resourceSize())
    }
	
	func update(fileInfo: CascanaFileInfo) {
		self.fileInfo = fileInfo
	}
	    
    // MARK: - MessageAttachment
    func getFileInfo() -> FileInfo {
        return fileInfo
    }
    
    func getFilesInfo() -> [FileInfo] {
        return [fileInfo]
    }
    
    func getState() -> AttachmentState {
        return state
    }
    
    func getProgress() -> CGFloat? {
        return nil
    }
    
    func getErrorType() -> String? {
        return nil
    }
    
    func getErrorMessage() -> String? {
        return nil
    }
	
	private func mimeTypeForPath(url: URL) -> String? {
		if let uti = UTTypeCreatePreferredIdentifierForTag(
			kUTTagClassFilenameExtension,
			url.pathExtension as NSString,
			nil
		)?.takeRetainedValue() {
			if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
				return mimetype as String
			}
		}
		return nil
	}
	
	private func mimeTypeForFilename(_ filename: String) -> String? {
		if let uti = UTTypeCreatePreferredIdentifierForTag(
			kUTTagClassFilenameExtension,
			NSString(string: filename.pathExtension()),
			nil
		)?.takeRetainedValue() {
			if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
				return mimetype as String
			}
		}
		return nil
	}
	
	private func utiForPath(url: URL) -> String? {
		if let uti = UTTypeCreatePreferredIdentifierForTag(
			kUTTagClassFilenameExtension,
			url.pathExtension as NSString,
			nil
		)?.takeRetainedValue() {
			if UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() != nil {
				return uti as String
			}
		}
		
		return nil
	}
	
	private func utiForFilename(_ filename: String) -> String? {
		if let uti = UTTypeCreatePreferredIdentifierForTag(
			kUTTagClassFilenameExtension,
			NSString(string: filename.pathExtension()),
			nil
		)?.takeRetainedValue() {
			if UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() != nil {
				return uti as String
			}
		}
		
		return nil
	}
}

struct CascanaChatEmptyResponse: Codable {}

enum CascanaChatMessageStatus: String, Codable {
    case undefined = "Undefined"
    case registered = "Registered"
    case readyToSent = "ReadyToSent"
    case sent = "Sent"
    case delivered = "Delivered"
    case read = "Read"
    case errorSending = "ErrorSending"
    case errorCommon = "CommonError"
    case deletePending = "DeletePending"    // set by app
    case editPending = "EditPending"        // set by app
}

enum CascanaChatMessageDirection: String {
    case unknown = "Unknown"
    case fromServer = "FromServer"
    case toServer = "ToServer"
}

enum CascanaChatMessageType: String {
    case text = "Text"
    case buttons = "Buttons"
    case score = "Score"
    case scoreRequest = "ScoreRequest"
}

struct CascanaChatKeyButton: Codable, KeyboardButton, Equatable {
    let title: String
    let text: String?
    let payload: String?
    let url: URL?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "caption"
        case text = "text"
        case payload = "payload"
        case url = "url"
        case type = "type"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(payload, forKey: .payload)
        try container.encode(url, forKey: .url)
        try container.encode(type, forKey: .type)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        text = try container.decode(String?.self, forKey: .text)
        payload = try container.decode(String?.self, forKey: .payload)
        if let urlPath = try container.decode(String?.self, forKey: .url) {
            url = URL(string: urlPath)
        } else {
            url = nil
        }
        type = try container.decode(String?.self, forKey: .type)
    }
    
    // MARK: - Keyboard Button
    func getID() -> String {
        return title
    }
    
    func getText() -> String {
        return text ?? ""
    }
    
    func getConfiguration() -> Configuration? {
        nil
    }
}

struct CascanaChatReceiveMessage: Codable,
								  Message,
								  MessageData,
								  Keyboard {
    let id: String
    var room: String?
    var username: String?
    var text: String?
    var date: Date?
    var direction: CascanaChatMessageDirection?
    var attachments: [CascanaChatAttachment]?
    var rating: Int?
    var replyTo: CascanaChatReplyMessage?
    var type: CascanaChatMessageType?
    var isBroadcast: Bool?
    var isHtml: Bool?
    var timeBodyModified: Date?
    var timeDeleted: Date?
    var status: CascanaChatMessageStatus?
    var buttons: [CascanaChatKeyButton]?
    var newText: String?
	var requestId: String?
	var senderId: String?
	
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case room = "room"
        case nickname = "nickname"
        case message = "message"
        case date = "date"
        case direction = "direction"
        case attachments = "attachments"
        case rating = "rating"
        case replyTo = "replyTo"
        case messageType = "messageType"
        case selfBroadcasted = "selfBroadcasted"
        case isHtml = "isHtml"
        case timeBodyModified = "timeBodyModified"
        case timeDeleted = "timeDeleted"
        case status = "status"
        case buttons = "buttons"
		case requestId = "requestId"
		case senderId = "senderId"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(room, forKey: .room)
        try container.encode(username, forKey: .nickname)
        try container.encode(text, forKey: .message)
        try container.encode(date, forKey: .date)
        try container.encode(direction?.rawValue, forKey: .direction)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(rating, forKey: .rating)
        try container.encode(replyTo, forKey: .replyTo)
        try container.encode(type?.rawValue, forKey: .messageType)
        try container.encode(isBroadcast, forKey: .selfBroadcasted)
        try container.encode(isHtml, forKey: .isHtml)
        try container.encode(timeBodyModified, forKey: .timeBodyModified)
        try container.encode(timeDeleted, forKey: .timeDeleted)
        try container.encode(status?.rawValue, forKey: .status)
        try container.encode(buttons, forKey: .buttons)
		try container.encode(requestId, forKey: .requestId)
		try container.encode(senderId, forKey: .senderId)
    }
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
	init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        room = try container.decode(String?.self, forKey: .room)
        username = try container.decode(String?.self, forKey: .nickname)
        text = try container.decode(String?.self, forKey: .message)
        if let dateString = try container.decode(String?.self, forKey: .date) {
            date = CascanaChatReceiveMessage.dateFormatter.date(from: dateString)
        }
        if let directionString = try container.decode(String?.self, forKey: .direction) {
            direction = CascanaChatMessageDirection(rawValue: directionString)
        }
        attachments = try container.decode([CascanaChatAttachment]?.self, forKey: .attachments)
        rating = try container.decode(Int?.self, forKey: .rating)
        replyTo = try container.decode(CascanaChatReplyMessage?.self, forKey: .replyTo)
        if let typeString = try container.decode(String?.self, forKey: .messageType) {
            type = CascanaChatMessageType(rawValue: typeString)
        }
        isBroadcast = try container.decode(Bool?.self, forKey: .selfBroadcasted)
        isHtml = try container.decode(Bool?.self, forKey: .isHtml)
        if let timeBodyModifiedString = try container.decode(String?.self, forKey: .date) {
            timeBodyModified = CascanaChatReceiveMessage.dateFormatter.date(from: timeBodyModifiedString)
        }
        if let timeDeletedString = try container.decode(String?.self, forKey: .date) {
            timeDeleted = CascanaChatReceiveMessage.dateFormatter.date(from: timeDeletedString)
        }
        if let statusString = try container.decode(String?.self, forKey: .status) {
            status = CascanaChatMessageStatus(rawValue: statusString)
        }
        buttons = try container.decodeIfPresent([CascanaChatKeyButton].self, forKey: .buttons)
		
		requestId = try container.decode(String?.self, forKey: .requestId)
		senderId = try container.decode(String?.self, forKey: .senderId)
    }
    
    init(
        id: String,
        room: String? = nil,
        username: String? = nil,
        text: String? = nil,
        date: Date? = nil,
        direction: CascanaChatMessageDirection? = nil,
        attachments: [CascanaChatAttachment]? = nil,
        rating: Int? = nil,
        replyTo: CascanaChatReplyMessage? = nil,
        type: CascanaChatMessageType? = nil,
        isBroadcast: Bool? = nil,
        isHtml: Bool? = nil,
        timeBodyModified: Date? = nil,
        timeDeleted: Date? = nil,
        status: CascanaChatMessageStatus? = nil,
        buttons: [CascanaChatKeyButton]? = nil,
		requestId: String? = nil,
		senderId: String? = nil
    ) {
        self.id = id
        self.room = room
        self.username = username
        self.text = text
        self.date = date
        self.direction = direction
        self.attachments = attachments
        self.rating = rating
        self.replyTo = replyTo
        self.type = type
        self.isBroadcast = isBroadcast
        self.isHtml = isHtml
        self.timeBodyModified = timeBodyModified
        self.timeDeleted = timeDeleted
        self.status = status
        self.buttons = buttons
		self.requestId = requestId
		self.senderId = senderId
    }
    
    // MARK: initialization from CascanaChatSendMessage
    init(from sendMessage: CascanaChatSendMessage) {
        self.id = sendMessage.id
        self.room = nil
        self.username = nil
        self.text = sendMessage.text
        self.date = Date()
        self.direction = .toServer
        self.attachments = sendMessage.attachments
        self.rating = nil
        self.replyTo = nil
        self.type = .text
        self.isBroadcast = false
        self.isHtml = false
        self.timeBodyModified = nil
        self.timeDeleted = nil
        self.status = .undefined
        self.buttons = nil
		self.requestId = nil
		self.senderId = nil
    }
    
    // MARK: - Webim message protocol
    func getRawData() -> [String: Any?]? {
        return nil
    }
    
    func getData() -> MessageData? {
        return self
    }
    
    func getID() -> String {
        return id
    }
    
    func getServerSideID() -> String? {
        return id
    }
    
    func getCurrentChatID() -> String? {
        return room
    }
    
    func getKeyboard() -> Keyboard? {
        guard let buttons = buttons
        else { return nil }
        
        return buttons.isEmpty ? nil : self
    }
    
    func getKeyboardRequest() -> KeyboardRequest? {
        nil
    }
    
    func getOperatorID() -> String? {
        nil
    }
    
    func getQuote() -> Quote? {
        return replyTo
    }
    
    func getSticker() -> Sticker? {
        nil
    }
    
    func getSenderAvatarFullURL() -> URL? {
        nil
    }
    
    func getSenderName() -> String {
        return username ?? ""
    }
    
    func getSendStatus() -> MessageSendStatus {
        switch status {
            case .errorCommon, .read, .readyToSent, .undefined, .none, .errorSending, .registered, .deletePending, .editPending:
                return .sending
            case .sent, .delivered:
                return .sent
        }
    }
    
    func getText() -> String {
        return text ?? ""
    }
    
    func getTime() -> Date {
        return date ?? Date()
    }
    
    func getType() -> MessageType {
        switch type {
            case .text:
                switch direction {
                    case .fromServer:
                        if let attachments = self.attachments,
                        !attachments.isEmpty {
                            return .fileFromOperator
                        }
                        return .operatorMessage
                    case .toServer:
                        if let attachments = self.attachments,
                        !attachments.isEmpty {
                            return .fileFromVisitor
                        }
                        return .visitorMessage
                    case .unknown:
                        return .unknown
                    case .none:
                        return .unknown
                }
            case .buttons:
                return .keyboard
            case .score:
                return .score
            case .scoreRequest:
                return .scoreRequest
            case .none:
                return .unknown
        }
    }
    
    func isEqual(to message: Message) -> Bool {
        return self.getID() == message.getID()
    }
    
    func isReadByOperator() -> Bool {
        return status == .delivered
    }
    
    func canBeEdited() -> Bool {
        switch getType() {
            case .visitorMessage:
                return true

            case
                .stickerVisitor,
                .fileFromVisitor,
                .fileFromOperator,
                .scoreRequest,
                .score,
                .keyboardResponse,
                .operatorBusy,
                .operatorMessage,
                .contactInformationRequest,
                .keyboard,
				.unknown:
                return false

        }
    }
    
    func canBeDeleted() -> Bool {
        switch getType() {
            case .visitorMessage, .stickerVisitor, .fileFromVisitor:
                return true

            case
                .fileFromOperator,
                .scoreRequest,
                .score,
                .keyboardResponse,
                .operatorBusy,
                .operatorMessage,
                .contactInformationRequest,
                .keyboard,
				.unknown:
                return false

        }
    }
    
    func canBeReplied() -> Bool {
        return type == .text ? true : false
    }
    
    func isEdited() -> Bool {
        return false
    }
    
    func canVisitorReact() -> Bool {
        return false
    }
    
    func getVisitorReaction() -> String? {
        return nil
    }
    
    func canVisitorChangeReaction() -> Bool {
        return false
    }
    
    // MARK: - Message Data
    func getAttachment() -> MessageAttachment? {
        return attachments?.first
    }
    
    // MARK: - Keyboard
    var keyboardState: KeyboardState = .canceled
    
    func getButtons() -> [[KeyboardButton]] {
        guard let buttons = buttons
        else { return [] }
        return [buttons]
    }
    
    func getState() -> KeyboardState {
        return keyboardState
    }
    
    func getResponse() -> KeyboardResponse? {
        nil
    }
	
	// MARK: - Operator identifiers
	func getRequestId() -> String? {
		return requestId
	}
	
	func getSenderId() -> String? {
		return senderId
	}
}

struct CascanaChatChangeMessageStatusRequest: Codable {
    let messageId: String
    let status: CascanaChatMessageStatus
}

struct CascanaChatDeleteMessageRequest: Codable {
    let id: String
}

struct CascanaChatDeleteMessageFromOperatorRequest: Codable {
    let id: String
}

struct CascanaChatEditMessageFromOperatorRequest: Codable {
    let messageId: String
    var text: String?
    var type: CascanaChatMessageType?
    var isHtml: Bool?
    
    enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case message = "message"
        case messageType = "messageType"
        case isHtml = "isHtml"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(text, forKey: .message)
        try container.encode(type?.rawValue, forKey: .messageType)
        try container.encode(isHtml, forKey: .isHtml)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decode(String.self, forKey: .messageId)
        text = try container.decode(String?.self, forKey: .message)
        if let typeString = try container.decode(String?.self, forKey: .messageType) {
            type = CascanaChatMessageType(rawValue: typeString)
        }
        isHtml = try container.decode(Bool?.self, forKey: .isHtml)
    }
}

struct CascanaChatEditMessageRequest: Codable {
    let id: String
    let text: String
    let attachments: [CascanaChatAttachment]?
}

struct CascanaChatReplyMessage: Codable, Quote {
    let id: String
    var room: String?
    var username: String?
    var text: String?
    var date: Date?
    var direction: CascanaChatMessageDirection?
    var attachments: [CascanaChatAttachment]?
    var rating: Int?
    var replyTo: String?
    var type: CascanaChatMessageType?
    var isBroadcast: Bool?
    var isHtml: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case room = "room"
        case nickname = "nickname"
        case message = "message"
        case date = "date"
        case direction = "direction"
        case attachments = "attachments"
        case rating = "rating"
        case replyTo = "replyTo"
        case messageType = "messageType"
        case selfBroadcasted = "selfBroadcasted"
        case isHtml = "isHtml"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(room, forKey: .room)
        try container.encode(username, forKey: .nickname)
        try container.encode(text, forKey: .message)
        try container.encode(date, forKey: .date)
        try container.encode(direction?.rawValue, forKey: .direction)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(rating, forKey: .rating)
        try container.encode(replyTo, forKey: .replyTo)
        try container.encode(type?.rawValue, forKey: .messageType)
        try container.encode(isBroadcast, forKey: .selfBroadcasted)
        try container.encode(isHtml, forKey: .isHtml)
    }
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        room = try container.decode(String?.self, forKey: .room)
        username = try container.decode(String?.self, forKey: .nickname)
        text = try container.decode(String?.self, forKey: .message)
        if let dateString = try container.decode(String?.self, forKey: .date) {
            date = CascanaChatReplyMessage.dateFormatter.date(from: dateString)
        }
        if let directionString = try container.decode(String?.self, forKey: .direction) {
            direction = CascanaChatMessageDirection(rawValue: directionString)
        }
        attachments = try container.decode([CascanaChatAttachment]?.self, forKey: .attachments)
        rating = try container.decode(Int?.self, forKey: .rating)
        
        if let reply = try container.decode(CascanaChatReplyMessage?.self, forKey: .replyTo) {
            replyTo = reply.text
        }
        
        if let typeString = try container.decode(String?.self, forKey: .messageType) {
            type = CascanaChatMessageType(rawValue: typeString)
        }
        isBroadcast = try container.decode(Bool?.self, forKey: .selfBroadcasted)
        isHtml = try container.decode(Bool?.self, forKey: .isHtml)
    }
    
    // MARK: sel initialization from CascanaChatSendMessage
    init(from receiveMessage: CascanaChatReceiveMessage) {
        self.id = receiveMessage.id
        self.room = receiveMessage.room
        self.username = receiveMessage.username
        self.text = receiveMessage.text
        self.date = receiveMessage.date
        self.direction = receiveMessage.direction
        self.attachments = receiveMessage.attachments
        self.rating = receiveMessage.rating
        self.replyTo = receiveMessage.replyTo?.text
        self.type = receiveMessage.type
        self.isBroadcast = receiveMessage.isBroadcast
        self.isHtml = receiveMessage.isHtml
    }
    
    // MARK: - Quote
    func getAuthorID() -> String? {
        return username
    }
    
    func getMessageAttachment() -> FileInfo? {
        return attachments?.first?.fileInfo
    }
    
    func getMessageTimestamp() -> Date? {
        return date
    }
    
    func getMessageID() -> String? {
        return id
    }
    
    func getMessageText() -> String? {
        return text
    }

    func getMessageType() -> MessageType? {
        switch type {
            case .text:
                switch direction {
                    case .fromServer:
                        if let attachments = self.attachments,
                        !attachments.isEmpty {
                            return .fileFromOperator
                        }
                        return .operatorMessage
                    case .toServer:
                        if let attachments = self.attachments,
                        !attachments.isEmpty {
                            return .fileFromVisitor
                        }
                        return .visitorMessage
                    case .unknown:
                        return nil
                    case .none:
                        return nil
                }
            case .buttons:
                return nil
            case .score:
                return .score
            case .scoreRequest:
                return nil
            case .none:
                return nil
        }
    }
    
    func getSenderName() -> String? {
        return username
    }
    
    func getState() -> QuoteState {
        return .filled
    }
}
