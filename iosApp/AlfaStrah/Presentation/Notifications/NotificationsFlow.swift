//
// NotificationsFlow
// AlfaStrah
//
// Created by Eugene Egorov on 16 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class NotificationsFlow: BaseFlow,
                         NotificationsServiceDependency,
                         InsurancesServiceDependency,
						 AccountServiceDependency {
    var insurancesService: InsurancesService!
    var notificationsService: NotificationsService!
	var accountService: AccountService!

    private var notificationSubscriptions: Subscriptions<BackendNotification> = Subscriptions()

    func showList(mode: ViewControllerShowMode, animated: Bool = true) {
        logger?.debug("")
        
        createAndShowNavigationController(
            viewController: notificationsListViewController(mode: mode),
            mode: mode,
            animated: animated
        )
    }
	
    func showNotification(_ notification: AppNotification, mode: ViewControllerShowMode) {
        logger?.debug("")
        directAction(for: notification, mode: mode)
    }

    // MARK: - Actions
    private func notificationsListViewController(mode: ViewControllerShowMode) -> NotificationsListViewController {
        let viewController = NotificationsListViewController()
        container?.resolve(viewController)
        viewController.input = .init(
            notifications: backendNotifications,
            showActionButtonIsNeeded: showActionButtonIsNeeded,
            notificationsCounter: notificationsCounter
        )
        viewController.output = .init(
            showMore: { notification in
                self.showMoreInfo(notification: notification, mode: mode)
            },
            action: { [weak viewController] notification in
                guard let viewController = viewController
                else { return }
                
                self.action(for: notification, from: viewController, with: .push)
            },
            showSettings: {},
            setAllNotificationsAreRead: { [weak viewController] topNotificationId, completion in
                guard let viewController = viewController
                else { return }
                
                self.presentReadAllActionSheet(from: viewController) {
                    self.notificationsService.readAllBackendNotifications(topNotificationId: topNotificationId) { result in
                        switch result {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                                completion(.failure(error))
                        }
                    }
                }
            },
            turnOnNotifications: {},
            notificationRead: setRead
        )
        if mode == .modal {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
        notificationSubscriptions.add(viewController.notify.notification).disposed(by: viewController.disposeBag)
        return viewController
    }
    
    private func setRead(_ notification: BackendNotification, _ completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        if notification.status == .unread {
            self.notificationsService.readBackendNotifications(with: [notification.id]) { result in
                completion(result)
                switch result {
                    case .success:
                        break
                    case .failure(let error):
                        ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                }
            }
        }
    }

    private func notificationsCounter(completion: @escaping (Int?) -> Void) {
        notificationsService.unreadNotificationsCounter { result in
            switch result {
                case .success(let unreadCount):
                    completion(unreadCount)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func presentReadAllActionSheet(from: ViewController, completion: @escaping () -> Void) {
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let readAllAction = UIAlertAction(
            title: NSLocalizedString("notifications_read_all_button_title", comment: ""),
            style: .default
        ) { _ in
            completion()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        
        actionSheet.addAction(readAllAction)
        actionSheet.addAction(cancelAction)
        
        actionSheet.actions.forEach { $0.setValue(Style.Color.Palette.black, forKey: "titleTextColor") }
                
        from.present(actionSheet, animated: true)
    }
    
    private func showMoreInfo(notification: BackendNotification, mode: ViewControllerShowMode) {
        let viewController = BackendNotificationInfoViewController()
        container?.resolve(viewController)
        viewController.input = .init(
            notification: notification,
            showActionButtonIsNeeded: showActionButtonIsNeeded
        )
        viewController.output = .init(
            action: { [weak viewController] notification in
                guard let viewContoller = viewController
                else { return }
                
                self.setRead(notification) { _ in }
                self.action(for: notification, from: viewContoller)
            }
        )
        if mode == .modal {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
        createAndShowNavigationController(viewController: viewController, mode: mode)
    }
    
    private func action(for notification: BackendNotification, from: ViewController, with mode: ViewControllerShowMode = .modal) {
        guard let action = notification.action
        else { return }
        
        switch action.type {
            case .kaskoReport(insuranceId: let insuranceId, reportId: let reportId):
                opentEventReport(with: .kasko(String(reportId)), for: insuranceId)
                
            case .osagoReport(insuranceId: let insuranceId, reportId: let reportId):
                opentEventReport(with: .osago(String(reportId)), for: insuranceId)
                
            case .telemedicine(insuranceId: let insuranceId):
                openTelemedicine(with: insuranceId, for: notification.id, from: from)
                
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
                
            case .path(url: let url, _, openMethod: let method):
                openUrlPath(url: url, openMethod: method, from: from)
                
            case .clinicAppointment(insuranceId: let insuranceId):
                openClinics(with: insuranceId, from: from)
            
            case .doctorCall, .none:
                return
        }
    }
    
    // MARK: - Notification actions handlers
    private func openInsurance(with insuranceId: String, from: ViewController, mode: ViewControllerShowMode) {
        logger?.debug(insuranceId)

        let insurancesFlow = InsurancesFlow()
        container?.resolve(insurancesFlow)
        
		if let analyticsData = analyticsData(
			from: insurancesService.cachedShortInsurances(forced: true),
			for: insuranceId
		) {
			analytics.track(
				navigationSource: .notifications,
				insuranceId: insuranceId,
				isAuthorized: accountService.isAuthorized,
				event: AnalyticsEvent.Dms.details,
				userProfileProperties: analyticsData.analyticsUserProfileProperties
			)
		}
		
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
    
    private func openPropertyRenewFlow(with insuranceId: String, from: ViewController) {
        logger?.debug(insuranceId)
        
        let insurancesFlow = InsurancesFlow()
        container?.resolve(insurancesFlow)
        
        getInsurance(insuranceId: insuranceId) { [weak from] insurance in
            guard let from = from
            else { return }
            
            insurancesFlow.renewRemontNeighbours(insurance, from: from)
        }
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
    
    private func openLoyalty() {
        ApplicationFlow.shared.show(item: .alfaPoints)
    }
    
    private func opentEventReport(with reportId: InsuranceEventFlow.EventReportId, for insuranceId: String) {
        getInsurance(insuranceId: insuranceId) { insurance in
            ApplicationFlow.shared.show(item: .eventReport(reportId, insurance))
        }
    }
    
    private func openUrlPath(url: URL, openMethod: BackendAction.UrlOpenMethod, from: ViewController) {
        logger?.debug(url.absoluteString)

        switch openMethod {
            case .external:
                SafariViewController.open(url, from: from)
            case .webview:
                WebViewer.openDocument(url, from: from)
        }
    }
    
    private func openTelemedicine(
        with insuranceId: String,
        for notificationId: Int,
        from: ViewController
    ) {
        let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        insurancesService.telemedicineUrl(
            notificationId: String(notificationId),
            insuranceId: insuranceId
        ) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func isModal(_ mode: ViewControllerShowMode) -> Bool {
        switch mode {
            case .modal:
                return true
            case .push:
                return false
        }
    }
    
    private func showMoreInfo(notification: AppNotification, mode: ViewControllerShowMode) {
        let controller = NotificationInfoViewController()
        container?.resolve(controller)
        controller.input = .init(
            notification: notification,
            insurance: insurance(id: notification.insuranceId)
        )
        controller.output = .init(
            action: { [weak controller] notification in
                guard let controller = controller else { return }

                switch notification.type {
                    case .unsupported:
                        break
                    case .newsNotification:
                        switch notification.target {
                            case .alfaPoints:
                                ApplicationFlow.shared.show(item: .alfaPoints)
                            case .externalUrl:
                                guard let urlString = notification.url,
                                      let url = URL(string: urlString)
                                else { return }

                                self.openUrl(url)
                            case .mainScreen, .insurancesList, .telemedecide, .kaskoProlongation, .unsupported:
                                break

                        }
                    case .fieldList, .kaskoLoadMorePhoto, .message, .offlineAppointment, .onlineAppointment, .osagoRenew,
                             .realtyRenew, .stoa, .telemedicineCall, .telemedicineNewMessage, .telemedicineSoon,
                             .telemedicineСonclusion:
                        self.openInsurance(with: notification.insuranceId, from: controller, mode: mode)
                }
            }
        )
        if mode == .modal {
            controller.addCloseButton { [weak controller] in
                controller?.dismiss(animated: true, completion: nil)
            }
        }
        createAndShowNavigationController(viewController: controller, mode: mode)
    }
        
    private func directAction(for notification: AppNotification, mode: ViewControllerShowMode) {
        switch notification.type {
            case .unsupported:
                break
            case .osagoRenew:
                let flow = OSAGORenewFlow(rootController: topModalController)
                container?.resolve(flow)
                flow.start(insuranceId: notification.insuranceId)
            case .offlineAppointment:
                guard let appointmentId = notification.offlineAppointmentId
                else { return }

                getInsurance(insuranceId: notification.insuranceId) { insurance in
                    let flow = ClinicAppointmentFlow(rootController: self.topModalController)
                    self.container?.resolve(flow)
                    flow.start(appointmentId: appointmentId, insurance: insurance, mode: mode)
                }
            case .onlineAppointment:
                guard let appointmentId = notification.onlineAppointmentId
                else { return }

                getInsurance(insuranceId: notification.insuranceId) { insurance in
                    let flow = CommonClinicAppointmentFlow(rootController: self.topModalController)
                    self.container?.resolve(flow)
                    flow.start(futureDoctorVisitId: appointmentId, insurance: insurance, mode: mode)
                }
            case .message, .fieldList, .stoa, .newsNotification, .realtyRenew:
                break
            case .kaskoLoadMorePhoto:
                break
            case .telemedicineСonclusion, .telemedicineSoon, .telemedicineNewMessage, .telemedicineCall:
                guard let controller = navigationController ?? fromViewController
                else { return }

                let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                insurancesService.telemedicineUrl(notificationId: notification.id, insuranceId: nil) { result in
                    hide(nil)
                    switch result {
                        case .success(let url):
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
        }
    }

    private func openUrl(_ url: URL) {
        logger?.debug(url.absoluteString)

        ApplicationFlow.shared.hideAllModalViewControllers(animated: true) {
            SafariViewController.open(url, from: self.topModalController)
        }
    }

    private func getInsurance(insuranceId: String, completion: @escaping (Insurance) -> Void) {
        guard let controller = self.navigationController ?? self.fromViewController else { return }
        
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
        
    private func insurance(id: String) -> Insurance? {
        insurancesService.cachedInsurance(id: id)
    }
    
    private func showActionButtonIsNeeded(_ notification: BackendNotification) -> Bool {
        if let action = notification.action {
            switch action.type {
                case .insurance(id: let insuranceId),
                    .offlineAppointment(insuranceId: let insuranceId, _),
                    .onlineAppointment(insuranceId: let insuranceId, _),
                    .osagoReport(insuranceId: let insuranceId, _),
                    .kaskoReport(insuranceId: let insuranceId, _),
                    .clinicAppointment(insuranceId: let insuranceId):
                    
                    return insurancesService.cachedInsurance(id: insuranceId) != nil
                    
                case .telemedicine(insuranceId: let insuranceId):
                    if let insurance = insurancesService.cachedInsurance(id: insuranceId) {
                        return insurance.telemedicine
                    } else {
                        return false
                    }
                    
                case .propertyProlongation(insuranceId: let insuranceId):
                    if let insurance = insurancesService.cachedInsurance(id: insuranceId) {
                        return insurance.renewAvailable ?? false
                    } else {
                        return false
                    }
                    
                case .path, .loyalty:
                    return true
                    
                case .doctorCall, .none:
                    return false
                    
            }
        } else {
            return false
        }
    }

    // MARK: - Data
    private func backendNotifications(
        _ fromId: Int?,
        _ count: Int,
        completion: @escaping (Result<BackendNotificationsResponse, AlfastrahError>) -> Void
    ) {
        notificationsService.backendNotifications(fromId: fromId, count: count, completion: completion)
    }
    
    private func notifications(offset: Int, limit: Int?, completion: @escaping (Result<[AppNotification], AlfastrahError>) -> Void) {
        notificationsService.all(offset: offset, limit: limit, completion: completion)
    }
}
