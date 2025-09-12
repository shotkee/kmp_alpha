//
//  UtilityViewControllers.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 22.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Legacy
import UIKit
import SafariServices
import WebKit

enum SafariViewController
{
    static func viewController(for url: URL) -> UIViewController?
    {
        guard ["http", "https"].contains(url.scheme)
        else { return nil }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = Style.Color.Palette.red
        safariViewController.dismissButtonStyle = .close
        
        return safariViewController
    }
    
    static func open(
        _ url: String,
        from viewController: UIViewController
    )
    {
        guard let url = URL(string: url)
        else { return }
        
        open(
            url,
            from: viewController
        )
    }
    
    static func open(
        _ url: URL,
        from viewController: UIViewController
    )
    {
        guard let safariViewController = Self.viewController(for: url)
        else { return }
        
        viewController.present(
            safariViewController,
            animated: true
        )
    }
}

enum LocalDocumentViewer {
    static func open(
        _ url: URL,
        from controller: UIViewController,
		uti: String? = nil,
		name: String? = nil
    ) {
        DocumentInteractionController.shared.openDocument(
            url: url,
            from: controller,
			uti: uti,
			name: name
        )
    }
}

enum WebViewer {
    static func encryptUrlAndHandleRedirect(
        _ url: URL,
        baseUrl: URL?,
        httpRequestAuthorizer: HttpRequestAuthorizer,
        accessToken: String,
        showShareButton: Bool = false,
        from controller: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        let webViewController = EncryptLinksWebViewController()
                
        webViewController.input = .init(
            url: url,
            baseUrl: baseUrl,
            httpRequestAuthorizer: httpRequestAuthorizer,
            accessToken: accessToken,
            showShareButton: showShareButton
        )
        
        webViewController.output = .init(
            close: { [weak controller] in
                controller?.dismiss(
                    animated: true,
                    completion: completion
                )
            }
        )
        
        if let navigationController = controller.navigationController,
            let topViewController = navigationController.topViewController {
            
            let navigationController = UINavigationController()
            
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.viewControllers = [webViewController]
            
            webViewController.addCloseButton { [weak webViewController] in
                navigationController.dismiss(animated: true)
            }
            
            topViewController.present(
                navigationController,
                animated: true
            )
            return
        }

        controller.present(UINavigationController(rootViewController: webViewController), animated: true)
    }
    
    @discardableResult
    static func openDocument(
        _ url: URL,
        withAuthorization: Bool = false,
        showShareButton: Bool = true,
        needSharedUrl: Bool = false,
        urlShareable: URL? = nil,
        from controller: UIViewController,
        cookiesDidChange: ((WKHTTPCookieStore) -> Void)? = nil,
        cookiePartUrlDetectStringCondition: String? = nil,
		customHeaders: [BDUI.HeaderComponentDTO]? = nil,
        completion: (() -> Void)? = nil
    ) -> ViewController {
		// TODO: Remove later. Site doesn't support webview for now
		if url.absoluteString.contains("nsis.ru") {
			UIApplication.shared.open(url)
			return .init()
		}
		
        let webViewController = WebViewController()
        
        if let controller = controller as? ViewController,
		   let container = controller.container,
           withAuthorization {  // fix crash on requestAuthorizationIsNeeded = true
			container.resolve(webViewController)
            
            webViewController.input = .init(
				url: { completion in
					completion(.success(url))
				},
                requestAuthorizationIsNeeded: true,
                showShareButton: showShareButton,
                needSharedUrl: needSharedUrl,
                urlShareable: urlShareable,
                cookiesDidChange: cookiesDidChange,
                cookiePartUrlDetectStringCondition: cookiePartUrlDetectStringCondition,
				headers: customHeaders
            )
        } else {
            webViewController.input = .init(
				url: { completion in
					completion(.success(url))
				},
                requestAuthorizationIsNeeded: false,
                showShareButton: showShareButton,
                needSharedUrl: needSharedUrl,
                urlShareable: urlShareable,
                cookiesDidChange: cookiesDidChange,
                cookiePartUrlDetectStringCondition: cookiePartUrlDetectStringCondition,
				headers: customHeaders
            )
        }
                
        webViewController.output = .init(
			toChat: {
				ApplicationFlow.shared.show(item: .tabBar(.chat))
			}, 
			toFile:
			{
				[weak webViewController] in
				
				guard let webViewController
				else { return }
				
				self.openDocument(
					$0,
					needSharedUrl: true,
					from: webViewController
				)
			},
            close: { [weak controller] in
                controller?.dismiss(
                    animated: true,
                    completion: completion
                )
            }
        )
        
        controller.present(
            UINavigationController(rootViewController: webViewController),
            animated: true
        )
        
        return webViewController
    }

	@discardableResult
	static func openDocument(
		url: @escaping (@escaping(Result<URL, AlfastrahError>) -> Void) -> Void,
		openMode: ViewControllerShowMode,
		withAuthorization: Bool = false,
		showShareButton: Bool = true,
		needSharedUrl: Bool = false,
		urlShareable: URL? = nil,
		from controller: UIViewController,
		cookiesDidChange: ((WKHTTPCookieStore) -> Void)? = nil,
		cookiePartUrlDetectStringCondition: String? = nil,
		customHeaders: [BDUI.HeaderComponentDTO]? = nil,
		completion: (() -> Void)? = nil
	) -> ViewController {
		let webViewController = WebViewController()
		
		if let controller = controller as? ViewController,
		   withAuthorization {  // fix crash on requestAuthorizationIsNeeded = true
			controller.container?.resolve(webViewController)
		}
		
		webViewController.input = .init(
			url: url,
			requestAuthorizationIsNeeded: withAuthorization,
			showShareButton: showShareButton,
			needSharedUrl: needSharedUrl,
			urlShareable: urlShareable,
			cookiesDidChange: cookiesDidChange,
			cookiePartUrlDetectStringCondition: cookiePartUrlDetectStringCondition,
			headers: customHeaders
		)
				
		webViewController.output = .init(
			toChat: { [weak webViewController] in
				guard let webViewController, let controller = controller as? ViewController
				else { return }

				let chatFlow = ChatFlow()
				controller.container?.resolve(chatFlow)
				chatFlow.show(from: webViewController, mode: .fullscreen)
			},
			toFile:
			{
				[weak webViewController] in
				
				guard let webViewController
				else { return }
				
				self.openDocument(
					$0,
					needSharedUrl: true,
					from: webViewController
				)
			},
			close: { [weak controller] in
				switch openMode {
					case .modal:
						controller?.dismiss(
							animated: true,
							completion: completion
						)
					case .push:
						controller?.navigationController?.popViewController(animated: true)
				}
				
			}
		)
		
		webViewController.hidesBottomBarWhenPushed = true
		
		switch openMode {
			case .modal:
				controller.present(
					UINavigationController(rootViewController: webViewController),
					animated: true
				)
			case .push:
				controller.navigationController?.pushViewController(webViewController, animated: true)
		}
		
		return webViewController
	}
}
