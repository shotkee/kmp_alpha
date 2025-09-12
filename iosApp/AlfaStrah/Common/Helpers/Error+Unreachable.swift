//
//  Error+Unreachable.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

extension HttpError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error):
                return (error as? Unreachable)?.isUnreachableError ?? false
            case .unreachable:
                return true
            default:
                return false
        }
    }
}

extension NetworkError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error, _, _):
                return error?.isUnreachableError ?? false
            default:
                return false
        }
    }
}

extension AlfastrahError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error):
                return (error as? Unreachable)?.isUnreachableError ?? false
            case .network(let error):
                return error.isUnreachableError
            default:
                return false
        }
    }
}

extension CalendarServiceError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error):
                return (error as? Unreachable)?.isUnreachableError ?? false
            default:
                return false
        }
    }
}

extension PassbookServiceError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error):
                return error.isUnreachableError
            default:
                return false
        }
    }
}

extension ServiceUpdateError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error):
                return error.isUnreachableError
            default:
                return false
        }
    }
}

extension ChatNotFatalError: Unreachable {
    var isUnreachableError: Bool {
        false
    }
}

extension EuroProtocolServiceError: Unreachable {
    var isUnreachableError: Bool {
        switch self {
            case .error(let error):
                return error.isUnreachableError
            default:
                return false
        }
    }
}

extension RsaSdkError: Unreachable {
    var isUnreachableError: Bool {
        false
    }
}

extension EsiaWebAuthError: Unreachable {
    var isUnreachableError: Bool {
        false
    }
}
