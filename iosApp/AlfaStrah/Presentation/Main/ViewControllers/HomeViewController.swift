//
//  HomeViewController.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 06/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import UIKit
import Legacy

// swiftlint:disable file_length
class HomeViewController: ViewController, UIScrollViewDelegate {
	private let scrollView = UIScrollView()
	private let mainStackView = UIStackView()
	private let demoView = DemoView()
    
    private var servicesStateBannerView: StateInfoBannerView?
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    private lazy var activityIndicatorView = ActivityIndicatorView()
    
    private var sections: [HomeModel.WidgetSections] = [
        .currentlyActiveInsurances,
        .notification,
		.demo,
        .stories,
        .insurance,
        .promo,
        .faq,
        .vzrDisclaimer,
		.enterBDUI
    ]
    
    private var stories: [Story] = []
    private var questions: [Question] = []
    private var viewedStoriesPage: [Int: Int] = [:]
    
    var input: Input!
    var output: Output!
    
    struct Notify {
        var notifications: ([AppNotification]) -> Void
        var stories: ([Story]) -> Void
        var allReload: () -> Void
        var didBecomeReachable: (Bool) -> Void
        var accountIsChanged: () -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        notifications: { _ in },
        stories: { [weak self] in
            guard let self = self
            else { return }
            
            self.reloadSection(stories: $0)
        },
        allReload: { [unowned self] in
            guard self.isViewLoaded
            else { return }
            
            if !self.input.isAuthorized() {
                self.stopPullToRefresh(animate: false)
                self.removeActivityIndicatorView()
                self.accountDataWasUpdated = false
                
                self.removePreviousServicesStateBannerViewIfNeeded()
                
                self.resetInsurancesSection()
            }
            
            self.allReload {}
        },
        didBecomeReachable: { [weak self] reachable in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.didBecomeReachable(reachable)
        },
        accountIsChanged: { [weak self] in
            // reset when account was changed
            self?.accountDataWasUpdated = false
        }
    )
    
    struct Input {
        var accountDataWasLoaded: () -> Bool
        var isAuthorized: () -> Bool
        var isDemoAccount: () -> Bool
        var isAlphaLife: () -> Bool
        var showFirstAlphaPoints: () -> Bool
        var promos: () -> [NewsItemModel]
        var notification: () -> [AppNotification]
        var insurance: () -> [InsuranceGroup]
        var vzrOnOffInput: (@escaping (Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>) -> Void) -> Void
        var flatOnOffInput: (@escaping ([Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>]) -> Void) -> Void
        var updateNotification: (_ completion: @escaping ([AppNotification]) -> Void) -> Void
        var updateNotificationCounter: (_ completion: @escaping (Int?) -> Void) -> Void
        var updatePromo: (_ completion: @escaping ([NewsItemModel]) -> Void) -> Void
        var updateInsurances: (_ useCache: Bool, _ completion: @escaping ([InsuranceGroup]) -> Void) -> Void
        var updateInsurancesStore: () -> Void
        var filters: () -> [InsuranceCategoryMain.CategoryType]
        var updateAccountData: (_ completion: @escaping (Result<Account, AlfastrahError>) -> Void) -> Void
        let apiStatus: () -> Void
        let stories: (_ isForced: Bool, _ completion: @escaping ([Story]) -> Void) -> Void
        let questions: (_ completion: @escaping ([Question]) -> Void) -> Void
		let bonuses: (_ useCache: Bool, _ completion: @escaping (Result<BonusPointsData, AlfastrahError>) -> Void) -> Void
    }
    
    struct Output {
        let toArchive: () -> Void
		let toDemo: () -> Void
        let toSearch: () -> Void
        let toActivate: () -> Void
        let toBuyInsurance: () -> Void
        let toFaq: () -> Void
        let openQuestion: (Question) -> Void
        let toSignIn: () -> Void
        let toChat: () -> Void
        let promoAction: (NewsItemModel) -> Void
        let notificationAction: (HomeModel.NotificationItem) -> Void
        let notificationOpen: (HomeModel.NotificationItem) -> Void
        let toNotificationHistory: () -> Void
		let toBonusPoints: () -> Void
        let showInsurance: (InsuranceShort) -> Void
        let prolongInsurance: (InsuranceShort) -> Void
        let openFilter: () -> Void
        let resetFilter: () -> Void
        let sos: (InsuranceGroupCategory) -> Void
        let viewVzrInsurance: () -> Void
        let viewFlatInsurance: () -> Void
        let selectedStory: ((Int, [Story], [Int: Int], (Int, Int) -> Void)) -> Void
        let openDraft: () -> Void
    }
    
    private weak var vzrOnOffActiveTripView: ActiveOnOffInsuranceView?
    private var flatOnOffActiveTripViews: [ActiveOnOffInsuranceView] = []
    private var activeInsurancesView: HorizontalScrollView?
    private var isTimerRefreshing: Bool = false
    private var isVzrRefreshing: Bool = false
    private var isFlatRefreshing: Bool = false
    private var isSectionsBuilt: Bool = false
    
    private var accountDataWasUpdated: Bool = false
    private var pullToRefreshInProgress: Bool = false
    private var activityIndicatorIsAdded: Bool = false
    private var pullToRefreshCanStart: Bool = true
    private var pullToRefreshIsPrepared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupScrollView()
		setupMainStackView()
        
        scrollView.contentInset.top = Constants.defaultScrollInset
        addActivityIndicatorView()
        activityIndicatorView.alpha = 1
		
		// initally load bonus points data from cache
		input.bonuses(true) { [weak self] result in
			guard let self = self
			else { return }
			
			switch result {
				case .success(let data):
					self.headerSectionData.bonusPointsData = data
				case .failure:
					break
			}
		}
		
		allReload {}
		setupDemoView()
    }
	
	struct HeaderSectionData {
		var unreadNotificationsCounter: Int?
		var bonusPointsData: BonusPointsData?
	}
	
	private var headerSectionData = HeaderSectionData()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !activityIndicatorIsAdded && input.isAuthorized() { // re-login  handle
            addActivityIndicatorView()
            activityIndicatorView.alpha = 1
        }
        
        // load "default" insurances from cache until policies will not updated
        // by loadDataAfterPullToRefresh
        if input.isAuthorized() && !accountDataWasUpdated && !pullToRefreshInProgress {
            scrollView.contentInset.top = Constants.spacingForActivityIndicator
            // fix content offset after re-login & switch tab
            scrollView.setContentOffset(
                CGPoint(x: 0, y: -Constants.spacingForActivityIndicator),
                animated: false
            )
            startPullToRefresh()
        } else {
            allReload {}
        }
        
        if let index = self.sections.firstIndex(of: .notification) {
            if input.isAuthorized(), !input.isDemoAccount() {
				let dispatchGroup = DispatchGroup()
				
				dispatchGroup.enter()
                input.updateNotificationCounter { [weak self] unreadNotificationsCounter in
					dispatchGroup.leave()
					
                    guard let self = self
                    else { return }
                    
					self.headerSectionData.unreadNotificationsCounter = unreadNotificationsCounter
                }
				
				dispatchGroup.enter()
				input.bonuses(false) { [weak self] result in
					dispatchGroup.leave()
					
					guard let self = self
					else { return }
					
					switch result {
						case .success(let data):
							self.headerSectionData.bonusPointsData = data
						case .failure(let error):
							/// hide section if any error occured
							switch error {
								case .api, .error, .infoMessage:
									self.headerSectionData.bonusPointsData = nil
								case .network(let networkError):
									if !networkError.isUnreachableError {
										self.headerSectionData.bonusPointsData = nil
									}
							}
					}
				}
				
				dispatchGroup.notify(queue: .main) {
					self.replaceSection(
						view: self.createHeaderSectionView(
							themedTitle: self.headerSectionData.bonusPointsData?.themedTitle,
							themedIcons: self.headerSectionData.bonusPointsData?.themedIcons,
							notificationsCounter: self.headerSectionData.unreadNotificationsCounter
						),
						at: index
					)
				}
            } else {
                self.replaceSection(
                    view: self.createHeaderSectionView(
						themedTitle: nil,
						themedIcons: nil,
                        notificationsCounter: nil,
                        showNotifications: false
                    ),
                    at: index
                )
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
		if !input.isDemoAccount()
		{
			navigationController?.setNavigationBarHidden(false, animated: false)
		}
    }
	    
	private func setupScrollView() {
		scrollView.bounces = true
		scrollView.alwaysBounceVertical = true
		scrollView.backgroundColor = .clear
		
		view.addSubview(scrollView)
		
		scrollView.edgesToSuperview()
	}
	
	private func setupMainStackView() {
		scrollView.addSubview(mainStackView)
		
		mainStackView.isLayoutMarginsRelativeArrangement = true
		mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		mainStackView.axis = .vertical
		mainStackView.spacing = 18
		mainStackView.backgroundColor = .clear
		
		mainStackView.edgesToSuperview(excluding: .top)
		mainStackView.topToSuperview(offset: 9)
		mainStackView.width(to: view)
	}
	
    private func addActivityIndicatorView() {
        activityIndicatorIsAdded = true
        
        activityIndicatorView.clearBackgroundColor()
		activityIndicatorView.setSpinnerColor(.Icons.iconAccent)
        
        activityIndicatorView.set(title: NSLocalizedString("refresh_control_title", comment: ""))
        
        view.insertSubview(activityIndicatorView, at: 0)
        
        scrollView.delegate = self
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
				constant: Constants.activityIndicatorViewTopOffset
            ),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: Constants.activityIndicatorSpinnerHeight),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: Constants.activityIndicatorSpinnerHeight)
        ])
    }
    
    private func removeActivityIndicatorView() {
        activityIndicatorIsAdded = false
        activityIndicatorView.removeFromSuperview()
    }
    
    private func startPullToRefresh() {
        guard !pullToRefreshInProgress
        else { return }
        
        pullToRefreshInProgress = true
        pullToRefreshCanStart = false
        
        activityIndicatorView.alpha = 1
        
        activityIndicatorView.animating = true
        
        // update sections if needed with p2r start
        input.updateAccountData { [weak self] result in
            guard let self = self
            else { return }
            
            switch result {
                case .success:
                    self.input.apiStatus()
                    self.refreshMainStackView()
                case .failure:
                    // need stop animation if this method is failed
                    self.stopPullToRefresh()
                    self.handlePullToRefreshCompletion()
            }
        }
    }
	
	private func setupDemoView()
	{
		demoView.isHidden = !input.isDemoAccount()
		demoView.onTapButton = output.toDemo
		view.addSubview(demoView)
		demoView.topToSuperview(
			offset: UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
		)
		demoView.leadingToSuperview(relation: .equalOrGreater)
		demoView.trailingToSuperview()
	}
    
    private func stopPullToRefresh(animate: Bool = true) {
        activityIndicatorView.animating = false
        
        if animate {
            if !self.scrollView.isDragging {
                UIView.animate(
                    withDuration: 0.6,
                    animations: {
                        self.scrollView.contentInset.top = Constants.defaultScrollInset
                    },
                    completion: { [weak self] _ in
                        self?.handlePullToRefreshCompletion()
                    }
                )
            }
        } else {
            scrollView.contentInset.top = Constants.defaultScrollInset
            // fix content offset after re-login & switch tab
            scrollView.setContentOffset(
                CGPoint(x: 0, y: -Constants.defaultScrollInset),
                animated: false
            )
            handlePullToRefreshCompletion()
        }
    }
    
    private func reloadSection(stories: [Story]){
        if let index = self.sections.firstIndex(of: .stories) {
            
            let view = self.createStoryView(
                stories: stories
            )
            
            self.replaceSection(
                view: view,
                at: index
            )
            
            view.isHidden = stories.isEmpty
        }
    }
    
    private func refreshMainStackView() {
        requestAndSaveDataWithPullToRefresh(useCache: false) {
            self.buildSections()
            self.stopPullToRefresh()
            self.accountDataWasUpdated = true
        }
        
        input.updateInsurancesStore()
    }
    
    private func allReload(useCache: Bool = true, completion: @escaping () -> Void) {
        buildSections()
        updateData(useCache: useCache, completion: completion)
    }
    
    private func resetInsurancesSection() {
        guard let index = self.sections.firstIndex(of: .insurance)
        else { return }
        self.replaceSection(
            view: self.createInsuranceView(with: []),
            at: index
        )
    }
    
    private func updateData(useCache: Bool = true, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        input.vzrOnOffInput { [weak self] vzrOnOffInput in
            dispatchGroup.leave()
            
            guard let self = self
            else { return }
            
            // avoid scroll rattling during "pull to refresh" at app start if user begin to drag scroll view
            if !self.pullToRefreshInProgress {
                guard let index = self.sections.firstIndex(of: .currentlyActiveInsurances)
                else { return }
                
                self.updateActiveInsuranceView(input: vzrOnOffInput, kind: .vzr)
                self.replaceSection(
                    view: self.createCurrentlyActiveInsurancesView(),
                    at: index
                )
            }
        }
        
        dispatchGroup.enter()
        input.flatOnOffInput { [weak self] flatOnOffInput in
            dispatchGroup.leave()
            
            guard let self = self
            else { return }
            
            if !self.pullToRefreshInProgress {
                guard let index = self.sections.firstIndex(of: .currentlyActiveInsurances)
                else { return }
                
                if flatOnOffInput.isEmpty {
                    self.flatOnOffActiveTripViews.removeAll()
                } else {
                    flatOnOffInput.forEach { self.updateActiveInsuranceView(input: $0, kind: .flat) }
                }
                self.replaceSection(
                    view: self.createCurrentlyActiveInsurancesView(),
                    at: index
                )
            }
        }
        
        dispatchGroup.enter()
        input.updateInsurances(useCache) { [weak self] result in
            dispatchGroup.leave()
            
            guard let self = self
            else { return }
            
            if !self.pullToRefreshInProgress {
                guard let index = self.sections.firstIndex(of: .insurance)
                else { return }
                
                self.replaceSection(
                    view: self.createInsuranceView(with: result),
                    at: index
                )
            }
        }
        
        dispatchGroup.enter()
        input.stories(false) { [weak self] stories in
            dispatchGroup.leave()
            guard let self = self
            else { return }
            
            if !self.pullToRefreshInProgress {
                self.stories = stories
                self.reloadSection(stories: stories)
            }
        }
        
        dispatchGroup.enter()
        input.updatePromo { [weak self] result in
            dispatchGroup.leave()
            guard let self = self
            else { return }
            
            if !self.pullToRefreshInProgress {
                guard let index = self.sections.firstIndex(of: .promo)
                else { return }
                
                self.replaceSection(
                    view: self.createPromoView(with: result),
                    at: index
                )
            }
        }
 
        dispatchGroup.enter()
        input.questions { [weak self] result in
            dispatchGroup.leave()
            guard let self = self
            else { return }

            if !self.pullToRefreshInProgress {
                guard let index = self.sections.firstIndex(of: .faq)
                else { return }
                
                self.replaceSection(
                    view: self.createQAView(with: result),
                    at: index
                )
                self.questions = result
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func buildSections() {
        guard !isSectionsBuilt
        else { return }
        
        mainStackView.subviews.forEach { $0.removeFromSuperview() }
        for section in sections {
            let view: UIView
            switch section {
                case .currentlyActiveInsurances:
                    view = createCurrentlyActiveInsurancesView()
				
                case .notification:
                    view = createHeaderSectionView(
						themedTitle: self.headerSectionData.bonusPointsData?.themedTitle,
						themedIcons: self.headerSectionData.bonusPointsData?.themedIcons,
                        notificationsCounter: nil,
                        showNotifications: input.isAuthorized() && !input.isDemoAccount()
                    )
				
				case .demo:
					view = createSpaceView()
                case .stories:
                    view = createStoryView(stories: self.stories)
                case .insurance:
                    view = createInsuranceView(with: input.insurance())
                case .promo:
                    view = createPromoView(with: input.promos())
                case .faq:
                    view = createQAView(with: questions)
                case .vzrDisclaimer:
                    view = createVzrDisclaimerView()
				case .enterBDUI:
					view = createSwitchToBduiView()
					
			}
            mainStackView.addArrangedSubview(view)
        }
        isSectionsBuilt = true
    }
	
	private func createSwitchToBduiView() -> UIView {
		let view = SwitchToBduiView()
		
		return view
	}
    
    private func replaceSection(view: UIView, at index: Int) {
        if let oldView = mainStackView.arrangedSubviews[safe: index] {
            mainStackView.removeArrangedSubview(oldView)
            // now remove it from the view hierarchy – this is important!
            oldView.removeFromSuperview()
        }
		
		if !mainStackView.subviews.isEmpty
		{
			mainStackView.insertArrangedSubview(view, at: index)
		}
    }
    
    private func refreshVzrView() {
        isVzrRefreshing = true
        input.vzrOnOffInput { [weak self] result in
            guard let self = self else { return }
            
            self.isVzrRefreshing = false
            switch result {
            case .success(let input):
                if let input = input {
                    self.vzrOnOffActiveTripView?.notify.stateUpdated(.data(input))
                } else if let vzrOnOffView = self.vzrOnOffActiveTripView {
                    self.activeInsurancesView?.removeSubview(vzrOnOffView)
                }
            case .failure:
                self.vzrOnOffActiveTripView?.notify.stateUpdated(.error)
            }
        }
    }
    
    private func refreshFlatView() {
        isFlatRefreshing = true
        input.flatOnOffInput { [weak self] results in
            guard let self = self else { return }
            
            self.isFlatRefreshing = false
            guard results.count == self.flatOnOffActiveTripViews.count else {
                return self.updateData {}
            }
            
            for (result, flatOnOffView) in zip(results, self.flatOnOffActiveTripViews) {
                switch result {
                case .success(let input):
                    if let input = input {
                        flatOnOffView.notify.stateUpdated(.data(input))
                    } else {
                        flatOnOffView.superview?.removeFromSuperview()
                    }
                case .failure:
                    flatOnOffView.notify.stateUpdated(.error)
                }
            }
        }
    }
    
    private func didBecomeReachable(_ isReachable: Bool) {
        if isReachable {
            allReload {}
        } else {
            // keep it for now, may be needed again after some time of usage
            //            vzrOnOffActiveTripView?.notify.stateUpdated(.error)
            //            flatOnOffActiveTripViews.forEach { $0.notify.stateUpdated(.error) }
        }
    }
    
    private func updateActiveInsuranceView(
        input: Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>,
        kind: ActiveOnOffInsuranceView.Kind
    ) {
        var activeInsuranceView: ActiveOnOffInsuranceView?
        let output: ActiveOnOffInsuranceView.Output
        switch kind {
        case .flat:
            activeInsuranceView = flatOnOffActiveTripViews.first { $0.insuranceId == input.value??.insuranceId }
            output = .init(
                viewInsurance: { [weak self] in
                    self?.output.viewFlatInsurance()
                },
                reload: { [weak self] in
                    self?.refreshFlatView()
                }
            )
        case .vzr:
            activeInsuranceView = self.vzrOnOffActiveTripView
            output = .init(
                viewInsurance: { [weak self] in
                    self?.output.viewVzrInsurance()
                },
                reload: { [weak self] in
                    self?.refreshVzrView()
                }
            )
        }
        switch input {
        case .success(let input):
            if let input = input {
                let activeInsuranceViewUpdated = activeInsuranceView ?? ActiveOnOffInsuranceView.fromNib()
                activeInsuranceViewUpdated.configure(for: kind)
                activeInsuranceViewUpdated.notify.stateUpdated(.data(input))
                activeInsuranceViewUpdated.output = output
                setViewForActiveInsuranceKind(view: activeInsuranceViewUpdated, insuranceId: input.insuranceId, kind: kind)
            } else {
                setViewForActiveInsuranceKind(view: nil, insuranceId: nil, kind: kind)
            }
        case .failure:
            activeInsuranceView?.notify.stateUpdated(.error)
        }
        activeInsuranceView?.output = output
    }
    
    private func setViewForActiveInsuranceKind(view: ActiveOnOffInsuranceView?, insuranceId: String?, kind: ActiveOnOffInsuranceView.Kind) {
        switch kind {
        case .flat:
            flatOnOffActiveTripViews.removeAll(where: { $0.insuranceId == insuranceId })
            view.map { flatOnOffActiveTripViews.append($0) }
        case .vzr:
            vzrOnOffActiveTripView = view
        }
    }
	
	private func createSpaceView() -> UIView
	{
		let spaceView = UIView()
		spaceView.backgroundColor = .clear
		spaceView.height(30)
		spaceView.isHidden = !input.isDemoAccount()
		
		return spaceView
	}
    
    private func createCurrentlyActiveInsurancesView() -> UIView {
        var views: [UIView] = []
        flatOnOffActiveTripViews.forEach { views.append(self.embededInCardView($0)) }
        vzrOnOffActiveTripView.map { views.append(self.embededInCardView($0)) }
        let activeInsurancesView = HorizontalScrollView(spacing: 9, insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18), views: views)
        activeInsurancesView.showsScrollIndicator = false
        self.activeInsurancesView = activeInsurancesView
        let shouldShow = !views.isEmpty
        activeInsurancesView.isHidden = !shouldShow
        NSLayoutConstraint.fixHeight(view: activeInsurancesView, constant: shouldShow ? 179 : 0)
        return activeInsurancesView
    }
    
    private func embededInCardView(_ view: UIView) -> UIView {
        let cardView = CardView(contentView: view)
        let cardViewContainer = UIView()
        cardViewContainer.backgroundColor = .clear
        cardViewContainer.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: cardView,
                in: cardViewContainer,
                margins: .zero
            )
        )
        return cardViewContainer
    }
    
    private func createNotifyView(with notifications: [AppNotification]) -> UIView {
        var notificationViews: [UIView] = []
        
        let isAuthorized = input.isAuthorized()
        if isAuthorized {
            if input.showFirstAlphaPoints() {
                let alphaPointView = MainNotifyItemView.fromNib()
                alphaPointView.set(
                    item: .alphaPoint,
                    output: .init(
                        tapAction: notificationAction,
                        tapView: notificationOpen
                    )
                )
                notificationViews.append(alphaPointView)
            }
            for notification in notifications {
                let notify = MainNotifyItemView.fromNib()
                notify.set(
                    item: .notification(notification),
                    output: .init(
                        tapAction: notificationAction,
                        tapView: notificationOpen
                    )
                )
                notificationViews.append(notify)
            }
            let history = NotificationToHistoryView.fromNib()
            history.set(
                title: NSLocalizedString("notifications_history", comment: ""),
                subtitle: NSLocalizedString("notifications_history_subtitle", comment: ""),
                action: output.toNotificationHistory
            )
            notificationViews.append(history)
        } else {
            let history = NotificationToHistoryView.fromNib()
            history.set(
                title: NSLocalizedString("notifications_by_request", comment: ""),
                subtitle: NSLocalizedString("notifications_unatorized_subtitle", comment: "")
            ) {}
            notificationViews.append(history)
        }
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 9
        let titleLabel = UILabel()
        let titleLabelContainerView = UIView()
        titleLabelContainerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.fill(
            view: titleLabel,
            in: titleLabelContainerView,
            margins: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        )
        constraints.append(titleLabelContainerView.heightAnchor.constraint(equalToConstant: 32))
        NSLayoutConstraint.activate(constraints)
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.text = NSLocalizedString("notifications_title", comment: "")
        let notificationsView = HorizontalScrollView(
            spacing: 9.0,
            insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
            views: notificationViews.map { CardView(contentView: $0) }
        )
        notificationsView.showsScrollIndicator = false
        containerStackView.addArrangedSubview(titleLabelContainerView)
        containerStackView.addArrangedSubview(notificationsView)
        NSLayoutConstraint.fixHeight(view: containerStackView, constant: 153)
        return containerStackView
    }
    
    private func createHeaderSectionView(
		themedTitle: ThemedText?,
		themedIcons: [ThemedValue]?,
        notificationsCounter: Int?,
        showNotifications: Bool = true
    ) -> UIView {
        let headerSectionView = HeaderSectionView()
        
        headerSectionView.set(
			themedTitle: themedTitle,
			themedIcons: themedIcons,
            counter: notificationsCounter,
            showNotificationsButton: showNotifications,
            rightWidgetTap: { [weak self] in
                self?.output.toNotificationHistory()
            },
            leftWidgetTap: { [weak self] in
				self?.output.toBonusPoints()
            }
        )
		
		headerSectionView.isHidden = !showNotifications
		
        return headerSectionView
    }
    
    private func createStoryView(stories: [Story]) -> UIView {
        let storyView = StoryView()
        
        storyView.input = .init(
            stories: stories
        )
        
        storyView.output = .init(
            select: { [weak self] in
                guard let self = self
                else { return }
                
                self.output.selectedStory(
                    (
                        $0,
                        stories,
                        self.viewedStoriesPage,
                        {
                            [weak self] storyId, currentStoryPageIndex in
                            
                            self?.viewedStoriesPage[storyId] = currentStoryPageIndex
                        }
                    )
                )
            }
        )
        
        storyView.isHidden = true
        
        return storyView
    }
    
    private func createPromoView(with news: [NewsItemModel]) -> UIView {
        var promoViews: [UIView] = []
        for promo in news {
            let promoView = MainPromoItem.fromNib()
            container?.resolve(promoView)
            promoView.set(
                input: .init(model: promo),
                action: output.promoAction
            )
            promoViews.append(CardView(contentView: promoView))
        }
        let notificationsView = HorizontalScrollView(
            spacing: 9.0,
            insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
            views: promoViews,
            autoscrollInterval: 5.0
        )
        notificationsView.showsScrollIndicator = false
        return notificationsView
    }
    
    private func createQAView(with questions: [Question]) -> UIView {
        if questions.isEmpty {
            return UIView()
        }
        var questionsViews: [UIView] = []
        for question in questions.prefix(5) {
            let questionView = MainQAItem.fromNib()
            
            questionView.input = .init(
                image: .Icons.question,
                text: question.questionText
            )
            
            questionView.output = .init(
                tapOnView: { [weak self] in
                    self?.output.openQuestion(question)
                }
            )

            questionsViews.append(CardView(contentView: questionView))
        }
        
        let showAllView = QASectionShowAll()
        showAllView.output = .init(
            tapOnView: { [weak self] in
                self?.output.toFaq()
            }
        )

        questionsViews.append(showAllView)
        
        let sectionView = HorizontalScrollView(
            spacing: 12,
            insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
            views: questionsViews,
            sectionWidth: Constants.questionCellsWidth,
            isPaging: false
        )
        sectionView.showsScrollIndicator = false
        
        let resultView = MainQAView.fromNib()
        
        resultView.input = .init(
            title: NSLocalizedString("main_faq_title", comment: ""),
            horizontalScrollView: sectionView
        )
        
        resultView.output = .init(
            tapAllQuestions: output.toFaq
        )

        return resultView
    }
    
    private func createInsuranceView(with insurances: [InsuranceGroup]) -> UIView {
        let insuranceView = MainInsuranceView.fromNib()
        
        insuranceView.set(
            input: .init(
                filters: input.filters(),
                insurances: insurances,
                isAuthorized: input.isAuthorized(),
                isAlphaLife: input.isAlphaLife()
            ),
            output: insuranceViewActions()
        )
        return CardView(contentView: insuranceView)
    }
    
    private func insuranceViewActions() -> MainInsuranceView.Output {
        .init(
            search: output.toSearch,
            activate: output.toActivate,
            archive: output.toArchive,
            buy: output.toBuyInsurance,
            signIn: output.toSignIn,
            chat: output.toChat,
            insurance: output.showInsurance,
            prolong: output.prolongInsurance,
            filter: output.openFilter,
            resetFilter: output.resetFilter,
            sos: { [weak self] category in
                guard let self = self
                else { return }
                
                switch category.insuranceCategory.type {
                    case .travel:
                        self.analytics.track(event: AnalyticsEvent.Vzr.reportVzrMain)
						
                    case .health:
						break
						
                    case .auto:
                        self.analytics.track(event: AnalyticsEvent.Auto.reportAutoMain)
						
                    case .passengers:
                        self.analytics.track(event: AnalyticsEvent.Passenger.reportPassengersMain)
						
                    case .property, .life, .unsupported:
                        break
						
                }
                
                self.output.sos(category)
            },
            openDraft: output.openDraft
        )
    }
    
    private func createVzrDisclaimerView() -> UIView {
        addIntendView(at: CardView(contentView: MainVzrDisclaimerView.fromNib()))
    }
    
    private func addIntendView(at view: UIView) -> UIView {
        let intendView = UIView()
        intendView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: intendView.topAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: intendView.leadingAnchor, constant: 18),
            intendView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            intendView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 18),
        ])
        return intendView
    }
    
    private func notificationAction(_ item: HomeModel.NotificationItem) {
        output.notificationAction(item)
    }
    
    private func notificationOpen(_ item: HomeModel.NotificationItem) {
        output.notificationOpen(item)
    }
    
    private func removePreviousServicesStateBannerViewIfNeeded() {
        guard let servicesStateBannerView = self.servicesStateBannerView
        else { return }
        
        if servicesStateBannerView.isDescendant(of: view) {
            servicesStateBannerView.removeFromSuperview()
        }
        
        self.servicesStateBannerView = nil
    }
    
    func showServicesState(
        title: String,
        description: String,
        appearance: StateInfoBannerView.Appearance
    ) {
        removePreviousServicesStateBannerViewIfNeeded()
        
        let servicesStateBannerView = StateInfoBannerView()
        
        self.servicesStateBannerView = servicesStateBannerView
        
        view.addSubview(servicesStateBannerView)
        
        servicesStateBannerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            servicesStateBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            servicesStateBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            servicesStateBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        
        let servicesStateBannerViewOffset = servicesStateBannerView.frame.origin.y + servicesStateBannerView.frame.height
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        servicesStateBannerView.set(
            appearance: appearance,
            title: title,
            description: description,
            hasCloseButton: true,
            iconImage: UIImage(named: "icon-info-alert-template"),
            titleFont: Style.Font.headline3,
            startBannerOffset: -(servicesStateBannerViewOffset + statusBarHeight)
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resetPullToRefreshAtAnimationStartPoint()
        
        guard input.isAuthorized()
        else { return }
        
        if scrollView.contentOffset.y < 0 && !pullToRefreshInProgress && pullToRefreshCanStart {
            if !pullToRefreshIsPrepared {
                pullToRefreshIsPrepared = true
                activityIndicatorView.setInitialState()
                activityIndicatorView.alpha = 0
            }
            
            activityIndicatorView.alpha = min(
				abs(scrollView.contentOffset.y + Constants.defaultScrollInset)
				/ Constants.spacingForActivityIndicator,
				1
			)
        }
        
		if scrollView.contentOffset.y >= -Constants.pullToRefreshZeroPointOffset - 10 && !pullToRefreshInProgress {
            activityIndicatorView.alpha = 0
        }
        
        if scrollView.contentOffset.y < 0
			&& abs(scrollView.contentOffset.y) > abs(Constants.spacingForActivityIndicator + Constants.pullToRefreshZeroPointOffset)
            && !pullToRefreshInProgress
            && pullToRefreshCanStart {
            generator.impactOccurred()
            startPullToRefresh()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard pullToRefreshInProgress
        else { return }
        
        // if user released scroll before activity indicator animation ended
        if activityIndicatorView.animating {
            UIView.animate(
                withDuration: 0.6,
                animations: {
                    self.scrollView.contentInset.top = Constants.spacingForActivityIndicator
                }
            )
        } else {
            // if user released scroll after activity indicator animation ended
            UIView.animate(
                withDuration: 0.6,
                animations: {
                    self.scrollView.contentInset.top = Constants.defaultScrollInset
                },
                completion: { [weak self] _ in
                    self?.handlePullToRefreshCompletion()
                }
            )
        }
    }
    
    private func resetPullToRefreshAtAnimationStartPoint() {
        // pullToRefresh op can start only after scroll returns to the initial position
		if scrollView.contentOffset.y == -Constants.pullToRefreshZeroPointOffset {
            pullToRefreshCanStart = true
            pullToRefreshIsPrepared = false
        }
    }
    
    // MARK: - Update main stack with pull to refresh
    // this mechanics is necessary to avoid scroll rattling during restructuring of main stack view layout
    struct PullToRefreshData {
        var vzrOnOffInsuranceViewInfo: Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>?
        var flatOnOffInsuranceViewInfo: [Result<ActiveOnOffInsuranceView.Info?, AlfastrahError>]?
        var insuranceGroup: [InsuranceGroup] = []
        var promos: [NewsItemModel] = []
        var stories: [Story] = []
    }
    
    private var pullToRefreshData = PullToRefreshData()
    
    private func clearPullToRefreshData() {
        pullToRefreshData = PullToRefreshData()
    }
    
    private func requestAndSaveDataWithPullToRefresh(useCache: Bool = true, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
                
        dispatchGroup.enter()
        input.vzrOnOffInput { [weak self] vzrOnOffInput in
            dispatchGroup.leave()
            
            self?.pullToRefreshData.vzrOnOffInsuranceViewInfo = vzrOnOffInput
        }
        
        dispatchGroup.enter()
        input.flatOnOffInput { [weak self] flatOnOffInput in
            dispatchGroup.leave()
                        
            self?.pullToRefreshData.flatOnOffInsuranceViewInfo = flatOnOffInput
        }
          
        dispatchGroup.enter()
        input.updateInsurances(useCache) { [weak self] result in
            dispatchGroup.leave()
            
            self?.pullToRefreshData.insuranceGroup = result
        }
        
        dispatchGroup.enter()
        input.stories(true) {[weak self] stories in
            dispatchGroup.leave()
            
            self?.pullToRefreshData.stories = stories
        }
        
        dispatchGroup.enter()
        input.updatePromo { [weak self] result in
            dispatchGroup.leave()
                        
            self?.pullToRefreshData.promos = result
        }
		
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func loadDataAfterPullToRefresh() {
        if let vzrOnOffInsuranceViewInfo = pullToRefreshData.vzrOnOffInsuranceViewInfo,
           let index = sections.firstIndex(of: .currentlyActiveInsurances) {
            updateActiveInsuranceView(input: vzrOnOffInsuranceViewInfo, kind: .vzr)
            replaceSection(
                view: createCurrentlyActiveInsurancesView(),
                at: index
            )
        }
        
        if let flatOnOffInsuranceViewInfo = pullToRefreshData.flatOnOffInsuranceViewInfo,
           let index = sections.firstIndex(of: .currentlyActiveInsurances) {
            if flatOnOffInsuranceViewInfo.isEmpty {
                flatOnOffActiveTripViews.removeAll()
            } else {
                flatOnOffInsuranceViewInfo.forEach { updateActiveInsuranceView(input: $0, kind: .flat) }
            }
            replaceSection(
                view: createCurrentlyActiveInsurancesView(),
                at: index
            )
        }
		
		if let index = self.sections.firstIndex(of: .demo) {
			self.replaceSection(
				view: createSpaceView(),
				at: index
			)
		}
        
        if !pullToRefreshData.stories.isEmpty {
            self.reloadSection(stories: pullToRefreshData.stories)
        }
        
        if  !pullToRefreshData.insuranceGroup.isEmpty,
            let index = sections.firstIndex(of: .insurance) {
            replaceSection(
                view: createInsuranceView(with: pullToRefreshData.insuranceGroup),
                at: index
            )
        }
        
        if !pullToRefreshData.promos.isEmpty,
           let index = sections.firstIndex(of: .promo) {
            replaceSection(
                view: createPromoView(with: pullToRefreshData.promos),
                at: index
            )
        }
		
        clearPullToRefreshData()
    }
        
    private func handlePullToRefreshCompletion() {
        pullToRefreshInProgress = false
        loadDataAfterPullToRefresh()
        generator.impactOccurred()
    }
    
    enum Constants {
        static let questionCellsWidth: CGFloat = 230
        static let defaultScrollInset: CGFloat = 0
        static let spacingForActivityIndicator: CGFloat = 108
        static let activityIndicatorSpinnerHeight: CGFloat = 52
		static let pullToRefreshZeroPointOffset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 48
		static let activityIndicatorViewTopOffset: CGFloat = 27
    }
}
// swiftlint:enable file_length
