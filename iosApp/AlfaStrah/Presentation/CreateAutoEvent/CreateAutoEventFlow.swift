//
//  CreateAutoEvent
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 22.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class CreateAutoEventFlow: InsurancesServiceDependency,
						   AlertPresenterDependency,
						   AccountServiceDependency,
						   DependencyContainerDependency,
						   GeolocationServiceDependency,
						   LoggerDependency,
						   EventReportServiceDependency,
						   AttachmentServiceDependency,
						   GeocodeServiceDependency,
						   EventReportLoggerDependency,
						   AnalyticsServiceDependency {
    var geocodeService: GeocodeService!
    var insurancesService: InsurancesService!
    var eventReportService: EventReportService!
    var attachmentService: AttachmentService!
    var eventReportLogger: EventReportLoggerService!
    var alertPresenter: AlertPresenter!
    var accountService: AccountService!
    var geoLocationService: GeoLocationService!
    var analytics: AnalyticsService!
    var container: DependencyInjectionContainer?
    var logger: TaggedLogger?

    private lazy var photoSelectionBehavior = DocumentPickerBehavior()
    private let storyboard = UIStoryboard(name: "CreateAutoEvent", bundle: nil)
	private var insurance: Insurance?
    private var photosUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private weak var navigationController: UINavigationController?

    func start(with insurance: Insurance, from: UIViewController, draft: AutoEventDraft?) {
        self.insurance = insurance
		
		guard let navigationController = (from as? UINavigationController) ?? from.navigationController else {
			let reason = "Expected to start from a view controller inside a UINavigationController stack or from UINavigationController"
			fatalError("\(type(of: self)).\(#function) -> " + reason)
		}

		self.navigationController = navigationController
		
		if let caseType = draft?.caseType {
			showCreateAutoEventViewController(caseType: caseType, draft: draft)
		} else {
			self.navigationController?.pushViewController(selectTypeViewController(for: insurance, draft: draft), animated: true)
		}
		
		setupLocationServices()
    }
	
	func start(with insuranceId: String, from: UIViewController, draft: AutoEventDraft?) {
		guard let insurance = insurancesService.cachedInsurance(id: insuranceId)
		else {
			alertPresenter.show(alert: ErrorNotificationAlert(text: NSLocalizedString("insurance_not_found", comment: "")))
			return
		}

		self.insurance = insurance
		
		start(with: insurance, from: from, draft: draft)
    }
	
	private func selectTypeViewController(for insurance: Insurance, draft: AutoEventDraft?) -> AutoEventSelectTypeViewController {
        let controller: AutoEventSelectTypeViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.title = NSLocalizedString("insurance_event_type_title", comment: "")
        controller.input = .init(
			isDemo: self.accountService.isDemo,
			insurance: insurance
		)
        controller.output = .init(
            select: { [weak controller] type in
                guard let viewController = controller else { return }

                self.userDidSelect(
                    caseType: type,
                    draft: draft,
                    fromViewController: viewController
                )
            },
			selectOffices: selectOfficesForInsuranceKind,
			demo: { [weak controller]  in
				guard let controller
				else { return }
				
				DemoBottomSheet.presentInfoDemoSheet(from: controller)
			}
        )
        return controller
    }

    private func selectOfficesForInsuranceKind(_ insuranceKind: Insurance.Kind) {
		guard let navigationController
		else { return }
		
        let officesFlow = OfficesFlow()
        container?.resolve(officesFlow)
        officesFlow.start(from: navigationController, with: insuranceKind)
    }

    private func userDidSelect(caseType: AutoEventCaseType, draft: AutoEventDraft?, fromViewController: UIViewController) {
		guard let insurance
		else { return }
		
        switch caseType {
            case .competentAuthoritiesInvolved:
                showCreateAutoEventViewController(caseType: caseType, draft: draft)
            case .executedByTrafficAccidentParticipants:
                switch insurance.type {
                    case .osago:
                        let hide = fromViewController.showLoadingIndicator(
                            message: NSLocalizedString("insurance_euro_protocol_loader_wait_title", comment: "")
                        )
                        eventReportService.checkEuroProtocolAvailability { result in
                            hide { }
                            switch result {
                                case .success(let available):
                                    self.openViewController(if: available, caseType: caseType, draft: draft)

                                case .failure(let error):
                                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                            }
                        }
                    default:
                        showCreateAutoEventViewController(caseType: caseType, draft: draft)
                }
            default:
                break
        }
    }

    private func showRegistrationAccidentViewController(caseType: AutoEventCaseType, draft: AutoEventDraft?) {
        let viewController = AutoEventRegistrationAccidentViewController()
        container?.resolve(viewController)

        viewController.output = .init(
            drawUpEuroProtocolTap: { [weak viewController] in
                guard let fromViewController = viewController,
					  let insurance = self.insurance
				else { return }

                let flow = EuroProtocolEventFlow(rootController: fromViewController) {
                    self.navigationController?.popToViewController(fromViewController, animated: false)
                    self.showCreateAutoEventViewController(caseType: caseType, draft: draft)
                }
                self.container?.resolve(flow)
                flow.start(insuranceId: insurance.id)
            },
            paperEuroProtocolTap: {
                self.showCreateAutoEventViewController(caseType: caseType, draft: draft)
            }
        )

        navigationController?.pushViewController(viewController, animated: true)
    }
			
	func showEuroProtocol(with insuranceId: String, from: ViewController, draft: AutoEventDraft?, isModal: Bool = false) {
		let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
		
		insurancesService.insurance(useCache: true, id: insuranceId) { result in
			hide(nil)
			switch result {
				case .success(let insurance):
					self.insurance = insurance
					
					let flow = EuroProtocolEventFlow(rootController: from) {
						from.dismiss(animated: true) {
							self.showCreateAutoEventViewController(
								caseType: .executedByTrafficAccidentParticipants,
								draft: draft,
								isModal: isModal,
								from: from
							)
						}
					}
					
					self.container?.resolve(flow)
					flow.start(insuranceId: insuranceId, isModal: isModal)
					
				case .failure(let error):
					self.alertPresenter.show(alert: ErrorNotificationAlert(text: NSLocalizedString("insurance_not_found", comment: "")))
					
			}
		}
		
	}

	private func showCreateAutoEventViewController(
		caseType: AutoEventCaseType,
		draft: AutoEventDraft?,
		isModal: Bool = false,
		from: ViewController? = nil
	) {
		guard let insurance = self.insurance
		else { return }
		
        let viewController: CreateAutoEventViewController = storyboard.instantiate()
        container?.resolve(viewController)
        let photoGroups = caseType.photoGroupsPreset
        viewController.input = .init(
            photoGroups: photoGroups,
            insurance: insurance,
			draft: draft,
			caseType: caseType,
            isDemo: accountService.isDemo,
            locationInfo: {
                LocationInfo(
                    position: self.selectedPosition,
                    address: self.selectedPlace?.fullTitle,
                    place: self.selectedPlace
                )
            }
        )

        viewController.output = .init(
            loadLocation: { point in
                self.selectedPosition = point
                self.reverseGeocodeSelectedPosition()
            },
            pickLocation: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showLocationPicker(from: controller)
            },
            inputTextAddress: { [weak viewController] currentAddress, completion in
                guard let viewController = viewController else { return }

                self.showTextAddressInput(from: viewController, currentAddress: currentAddress) { place in
                    viewController.dismiss(animated: true) {
                        completion(place.fullTitle)
                    }
                }
            },
            saveDraft: { draft in
                self.eventReportService.saveAutoEventDraft(draft)
                self.alertPresenter.show(alert: BasicNotificationAlert(text: NSLocalizedString("osago_create_draft_saved", comment: "")))
            },
            createEvent: { event, isDraft, completion in
				guard let insurance = self.insurance
				else { return }
				
                let completion: (Result<String, AlfastrahError>) -> Void = { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                        case .success(let eventId):
                            self.eventReportLogger.addLog(
                                "Insurance event created (id = \(eventId). " +
                                "Photos (count = \(event.documentCount)) will be converted to attachments and send on server",
                                eventReportId: eventId
                            )
                            self.analytics.track(
                                event: AnalyticsEvent.Auto.reportAutoDone,
                                properties: [ AnalyticsParam.Auto.sentFromDraft: AnalyticsParam.string(isDraft) ]
                            )
                            self.preparePhotosForSend(for: photoGroups, eventId: eventId)
                            let eventReportId: InsuranceEventFlow.EventReportId?
							
                            switch insurance.type {
                                case .passengers:
                                    eventReportId = .passengers(eventId)
                                case .kasko:
                                    eventReportId = .kasko(eventId)
                                case .osago:
                                    eventReportId = .osago(eventId)
                                case .accident, .dms, .life, .property, .unknown, .vzr, .vzrOnOff, .flatOnOff:
                                    eventReportId = nil
                            }
							
                            eventReportId.map { self.showAttachmentsUpload(eventReportId: $0) }

                            // Delete draft
                            draft.map { self.eventReportService.deleteAutoEventDraft($0) }
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                    completion()
                }

                switch insurance.type {
                    case .kasko:
                        self.eventReportService.createKaskoEvent(event, completion: completion)
                    case .osago:
                        self.eventReportService.createOsagoEvent(event, completion: completion)
                    case .accident, .dms, .life, .passengers, .property, .vzr, .vzrOnOff, .flatOnOff, .unknown:
                        break
                }
            },
            photoGroup: { photoGroup in
                switch photoGroup.type {
                    case .place, .plan, .vin, .docs:
                        self.showPhotoSteps(photoGroup)
                    case .damage:
                        self.showDamagePhotoSteps(photoGroup)
                }
            },
            goBack: {
				if isModal {
					from?.dismiss(animated: true)
				} else {
					self.navigationController?.popViewController(animated: true)
				}
            }
        )
        locationUpdatedSubscriptions.add(viewController.notify.locationUpdated).disposed(by: viewController.disposeBag)
		
		if let navigationController, !isModal {
			navigationController.pushViewController(viewController, animated: true)
		} else {
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			navigationController.setViewControllers([ viewController ], animated: true)
			from?.present(navigationController, animated: true, completion: nil)
		}
		
        geoLocationService.requestAvailability(always: false)
    }

    private func showTextAddressInput(
		from: CreateAutoEventViewController,
		currentAddress: String?,
		_ completion: @escaping (GeoPlace) -> Void
	) {
        let controller: AddressInputViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(
			isDemo: accountService.isDemo,
            scenario: .autoEvent,
            currentAddress: currentAddress
        )
        controller.output = .init(
            enterAddress: geocodeService.searchLocation,
            selectAddress: { [weak from] place in
                self.geocodeService.geocode(place) { result in
                    switch result {
                        case .success(let coordinate):
                            self.selectedPosition = coordinate
                            self.locationUpdatedSubscriptions.fire(())
                        case .failure(let error):
                            from?.processError(error)
                    }
                }
                completion(place)
            },
            showMap: { [weak controller] in
                guard let controller = controller else { return }

                self.showLocationPicker(from: controller, modally: false)
            },
            saveAddress: { address in
				from.dismiss(
					animated: true,
					completion: {
						from.updateLocationView(text: address)
					}
				)
			}
        )
		
        controller.addCloseButton {
            from.dismiss(animated: true)
        }
        let navigationController = RMRNavigationController(rootViewController: controller)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        from.present(navigationController, animated: true)
    }

    private func showPhotoSteps(_ group: PhotoGroup) {
        let viewController: AutoEventPhotoStepsListViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(photoGroup: group)
        viewController.output = .init(
            // Important to capture weak self to avoid memory leak.
            addPhoto: { [weak viewController, weak self] step in
                guard let controller = viewController, let self = self else { return }

                if !step.attachments.isEmpty {
                    self.showGallery(step: step, group: group, from: controller)
                } else {
                    self.pickPhotos(to: step, group: group, from: controller) { [weak controller, weak self] in
                        guard let controller = controller, let self = self, !step.attachments.isEmpty else { return }

                        self.showGallery(step: step, group: group, from: controller)
                    }
                }
            },
            goBack: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        photosUpdatedSubscriptions.add(viewController.notify.photosUpdated).disposed(by: viewController.disposeBag)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showDamagePhotoSteps(_ group: PhotoGroup) {
        let viewController: AutoEventPhotoDamagePickerViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(photoGroup: group)
        viewController.output = .init(
            // Important to capture weak self to avoid memory leak.
            addPhoto: { [weak viewController, weak self] step in
                guard let controller = viewController, let self = self else { return }

                if !step.attachments.isEmpty {
                    self.showGallery(step: step, group: group, from: controller)
                } else {
                    self.pickPhotos(to: step, group: group, from: controller) { [weak controller, weak self] in
                        guard let controller = controller, let self = self, !step.attachments.isEmpty else { return }

                        self.showGallery(step: step, group: group, from: controller)
                    }
                }
            },
            goBack: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        photosUpdatedSubscriptions.add(viewController.notify.photosUpdated).disposed(by: viewController.disposeBag)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showGallery(step: AutoPhotoStep, group: PhotoGroup, from: UIViewController) {
        let viewController: DocumentInputBottomViewController = .init()
        container?.resolve(viewController)

        let actionSheetViewController = ActionSheetViewController(with: viewController)

        viewController.input = .init(
            title: NSLocalizedString("common_documents_title", comment: ""),
            description: NSLocalizedString("common_photos_sub_title", comment: ""),
            step: step
        )
        viewController.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            done: { [weak from] in
                from?.dismiss(animated: true)
            },
            delete: { photoAttachment in
                let ids = photoAttachment.map { $0.id }
                step.attachments.removeAll { ids.contains($0.id) }
                photoAttachment.forEach { self.attachmentService.delete(attachment: $0) }
                self.photosUpdatedSubscriptions.fire(())
            },
            pickFile: { [weak actionSheetViewController] in
                guard let controller = actionSheetViewController else { return }

                self.pickPhotos(to: step, group: group, from: controller) {}
            },
            showPhoto: { [weak actionSheetViewController] showPhotoController, animated, completion in
                guard let controller = actionSheetViewController else { return }

                controller.present(
                    showPhotoController,
                    animated: animated,
                    completion: completion
                )
            },
            openDocument: { [weak viewController] attachment in
                guard let controller = viewController else { return }

                LocalDocumentViewer.open(attachment.url, from: controller)
            }
        )

        from.present(actionSheetViewController, animated: true)

        photosUpdatedSubscriptions.add(viewController.notify.filesUpdated).disposed(by: viewController.disposeBag)
    }

    private func pickPhotos(to step: AutoPhotoStep, group: PhotoGroup, from: UIViewController, completion: @escaping () -> Void) {
        let photoTip = step.minDocuments > 0
            ? String(format: NSLocalizedString("photos_mandatory_tip_value", comment: ""), "\(step.minDocuments)", "\(step.maxDocuments)")
            : String(format: NSLocalizedString("photos_optional_tip_value", comment: ""), "\(step.maxDocuments)")
        let hint = AutoOverlayHint(
            groupTitle: group.title,
            groupTip: String(
                format: NSLocalizedString("photos_group_hint_value", comment: ""),
                "\(step.order)", "\(group.steps.count)", photoTip
            ),
            stepTitle: step.title,
            stepTip: step.hint,
            icon: UIImage(named: step.icon)
        )
        photoSelectionBehavior.pickDocuments(
            from,
            attachmentService: attachmentService,
            sources: group.isPhotoLibraryAllowed ? [ .library, .camera ] : [ .camera ],
            maxDocuments: step.maxDocuments - step.attachments.count,
            cameraHint: hint
        ) { [weak self] attachments in
            guard let self = self else { return }

            step.attachments.append(contentsOf: attachments)
            self.photosUpdatedSubscriptions.fire(())
            completion()
        }
    }

    private func showAttachmentsUpload(eventReportId: InsuranceEventFlow.EventReportId) {
        let viewController: AttachmentUploadViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            eventReportId: eventReportId.value,
            text: NSLocalizedString("photos_upload_tip", comment: ""),
            presentationMode: .push
        )
        viewController.output = .init(
            close: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            },
            doneAction: {
				guard let insurance = self.insurance
				else { return }
				
                ApplicationFlow.shared.show(item: .eventReport(eventReportId, insurance))
            }
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Helpers

    private func preparePhotosForSend(for groups: [PhotoGroup], eventId: String) {
        var autoEventAttachment: [AutoEventAttachment] = []
        let steps = groups.flatMap { $0.steps }
        for step in steps {
            let photos: [Attachment] = step.attachments.filter { attachmentService.attachmentExists($0) }
            let attachments: [AutoEventAttachment] = photos.map {
                AutoEventAttachment(id: UUID().uuidString, eventReportId: eventId, filename: $0.filename,
                    fileType: step.fileType, isOptional: false)
            }
            autoEventAttachment.append(contentsOf: attachments)
        }
        attachmentService.addToUploadQueue(attachments: autoEventAttachment)
    }

    private func deleteAttachments(_ attachments: [Attachment]) {
        attachments.forEach { attachmentService.delete(attachment: $0) }
    }

    private func openViewController(if available: Bool, caseType: AutoEventCaseType, draft: AutoEventDraft?) {
        if available {
            self.showRegistrationAccidentViewController(caseType: caseType, draft: draft)
        } else {
            self.showCreateAutoEventViewController(caseType: caseType, draft: draft)
        }
    }

    // MARK: - Types
	
    private func showLocationPicker(from controller: UIViewController, modally: Bool = true) {
        let viewController = LocationPickerViewController()
        container?.resolve(viewController)
        viewController.input = .init(
            point: selectedPosition
        )
        viewController.output = .init(
            selectedPoint: { [weak viewController] point in
                self.selectedPosition = point
                self.reverseGeocodeSelectedPosition()
                viewController?.dismiss(animated: true, completion: nil)
            },
            requestAvailability: { self.geoLocationService.requestAvailability(always: false) }
        )
        if modally {
            let navigationController = RMRNavigationController(rootViewController: viewController)
            navigationController.strongDelegate = RMRNavigationControllerDelegate()
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            controller.present(navigationController, animated: true, completion: nil)
        } else {
            controller.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // MARK: - GeoLocation

    private var locationUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private var geoLocationAvailabilitySubscription: Subscription?
    private var geoLocationSubscription: Subscription?
    private var selectedPosition: Coordinate?
    private var selectedPlace: GeoPlace?

    /// Sets up GeoLocationService subscriptions.
    private func setupLocationServices() {
        geoLocationAvailabilitySubscription = geoLocationService.subscribeForAvailability { [weak self] availability in
            guard let self,
				  let navigationController
			else { return }
			
            switch availability {
                case .allowedAlways, .allowedWhenInUse:
                    break
				case .denied, .notDetermined:
                    let controller = UIHelper.findTopModal(controller: navigationController)
                    UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: true)
                case .restricted:
                    let controller = UIHelper.findTopModal(controller: navigationController)
                    UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: false)
            }
        }

        geoLocationSubscription = geoLocationService.subscribeForLocation { [weak self] deviceLocation in
            guard let self = self else { return }

            self.selectedPosition = deviceLocation
            self.geoLocationSubscription?.unsubscribe()
            self.reverseGeocodeSelectedPosition()
        }
    }

    private func reverseGeocodeSelectedPosition() {
        guard let selectedPosition = selectedPosition else { return }

        geocodeService.reverseGeocode(location: selectedPosition) { [weak self] result in
            guard let self = self else { return }

            if case .success(let place) = result {
                self.selectedPlace = place
            }
            self.locationUpdatedSubscriptions.fire(())
        }
    }
}

extension AutoEventCaseType {
	func title(insuranceKind: Insurance.Kind) -> String {
		switch self {
			case .competentAuthoritiesInvolved:
				return NSLocalizedString("auto_event_case_accident_osago_gibdd_title", comment: "")
			case .executedByTrafficAccidentParticipants:
				return NSLocalizedString("auto_event_case_accident_osago_no_gibdd_title", comment: "")
			case .other:
				return NSLocalizedString("auto_event_case_other_title", comment: "")
		}
	}
	
	func hint(insuranceKind: Insurance.Kind) -> String {
		if insuranceKind == .osago {
			switch self {
				case .competentAuthoritiesInvolved:
					return NSLocalizedString("auto_event_case_accident_osago_gibdd_text", comment: "")
				case .executedByTrafficAccidentParticipants:
					return NSLocalizedString("auto_event_case_accident_osago_no_gibdd_text", comment: "")
				case .other:
					return NSLocalizedString("auto_event_case_accident_osago_other_text", comment: "")
			}
		} else if insuranceKind == .kasko {
			switch self {
				case .competentAuthoritiesInvolved:
					return  NSLocalizedString("auto_event_case_accident_kasko_gibdd_text", comment: "")
				case .executedByTrafficAccidentParticipants:
					return NSLocalizedString("auto_event_case_accident_kasko_no_gibdd_text", comment: "")
				case .other:
					return NSLocalizedString("auto_event_case_accident_kasko_other_text", comment: "")
			}
		} else {
			switch self {
				case .competentAuthoritiesInvolved:
					return  NSLocalizedString("auto_event_case_authorities_involved", comment: "")
				case .executedByTrafficAccidentParticipants:
					return NSLocalizedString("auto_event_case_executed_by_particioants", comment: "")
				case .other:
					return NSLocalizedString("auto_event_case_other", comment: "")
			}
		}
	}
	
	var photoGroupsPreset: [PhotoGroup] {
		switch self {
			case .competentAuthoritiesInvolved:
				return PhotoModelsPresets().authorities
			case .executedByTrafficAccidentParticipants:
				return PhotoModelsPresets().noAuthorities
			case .other:
				fatalError("Unexpected behavior, photo groups are not designed for this case!")
		}
	}
}
