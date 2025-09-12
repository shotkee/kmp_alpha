//
//  InsuranceProgramFlow.swift
//  AlfaStrah
//
//  Created by mac on 19.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class InsuranceProgramFlow: BaseFlow, InsuranceProgramServiceDependency {
    var insuranceProgramService: InsuranceProgramService!
    public func show(insuranceId: String, insuranceHelpType: Insurance.HelpType?, insuranceHelpUrl: URL?) {
        let hide = fromViewController.showLoadingIndicator(message: nil)
        insuranceProgramService.getHelpBlocks(insuranceId: insuranceId) { result in
            hide {}
            switch result {
                case .success(let helpBlocks):
                    let controller = InsuranceProgramViewController()
                    controller.input = .init(
                        helpBlocks: helpBlocks,
                        showDownloadPdfButton: insuranceHelpType == .blocksWithFile && insuranceHelpUrl != nil,
                        pdfURL: insuranceHelpUrl
                    )
                    controller.output = .init(
                        pdfLinkTap: { [weak controller] url in
                            guard let controller
                            else { return }
                            
                            WebViewer.openDocument(url, from: controller)
                        },
                        openHelpBlockContent: { [weak controller] helpBlock in
                            guard let controller
                            else { return }

                            let memoController = InsuranceProgramMemoViewController()
                            memoController.input = .init(
                                insuranceContent: helpBlock.content
                            )
                            
                            self.createAndShowNavigationController(
                                viewController: memoController,
                                mode: .push
                            )
                        }
                    )
                    self.createAndShowNavigationController(viewController: controller, mode: .push)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
}
