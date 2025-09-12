//
//  ChatService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 28/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import Legacy
import SDWebImage

protocol ChatService {
    var messages: [Message] { get }
    func getMessageIndex(by id: String) -> Int?
    
    var baseUrl: URL? { get set }
    
    var historyWasEmpty: Bool { get }
    var currentOperator: Operator? { get }
    var serviceState: ChatServiceState { get }

    func startNewChatService()
    func subscribeForServiceStateUpdates(listener: @escaping (ChatServiceState) -> Void) -> Subscription
    func subscribeForOperatorIsTypingUpdates(listener: @escaping (_ isTyping: Bool) -> Void) -> Subscription
    func subscribeForNonFatalErrors(listener: @escaping (Error) -> Void) -> Subscription
    func subscribeChatMessagesChanged(listener: @escaping () -> Void) -> Subscription
	func subscribeChatOperatorScore(listener: @escaping () -> Void) -> Subscription
	func subscribeChatOperatorScoreResult(listener: @escaping (Bool) -> Void) -> Subscription

    func isChat(remoteNotification: UNNotification) -> Bool
	func rateOperatorWith(
		requestId: String,
		comment: String?,
		byRating rating: Int,
		senderId: String?,
		completionHandler: RateOperatorCompletionHandler?
	)
    func getLastRatingOperatorWith(id: String?) -> Int?
    func updatePushToken(_ token: String)
    func send(message: String)
    func reply(with message: String, to repliedMessage: Message)
    func delete(message: Message, completionHandler: DeleteMessageCompletionHandler?)
    func edit(message: Message, newText: String, completionHandler: EditMessageCompletionHandler?)
    func sendChatBotHint(button: KeyboardButton, message: Message, completionHandler: SendKeyboardRequestCompletionHandler?)
	func send(attachment: Attachment, completion: @escaping (Result<Attachment, ChatServiceError>) -> Void)
    func getNextMessages(completion: @escaping (GetMessagesResponse) -> Void)
    func setChatRead(_ unreadMessages: [Message])
    func search(by text: String, completion: @escaping (Result<ChatSearchResponse, AlfastrahError>) -> Void)
    
    func getMessages(to searchResultDate: Date, completion: @escaping () -> Void)
	
	func cancelAttachmentOperation(for message: Message, with state: AttachmentState)
	func openAttachment(for message: Message, from: UIViewController)
	func downloadAttachment(for message: Message)
	func retryAttachmentOperation(for message: Message)
	
	@discardableResult func cachedImage(for url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) -> SDWebImageCombinedOperation?
	func fileAttachment(for message: Message) -> FileAttachment?
	
	func saveLastVisibleScoreRequestMessageId(_ id: String)
}

struct GetMessagesResponse {
    let messages: [Message]
    let canDisplayMoreMessages: Bool
}

enum ChatServiceState: Equatable {
    case chatting(ChatState)
    case loading
    case started
    case demoMode
    case disabled
    case logout
    case emptyUserInfo
    case networkError(AlfastrahError)
    case sessionError(Error)
    case accessError(Error)
    case unknownError(Error)
    case fatalError(FatalErrorType)

    var description: String {
        switch self {
            case .chatting:
                return "chatting"
            case .loading:
                return "loading"
            case .started:
                return "started"
            case .demoMode:
                return "demoMode"
            case .disabled:
                return "demoMode"
            case .logout:
                return "logout"
            case .networkError:
                return "userInfoError"
            case .emptyUserInfo:
                return "userInfoError"
            case .sessionError:
                return "sessionError"
            case .accessError:
                return "accessError"
            case .unknownError:
                return "unknownError"
            case .fatalError:
                return "fatalError"
        }
    }
        
    static func == (lhs: ChatServiceState, rhs: ChatServiceState) -> Bool {
        switch (lhs, rhs) {
            case (.loading, .loading), (.started, .started),
                (.demoMode, .demoMode), (.disabled, .disabled), (.logout, .logout),
                (.networkError, .networkError), (.emptyUserInfo, .emptyUserInfo), (.sessionError, .sessionError),
                (.accessError, .accessError), (.unknownError, .unknownError), (.fatalError, .fatalError):
                return true
            case (.chatting(let lhsType), .chatting(let rhsType)):
                return lhsType == rhsType
            default:
                return false
        }
    }
}

enum ChatNotFatalError: Error {
    case noInternetConnection
    case serverNotAvailable
}

public protocol Operator {
    func getID() -> String
    func getName() -> String
    func getAvatarURL() -> URL?
    func getTitle() -> String?
    func getInfo() -> String?
	func getRate() -> Int?
	func setRate(_ rate: Int)
	func getSenderId() -> String?
	func getRequestId() -> String?
	func ratingCanBeGiven() -> Bool
}

public protocol Message {
    func getRawData() -> [String: Any?]?
    func getData() -> MessageData?
    func getID() -> String
    func getServerSideID() -> String?
    func getCurrentChatID() -> String?
    func getKeyboard() -> Keyboard?
    func getKeyboardRequest() -> KeyboardRequest?
    func getOperatorID() -> String?
    func getQuote() -> Quote?
    func getSticker() -> Sticker?
    func getSenderAvatarFullURL() -> URL?
    func getSenderName() -> String
    func getSendStatus() -> MessageSendStatus
    func getText() -> String
    func getTime() -> Date
    func getType() -> MessageType
    func isEqual(to message: Message) -> Bool
    func isReadByOperator() -> Bool
    func canBeEdited() -> Bool
    func canBeDeleted() -> Bool
    func canBeReplied() -> Bool
    func isEdited() -> Bool
    func canVisitorReact() -> Bool
    func getVisitorReaction() -> String?
    func canVisitorChangeReaction() -> Bool
	func getRequestId() -> String?
	func getSenderId() -> String?
}

public protocol MessageData {
    func getAttachment() -> MessageAttachment?
}

public protocol MessageAttachment {
    func getFileInfo() -> FileInfo
    func getFilesInfo() -> [FileInfo]
    func getState() -> AttachmentState
    func getProgress() -> CGFloat?
    func getErrorType() -> String?
    func getErrorMessage() -> String?
	var stateChanged: ((AttachmentState) -> Void)? { get set }
	func addAttachmentStateObserver(_ listener: @escaping (AttachmentState) -> Void)
	func deleteAttachmentStateObserver()
}

public protocol FileInfo {
    func getContentType() -> String?
    func getFileName() -> String
    func getImageInfo() -> ImageInfo?
    func getSize() -> Int64?
    func getGuid() -> String?
    func getURL() -> URL?
}

public protocol ImageInfo {
    func getThumbURL() -> URL
    func getHeight() -> Int?
    func getWidth() -> Int?
}

public protocol Keyboard {
    func getButtons() -> [[KeyboardButton]]
    func getState() -> KeyboardState
    func getResponse() -> KeyboardResponse?
}

public enum KeyboardState {
    case pending
    case completed
    case canceled
}

public protocol KeyboardResponse {
    func getButtonID() -> String
    func getMessageID() -> String
}

public protocol KeyboardButton {
    func getID() -> String
    func getText() -> String
    func getConfiguration() -> Configuration?
}

public protocol Configuration {
    func isActive() -> Bool
    func getButtonType() -> ButtonType
    func getData() -> String
    func getState() -> ButtonState
}

public protocol KeyboardRequest {
    func getButton() -> KeyboardButton
    func getMessageID() -> String
}

public protocol Quote {
    func getAuthorID() -> String?
    func getMessageAttachment() -> FileInfo?
    func getMessageTimestamp() -> Date?
    func getMessageID() -> String?
    func getMessageText() -> String?
    func getMessageType() -> MessageType?
    func getSenderName() -> String?
    func getState() -> QuoteState
}

public enum QuoteState {
    case pending
    case filled
    case notFound
}

public enum MessageType {
    case scoreRequest
    case contactInformationRequest
    case fileFromOperator
    case fileFromVisitor
    case score
    case keyboard
    case keyboardResponse
    case operatorMessage
    case operatorBusy
    case visitorMessage
    case stickerVisitor
	case unknown
}

public enum ButtonType {
    case url
    case insert
}

public enum ButtonState {
    case showing
    case showingSelected
    case hidden
}

public protocol Sticker {
    func getStickerId() -> Int
}

public enum MessageSendStatus {
    case sending
    case sent
}

public enum AttachmentState {
	case local(_ totalSizeInBytes: Int64?)
	case remote(_ totalSizeInBytes: Int64?)
	case uploading(_ progress: CGFloat, _ totalSizeInBytes: Int64?)
	case downloading(_ progress: CGFloat, _ totalSizeInBytes: Int64?)
	case retry(_ reason: String?, _ totalSizeInBytes: Int64?)
}

public enum ChatState: Equatable {
    case chatting
    case chattingWithRobot
    case closedByOperator
    case closedByVisitor
    case invitation
    case closed
    case queue
    case unknown
}

public enum FatalErrorType {
    case accountBlocked
    case providedVisitorFieldsExpired
    case unknown
    case visitorBanned
    case wrongProvidedVisitorHash
    
    var displayValue: String? {
        switch self {
            case .accountBlocked, .visitorBanned:
                return NSLocalizedString("chat_account_blocked_error", comment: "")
            case .providedVisitorFieldsExpired, .wrongProvidedVisitorHash:
               return NSLocalizedString("chat_session_error", comment: "")
            case .unknown:
                return NSLocalizedString("common_error_unknown_error", comment: "")
        }
    }
}

public protocol DeleteMessageCompletionHandler {
    func onSuccess(messageID: String)
    func onFailure(messageID: String, error: DeleteMessageError)
}

public enum DeleteMessageError: Error {
    case unknown
    case notAllowed
    case messageNotOwned
    case messageNotFound
}

public protocol RateOperatorCompletionHandler {
    func onSuccess()
    func onFailure(error: Error)
}

public protocol EditMessageCompletionHandler {
    func onSuccess(messageID: String)
    func onFailure(messageID: String, error: EditMessageError)
}

public enum EditMessageError: Error {
    case unknown
    case notAllowed
    case messageEmpty
    case messageNotOwned
    case maxLengthExceeded
    case wrongMesageKind
}

public protocol SendFileCompletionHandler {
    func onSuccess(messageID: String)
    func onFailure(messageID: String, error: SendFileError)
}

public enum SendFileError: Error {
    case fileSizeExceeded
    case fileSizeTooSmall
    case fileTypeNotAllowed
    case maxFilesCountPerChatExceeded
    case uploadedFileNotFound
    case unknown
    case unauthorized
    
    var displayValue: String? {
        switch self {
            case .fileSizeExceeded:
                return NSLocalizedString("chat_send_file_size_exceeded", comment: "")
            case .fileSizeTooSmall:
                return NSLocalizedString("chat_send_file_size_too_small", comment: "")
            case .fileTypeNotAllowed:
                return NSLocalizedString("chat_send_file_type_not_allowed", comment: "")
            case .uploadedFileNotFound:
                return NSLocalizedString("chat_send_file_not_found", comment: "")
            case .maxFilesCountPerChatExceeded:
                return NSLocalizedString("chat_max_file_count_exeeded", comment: "")
            case .unknown:
                return NSLocalizedString("common_error_unknown_error", comment: "")
            case .unauthorized:
                return NSLocalizedString("chat_session_error", comment: "")
        }
    }
}

public protocol SendKeyboardRequestCompletionHandler {
    func onSuccess(messageID: String)
    func onFailure(messageID: String, error: KeyboardResponseError)
}

public enum KeyboardResponseError: Error {
    case unknown
    case noChat
    case buttonIdNotSet
    case requestMessageIdNotSet
    case canNotCreateResponse
    
    var displayValue: String? {
        switch self {
            case .unknown, .noChat, .buttonIdNotSet, .canNotCreateResponse, .requestMessageIdNotSet:
                return NSLocalizedString("chat_bot_errors", comment: "")
        }
    }
}

enum ChatServiceError: Error {
	case unknown
	case common(_ error: String)
	case error(Error)
	case upload
	case download

	var displayValue: String? {
		switch self {
			case .unknown:
				return NSLocalizedString("common_unknown_error", comment: "")
				
			case .common(let description):
				return description
				
			case .error(let error):
				return error.localizedDescription
				
			case .upload:
				return NSLocalizedString("chat_files_upload_error", comment: "")
				
			case .download:
				return NSLocalizedString("chat_files_download_error", comment: "")
				
		}
	}
}
