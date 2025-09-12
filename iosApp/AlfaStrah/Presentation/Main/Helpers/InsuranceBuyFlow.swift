//
//  InsuranceBuyFlow.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 17/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsurancesBuyFlow: BDUI.ActionHandlerFlow,
						 InsurancesProductCategoryServiceDependency	{
	var insurancesProductCategoryService: InsurancesProductCategoryService!
	
    private var insuranceProductCategory: [InsuranceProductCategory] = []
    
    deinit {
        logger?.debug("")
    }
    
    private weak var fromViewController: ViewController?

	override init() {
		super.init()
		
        let navigationController = TranslucentNavigationController()
        navigationController.strongDelegate = TranslucentNavigationControllerDelegate()
		initialViewController = navigationController
    }

    func start() {
		setupInitalController(withNativeRender: false)

        initialViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar_products_title", comment: ""),
            image: .Icons.threeSquaresPlus,
            selectedImage: nil
        )
        
        initialViewController.tabBarItem.imageInsets = insets(2)
    }
	
	func setupInitalController(withNativeRender withNativeRender: Bool) {
		if withNativeRender {
			initialViewController.setViewControllers(
				[
					createBuyListViewController(
						hasCloseButton: false,
						title: NSLocalizedString("product_showcase_title", comment: ""),
						showButtonsAndHeader: true
					)
				],
				animated: false
			)
		} else {
			backendDrivenService.products { result in
				switch result {
					case .success(let data):
						if let screenBackendComponent = BDUI.DataComponentDTO(body: data).screen {
							let homeViewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
								with: screenBackendComponent,
								use: self.backendDrivenService,
								use: self.analytics,
								isRootController: true,
								tabIndex: 3,
								backendActionSelectorHandler: { events, viewController in
									guard let viewController
									else { return }
									
									self.handleBackendEvents(
										events,
										on: viewController,
										with: screenBackendComponent.screenId,
										isModal: false,
										syncCompletion: nil
									)
								},
								syncCompletion: nil
							)
							
							self.container?.resolve(homeViewController)
							
							self.initialViewController.setViewControllers([ homeViewController ], animated: false)
						}
						
					case .failure:
						self.setupInitalController(withNativeRender: true)
						
				}
			}
		}
	}
    
    func start(from: ViewController) {
        logger?.debug("")
        fromViewController = from
        toBuyInsurance()
    }

    func buyKASKO(from: ViewController) {
        logger?.debug("")
        fromViewController = from
        getInsuranceUrlOfType(product: .kasko)
    }

    private func openURL(url: URL?) {
        guard let controller = fromViewController, let url = url else { return }

        SafariViewController.open(url, from: controller)
    }

    private func getInsuranceUrlOfType(product: Product) {
        guard accountService.isAuthorized else {
            openURL(url: InsuranceHelper.defaultInsuranceUrlOfType(product: product))
            return
        }

        getInsuranceURL(with: "\(product.rawValue)")
    }

    private func getInsuranceURL(with id: String) {
        guard let topViewController = initialViewController.topViewController as? ViewController
        else { return }

        let cancellable = CancellableNetworkTaskContainer()
        let hide = topViewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: ""),
            cancellable: cancellable
        )
        
        guard !(accountService.isDemo)
        else {
            hide(nil)
            DemoAlertHelper().showDemoAlert(from: topViewController)
            return
        }
        
        let networkTask = self.insurancesService.insuranceFromListedProductsDeeplinkUrl(
            productId: id
        ) { [weak self] result in
            hide(nil)
            
            guard let self = self
            else { return }

            switch result {
                case .success(let newUrl):
                    topViewController.dismiss(animated: true, completion: {
                        self.openURL(url: newUrl)
                    })
                case .failure(let error):
                    guard !error.isCanceled else { return }

                    topViewController.processError(error)
            }
        }
        
        cancellable.addCancellables([ networkTask ])
    }

    private func urlWithMobileFlagFrom(url: URL) -> URL {
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let newItem = URLQueryItem(name: "mobile_client", value: "iOS")
        var queryItems = component?.queryItems ?? []
        queryItems.append(newItem)
        component?.queryItems = queryItems
        return component?.url ?? url
    }

    private func createBuyListViewController(
        hasCloseButton: Bool,
        title: String,
        showButtonsAndHeader: Bool
    ) -> BuyListViewController {
        let buyListViewController = BuyListViewController()
        container?.resolve(buyListViewController)
        if hasCloseButton {
            buyListViewController.addCloseButton { [weak buyListViewController] in
                buyListViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        buyListViewController.input = .init(
            showButtonsAndHeader: showButtonsAndHeader,
            title: title,
            insurances: { [weak self] in
                self?.insurancesProductCategoryService.getInsurancesProductList(
                    completion: { [weak self] result in
                        switch result {
                            case .success(let insuranceProductCategory):
                                self?.insuranceProductCategory = insuranceProductCategory
                                buyListViewController.notify.updateWithState(
                                    .filled(insuranceProductCategory)
                                )
                            case .failure:
                                buyListViewController.notify.updateWithState(.failure)
                        }
                    }
                )
            },
            filterCategoryInsurances: { [weak self] filterTitle in
                guard let self = self
                else { return [] }
                
                if let index = self.insuranceProductCategory.firstIndex(where: { $0.title == filterTitle }),
                   let insuranceProductCategoryId = self.insuranceProductCategory[safe: index]?.id {
                    return self.insurancesProductCategoryService.getFilterInsurancesProductList(
                        insuranceProductCategory: self.insuranceProductCategory,
                        insuranceProductCategoryId: insuranceProductCategoryId
                    )
                }
                else {
                    return []
                }
            }
        )
        buyListViewController.output = .init(
            goToChat: { [weak buyListViewController] in
                guard let viewController = buyListViewController
                else { return }
                
                self.openChatFullscreen(
                    from: viewController
                )
            },
            openChatTab: { [weak buyListViewController] in
                guard let buyListViewController
                else { return }
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            openOffices: { [weak self, weak buyListViewController] in
                guard let buyListViewController
                else { return }
                let officesFlow = OfficesFlow()
                self?.container?.resolve(officesFlow)
                officesFlow.start(from: buyListViewController)
            },
            pushToAboutInsuranceProduct: { [weak self] in
                guard let self
                else { return }
                
                self.presentAboutInsuranceProductViewController(insuranceProduct: $0)
            }
        )

        return buyListViewController
    }

    private func toBuyInsurance() {
        initialViewController.pushViewController(
            self.createBuyListViewController(
                hasCloseButton: true,
                title: NSLocalizedString("buy_insurance_title", comment: ""),
                showButtonsAndHeader: false
            ),
            animated: true
        )
        fromViewController?.navigationController?.present(initialViewController, animated: false)
    }
    
    private func presentAboutInsuranceProductViewController(
        insuranceProduct: InsuranceProduct
    ) {
        let aboutInsuranceProductViewController = AboutInsuranceProductViewController()
        container?.resolve(aboutInsuranceProductViewController)
        aboutInsuranceProductViewController.input = .init(
            insuranceProduct: insuranceProduct
        )
        aboutInsuranceProductViewController.output = .init(
            openUrl: { [weak initialViewController] url in
                guard let viewController = initialViewController?.topViewController
                else { return }
                
                WebViewer.openDocument(
                    url,
                    from: viewController
                )
            },
            onAction: { [weak initialViewController] action in
                guard let viewController = initialViewController?.topViewController as? ViewController
                else { return }
                
                self.action(
                    for: action,
                    from: viewController,
                    with: .push
                )
            }
        )
        
        aboutInsuranceProductViewController.hidesBottomBarWhenPushed = true
        
        initialViewController.pushViewController(
            aboutInsuranceProductViewController,
            animated: true
        )
    }
    
    private func openChatFullscreen(from: ViewController) {
        let chatFlow = ChatFlow()
        container?.resolve(chatFlow)
        chatFlow.show(from: from, mode: .fullscreen)
    }

    private func obtainBuyList(completion: @escaping (Result<[InsuranceProductCategory], AlfastrahError>) -> Void) {
        insurancesProductCategoryService.getInsurancesProductList(completion: completion)
    }
    
    private func action(
        for action: BackendAction,
        from: ViewController,
        with mode: ViewControllerShowMode = .modal
    ) {
        switch action.type {
            case .kaskoReport(insuranceId: let insuranceId, reportId: let reportId):
                opentEventReport(with: .kasko(String(reportId)), for: insuranceId)
                    
            case .osagoReport(insuranceId: let insuranceId, reportId: let reportId):
                opentEventReport(with: .osago(String(reportId)), for: insuranceId)
                    
            case .telemedicine(insuranceId: let insuranceId):
                showTelemedicine(insuranceId: insuranceId, from: from)
                    
            case .propertyProlongation(insuranceId: let insuranceId):
                openInsurance(with: insuranceId, from: from, mode: mode)
                    
            case .loyalty:
                openLoyalty()
                    
            case .onlineAppointment(insuranceId: let insuranceId, doctorVisitId: let doctorVisitId):
                openOnlineAppointment(with: insuranceId, for: doctorVisitId, from: from, mode: mode)
                    
            case .offlineAppointment(insuranceId: let insuranceId, appointmentId: let appointmentId):
                openOfflineAppointment(with: insuranceId, for: appointmentId, from: from, mode: mode)
                    
            case .insurance(id: let insuranceId):
                openInsurance(with: insuranceId, from: from, mode: mode)
                    
            case .path(url: let url, urlShareable: let urlShareable, openMethod: let method):
                openUrlPath(
                    url: url,
                    urlShareable: urlShareable,
                    openMethod: method,
                    from: from
                )
            case .clinicAppointment(insuranceId: let insuranceId):
                openClinics(with: insuranceId, from: from)
            
            case .doctorCall:
                return
                
            case .none:
                return
        }
    }


    private func opentEventReport(
        with reportId: InsuranceEventFlow.EventReportId,
        for insuranceId: String
    ) {
        getInsurance(insuranceId: insuranceId) { insurance in
            ApplicationFlow.shared.show(item: .eventReport(reportId, insurance))
        }
    }

    private func getInsurance(
        insuranceId: String,
        completion: @escaping (Insurance) -> Void
    ) {
        guard let controller = self.fromViewController
        else { return }
            
        let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        insurancesService.insurance(useCache: true, id: insuranceId) { result in
            hide(nil)
            switch result {
                case .success(let insurance):
                    completion(insurance)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func showTelemedicine(insuranceId: String, from controller: ViewController) {
        let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        insurancesService.telemedicineUrl(insuranceId: insuranceId) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func openInsurance(
        with insuranceId: String,
        from: ViewController,
        mode: ViewControllerShowMode
    ) {
        logger?.debug(insuranceId)
        
        let insurancesFlow = InsurancesFlow()
        container?.resolve(insurancesFlow)
        
        insurancesFlow.showInsurance(
            id: insuranceId,
            from: from,
            isModal: isModal(mode)
        )
    }
    
    private func openClinics(with insuranceId: String, from: ViewController) {
        logger?.debug(insuranceId)
        
        let flow = ClinicAppointmentFlow(rootController: from)
        self.container?.resolve(flow)
        flow.start(insuranceId: insuranceId, mode: .modal)
    }
    
    private func isModal(_ mode: ViewControllerShowMode) -> Bool {
        switch mode {
            case .modal:
                return true
            case .push:
                return false
        }
    }

    private func openLoyalty() {
        ApplicationFlow.shared.show(item: .alfaPoints)
    }

    private func openOnlineAppointment(
        with insuranceId: String,
        for doctorVisitId: Int,
        from: ViewController,
        mode: ViewControllerShowMode
    ) {
        logger?.debug(insuranceId)
            
        getInsurance(insuranceId: insuranceId) { [weak from] insurance in
            guard let from = from
            else { return }
                
            let flow = CommonClinicAppointmentFlow(rootController: from)
            self.container?.resolve(flow)
            flow.start(futureDoctorVisitId: String(doctorVisitId), insurance: insurance, mode: mode)
        }
    }

    private func openOfflineAppointment(
        with insuranceId: String,
        for appointmentId: Int,
        from: ViewController,
        mode: ViewControllerShowMode
    ) {
        getInsurance(insuranceId: insuranceId) { [weak from] insurance in
            guard let from = from
            else { return }

            let flow = ClinicAppointmentFlow(rootController: from)
            self.container?.resolve(flow)
            flow.start(appointmentId: String(appointmentId), insurance: insurance, mode: mode)
        }
    }

    private func openUrlPath(
        url: URL,
        urlShareable: URL?,
        openMethod: BackendAction.UrlOpenMethod,
        from: ViewController
    ) {
        logger?.debug(url.absoluteString)

        switch openMethod {
            case .external:
                SafariViewController.open(url, from: from)
            case .webview:
                WebViewer.openDocument(
                    url,
                    urlShareable: urlShareable,
                    from: from
                )
        }
    }
}
