//
//  InsuranceBillPaymentViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import WebKit

class InsuranceBillPaymentViewController: UIViewController, WKNavigationDelegate {
    struct Input {
        let paymentPageInfo: InsuranceBillPaymentPageInfo
    }
    struct Output {
        let onSuccess: () -> Void
        let onFailure: () -> Void
        let onExternalRedirect: (Bool) -> Void
    }
    var input: Input!
    var output: Output!

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = NSLocalizedString("insurance_bill_payment", comment: "")

        view.addSubview(webView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: webView, in: view))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        webView.load(URLRequest(url: input.paymentPageInfo.url))
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url {
            if UIApplication.shared.canOpenURL(url) {
                switch navigationAction.request.url?.absoluteString {
                    case let url? where url.contains(input.paymentPageInfo.successString):
                        output.onSuccess()
                        decisionHandler(.cancel)
                    case let url? where url.contains(input.paymentPageInfo.failureString):
                        output.onFailure()
                        decisionHandler(.cancel)
                    default:
                        decisionHandler(.allow)
                }
            } else {
                UIApplication.shared.open(url) { success in
                    // true if external redirect was successful
                    // false if webview stay on screen
                    self.output.onExternalRedirect(success)
                }
                decisionHandler(.allow)
            }
        }
    }
}
