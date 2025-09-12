//
//  Error (Displayable).swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

extension HttpError: Displayable {
    var displayValue: String? {
        switch self {
            case .error(let error):
                return (error as? Displayable)?.displayValue
            case .unreachable(let error):
                let error = error as NSError
                if error.code == NSURLErrorTimedOut {
                    return NSLocalizedString("common_request_timeout", comment: "")
                }
                return NSLocalizedString("no_internet_connection", comment: "")
            default:
                return NSLocalizedString("common_error_unknown_error", comment: "")
        }
    }

    var debugDisplayValue: String {
        switch self {
            case .nonHttpResponse(response: let response):
                if let response = response as? HTTPURLResponse {
                    return "code: \(response.statusCode)\nurl: \(response.url?.absoluteString ?? "")"
                } else {
                    return String(describing: self)
                }
            case .unreachable(let error), .error(let error):
                let error = error as NSError
                let url = error.userInfo["NSErrorFailingURLStringKey"] as? String
                return "code: \(error.code)\nerror: \(error.localizedDescription)\nurl: \(url ?? "")"
            case .status(let code, let error):
                var value = "code: \(code)"
                if let errorDescription = error?.localizedDescription {
                    value += "\nerror: \(errorDescription)"
                }
                if let error = error, let url = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String {
                    value += "\nurl: \(url)"
                }
                return value
            default:
                return NSLocalizedString("common_error_unknown_error", comment: "")
        }
    }
}

extension NetworkError: Displayable {
    var displayValue: String? {
        switch self {
            case .error(let error, _, _):
                return error?.displayValue
            default:
                return NSLocalizedString("common_error_unknown_error", comment: "")
        }
    }

    var debugDisplayValue: String {
        switch self {
            case .badUrl:
                return String(describing: self)
            case .auth(let error):
                if let error = error {
                    let error = error as NSError
                    let url = error.userInfo["NSErrorFailingURLStringKey"] as? String
                    return "code: \(error.code)\nerror: \(error.localizedDescription)\nurl: \(url ?? "")"
                }
                return String(describing: self)
            case .http(let code, let error, let response, _):
                var value = "code: \(code)"
                if let errorDescription = error?.localizedDescription {
                    value += "\nerror: \(errorDescription)"
                }
                if let urlString = response?.url?.absoluteString {
                    value += "\nurl: \(urlString)"
                }
                return value
            case .error(let error, _, _):
                return error?.debugDisplayValue ?? String(describing: self)
        }
    }
}

extension AlfastrahError: Displayable {
    var displayValue: String? {
        switch self {
            case .network(let error):
                return error.displayValue
            case .api(let error):
                return error.message
            case .error(let error):
                return (error as? Displayable)?.displayValue ?? NSLocalizedString("common_error_unknown_error", comment: "")
			case .infoMessage(let infoMessage):
				return infoMessage.desciptionText ?? NSLocalizedString("common_error_unknown_error", comment: "")
        }
    }

    var debugDisplayValue: String {
        switch self {
            case .network(let error):
                return error.debugDisplayValue
            case .api(let error):
                return "HTTP Code: \(error.httpCode)\nInternal Code: \(error.internalCode)\nDescription: \(error.title), \(error.message)"
            case .error(let error):
                return (error as? Displayable)?.debugDisplayValue ?? NSLocalizedString("common_error_unknown_error", comment: "")
			case .infoMessage(let infoMessage):
				return infoMessage.desciptionText ?? NSLocalizedString("common_error_unknown_error", comment: "")
        }
    }
}

extension CalendarServiceError: Displayable {
    var displayValue: String? {
        switch self {
            case .accessDenied:
                return NSLocalizedString("calendar_access_denied_message", comment: "")
            case .dateInPast:
                return NSLocalizedString("calendar_date_in_past", comment: "")
            case .error(let error):
                return (error as? Displayable)?.displayValue
        }
    }
}

extension PassbookServiceError: Displayable {
    var displayValue: String? {
        switch self {
            case .passAlreadyExists:
                return NSLocalizedString("insurance_passbook_pass_exists", comment: "")
            case .error(let error):
                return error.displayValue
        }
    }
}

extension ServiceUpdateError: Displayable {
    var displayValue: String? {
        switch self {
            case .authNeeded:
                return "Service cann't be updated without authorization"
            case .notImplemented:
                return "Service update not implemented"
            case .error(let error):
                return error.displayValue
        }
    }
}

extension ChatNotFatalError: Displayable {
    var displayValue: String? {
        switch self {
            case .noInternetConnection:
                return NSLocalizedString("no_internet_connection", comment: "")
            case .serverNotAvailable:
                return NSLocalizedString("chat_server_unavailable_error", comment: "")
        }
    }

    var debugDisplayValue: String {
        switch self {
            case .noInternetConnection:
                return NSLocalizedString("no_internet_connection", comment: "")
            case .serverNotAvailable:
                return NSLocalizedString("chat_server_unavailable_error", comment: "")
        }
    }
}

extension EuroProtocolServiceError: Displayable {
    var displayValue: String? {
        switch self {
            case .sdkError(let error):
                return error.displayValue
            case .error(let error):
                return error.displayValue
            case .sdkAuthInfoMissing:
                return NSLocalizedString("insurance_euro_protocol_sdk_auth_error", comment: "")
            case .successResponseParsingError:
                return NSLocalizedString("insurance_euro_protocol_sdk_parsing_error", comment: "")
        }
    }

    var debugDisplayValue: String {
        switch self {
            case .sdkError(let error):
                return error.debugDisplayValue
            case .error(let error):
                return error.debugDisplayValue
            case .sdkAuthInfoMissing:
                return "Не хватает данных для авторизации в SDK RSA"
            case .successResponseParsingError:
                return "Не получилось распарсить успешный ответ от SDK"
        }
    }
}

extension RsaSdkError: Displayable {
    var displayValue: String? {
        errorMessage.message
    }

    var debugDisplayValue: String {
        "\(errorMessage.message)\nSDK Error. Code: \(info.code)"
    }
}

extension EsiaWebAuthError: Displayable {
    var displayValue: String? {
        switch self {
            case .tokenScsMissing:
                return NSLocalizedString("insurance_euro_protocol_esia_token_error", comment: "")
            case .error(let message):
                return message
        }
    }
}
