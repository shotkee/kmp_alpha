//
//  PurchaseTimeWebViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 7/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import WebKit

class PurchaseTimeWebViewController: ViewController, WKNavigationDelegate {
    struct Input {
        let url: URL
    }

    struct Output {
        let showOperationStatus: (Bool) -> Void
    }

    var input: Input!
    var output: Output!

    private var didDisplayStatus: Bool = false
    private lazy var webView: WKWebView = {
        WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    }()

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: input.url))
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard
            let url = webView.url,
            !didDisplayStatus
        else { return }

        var successfullPayment: Bool?
        if url.absoluteString.contains("/rmr/billing/success") {
            successfullPayment = true
        // NOTE: - 'failture' is a middleware mistake
        } else if url.absoluteString.contains("/rmr/billing/failture") {
            successfullPayment = false
        }

        successfullPayment.map { [weak self] success in
            guard let self = self else { return }

            self.presentingViewController?.dismiss(animated: true) {
                self.output.showOperationStatus(success)
                self.didDisplayStatus = true
            }
        }
    }
}
