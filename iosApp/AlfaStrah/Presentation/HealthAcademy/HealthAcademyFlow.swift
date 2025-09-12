//
//  HealthAcademyFlow.swift
//  AlfaStrah
//
//  Created by mac on 26.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

class HealthAcademyFlow: BaseFlow,
                         HealthAcademyServiceDependency {
    var healthAcademyService: HealthAcademyService!
        
    private func createAndShowController(
        type: HealthAcademyViewController.ControllerType,
        cardGroups: [HealthAcademyCardGroup],
        title: String
    ) {
        let viewController = HealthAcademyViewController()
        self.container?.resolve(viewController)
        
        viewController.input = .init(
            cardGroups: cardGroups,
            type: type,
            title: title
        )

        viewController.output = .init(
            tap: { (card: HealthAcademyCard) in
                switch card.type {
                    case .group(let cardGroup):
                        if let unwrappedCardGroup = cardGroup {
                            self.createAndShowController(
                                type: .subsection,
                                cardGroups: [unwrappedCardGroup],
                                title: unwrappedCardGroup.title
                            )
                        }
                    case .url(let url):
                        if let unwrappedUrl = url {
							WebViewer.openDocument(
								url: { completion in
									completion(.success(unwrappedUrl))
								},
								openMode: .push,
								showShareButton: true,
								from: viewController
							)
                        }
                }
            }
        )
        
        self.createAndShowNavigationController(
            viewController: viewController,
            mode: .push
        )
    }

    public func show() {
        let hide = fromViewController.showLoadingIndicator(message: nil)
        self.healthAcademyService.getData { result in
            hide(nil)
            switch result {
                case .success(let cardGroups):
                    if let unwrappedCardGroups = cardGroups {
                        self.createAndShowController(
                            type: .healthAcademyHome,
                            cardGroups: unwrappedCardGroups,
                            title: NSLocalizedString("insurance_health_academy", comment: "")
                        )
                    } else {
                        ErrorHelper.show(
                            error: nil,
                            text: NSLocalizedString("insurance_euro_protocol_sdk_unknown_error", comment: ""),
                            alertPresenter: self.alertPresenter
                        )
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
}
