//
//  EuroProtocolSdkAuthViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import WebKit
import Legacy

enum EsiaWebAuthError: Error {
    case tokenScsMissing
    case error(message: String?)
}

class EuroProtocolSdkAuthViewController: EuroProtocolBaseViewController, WKNavigationDelegate, EuroProtocolServiceDependency {
    typealias TokenScs = String
    typealias SdkToken = String

    private enum Constants {
        static let resultQuery = "result"
        static let errorQuery = "error"
        static let errorDescriptionQuery = "error_description"
        static let tokenKey = "tokenSCS"
        static let authorizedValue = "AUTHORIZED"
        static let failedValue = "FAILED"
        static let delayTime: TimeInterval = 1 // For smooth loading animation on fast internet
    }

    var euroProtocolService: EuroProtocolService!

    enum Mode {
        case newSession
        case loadDraft
    }

    struct Input {
        let esiaLink: (@escaping (Result<EsiaLinkInfo, EuroProtocolServiceError>) -> Void) -> Void
        let esiaUser: (TokenScs, @escaping (Result<EsiaUserData, EuroProtocolServiceError>) -> Void) -> Void
        let startSdk: (@escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
        let stopSdk: (@escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
        let currentDraftContentModel: (@escaping (Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError>) -> Void) -> Void
    }

    struct Output {
        let authDone: (_ draft: EuroProtocolCurrentDraftContentModel?) -> Void
        let exitFlow: () -> Void
        let openAppStore: (_ completion: @escaping (Result<String, AlfastrahError>) -> Void) -> Void
    }

    var input: Input!
    var output: Output!

    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
        title = NSLocalizedString("euro_protocol_process_title", comment: "")

        view.addSubview(webView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: webView, in: view))
    }

    private var permissionsStatusUpdateSubscription: Subscription?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        permissionsStatusUpdateSubscription = euroProtocolService.subscribeForPermissionsStatusUpdates { [weak self] status in
            self?.handlePermissions(status: status)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        permissionsStatusUpdateSubscription?.unsubscribe()
    }

    private func handlePermissions(status: EuroProtocolServicePermissionsStatus) {
        switch status {
            case .unknown, .cameraAccessRequired, .locationPermissionRequired, .photoStoragePermissionRequired:
                let permissionsCards = CommonPermissionsView.PermissionCardInfo.euroProtocolPermissions
                zeroView?.update(viewModel: .init(kind: .permissionsRequired(permissionsCards)))
                showZeroView()
            case .permissionsGranted:
                hideZeroView()
                loadEsiaLink()
        }
    }

    private func restartAuth() {
        hideZeroView()

        loadingIndicator(show: true, message: NSLocalizedString("insurance_euro_protocol_sdk_auth_loading_title", comment: ""))
        input.stopSdk { [weak self] _ in
            self?.esiaLinkInfo = nil
            self?.loadEsiaLink()
        }
    }

    // MARK: - Esia web auth

    private var esiaLinkInfo: EsiaLinkInfo?

    private func loadEsiaLink() {
        loadingIndicator(show: true, message: NSLocalizedString("insurance_euro_protocol_sdk_auth_loading_title", comment: ""))

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayTime) {
            self.input.esiaLink { [weak self] result in
                self?.loadingIndicator(show: false)
                switch result {
                    case .success(let esiaLinkInfo):
                        self?.esiaLinkInfo = esiaLinkInfo
                        self?.openAuthWebPage(esiaLinkInfo)
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }

    private func openAuthWebPage(_ esiaLinkInfo: EsiaLinkInfo) {
        webView.load(URLRequest(url: esiaLinkInfo.esiaUrl))
    }

    // MARK: - Start SDK Session

    private func loadEsiaUser(tokenScs: TokenScs) {
        loadingIndicator(show: true, message: NSLocalizedString("insurance_euro_protocol_sdk_auth_loading_title", comment: ""))
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayTime) {
            self.input.esiaUser(tokenScs) { [weak self] result in
                switch result {
                    case .success:
                        self?.startSdkSession()
                    case .failure(let error):
                        self?.loadingIndicator(show: false)
                        self?.handleError(error)
                }
            }
        }
    }

    private func startSdkSession() {
        loadingIndicator(show: true, message: NSLocalizedString("insurance_euro_protocol_sdk_auth_loading_title", comment: ""))
        input.startSdk { [weak self] result in
            switch result {
                case .success:
                    self?.loadingIndicator(show: false)
                    self?.output.authDone(nil)
                case .failure(let error):
                    switch error {
                        case .sdkError(.foundActiveSession):
                            self?.loadDraft()
                        default:
                            self?.loadingIndicator(show: false)
                            self?.handleError(error)
                    }
            }
        }
    }

    private func loadDraft() {
        input.currentDraftContentModel { [weak self] result in
            self?.loadingIndicator(show: false)

            switch result {
                case .success(let draft):
                    self?.output.authDone(draft)
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    // MARK: - Handle Error

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        switch error {
            case EuroProtocolServiceError.sdkError(.invalidSDKVersion):
                showInvalidSDKVersionError(error)
            default:
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.restartAuth() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
        return true
    }

    private func showInvalidSDKVersionError(_ error: Error) {
        guard let error = error as? EuroProtocolServiceError else { return }

        let zeroViewModel = ZeroViewModel(
            kind: .custom(
                title: error.errorMessage.title,
                message: error.errorMessage.message,
                iconKind: .error
            ),
            canCloseScreen: false,
            buttons: [
                .init(
                    title: NSLocalizedString("insurance_euro_protocol_create_paper_europrotocol", comment: ""),
                    isPrimary: false,
                    action: { [weak self] in self?.output.exitFlow() }
                ),
                .init(
                    title: NSLocalizedString("insurance_euro_protocol_update_app", comment: ""),
                    isPrimary: true,
                    action: { [weak self] in
                        let hide = self?.showLoadingIndicator(message: nil)

                        self?.output.openAppStore { completion in
                            hide?(nil)
                            if case .failure(let error) = completion {
                                self?.handleError(error)
                            }
                        }
                    }
                )
            ]
        )
        zeroView?.update(viewModel: zeroViewModel)
        showZeroView()
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url, let esiaLinkInfo = esiaLinkInfo,
                esiaLinkInfo.redirectUrl.scheme == url.scheme, esiaLinkInfo.redirectUrl.host == url.host,
                let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                let result = query.first(where: { $0.name == Constants.resultQuery })?.value {
            if result == Constants.authorizedValue {
                let cookieStore = WKWebsiteDataStore.default().httpCookieStore
                cookieStore.getAllCookies { cookies in
                    let tokenCookie = cookies.first { $0.name == Constants.tokenKey }
                    if let tokenScs = tokenCookie?.value {
                        self.loadEsiaUser(tokenScs: tokenScs)
                    } else {
                        self.handleError(EsiaWebAuthError.tokenScsMissing)
                    }
                }
            } else {
                let errorTitle = query.first(where: { $0.name == Constants.errorQuery })?.value
                let errorDescription = query.first(where: { $0.name == Constants.errorDescriptionQuery })?.value
                handleError(EsiaWebAuthError.error(message: errorDescription ?? errorTitle))
            }

            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
