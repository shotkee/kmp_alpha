//
//  DocumentInteractionController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 10.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import WebKit

class DocumentInteractionController: NSObject,
									 UIDocumentInteractionControllerDelegate,
									 UIDocumentBrowserViewControllerDelegate {
    static let shared: DocumentInteractionController = .init()

    private weak var sourceController: UIViewController!
    private var documentInteractionController: UIDocumentInteractionController?

    private override init() { }

	func openDocument(
		url: URL,
		from controller: UIViewController,
		animated: Bool = true,
		uti: String? = nil,
		name: String? = nil
	) {
		sourceController = controller
		
		documentInteractionController = .init(url: url)

		guard let documentInteractionController
		else { return }

		documentInteractionController.delegate = self
		
		documentInteractionController.name = name
		documentInteractionController.uti = uti

		documentInteractionController.presentPreview(animated: animated)
    }

	// MARK: - UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        sourceController
    }

    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        documentInteractionController = nil
    }

    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {}
}
