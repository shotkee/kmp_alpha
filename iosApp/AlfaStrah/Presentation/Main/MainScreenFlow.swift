//
//  MainScreenFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length
class MainScreenFlow: BDUI.ActionHandlerFlow,
					  ApiStatusServiceDependency,
					  BonusPointsServiceDependency,
					  CampaignServiceDependency,
					  FlatOnOffServiceDependency,
					  LoyaltyServiceDependency,
					  NotificationsServiceDependency,
					  QuestionServiceDependency,
					  ServiceDataManagerDependency,
					  StoriesServiceDependency,
					  UserSessionServiceDependency,
					  VzrOnOffServiceDependency {
	var apiStatusService: ApiStatusService!
	var bonusPointsService: BonusPointsService!
	var campaignService: CampaignService!
	var flatOnOffService: FlatOnOffService!
	var loyaltyService: LoyaltyService!
	var notificationsService: NotificationsService!
	var questionService: QuestionService!
	var serviceDataManager: ServiceDataManager!
	var storiesService: StoriesService!
	var userSessionService: UserSessionService!
	var vzrOnOffService: VzrOnOffService!
	
    private let disposeBag: DisposeBag = DisposeBag()
    private var notificationSubscriptions: Subscriptions<[AppNotification]> = Subscriptions()
    private var needRefreshSubscriptions: Subscriptions<Void> = Subscriptions()
    private var accountIsChangedSubscriptions: Subscriptions<Void> = Subscriptions()
	
    private var allNotifications: [AppNotification] = []
    private var accountAuthorized: Bool = false
    private var previousAuthorizationStatus: Bool = false
    private let storyboard = UIStoryboard(name: "Home", bundle: nil)
	
	private var nativeHomeViewController: HomeViewController?
	
    private var filters: [InsuranceCategoryMain.CategoryType] = [] {
        didSet {
            needRefreshSubscriptions.fire(())
        }
    }

    deinit {
        logger?.debug("")
    }

	func start() {
        accountAuthorized = accountService.isAuthorized

        accountService
            .subscribeForAccountUpdates { [weak self] _ in
                guard let self = self else { return }

                self.accountAuthorized = self.accountService.isAuthorized
                
                // update short insurances after authorization process
                if self.previousAuthorizationStatus != self.accountAuthorized
                    && self.accountAuthorized {
                    // account was switched after logout state and auth was successful
                    self.accountIsChangedSubscriptions.fire(())
                } else {
                    self.needRefreshSubscriptions.fire(())
                }
                
                self.previousAuthorizationStatus = self.accountAuthorized
            }.disposed(by: disposeBag)

        serviceDataManager
            .subscribeForServicesUpdates { [weak self] in
                guard let self = self else { return }

                self.needRefreshSubscriptions.fire(())
            }.disposed(by: disposeBag)
		
		setupInitalController(
			withNativeRender: {
				switch applicationSettingsService.isNativeRender {
					case .yes:
						return true
					case .no, .none:
						return false
				}
			}()
		)
		
        initialViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar_main_title", comment: ""),
            image: .Icons.home,
            selectedImage: nil
        )
		
		notificationSubscriptions.add { appNotification in
			self.nativeHomeViewController?.notify.notifications(appNotification)
		}.disposed(by: self.disposeBag)

		storiesService.subscribeForStoryUpdates{ stories in
			self.nativeHomeViewController?.notify.stories(stories)
		}.disposed(by: self.disposeBag)

		accountIsChangedSubscriptions.add{
			self.nativeHomeViewController?.notify.accountIsChanged()
		}.disposed(by: self.disposeBag)

		needRefreshSubscriptions.add{
			self.nativeHomeViewController?.notify.allReload()
		}.disposed(by: self.disposeBag)

		ApplicationFlow.shared.subscribeForDidBecomeReachable{ isReachable in
			self.nativeHomeViewController?.notify.didBecomeReachable(isReachable)
		}.disposed(by: self.disposeBag)

		notificationsService.subscribeForNeedRefreshNotifications{
			self.nativeHomeViewController?.notify.allReload()
		}.disposed(by: self.disposeBag)

		insurancesService.subscribeForSingleInsuranceUpdate { _ in
			self.nativeHomeViewController?.notify.allReload()
		}.disposed(by: self.disposeBag)

        userSessionService.subscribeSession { _ in
			switch self.applicationSettingsService.isNativeRender {
				case .yes:
					self.nativeHomeViewController?.notify.allReload()
				case .no, .none:
					self.setupInitalController(withNativeRender: false)
			}
		}.disposed(by: self.disposeBag)
    }
	
	func setupInitalController(withNativeRender withNativeRender: Bool) {
		if withNativeRender {
			initialViewController.setViewControllers([ createHomeViewController() ], animated: false)
		} else {
			let hide = initialViewController.showLoadingIndicator(message: nil)
			backendDrivenService.backendDrivenDataForMain{ result in
				hide(nil)
				switch result {
					case .success(let data):
						if let screenBackendComponent = BDUI.DataComponentDTO(body: data).screen {
							let homeViewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
								with: screenBackendComponent,
								use: self.backendDrivenService,
								use: self.analytics,
								isRootController: true,
								tabIndex: 0,
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
						self.initialViewController.setViewControllers([ self.createHomeViewController() ], animated: false)
						
				}
			}
		}
	}
	
	private func showCallNumberActionSheet(
		phone: BDUI.PhoneComponentDTO,
		viewController: ViewController
	) {
		
		guard let humanReadable = phone.humanReadable,
			  let plain = phone.plain
		else { return }
		
		let actionSheet = UIAlertController(
			title: humanReadable,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		if phone.canMakeCall ?? false == true {
			let callNumberAction = UIAlertAction(
				title: NSLocalizedString("common_call", comment: ""),
				style: .default
			) { _ in
				
				guard let url = URL(string: "telprompt://" + plain)
				else { return }
				
				UIApplication.shared.open(url, completionHandler: nil)
			}
			actionSheet.addAction(callNumberAction)
		}
		
		if phone.canCopyValue ?? false == true {
			let copyNumberAction = UIAlertAction(
				title: NSLocalizedString("common_copy", comment: ""),
				style: .default,
				handler: { _ in
					UIPasteboard.general.string = plain
				}
			)
			
			actionSheet.addAction(copyNumberAction)
		}
		
		let cancel = UIAlertAction(
			title: NSLocalizedString(
				"common_cancel_button",
				comment: ""
			),
			style: .cancel,
			handler: nil
		)

		actionSheet.addAction(cancel)
		
		viewController.present(
			actionSheet,
			animated: true
		)
	}
	
	private func getInsurance(
		insuranceId: String,
		from: ViewController,
		completion: @escaping (Insurance) -> Void
	) {
		let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
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
	
    // swiftlint:disable function_body_length
    private func createHomeViewController() -> HomeViewController {
        let homeViewController = HomeViewController()
        container?.resolve(homeViewController)
		
        homeViewController.input = .init(
            accountDataWasLoaded: {
                return self.accountService.isUserAccountDataLoaded
            },
            isAuthorized: {
                return self.accountService.isAuthorized
            },
            isDemoAccount: {
                self.accountService.isDemo
            },
            isAlphaLife: {
                return self.applicationSettingsService.accountType == .alfaLife
            },
            showFirstAlphaPoints: {
                return self.applicationSettingsService.showFirstAlphaPoints
            },
            promos: {
                return self.obtainLocalNews()
            },
            notification: obtainNotifications,
            insurance: localInsurances,
            vzrOnOffInput: vzrOnOffInput,
            flatOnOffInput: flatOnOffInput,
            updateNotification: refreshNotifications,
            updateNotificationCounter: updateNotificationCounter,
            updatePromo: campaignsNews,
            updateInsurances: obtainInsurances,
            updateInsurancesStore: {},
            filters: { self.filters },
            updateAccountData: { [weak self] completion in
                guard let self = self,
                      self.accountService.isAuthorized
                else { return }
                
                self.accountService.getAccount(useCache: true) { result in
                    completion(result)
                }
            },
            apiStatus: {
                self.apiStatusService.apiStatus { [weak homeViewController] result in
                    guard let homeViewController = homeViewController
                    else { return }
                    
                    switch result {
                        case .success(let apiStatus):
                            func showView(
                                _ appearance: StateInfoBannerView.Appearance
                            ) {
                                homeViewController.showServicesState(
                                    title: apiStatus.title,
                                    description: apiStatus.description,
                                    appearance: appearance
                                )
                            }
                            switch apiStatus.state {
                                case .blocked:
                                    showView(.accent)
                                case .restricted:
                                    showView(.standard)
                                case .normal:
                                    // do not show at normal statе
                                    return
                            }
                        case .failure:
                            // do not handle the error anyway
                            return
                    }
                }
            },
            stories: { isForced, completion in
                self.storiesService.getStories(
                    isForced: isForced,
                    screenWidth: Int(UIScreen.main.bounds.width),
                    completion: { result in
                        switch result {
                            case .success(let stories):
                                completion(stories)
                            case .failure:
                                completion(self.storiesService.stories)
                        }
                    }
                )
            },
            questions: { completion in
                self.questionService.questionList(useCache: true) { result in
                    switch result {
                        case .success(let categories):
                            let faq = categories.flatMap {
                                $0.questionGroupList.flatMap {
                                    $0.questionList.filter { $0.isFrequent }
                                }
                            }
                            completion(faq)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                }
            },
			bonuses: { useCache, completion in				
				self.bonusPointsService.bonuses(useCache: useCache) { result in
					completion(result)
				}
			}
        )
		
        homeViewController.output = .init(
			toArchive: { [weak homeViewController] in
				guard let fromController = homeViewController
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: fromController)
				}
				else
				{
					self.analytics.track(event: AnalyticsEvent.App.openArchive)
					let flow = InsurancesFlow()
					self.container?.resolve(flow)
					flow.archiveInsurancesListModal(from: fromController)
				}
            },
			toDemo: {
				DemoBottomSheet.presentInfoDemoSheet(
					from: homeViewController
				)
			},
            toSearch: { [weak homeViewController] in
                guard let fromController = homeViewController else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: fromController)
				}
				else
				{
					self.analytics.track(event: AnalyticsEvent.App.openSearch)
					let flow = InsurancesFlow()
					self.container?.resolve(flow)
					flow.searchInsuranceModal(from: fromController)
				}
            },
            toActivate: { [weak homeViewController] in
                guard let controller = homeViewController 
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: controller)
				}
				else
				{
					self.openActivateInsurance()
				}
            },
            toBuyInsurance: { [weak homeViewController] in
                guard let controller = homeViewController
				else { return }

                self.analytics.track(event: AnalyticsEvent.App.openShop)
                let flow = InsurancesBuyFlow()
                self.container?.resolve(flow)
                flow.start(from: controller)
            },
            toFaq: openFaq,
            openQuestion: { question in
                guard let fromViewController = self.initialViewController.topViewController as? ViewController
                else { return }
                let flow = QAFlow(rootController: fromViewController)
                self.container?.resolve(flow)
                flow.showQuestion(question, from: fromViewController)
            },
            toSignIn: openSignIn,
            toChat: openChat,
			promoAction: { [weak homeViewController] item in
				
				guard let homeViewController
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: homeViewController)
				}
				else
				{
					self.newsAction(item: item)
				}
			},
            notificationAction: notificationAction,
            notificationOpen: notificationOpen,
            toNotificationHistory: showNotificationsScreen,
			toBonusPoints: { [weak homeViewController] in
				guard let homeViewController
				else { return }
				
				self.showBonusPoints(from: homeViewController)
			},
            showInsurance: showInsurance,
            prolongInsurance: prolong,
            openFilter: openFilter,
            resetFilter: { self.filters = [] },
            sos: sosAction,
            viewVzrInsurance: { [weak homeViewController] in
                guard let fromVC = homeViewController else { return }

                self.showVzrOnOffInsurance(fromVC: fromVC)
            },
            viewFlatInsurance: { [weak homeViewController] in
                guard let fromVC = homeViewController else { return }

                self.showFlatOnOffInsurance(fromVC: fromVC)
            },
            selectedStory: { [weak homeViewController] in
                guard let controller = homeViewController
                else { return }
                
                let storiesFlow = StoriesFlow(rootController: controller)
                self.container?.resolve(storiesFlow)
                storiesFlow.start(
                    selectedStoryIndex: $0.0,
                    stories: $0.1,
                    viewedStoriesPage: $0.2,
                    completion: $0.3
                )
            },
            openDraft: { [weak homeViewController] in
                guard let controller = homeViewController
                else { return }
				
				if self.accountService.isDemo {
					DemoBottomSheet.presentInfoDemoSheet(from: controller)
				} else {
					let draftFlow = DraftsCalculationsFlow(rootController: controller)
					self.container?.resolve(draftFlow)
					draftFlow.start()
				}
            }
        )
        		        
        return homeViewController
    }
    // swiftlint:enable function_body_length
    
    private func vzrOnOffInput(_ completion: @escaping (Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>) -> Void) {
        guard accountService.isAuthorized, !accountService.isDemo else { return completion(.success(nil)) }

        vzrOnOffService.activeTripInsurance(useCache: true) { result in
            switch result {
                case .success(let vzrInsurance):
                    if let vzrInsurance = vzrInsurance {
                        self.insurancesService.insurance(useCache: true, id: vzrInsurance.insuranceId) { result in
                            switch result {
                                case .success(let insurance):
                                    guard let activeTrip = vzrInsurance.activeTripList.first(where: { $0.status == .active }) else {
                                        return completion(.success(nil))
                                    }

                                    completion(
                                        .success(
                                            .init(
                                                insuredObjectTitle: insurance.insuredObjectTitle,
                                                startDate: activeTrip.startDate,
                                                endDate: activeTrip.endDate,
                                                insuranceId: vzrInsurance.insuranceId
                                            )
                                        )
                                    )
                                case .failure(let error):
                                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                                    completion(.failure(error))
                            }
                        }
                    } else {
                        completion(.success(nil))
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    completion(.failure(error))
            }
        }
    }

    private func flatOnOffInput(_ completion: @escaping ([Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>]) -> Void) {
        guard accountService.isAuthorized, !accountService.isDemo else { return completion([]) }

        flatOnOffService.insurances { result in
            switch result {
                case .success(let insurances):
                    let dispatchGroup = DispatchGroup()
                    var info: [Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>] = []
                    let activeInsurances = insurances.filter { $0.protections.contains(where: { $0.status == .active }) }
                    for flatOnOffInsurance in activeInsurances {
                        dispatchGroup.enter()
                        self.insurancesService.insurance(useCache: true, id: flatOnOffInsurance.id) { result in
                            dispatchGroup.leave()
                            switch result {
                                case .success(let insurance):
                                    guard let protection = flatOnOffInsurance.protections.first(where: { $0.status == .active }) else {
                                        fatalError("Inconsistent state!")
                                    }

                                    info.append(
                                        .success(
                                            .init(
                                                insuredObjectTitle: insurance.insuredObjectTitle,
                                                startDate: protection.startDate,
                                                endDate: protection.endDate,
                                                insuranceId: insurance.id
                                            )
                                        )
                                    )
                                case .failure(let error):
                                    info.append(.failure(error))
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        completion(info)
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    completion([])
            }
        }
    }
	
    private func showVzrOnOffInsurance(fromVC: ViewController) {
        let hide = fromVC.showLoadingIndicator(message: nil)
        vzrOnOffService.insurances { result in
            hide {}
            switch result {
                case .success(let insurances):
                    if let vzrInsurance = insurances.first(where: { $0.activeTripList.contains(where: { $0.status == .active }) }) {
                        self.showInsurance(with: vzrInsurance.insuranceId)
                    } else {
                        ErrorHelper.show(error: nil, alertPresenter: self.alertPresenter)
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func showFlatOnOffInsurance(fromVC: ViewController) {
        let hide = fromVC.showLoadingIndicator(message: nil)
        flatOnOffService.insurances { result in
            hide {}
            switch result {
                case .success(let insurances):
                    for insurance in insurances {
                        if insurance.protections.contains(where: { $0.status == .active }) {
                            self.showInsurance(with: insurance.id)
                            break
                        }
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func sosAction(_ group: InsuranceGroupCategory) {
        guard let kind = group.sosActivity?.kind
        else { return }

        switch kind {
            case .doctorAppointment:
				guard let fromController = initialViewController.topViewController as? ViewController,
					  let insuranceIds = group.sosActivity?.insuranceIdList
				else { return }
		
				let flow = InsurancesFlow()
				container?.resolve(flow)
				flow.eventInsurance(from: fromController, showMode: .modal, ids: insuranceIds)
			
			case .accidentInsuranceEvent:
				guard let fromController = initialViewController.topViewController as? ViewController,
					  let insuranceIds = group.sosActivity?.insuranceIdList
				else { return }
			
				if accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: fromController)
				}
				else
				{
					let flow = InsurancesFlow()
					container?.resolve(flow)
					flow.eventInsurance(from: fromController, showMode: .modal, ids: insuranceIds)
				}
                
            case
                .autoInsuranceEvent,
                .passengersInsuranceEvent,
                .passengersInsuranceWebEvent,
                .vzrInsuranceEvent,
                .onWebsite,
				.life,
                .interactiveSupport:
                guard
                    let controller = UIHelper.findTopModal(controller: initialViewController) as? ViewController,
                    let insuranceId = group.sosActivity?.insuranceIdList.first
                else { return }

                let eventFlow = InsuranceEventFlow(rootController: controller)
                container?.resolve(eventFlow)
                eventFlow.startActiveEventsList(insuranceId: insuranceId, group, from: controller)
                
            case .onlinePayment:
                SafariViewController.open(SosFlow.Constants.aslPaymentUrl, from: initialViewController)
                
            case
                .call,
                .callback,
                .voipCall,
                .unsupported:
                break
        }
		
		if let analyticsData = analyticsData(
				from: self.insurancesService.cachedShortInsurances(forced: true),
				for: group.insuranceCategory.type
		) {
			switch kind {
				case .doctorAppointment:
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.main,
						insuranceId: analyticsData.insuranceId,
						event: AnalyticsEvent.Clinic.appointmentMain,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
					
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.main,
						insuranceId: analyticsData.insuranceId,
						event: AnalyticsEvent.Dms.clinics,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
					
				case .interactiveSupport:
					/// common event for appointment in main
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.main,
						insuranceId: analyticsData.insuranceId,
						event: AnalyticsEvent.Clinic.appointmentMain,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
					// specialized event for virtual assistant
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.main,
						insuranceId: analyticsData.insuranceId,
						event: AnalyticsEvent.Dms.interactiveSupport,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
					
				case
					.accidentInsuranceEvent,
					.autoInsuranceEvent,
					.call,
					.callback,
					.life,
					.onWebsite,
					.onlinePayment,
					.passengersInsuranceEvent,
					.passengersInsuranceWebEvent,
					.unsupported,
					.voipCall,
					.vzrInsuranceEvent:
					break
			}
		}
    }

    private func prolong(insurance: InsuranceShort) {
        guard let fromViewController = initialViewController.topViewController as? ViewController else { return }

        let flow = InsurancesFlow()
        container?.resolve(flow)

        flow.showRenew(
            insuranceId: insurance.id,
            renewalType: insurance.renewType,
            from: fromViewController
        )
    }

    private func openFilter() {
        guard let insuranceMain = insurancesService.cachedShortInsurances(forced: false) else { return }

        let filterViewController: FilterInsuranceViewController = storyboard.instantiate()
        filterViewController.addCloseButton { [weak filterViewController] in
            filterViewController?.dismiss(animated: true, completion: nil)
        }
        let category = insuranceMain.insuranceGroupList.flatMap { $0.insuranceGroupCategoryList }
        filterViewController.input = .init(
            insurances: category,
            selected: filters
        )
        filterViewController.output = .init(
            filteredInsurances: { [weak filterViewController] filter in
                guard let viewController = filterViewController else { return }

                self.showFilteredInsurance(filters: filter)
                viewController.dismiss(animated: true, completion: nil)
            }
        )
        let navigationController = RMRNavigationController(rootViewController: filterViewController)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        initialViewController.present(navigationController, animated: true, completion: nil)
    }

    private func showFilteredInsurance(filters: [InsuranceCategoryMain.CategoryType]) {
        self.filters = filters
    }

    private func notificationAction(_ item: HomeModel.NotificationItem) {
        switch item {
            case .alphaPoint:
                applicationSettingsService.showFirstAlphaPoints = false
            case .notification(let notification):
                removeNotification(notification) {
                    self.refreshNotifications { notifications in
                        self.notificationSubscriptions.fire(notifications)
                    }
                }
        }
    }

    private func notificationOpen(_ item: HomeModel.NotificationItem) {
        switch item {
            case .alphaPoint:
                alfaPointsPresent()
            case .notification(let notification):
                showNotification(notification)
        }
    }

    private func alfaPointsPresent() {
        let loyaltyFlow = LoyaltyFlow()
        container?.resolve(loyaltyFlow)
        loyaltyFlow.startModally(from: initialViewController)
    }

    private func localInsurances() -> [InsuranceGroup] {
        let insuranceMain = insurancesService.cachedShortInsurances(forced: false)
        return insuranceMain?.insuranceGroupList ?? []
    }
	
    private func obtainInsurances(useCache: Bool, completion: @escaping ([InsuranceGroup]) -> Void) {
        insurancesService.insurances(useCache: useCache) { [weak self] result in
            guard let self = self
            else { return }

            switch result {
                case .success(let response):
                    completion(response.insuranceGroupList)
                    if !self.accountService.isAuthorized {
                        self.insurancesService.cacheAnonymousSos(
                            sosList: response.sosList,
                            sosEmergencyCommunication: response.sosEmergencyCommunication
                        )
                    }
                    
                case .failure(let error):
                    self.errorProceed(error)
                    
                    if let insuranceMain = self.insurancesService.cachedShortInsurances(
                        forced: true
                    ) {
                        completion(insuranceMain.insuranceGroupList)
                    } else {
                        completion([])
                    }
                    
            }
        }
    }

	private func showInsurance(_ insurance: InsuranceShort) {
        guard let fromViewController = initialViewController.topViewController as? ViewController
        else { return }

        let flow = InsurancesFlow()
        container?.resolve(flow)
		
		flow.showInsurance(insurance, from: fromViewController, isModal: true)

		if let analyticsData = analyticsData(
			from: insurancesService.cachedShortInsurances(forced: true),
			for: insurance.id
		) {
			analytics.track(
				navigationSource: .main,
				insuranceId: insurance.id,
				isAuthorized: accountService.isAuthorized,
				event: AnalyticsEvent.Dms.details,
				userProfileProperties: analyticsData.analyticsUserProfileProperties
			)
		}
    }
	
	private func showInsurance(with id: String) {
		guard let fromViewController = initialViewController.topViewController as? ViewController
		else { return }

		let flow = InsurancesFlow()
		container?.resolve(flow)
		
		let hide = fromViewController.showLoadingIndicator(
			message: NSLocalizedString("common_load", comment: "")
		)
		
		insurancesService.insurance(useCache: true, id: id) { result in
			hide(nil)
			switch result {
				case .success(let insurance):
					flow.showInsurance(id: id, from: fromViewController, isModal: true, kind: insurance.type)
					
				case .failure(let error):
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
					
			}
		}
	}

    private func obtainNotifications() -> [AppNotification] {
        guard accountAuthorized else { return [] }

        allNotifications = notificationsService.cachedMain()
        return topNotifications(allNotifications)
    }

    private func topNotifications(_ notifications: [AppNotification]) -> [AppNotification] {
        guard accountAuthorized else { return [] }

        let sliceNotifications = notifications
            .sorted { notification1, notification2 in
                if notification1.isRead != notification2.isRead {
                    return notification2.isRead
                } else {
                    return notification1.date > notification2.date
                }
            }
            .prefix(3)
        return Array(sliceNotifications)
    }

    private func refreshNotifications(completion: @escaping ([AppNotification]) -> Void) {
        guard accountService.isAuthorized
        else {
            completion([])
            return
        }

        notificationsService.main { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let response):
                    completion(self.topNotifications(response.notificationList))
                case .failure(let error):
                    if error.apiErrorKind != .notAvailableInDemoMode {
                        self.errorProceed(error)
                    }
                    completion([])
            }
        }
    }
        
    private func updateNotificationCounter(completion: @escaping (Int?) -> Void) {
        guard accountService.isAuthorized
        else {
            completion(nil)
            return
        }
        
        notificationsService.unreadNotificationsCounter { result in
            switch result {
                case .success(let unreadCount):
                    completion(unreadCount)
                case .failure(let error):
                    if error.apiErrorKind != .notAvailableInDemoMode {
                        self.errorProceed(error)
                    }
                    completion(nil)
            }
        }
    }
    
    private func removeNotification(_ notification: AppNotification, complition: @escaping () -> Void) {
        notificationsService.delete(notification: notification) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(true):
                    complition()
                case .success(false):
                    self.errorProceed(nil)
                case .failure(let error):
                    self.errorProceed(error)
            }
        }
    }
	
	private func showBonusPointsScreen(with bonusPointsData: BonusPointsData) {
		guard let from = initialViewController.topViewController
		else { return }
		
		guard !accountService.isDemo else {
			DemoAlertHelper().showDemoAlert(from: from)
			return
		}

		let viewController = BonusPointsViewController()
		container?.resolve(viewController)
		
		viewController.input = .init(
			bonusPointsData: bonusPointsData)
		
		viewController.output = .init(
			close: { [weak viewController] in
				viewController?.dismiss(animated: true)
			},
			backendAction: { [weak viewController] backendAction in
				guard let viewController
				else { return }
				
				self.handleThemedButtonAction(backendAction, from: viewController)
			}
		)

		if is7IphoneOrLess() {
			from.modalPresentationStyle = .fullScreen
			from.present(viewController, animated: true)
		} else {
			let actionSheetViewController = ActionSheetViewController(with: viewController)
			actionSheetViewController.enableDrag = true
			actionSheetViewController.enableTapDismiss = false
			from.present(actionSheetViewController, animated: true)
		}
	}
	
	private func handleThemedButtonAction(_ actionInfo: BackendAction, from: UIViewController) {
		switch actionInfo.type {
			case
				.doctorCall,
				.telemedicine,
				.clinicAppointment,
				.insurance,
				.kaskoReport,
				.onlineAppointment,
				.offlineAppointment,
				.osagoReport,
				.propertyProlongation,
				.none:
				break
				
			case .loyalty:
				let flow = LoyaltyFlow()
				container?.resolve(flow)
				flow.startModally(from: from)
				
			case .path(url: let url, urlShareable: let urlShareable, openMethod: let method):
				self.openUrlPath(
					url: url,
					urlShareable: urlShareable,
					openMethod: method,
					from: from
				)
		}
	}
	
	private func openUrlPath(
		url: URL,
		urlShareable: URL?,
		openMethod: BackendAction.UrlOpenMethod,
		from: UIViewController
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

    private func showNotificationsScreen() {
        guard let controller = initialViewController.topViewController
		else { return }

        guard !accountService.isDemo else {
            DemoAlertHelper().showDemoAlert(from: controller)
            return
        }

        let flow = NotificationsFlow(rootController: controller)
        container?.resolve(flow)
        flow.showList(mode: .modal)
    }

    private func showNotification(_ notification: AppNotification) {
        guard let controller = initialViewController.topViewController else { return }

        guard !accountService.isDemo else {
            DemoAlertHelper().showDemoAlert(from: controller)
            return
        }

        let flow = NotificationsFlow(rootController: controller)
        container?.resolve(flow)
        flow.showNotification(notification, mode: .modal)
    }

    private func openChat() {
		guard let topViewController = initialViewController.topViewController as? ViewController
		else { return }
		
		if accountService.isDemo
		{
			DemoBottomSheet.presentInfoDemoSheet(from: topViewController)
		}
		else
		{
			ApplicationFlow.shared.show(item: .tabBar(.chat))
		}
    }

    private func openSignIn() {
        ApplicationFlow.shared.show(item: .login)
    }

    private func openActivateInsurance() {
        let flow = ActivateProductFlow()
        container?.resolve(flow)
        flow.startModally(from: initialViewController)
    }
    
    private func openProfile() {
        ApplicationFlow.shared.show(item: .tabBar(.profile))
    }

    private func openFaq() {
        guard let controller = initialViewController.topViewController as? ViewController
        else { return }

        let flow = QAFlow(rootController: controller)
        container?.resolve(flow)
        flow.startModaly()
    }

    private func topCampaigns(_ campaigns: [Campaign]) -> [Campaign] {
        let topCampaigns = campaigns
            .filter { campaign in
                campaign.endDate.timeIntervalSinceNow > 0
            }
            .sorted { campaign1, campaign2 in
                campaign1.beginDate < campaign2.beginDate
            }
        return Array(topCampaigns)
    }

    private func campaignsNews(completion: @escaping ([NewsItemModel]) -> Void) {
        campaignService.campaigns { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let campaigns):
                    let news = self.topCampaigns(campaigns).map(CampaignNewsItemModel.init)
                    completion(self.obtainLocalNews(news))
                case .failure(let error):
                    self.errorProceed(error)
                    completion(self.obtainLocalNews())
            }
        }
    }

    private func obtainLocalNews(_ news: [NewsItemModel] = []) -> [NewsItemModel] {
        let newsOrder = news
            + [ reachGoalsNews(), alfaHealthMagazineNews(), aviaMomentNews() ]
        return newsOrder
    }

    private func alfaHealthMagazineNews() -> NewsItemModel {
        ActionNewsItemModel(
            title: NSLocalizedString("main_banner_health_magazine_title", comment: ""),
            info: NSLocalizedString("main_banner_health_magazine_text", comment: ""),
            actionTitle: NSLocalizedString("main_banner_details", comment: ""),
            iconImage: UIImage(named: "icon-alfa-magazine-banner")
        ) { controller in
            let path = """
            https://www.alfastrah.ru/\
            alfahealth/?utm_source=mobile&utm_medium=banner&utm_campaign=alfahealth&tag=mobileApp
            """
            SafariViewController.open(path, from: controller)
        }
    }

    private func aviaMomentNews() -> NewsItemModel {
        ActionNewsItemModel(
            title: NSLocalizedString("main_banner_avia_moment_title", comment: ""),
            info: NSLocalizedString("main_banner_avia_moment_text", comment: ""),
            actionTitle: NSLocalizedString("main_banner_details", comment: ""),
            iconImage: UIImage(named: "alfa-avia-moment")
        ) { controller in
            SafariViewController.open("https://www.alfastrah.ru/individuals/travel/passengers/instant_payout/", from: controller)
        }
    }

    private func loyaltyNews() -> NewsItemModel {
        let points = Int(loyaltyService.cachedLoyalty(forced: true)?.amount ?? 0)
        return ActionNewsItemModel(
            title: points > 0
                ? NSLocalizedString("main_banner_promo_loyalty_text", comment: "")
                : NSLocalizedString("main_banner_promo_loyalty_title", comment: ""),
            info: NSLocalizedString("main_banner_promo_loyalty_text", comment: ""),
            alfaPoints: points,
            actionTitle: NSLocalizedString("main_banner_details", comment: ""),
            iconImage: UIImage(named: "alfa-points")
        ) { [weak self] controller in
            guard let self = self else { return }

            if self.accountAuthorized {
                self.alfaPointsPresent()
            } else {
                SafariViewController.open(LoyaltyFlow.Constants.alfaPointsProgramDetailsURL, from: controller)
            }
        }
    }

    private func reachGoalsNews() -> NewsItemModel {
        ActionNewsItemModel(
            title: NSLocalizedString("main_banner_reach_goals_title", comment: ""),
            info: NSLocalizedString("main_banner_reach_goals_text", comment: ""),
            actionTitle: NSLocalizedString("main_banner_details", comment: ""),
            iconImage: UIImage(named: "reach-goals-banner")
        ) { _ in
            let url = URL(string: "https://apps.apple.com/ru/app/alfalife/id1408515508")
            url.map { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
        }
    }
    
    private func newsAction(item: NewsItemModel) {
        switch item {
            case let item as ActionNewsItemModel:
                guard let fromViewController = initialViewController.topViewController else { return }

                item.action(fromViewController)
            case let item as CampaignNewsItemModel:
                let controller: CampaignDetailViewController = storyboard.instantiate()
                controller.campaign = item.campaign
                container?.resolve(controller)
                controller.addCloseButton { [weak controller] in
                    controller?.dismiss(animated: true, completion: nil)
                }
                let navigationController = RMRNavigationController(rootViewController: controller)
                navigationController.strongDelegate = RMRNavigationControllerDelegate()
                initialViewController.present(navigationController, animated: true)
            default: break
        }
    }

    private func errorProceed(_ error: Error?) {
        ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
    }
	
	private func showBonusPoints(from: ViewController) {
		self.backendDrivenService.bonusPoints { result in
			switch result {
				case .success(let data):
					let screenBackendComponent = {
						return BDUI.DataComponentDTO(body: data).screen
					}
					
					let action = BDUI.ScreenRenderActionDTO(screen: screenBackendComponent)
					
					let events = BDUI.EventsDTO(onTap: action, onRender: nil, onChange: nil)
					
					self.handleBackendEvents(
						events,
						on: from,
						with: nil,
						isModal: true,
						syncCompletion: nil
					)
					
				case .failure:
					self.bonusPointsService.bonuses(useCache: true) { result in
						switch result {
							case .success(let data):
								self.showBonusPointsScreen(with: data)
								
							case .failure:
								break
								
						}
					}
			}
		}
	}
}
// swiftlint:enable file_length
