//
//  AlfastrahError
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

enum AlfastrahError: Error {
	case infoMessage(InfoMessage)
    case network(NetworkError)
    case api(APIError)
    case error(Error)

    var apiErrorKind: ApiErrorKind? {
        switch self {				
            case .api(let error):
                return ApiErrorKind(rawValue: error.httpCode)
            case .network(NetworkError.http(let code, _, _, _)):
                return ApiErrorKind(rawValue: code)
            default:
                return nil
        }
    }

    var businessErrorKind: ApiBusinessErrorKind {
        switch self {
            case .api(let error):
                return ApiBusinessErrorKind(rawValue: error.internalCode) ?? .unsupported
            default:
                return .unknown
        }
    }

    var title: String? {
        switch self {
            case .api(let error):
                return error.title
            default:
                return nil
        }
    }

    var message: String? {
        switch self {
            case .api(let error):
                return error.message
            default:
                return nil
        }
    }

    var isCanceled: Bool {
        switch self {
            case .network(.error(.error(let error as NSError), _, _)):
                return error.code == NSURLErrorCancelled
            default:
                return false
        }
    }

    var isTimedOut: Bool {
        switch self {
            case .network(.error(.unreachable, _, _)):
                return true
            default:
                return false
        }
    }

    static let unknownError: AlfastrahError = AlfastrahError.api(
        .init(
            httpCode: -1,
            internalCode: 0,
            title: "",
            message: NSLocalizedString("common_error_unknown_error", comment: "")
        )
    )
}

enum ApiErrorKind: Int {
    case inconsistentResult = 400
    case invalidAccessToken = 401
    case userNotAuthorized = 403
    case notAvailableInDemoMode = 406
    case unprocessableEntity = 422
    case noResponse = 660
    case noInternetConnection = -1009
}

enum ApiBusinessErrorKind: Int {
    case unknown = -2
    case unsupported = -1
    case general = 0
    case startChat = 1
    case retryRequest = 2
    case flatOnOffNoEnoughDays = 3
    case flatOnOffInsuranceExpire = 4
    case flatOnOffRetryRequest = 5
    case flatOnOffInsuranceNotActiveV1 = 6
    case flatOnOffInsuranceNotActiveV2 = 8
    case osagoRenewOnWeb = 9
}

// sourcery: transformer
struct APIError {
    // sourcery: transformer.name = "code"
    var httpCode: Int
    // sourcery: transformer.name = "error_code"
    var internalCode: Int
    // sourcery: transformer.name = "error_title"
    var title: String
    // sourcery: transformer.name = "error_message"
    var message: String
}

enum OtpConfirmInternalCode: Int {
    case attemptsLeft = 10
    case attemptsLimitExceeded = 11
    case invalid = 12
}
