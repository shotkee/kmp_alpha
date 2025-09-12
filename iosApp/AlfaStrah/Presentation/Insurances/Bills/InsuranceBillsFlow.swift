//
//  InsuranceBillsFlow.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length

class InsuranceBillsFlow: BaseFlow,
						  InsuranceBillPaymentServiceDependency,
						  AccountServiceDependency,
						  InsurancesServiceDependency {
    var insuranceBillPaymentService: InsuranceBillPaymentService!
    var accountService: AccountService!
    var insurancesService: InsurancesService!
    
    private lazy var billPersonalInfoUpdatedSubscriptions: Subscriptions<BillPersonalInfo> = Subscriptions()
    
    private let storyboard = UIStoryboard(name: "InsuranceBills", bundle: nil)

    private var insurance: Insurance!
    
    private struct BillPersonalInfo {
        var phone: Phone?
        var email: String?
        
        var isFilled: Bool {
            let values: [Any?] = [
                phone,
                email
            ]
            return !values.contains { $0 == nil }
        }
    }
    
    private var billPersonalInfo: BillPersonalInfo = .init() {
        didSet {
            billPersonalInfoUpdatedSubscriptions.fire(billPersonalInfo)
        }
    }

    func showBills(
        insurance: Insurance,
        from: UIViewController
    ) {
        let hide = from.showLoadingIndicator(message: nil)
        accountService.getAccount(useCache: true) { result in
            hide(nil)
            switch result {
                case .success(let account):
                    self.insurance = insurance
                    self.billPersonalInfo = .init(phone: account.phone, email: account.email)
                    
                    let viewController = self.createInsuranceBillsViewController()
					
					if let navigationController = from.navigationController {
						viewController.hidesBottomBarWhenPushed = true
						navigationController.pushViewController(viewController, animated: true)
					} else {
						viewController.addCloseButton {
							viewController.dismiss(animated: true)
						}
						
						let navigationController = RMRNavigationController()
						navigationController.strongDelegate = RMRNavigationControllerDelegate()
						
						navigationController.setViewControllers([ viewController ], animated: true)
						from.present(navigationController, animated: true, completion: nil)
					}
					
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
					
            }
        }
    }
	
	private var billsIsLoading = false
	
	func showInsuranceBill(_ insuranceId: String, _ billId: Int, from: ViewController) {
		let hide = from.showLoadingIndicator(message: nil)
		
		func billPayment() {
			self.insuranceBillPaymentService.bill(insuranceId: insuranceId, billId: billId) { [weak from] result in
				hide(nil)
				
				guard let from
				else { return }
				
				switch result {
					case .success(let bill):
						self.showInsuranceBillScreen(insuranceBill: bill, from: from)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
		
		if self.insurance == nil {
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				switch result {
					case .success(let insurance):
						self.insurance = insurance
						billPayment()
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		} else {
			billPayment()
		}
	}
	
	func showPaymentBills(for insurance: Insurance, with billIds: [Int], from: ViewController) {
		let bills = insurance.bills.filter { billIds.contains($0.id) }
		
		let viewController = self.createInsuranceBillPersonalInfoViewController(insuranceBills: bills)
		
		if let navigationController = from.navigationController {
			navigationController.pushViewController(viewController, animated: true)
		} else {
			viewController.addCloseButton {
				viewController.dismiss(animated: true)
			}
			
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			navigationController.setViewControllers([ viewController ], animated: true)
			from.present(navigationController, animated: true, completion: nil)
		}
	}
    
    private func createInsuranceBillsViewController() -> InsuranceBillsViewController {
        let viewController: InsuranceBillsViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            insurance: insurance
        )
        
        viewController.output = .init(
            onInsuranceBillTapped: { [weak viewController] insuranceBill in
                guard let viewController = viewController
                else { return }
                
                let hide = viewController.showLoadingIndicator(message: nil)
                
                self.insuranceBillPaymentService.bill(insuranceId: self.insurance.id, billId: insuranceBill.id) { result in
                    hide(nil)
                    switch result {
                        case .success(let bill):
                            self.showInsuranceBillScreen(insuranceBill: bill, from: viewController)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            },
            payOffSelectedBills: { insuranceBills in
                let viewController = self.createInsuranceBillPersonalInfoViewController(insuranceBills: insuranceBills)
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            },
            updateBills: { [weak viewController] in
                guard let viewController = viewController
                else { return }
				if !self.billsIsLoading {
					let hide = viewController.showLoadingIndicator(message: nil)
                    self.billsIsLoading = true
					
					let addRightButton: () -> Void = {
						if !self.insurance.bills.isEmpty {
							viewController.addRightButton(
								title: NSLocalizedString("insurance_select_bills", comment: "")
							) { [weak viewController] in
								viewController?.toggleSelectionMode()
							}
						}
					}
					
					self.insurancesService.insurance(useCache: false, id: self.insurance.id) { result in
						hide(addRightButton)
						self.billsIsLoading = false
						switch result {
							case .success(let insurance):
								self.insurance = insurance
								viewController.notify.insuranceUpdated(insurance)
							case .failure(let error):
								ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						}
					}
				}
			}
        )
		
        insurancesService.subscribeForSingleInsuranceUpdate(
            listener: viewController.notify.insuranceUpdated
        ).disposed(by: viewController.disposeBag)
        
        return viewController
    }

    private func showInsuranceBillScreen(insuranceBill: InsuranceBill, from: UIViewController) {
        let viewController: InsuranceBillViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            insuranceBill: insuranceBill
        )
        viewController.output = .init(
            payOffInsuranceBill: {
                let viewController = self.createInsuranceBillPersonalInfoViewController(insuranceBills: [insuranceBill])
                
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            },
            submitDisagreement: { [weak viewController] in
                guard let controller = viewController
                else { return }
                
                let disagreementWithServicesFlow = DisagreementWithServicesFlow(rootController: controller)
                disagreementWithServicesFlow.navigationController = controller.navigationController
                self.container?.resolve(disagreementWithServicesFlow)
                
                disagreementWithServicesFlow.showSubmitDisagreement(
                    insuranceId: self.insurance.id,
                    insuranceBillId: insuranceBill.id
                )
				
				if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: self.insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.billsList,
						insuranceId: self.insurance.id,
						event: AnalyticsEvent.Dms.disagreement,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            updateBillInfo: { [weak viewController] in
                self.insuranceBillPaymentService.bill(insuranceId: self.insurance.id, billId: insuranceBill.id) { result in
                    switch result {
                        case .success(let bill):
                            if insuranceBill != bill {
                                viewController?.notify.insuranceBillUpdated(bill)
                            }
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
        )
        
        insurancesService.subscribeForSingleInsuranceUpdate(
            listener: { [weak viewController] insurance in
                if let updatedInsuranceBill = insurance.bills
                        .first(where: { $0.id == insuranceBill.id }) {
                    viewController?.notify.insuranceBillUpdated(updatedInsuranceBill)
                }
            }
        ).disposed(by: viewController.disposeBag)
		
		viewController.hidesBottomBarWhenPushed = true
        
        from.navigationController?.pushViewController(viewController, animated: true)
    }

    private func getPaymentLink(viewController: UIViewController, insuranceBills: [InsuranceBill]) {
        guard accountService.isAuthorized,
              let email = billPersonalInfo.email,
              let phone = billPersonalInfo.phone?.plain
        else { return }

        let hide = viewController.showLoadingIndicator(message: nil)
        
        self.insuranceBillPaymentService.paymentUrl(
            insuranceId: self.insurance.id,
            insuranceBillIds: insuranceBills.map { $0.id },
            email: email,
            phone: phone
        ) { [weak viewController] result in
            hide(nil)
            
            guard let fromVC = viewController
            else { return }

            switch result {
                case .success(let response):
                    self.showPaymentScreen(paymentPageInfo: response, from: fromVC) {
                        guard let navigationController = self.navigationController
                        else { return }
                                                
                        // pop to InsuranceBillViewController if single bill was payed
                        // or to InsuranceBillsViewController multiple bills were payed
                        let targetControllerType = insuranceBills.count == 1
                            ? InsuranceBillViewController.self
                            : InsuranceBillsViewController.self
                        
                        let targetController = navigationController.viewControllers
                            .first(where: { $0.isKind(of: targetControllerType) })
                        
                        if let targetController = targetController {
                            navigationController.popToViewController(
                                targetController,
                                animated: false
                            )
                        }
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func showPaymentScreen(
        paymentPageInfo: InsuranceBillPaymentPageInfo,
        from: UIViewController,
        _ completion: @escaping () -> Void
    ) {
        let viewController = InsuranceBillPaymentViewController()
        viewController.input = .init(
            paymentPageInfo: paymentPageInfo
        )
        viewController.output = .init(
            onSuccess: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.insurancesService.updateInsurance(id: self.insurance.id)
                
                self.showPaymentResultScreen(successful: true, from: viewController)
            },
            onFailure: { [weak viewController] in
                guard let viewController = viewController
                else { return }

                self.showPaymentResultScreen(successful: false, from: viewController)
            },
            onExternalRedirect: { success in
                if success {
                    completion()
                }
            }
        )
        from.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showPaymentResultScreen(successful: Bool, from: InsuranceBillPaymentViewController) {
        let navigationController = from.navigationController

        let operationView = OperationStatusView()
        operationView.notify.updateState(
            .info(
                successful
                    ? .init(
                        title: NSLocalizedString("insurance_bill_payment_success_title", comment: ""),
                        description: NSLocalizedString("insurance_bill_payment_success_description", comment: ""),
                        icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
                    )
                    : .init(
                        title: NSLocalizedString("insurance_bill_payment_failure_title", comment: ""),
                        description: NSLocalizedString("insurance_bill_payment_failure_description", comment: ""),
                        icon: UIImage(named: "icon-common-failure")
                    )
            )
        )
        operationView.notify.buttonConfiguration([
            .init(
                title: NSLocalizedString("common_to_main_screen", comment: ""),
                style: Style.RoundedButton.redTitle,
                action: {
                    ApplicationFlow.shared.show(item: .tabBar(.home))
                }
            ),
            .init(
                title: NSLocalizedString("common_done_button", comment: ""),
                style: Style.RoundedButton.oldPrimaryButtonSmall,
                action: { [weak navigationController] in
                    navigationController?.popToRootViewController(animated: true)
                }
            )
        ])

        let viewController = UIViewController()
        viewController.view.addSubview(operationView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationView, in: viewController.view))

        viewController.title = NSLocalizedString("insurance_bill_payment", comment: "")

        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeAll { $0 === from }
        viewControllers?.append(viewController)
        navigationController?.setViewControllers(viewControllers ?? [], animated: true)
    }
    
    private func createInsuranceBillPersonalInfoViewController(insuranceBills: [InsuranceBill]) -> InsuranceBillPersonalInfoViewController{
        let viewController: InsuranceBillPersonalInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            payButtonEnabled: billPersonalInfo.isFilled,
            phone: billPersonalInfo.phone?.humanReadable ?? "",
            email: billPersonalInfo.email ?? ""
        )
        
        viewController.output = .init(
            pay: { [weak viewController] in
                guard let viewController = viewController
                else { return }

                self.getPaymentLink(viewController: viewController, insuranceBills: insuranceBills)
            },
            emailInput: {
                self.openEmailInputBottomViewController(
                    from: viewController,
                    initialEmailText: self.billPersonalInfo.email ?? "",
                    completion: { email in
                        self.billPersonalInfo.email = email
                    }
                )
            },
            phoneInput: {
                self.openPhoneInputBottomViewController(
                    from: viewController,
                    initialPhoneText: self.billPersonalInfo.phone?.humanReadable ?? "",
                    completion: { phone in
                        self.billPersonalInfo.phone = phone
                    }
                )
            }
        )
        
        billPersonalInfoUpdatedSubscriptions
            .add { [weak viewController] billPersonalInfo in
                viewController?.notify.updateWith(billPersonalInfo.phone, billPersonalInfo.email)
                viewController?.notify.payButtonEnabled(billPersonalInfo.isFilled)
            }
            .disposed(by: viewController.disposeBag)
                
        return viewController
    }
    
    private func openEmailInputBottomViewController(
        from: UIViewController,
        initialEmailText: String,
        completion: @escaping (String) -> Void
    ) {
        let controller = EmailInputBottomViewController()
        
        controller.input = .init(
            title: NSLocalizedString("insurance_bill_email", comment: ""),
            placeholder: NSLocalizedString("insurance_bill_email_prompt", comment: ""),
            initialEmailText: initialEmailText
        )
        
        controller.output = .init(
            completion: { [weak from] email in
                completion(email)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openPhoneInputBottomViewController(
        from: UIViewController,
        initialPhoneText: String,
        completion: @escaping (Phone) -> Void
    ) {
        let controller = PhoneInputBottomViewController()

        controller.input = .init(
            title: NSLocalizedString("insurance_bill_phone_number", comment: ""),
            placeholder: NSLocalizedString("insurance_bill_phone_number_prompt", comment: ""),
            initialPhoneText: initialPhoneText
        )
        controller.output = .init(completion: { [weak from] plain, humanReadable in
            let phone = Phone(plain: plain, humanReadable: humanReadable)
            completion(phone)
            from?.dismiss(animated: true, completion: nil)
        })

        from.showBottomSheet(contentViewController: controller)
    }
}
