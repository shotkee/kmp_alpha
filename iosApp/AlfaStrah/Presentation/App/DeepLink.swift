//
// DeepLink
// AlfaStrah
//
// Created by Eugene Egorov on 24 December 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import Foundation

enum DeepLink {
    case openPolicyList
    case openPolicy(id: String)
    case confirmEmail(code: String)
    case auth(session: UserSession?, accountType: AccountType?)
    case authRequest(appName: String)

    private enum Constants {
        static let mainUrl: URL = {
            guard let url = URL(string: "https://www.alfastrah.ru") else { fatalError("Invalid url") }
            return url
        }()
        static let policiesAction = "/personal/policies"
        static let policiesMpAction = "/mp/personal/policies"
        static let insuranceAction = "/personal/policies/details.php"
        static let insuranceMpAction = "/mp/personal/policies/details.php"
        static let confirmEmailAction = "/login/confirm/email"
        static let currentAppScheme = "ru.alfastrah.iosapp.new"
        static let oldAppScheme = "ru.alfastrah.iosapp.old"
        static let authTokenAction = "/auth"
        static let tokenKey = "token"
        static let tokenIdKey = "tokenId"
        static let accountTypeKey = "accountType"
        static let appNameKey = "appName"
        static let policyIdKey = "policy_id"
        static let confirmationKey = "confirmation"
        static let authRequestAction = "/authRequest"
    }

    static func from(url: URL) -> DeepLink? {
        guard let scheme = url.scheme, url.host == Constants.mainUrl.host else { return nil }

        switch scheme {
            case Constants.mainUrl.scheme where url.path == Constants.policiesAction || url.path == Constants.policiesMpAction:
                    return .openPolicyList
            case Constants.mainUrl.scheme where url.path == Constants.insuranceAction || url.path == Constants.insuranceMpAction:
                guard
                    let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                    let idValue = query.first(where: { $0.name == Constants.policyIdKey })?.value,
                    let id = idValue.removingPercentEncoding
                else { return nil }

                return .openPolicy(id: id)
            case Constants.mainUrl.scheme where url.path == Constants.confirmEmailAction:
                guard
                    let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                    let codeValue = query.first(where: { $0.name == Constants.confirmationKey })?.value,
                    let code = codeValue.removingPercentEncoding,
                    !code.isEmpty
                else { return nil }

                return .confirmEmail(code: code)
            case Constants.currentAppScheme where url.path == Constants.authTokenAction:
                guard
                    let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                    let tokenId = query.first(where: { $0.name == Constants.tokenIdKey })?.value,
                    let token = query.first(where: { $0.name == Constants.tokenKey })?.value,
                    let accountTypeValue = (query.first(where: { $0.name == Constants.accountTypeKey })?.value).flatMap(Int.init),
                    let accountType = AccountType(rawValue: accountTypeValue)
                else {
                    return .auth(session: nil, accountType: nil)
                }

                return .auth(session: UserSession(id: tokenId, accessToken: token), accountType: accountType)
            case Constants.currentAppScheme where url.path == Constants.authRequestAction:
                let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
                let appName = query.first(where: { $0.name == Constants.appNameKey })?.value ?? "Unknown"
                return .authRequest(appName: appName)
            default:
                return nil
        }
    }

    func url() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.host = Constants.mainUrl.host

        switch self {
            case .authRequest(let appName):
                urlComponents.scheme = Constants.oldAppScheme
                urlComponents.path = Constants.authRequestAction
                urlComponents.queryItems = [ URLQueryItem(name: Constants.appNameKey, value: appName) ]
            default:
                return nil
        }

        return urlComponents.url
    }
}
