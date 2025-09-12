//
//  PdfViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 25.05.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import WebKit
import TinyConstraints
import Security

class WebViewController: ViewController,
                         WKNavigationDelegate,
                         WKUIDelegate,
                         WKHTTPCookieStoreObserver,
                         HttpRequestAuthorizerServiceDependency {
    var httpRequestAuthorizer: HttpRequestAuthorizer!
    
    // MARK: - Private UI
    
	enum State {
		case loading
		case failure
		case data
	}
	
	// MARK: - resource https://stackoverflow.com/questions/4212861/what-is-a-correct-mime-type-for-docx-pptx-etc
	
	enum RedirectFileType: String
	{
		case pdf = "pdf"
		case doc = "doc"
		case docx = "docx"
		case xls = "xls"
		case xlsx = "xlsx"
	}

    private let webView = WKWebView()
    private var cookiePartUrlDetectStringConditionIsSet: Bool = false
	private let operationStatusView = OperationStatusView()
	private var isFirstViewDidAppear = true
    
    // MARK: - Input
    
    struct Input {
		let url: (@escaping (Result<URL, AlfastrahError>) -> Void) -> Void
        let requestAuthorizationIsNeeded: Bool
        let showShareButton: Bool
        let needSharedUrl: Bool
        let urlShareable: URL?
        let cookiesDidChange: ((WKHTTPCookieStore) -> Void)?
        let cookiePartUrlDetectStringCondition: String?
		let headers: [BDUI.HeaderComponentDTO]?
    }
    
    var input: Input!
	private var url: URL?
    
    // MARK: - Output
    
    struct Output {
		let toChat: (() -> Void)?
		let toFile: ((URL) -> Void)
        let close: () -> Void
    }
    
    var output: Output!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
	
	private func loadUrl() {
		update(with: .loading)
		input.url { [weak self] result in
			guard let self
			else { return }

			switch result {
				case .success(let url):
					var urlRequest = URLRequest(url: url)
					
					if var headers = input.headers {
						headers.forEach {
							if let name = $0.header, let value = $0.value {
								urlRequest.setValue(value, forHTTPHeaderField: name)
							}
						}
					}
					
					self.url = url
				
					if RedirectFileType(rawValue: url.fileExtension) != nil
					{
						self.navigationItem.title = url.filename
					}

					if self.input.requestAuthorizationIsNeeded {
						urlRequest = self.httpRequestAuthorizer.authorize(request: urlRequest)
					}

					self.webView.load(urlRequest)
					
				case .failure:
					update(with: .failure)
			}
		}
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
		if isFirstViewDidAppear
		{
			isFirstViewDidAppear = false
			WKWebsiteDataStore.default().httpCookieStore.add(self)

			loadUrl()
		}
    }
    
    // MARK: - Cookie managment
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        if input.cookiePartUrlDetectStringCondition != nil,
           cookiePartUrlDetectStringConditionIsSet {    // if regex path was detected it fired once for specific cookie set
            input.cookiesDidChange?(cookieStore)
            cookiePartUrlDetectStringConditionIsSet = false
        }
    }
    
    // MARK: - Building UI
    
    private func buildUI() {
		view.backgroundColor = .Background.backgroundContent
		webView.isOpaque = false
		webView.scrollView.backgroundColor = .clear
		
        view.addSubview(webView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: webView,
                in: view
            )
        )

		view.addSubview(operationStatusView)
		operationStatusView.edgesToSuperview()

        navigationItem.leftBarButtonItem = .init(
            title: NSLocalizedString("common_close_button", comment: ""),
            style: .plain,
            target: self,
            action: #selector(onCloseButton)
        )
    }
	
	private func update(with state: State) {
		switch state {
			case .failure:
				let state: OperationStatusView.State = .info(
					.init(
						title: NSLocalizedString("common_error_title", comment: ""),
						description: NSLocalizedString("common_error_description", comment: ""),
						icon: .Icons.cross.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
					)
				)
				
				let buttons: [OperationStatusView.ButtonConfiguration] = [
					.init(
						title: NSLocalizedString("common_contact_to_chat", comment: ""),
						isPrimary: false,
						action: { [weak self] in
							self?.output.toChat?()
						}
					),
					.init(
						title: NSLocalizedString("web_view_error_request_retry", comment: ""),
						isPrimary: true,
						action: { [weak self] in
							self?.loadUrl()
						}
					)
				]
				operationStatusView.notify.updateState(state)
				operationStatusView.notify.buttonConfiguration(buttons)
				operationStatusView.isHidden = false
			case .loading:
				let state: OperationStatusView.State = .loading(.init(
					title: NSLocalizedString("common_load", comment: ""),
					description: nil,
					icon: nil
				))
				operationStatusView.notify.updateState(state)
				operationStatusView.isHidden = false
			case .data:
				webView.isOpaque = true
				operationStatusView.isHidden = true
		}
	}
    
    private func showShareButton() {
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(onShareButton)
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func onCloseButton() {
        output?.close()
    }
    
    @objc private func onShareButton() {
		guard let url
		else { return }
		
        if let urlShareable = input.urlShareable {
            presentUIActivityViewController(url: urlShareable)
        }
        else if input.needSharedUrl {
			presentUIActivityViewController(url: url)
        } else {
            let hide = showLoadingIndicator(message: nil)
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            var urlRequest = URLRequest(url: url)
            
            if input.requestAuthorizationIsNeeded {
                urlRequest = httpRequestAuthorizer.authorize(request: urlRequest)
            }
            
            Self.download(urlRequest) { localUrl, error in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self
                    else { return }
                    
                    hide(nil)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    if let error = error {
                        self.alert(
                            message: error.localizedDescription
                        )
                    } else if let localUrl = localUrl {
                        self.presentUIActivityViewController(url: localUrl)
                    } else {
                        self.alert(
                            message: NSLocalizedString("common_loading_error", comment: "")
                        )
                    }
                }
            }
        }
    }
    
    private func presentUIActivityViewController(url: URL) {
        let activityController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityController.popoverPresentationController?.sourceView = webView
        }
        
        present(
            activityController,
            animated: true
        )
    }
    
    // MARK: - Downloading pdf file
    
    static func download(
        _ urlRequest: URLRequest,
        completion: @escaping (_ localUrl: URL?, _ error: Error?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(
            with: urlRequest,
            completionHandler: { fileUrl, response, error in
                guard (response as? HTTPURLResponse)?.statusCode == 200,
                      error == nil,
                      let fileUrl = fileUrl
                else {
                    completion(nil, error)
                    return
                }
                
                do {
                    let renamedUrl = fileUrl
                        .deletingLastPathComponent()
						.appendingPathComponent(fileUrl.filename)
                    try? FileManager.default.removeItem(at: renamedUrl)
                    try FileManager.default.moveItem(
                        at: fileUrl,
                        to: renamedUrl
                    )
                    
                    completion(renamedUrl, error)
                }
                catch let error {
                    completion(nil, error)
                }
            }
        )
        
        task.resume()
    }
    
    // MARK: - Displaying errors
    func alert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            .init(
                title: NSLocalizedString("common_ok_button", comment: ""),
                style: .default
            )
        )
        
        present(
            alert,
            animated: true
        )
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        handleCookieCondition(with: navigationResponse)
        
        guard let mimeType = navigationResponse.response.mimeType
        else { return }

        if input.urlShareable != nil || input.needSharedUrl {
            showShareButton()
        }
        else if RedirectFileType(rawValue: mimeType) != nil && input.showShareButton {
            showShareButton()
        }
        
        decisionHandler(.allow)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url
        else { return }
        
        if !["http", "https"].contains(url.scheme) {
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
			if RedirectFileType(rawValue: url.fileExtension) != nil
			{
				output.toFile(url)
			}
			else
			{
				webView.load(
					URLRequest(url: url)
				)
			}
        }
            
        decisionHandler(.allow)
    }
	
	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		update(with: .data)
	}
    
    private func handleCookieCondition(with navigationResponse: WKNavigationResponse) {
        if var condition = input.cookiePartUrlDetectStringCondition {
            condition.removeFirst()
            condition.removeLast()
            
            if let regex = try? NSRegularExpression(pattern: condition),
               let path = navigationResponse.response.url?.absoluteString {
                let range = NSRange(location: 0, length: path.count)
                if regex.firstMatch(in: path, options: [], range: range) != nil {
                    cookiePartUrlDetectStringConditionIsSet = true
                }
            }
        }
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if input.cookiePartUrlDetectStringCondition != nil,
           input.cookiesDidChange != nil {
            output?.close()
        }
    }
}

class EncryptLinksWebViewController: ViewController,
                                     WKNavigationDelegate {
    // MARK: - Private UI
    private let webView = WKWebView()
    
    // MARK: - Input
    struct Input {
        let url: URL
        let baseUrl: URL?
        let httpRequestAuthorizer: HttpRequestAuthorizer
        let accessToken: String
        let showShareButton: Bool
    }
    
    var input: Input!
    
    // MARK: - Output
    struct Output {
        let close: () -> Void
    }
    
    var output: Output?
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        
        webView.navigationDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard var encryptedUrl = Self.handleWithEncryption(
            baseUrl: input.baseUrl,
            url: input.url,
            accessToken: input.accessToken
        ) else { return }
        
        var urlRequest = URLRequest(url: encryptedUrl)
        
        urlRequest = input.httpRequestAuthorizer.authorize(request: urlRequest)
        
        webView.load(urlRequest)
    }
    
    // MARK: - Building UI
    
    private func buildUI() {
        // background
        
        view.backgroundColor = Style.Color.background
        
        // web view
        
        view.addSubview(webView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: webView,
                in: view
            )
        )
        
        // close button
        
        navigationItem.leftBarButtonItem = .init(
            title: NSLocalizedString("common_close_button", comment: ""),
            style: .plain,
            target: self,
            action: #selector(onCloseButton)
        )
    }
    
    private func showShareButton() {
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(onShareButton)
        )
    }
    
    // MARK: - Actions
    @objc private func onCloseButton() {
        output?.close()
    }
    
    @objc private func onShareButton() {
        let hide = showLoadingIndicator(message: nil)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        var urlRequest = URLRequest(url: input.url)
        
        urlRequest = input.httpRequestAuthorizer.authorize(request: urlRequest)
        
        Self.download(urlRequest) { localUrl, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }
                
                hide(nil)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                if let error = error {
                    self.alert(
                        message: error.localizedDescription
                    )
                } else if let localUrl = localUrl {
                    self.presentUIActivityViewController(url: localUrl)
                } else {
                    self.alert(
                        message: NSLocalizedString("common_loading_error", comment: "")
                    )
                }
            }
        }
    }
    
    private func presentUIActivityViewController(url: URL) {
        let activityController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityController.popoverPresentationController?.sourceView = self.webView
        }
        
        self.present(
            activityController,
            animated: true
        )
    }
    
    // MARK: - Downloading pdf file
    
    static func download(
        _ urlRequest: URLRequest,
        completion: @escaping (_ localUrl: URL?, _ error: Error?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(
            with: urlRequest,
            completionHandler: { fileUrl, response, error in
                guard (response as? HTTPURLResponse)?.statusCode == 200,
                      error == nil,
                      let fileUrl = fileUrl
                else {
                    completion(nil, error)
                    return
                }
                
                do {
                    let renamedUrl = fileUrl
                        .deletingLastPathComponent()
                        .appendingPathComponent("download.pdf")
                    try? FileManager.default.removeItem(at: renamedUrl)
                    try FileManager.default.moveItem(
                        at: fileUrl,
                        to: renamedUrl
                    )
                    
                    completion(renamedUrl, error)
                }
                catch let error {
                    completion(nil, error)
                }
            }
        )
        
        task.resume()
    }
    
    // MARK: - Displaying errors
    func alert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            .init(
                title: NSLocalizedString("common_ok_button", comment: ""),
                style: .default
            )
        )
        
        present(
            alert,
            animated: true
        )
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        guard let mimeType = navigationResponse.response.mimeType
        else { return }
        
        if mimeType == "application/pdf" && input.showShareButton {
            showShareButton()
        }
        
        decisionHandler(.allow)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url
            else { return }
            
            webView.load(
                URLRequest(url: url)
            )
        }
        
        decisionHandler(.allow)
    }
    
    static func handleWithEncryption(
        baseUrl: URL?,
        url: URL,
        accessToken: String
    ) -> URL? {
        guard let baseUrl,
              let hostname = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)?.host
        else { return nil }
        
        let payload = """
        {"access_token":"\(accessToken)", "url":"\(url.absoluteString)"}
        """    // !: need raw string
                
        guard let encryptedPayload = Self.encrypt(string: payload, with: Constants.publicKey)
        else { return nil }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = hostname
        urlComponents.path = "/api/url_deeplink"
                
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "rsa_202311_8192"),
            URLQueryItem(
                name: "request_base64",
                value: encryptedPayload
            )
        ]
        
        return URL(string: (urlComponents.url?.absoluteString ?? "").replacingOccurrences(of: "+", with: "%2B"))
    }
    
    private static func encrypt(string: String, with publicKey: String) -> String? {
        guard let data = Data(base64Encoded: publicKey)
        else { return nil }
                        
        var attributes: CFDictionary {
            return [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
            ] as CFDictionary
        }
        
        var error: Unmanaged<CFError>? = nil
        
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error)
        else { return nil }
                
        guard let payload = string.data(using: .utf8)
        else { return nil }
        
        guard let encryptedData = SecKeyCreateEncryptedData(
            secKey,
            SecKeyAlgorithm.rsaEncryptionPKCS1,
            payload as CFData,
            &error
        ) as Data?
        else { return nil }
        
        return encryptedData.base64EncodedString()
    }
    
    struct Constants {
        // swiftlint:disable line_length
        static let publicKey = #"MIIEIjANBgkqhkiG9w0BAQEFAAOCBA8AMIIECgKCBAEAyzhpWgjbZZYOc14fq/xkiZrXZCIYw7yx8RRjE7TcceUIupkUNwOc+mUYBQmbjB6d7Xp1QaAVNwDFGVQErW7zDn9dTWJK0APMvLdiQL4Rl56W6ZjXryZ+5FU6TMpCxS9JvA8wSw4N9jxOC7lBb3GUS0SNJoejBA9ZpZgkmcXUojsI+auLTwKgoLu0l32Vqpu44jyUXcZQW0DmBS+peKr2/GuZPuLYI2xiO7zizGT3HiqqCPKy/d+mxWEpluWWZc+mmvLMyzqcj2ouXULL8MrSpkLCEtLQGrPNsLHAvgenQEe2oIgUM/TWDlYKHbPsXuL5Jx/DusJnaLxmgEPSRutXJOZjUL5USz6PY+ELXvovJdZ8SP7qeJrBrWUO2s5bCEZFHpajEVUjCwqdtJ4FoPPE2yuD7DXJhEeuinCJWyx/OpxYnc1EvG/N40rEZdDtQBdz1mM3fBGlwI60YhJ8V+70f+Jkl6pkb5G6lKl6zBnWlVFXlAfxgZN6yUFkiX2Uqm7qICbfwRr+PghqIPvOFGBGNOOIeqrZSrwnkbdTsR73zbtPJ+iTpU5k39kpByTxztRizSmXe8NegAkaYUfTRqORQA7cE+BKZ7ebJnnf/nNiKim7+VbDQslcMKcbuAcBaPshu03KMbRD4rC7sQdVjWKsbQgu20xdu0fe2KxtMxkvKcr6BFppnShMwrd4W6xuV+9QIrmLSdpS9KNDbBf5pHCHP0LvluPO4PteQDdTEE8TdUFMt7Pn2AAeIqel1PAz3sF7sDxXeduKAdL7DEWllkIwvnRZxTqU73ZXdX3A6h/hIYWaXvtovM4IGGDb1cvmUgCkW4sGNPQ4f2YpjngA8gigxQ9CQDRPWYw2v2ME2Yet2+nvaGuKOv/3lB36OCHZHK8mBMygMh+MCqmmyA/pmXjrDQO5INOuQVBMAZVkSFgZmwA3DXPYsbhEfDFhAjea9/DblScUWmjj1ghX6eXQIeF878Mmhp2TEEBH2aa+ZHR2Lzt+aSfU1+yx0r+QKH0nfVCcxxqApHm3Gpb4Bva4PPdT4/4+s7tLWHh6pXKHf0KW3XtKNg0i9nAi/7KWi7hSSNNZpmf5syJDZ+xGseMG9/a4D1BAXzN6lwqluMC1Hqt0bUedxLTMH4taRG8212IQbRLBU1qyO5GX+bMzG/AZ7lzpwfenUQguAVSiNDA/G6udapuH++WYGQ/7oBxlyAxCTK8RdGG5Czwsc4aLPk44XRKkF0UBGD6hBj7QTt91dJ/alTQj2Pf12bYmgKtMa1QnxMZ7jYMnReswWd2/ftQX2/qO9zZBEQg39qXDhIbVs/d9PeFdqOBXISkVsjC5A9LviYj6nrGmA7xGwvnUtjsLa/RhFwIDAQAB"#
        // swiftlint:enable line_length
    }
}
