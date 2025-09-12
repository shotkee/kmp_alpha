//
// NotificationsListViewController
// AlfaStrah
//
// Created by Eugene Egorov on 02 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class NotificationsListViewController: ViewController,
                                       UITableViewDataSource,
                                       UITableViewDelegate,
                                       UIScrollViewDelegate {
    enum State {
        case loading
        case data
    }
        
    struct Input {
        let notifications: (
            _ fromId: Int?,
            _ count: Int,
            _ completion: @escaping (Result<BackendNotificationsResponse, AlfastrahError>) -> Void
        ) -> Void
        let showActionButtonIsNeeded: (_ notification: BackendNotification) -> Bool
        let notificationsCounter: (_ completion: @escaping (Int?) -> Void) -> Void
    }

    struct Output {
        let showMore: (BackendNotification) -> Void
        let action: (BackendNotification) -> Void
        let showSettings: () -> Void
        let setAllNotificationsAreRead: (_ topNotification: Int, _ completion: @escaping (Result<Void, AlfastrahError>) -> Void) -> Void
        let turnOnNotifications: () -> Void
        let notificationRead: (BackendNotification, _ completion: @escaping (Result<Void, AlfastrahError>) -> Void) -> Void
    }

    struct Notify {
        var notification: (BackendNotification) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        notification: { [weak self] notification in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.update(notification: notification)
        }
    )

    private let tableView = UITableView()
    private let notificationCounterSpacerView = UIView()
    private let pullToRefreshView = PullToRefreshView()
    private let notificationCounterLabelContainer = UIView()
    private let notificationCounterLabel = UILabel()
    
    private let operationStatusView = OperationStatusView()

    struct NotificationItem {
        var notification: BackendNotification
        let showActionButton: Bool
    }
    
    private var notificationItems: [NotificationItem] = []
    
    private var canLoadMore: Bool = true
    private var loading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundContent
        
        navigationItem.titleView = createCustomTitleView()
        
        subscribeDidBecomeActiveNotification()
        setupOperationStatusView()
        setupTableView()
        setupPullToRefreshView()
    }

    private func subscribeDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		NotificationCenter.default.removeObserver(self)
	}
    
    @objc func didBecomeActiveNotification() {
        // do not need reloadFirstPage() cause otherwise a flickering screen appears
        self.loadPage(reload: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNotificationCounter { [weak self] counterValue in
            self?.updateReadAllButtonVisibility(by: counterValue)
        }

        reloadFirstPage()
    }
    
    private func reloadFirstPage() {
        update(with: .loading)
        self.loadPage(reload: true) { [weak self] _ in
            self?.update(with: .data)
        }
    }
    
    private func loadPage(
        reload: Bool,
        completion: @escaping (Result<[BackendNotification], AlfastrahError>) -> Void = { _ in }
    ) {
        loading = true
        input.notifications(
            reload
                ? nil
                : notificationItems.last?.notification.id,
            Constants.pageSize
        ) { [weak self] result in
            guard let self = self
            else { return }

            self.loading = false
            switch result {
                case .success(let response):
                    if reload {
                        self.notificationItems.removeAll()
                    }
                    
                    self.notificationItems += self.items(from: response.notifications)
                    self.canLoadMore = response.remainingCounter != 0
                        && !response.notifications.isEmpty
                    
                    self.tableView.reloadData()
                    
                    completion(.success(response.notifications))
                case .failure(let error):
                    self.processError(error)
                    completion(.failure(error))
            }
           
        }
    }
    
    private func items(from notifications: [BackendNotification]) -> [NotificationItem] {
        var items: [NotificationItem] = []
        for notification in notifications {
            items.append(NotificationItem(notification: notification, showActionButton: input.showActionButtonIsNeeded(notification)))
        }
        return items
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: tableView, in: view)
        )
        
        tableView.registerReusableCell(NotificationCell.id)
        tableView.registerReusableCell(LoadingTableViewCell.id)
    }
    
    private func setupPullToRefreshView() {
        pullToRefreshView.refreshDataCallback = { [weak self] completion in
            guard let self = self
            else { return }
            
            self.loadPage(reload: true) { _ in
                completion()
            }
        }
        
        pullToRefreshView.scrollView = tableView
        pullToRefreshView.title = NSLocalizedString("notifications_pull_to_refresh_description", comment: "")
        
        view.insertSubview(pullToRefreshView, at: 0)
        
        pullToRefreshView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pullToRefreshView.topAnchor.constraint(equalTo: view.topAnchor),
            pullToRefreshView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pullToRefreshView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func update(notification: BackendNotification) {
        guard let index = notificationItems.firstIndex(where: { $0.notification.id == notification.id }) else { return }

        notificationItems[index] = NotificationItem(
            notification: notification,
            showActionButton: input.showActionButtonIsNeeded(notification)
        )
        tableView.reloadRows(at: [ IndexPath(row: index, section: 0) ], with: .automatic)
    }
    
    private func updateNotificationCounter(_ completion: @escaping (Int) -> Void) {
        input.notificationsCounter { [weak self] counterValue in
            guard let self = self
            else { return }
            
            if let counterValue = counterValue {
                self.notificationCounterLabel.text = counterValue >= Constants.maxNotificationCounter
                    ? "\(Constants.maxNotificationCounter)+"
                    : "\(counterValue)"
                
                self.notificationCounterLabelContainer.isHidden = counterValue == 0
                self.notificationCounterSpacerView.isHidden = counterValue == 0
                
                completion(counterValue)
            } else {
                self.notificationCounterLabelContainer.isHidden = true
                self.notificationCounterSpacerView.isHidden = true
            }
        }
    }
        
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notificationItems.count + (canLoadMore ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < notificationItems.count {
            let cell = tableView.dequeueReusableCell(NotificationCell.id, indexPath: indexPath)
            let item = notificationItems[indexPath.row]
            let notification = item.notification
            let showActionButton = item.showActionButton
            
            let showMoreButton = notification.description.count >= Constants.notificationDescriptionCharactersLimit || !showActionButton
            
            cell.set(
                notification: notification,
                showMore: { [weak self] in
                    guard let self = self
                    else { return }
                    
                    if !item.showActionButton {
                        self.setIsRead(for: indexPath)
                    }
                    self.output.showMore(notification)
                },
                showMoreButton: showMoreButton,
                action: { [weak self] in
                    guard let self = self
                    else { return }
                    
                    if item.showActionButton {
                        self.setIsRead(for: indexPath)
                    }
                    self.output.action(notification)
                },
                showActionButton: showActionButton
            )
            return cell
        } else {
            if !loading && canLoadMore {
                loadPage(reload: false)
            }
            let cell = tableView.dequeueReusableCell(LoadingTableViewCell.id, indexPath: indexPath)
            cell.animate(true)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        setIsRead(for: indexPath)
        notificationItems[indexPath.row].notification.status = .read
        
        self.output.showMore(notificationItems[indexPath.row].notification)
    }
    
    private func setIsRead(for indexPath: IndexPath) {
        guard let notification = notificationItems[safe: indexPath.row]?.notification
        else { return }
                
        if notification.status == .unread {
            if let cell = tableView.cellForRow(at: indexPath) as? NotificationCell {
                cell.setIsRead()
            }
            
            output.notificationRead(notification) { _ in }
            updateNotificationCounter { [weak self] counterValue in
                self?.updateReadAllButtonVisibility(by: counterValue)
            }
        }
    }
    
    @objc private func readAll() {
        guard let topNotification = notificationItems[safe: 0]?.notification
        else { return }
        
        output.setAllNotificationsAreRead(topNotification.id) { result in
            switch result {
                case .success:
                    self.reloadFirstPage()
                case .failure:
                    break
            }
        }
    }
        
    @objc private func showSettings() {
        output.showSettings()
    }
    
    func createCustomTitleView() -> UIView {
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerStackView = UIStackView()
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.axis = .horizontal
        containerStackView.alignment = .fill
        containerStackView.distribution = .fill
        containerStackView.spacing = Constants.titleViewSpacing
        
        titleView.addSubview(containerStackView)
        
        notificationCounterSpacerView.backgroundColor = .clear
        notificationCounterSpacerView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(notificationCounterSpacerView)
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("notifications_title", comment: "")
        
        containerStackView.addArrangedSubview(titleLabel)
        
        containerStackView.addArrangedSubview(notificationCounterLabelContainer)
		notificationCounterLabelContainer.backgroundColor = .Icons.iconAccent
        notificationCounterLabelContainer.layer.cornerRadius = 11
        notificationCounterLabelContainer.clipsToBounds = true
        
        notificationCounterLabel.textAlignment = .center
        notificationCounterLabel <~ Style.Label.contrastHeadline3
        
        notificationCounterLabelContainer.addSubview(notificationCounterLabel)
            
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: containerStackView, in: titleView) +
            NSLayoutConstraint.fill(
                view: notificationCounterLabel,
                in: notificationCounterLabelContainer,
                margins: UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
            ) +
            [
                notificationCounterLabelContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minCounterViewWidth),
                notificationCounterLabelContainer.heightAnchor.constraint(equalToConstant: Constants.minCounterViewWidth),
                notificationCounterSpacerView.widthAnchor.constraint(equalTo: notificationCounterLabelContainer.widthAnchor)
            ]
        )
        
        notificationCounterLabelContainer.isHidden = true
        notificationCounterSpacerView.isHidden = true
        
        return titleView
    }
    
    private func addReadAllButton() {
        let readAllButton = createButton(named: "notifications-navbar-readall-button", selector: #selector(readAll))
        let readAllItem = UIBarButtonItem(customView: readAllButton)
                        
        navigationItem.rightBarButtonItems = [readAllItem]
    }
    
    private func removeNavigationItems() {
        navigationItem.rightBarButtonItems = []
    }
    
    private func updateReadAllButtonVisibility(by counterValue: Int) {
        if counterValue == 0 {
            removeNavigationItems()
        } else {
            addReadAllButton()
        }
    }
    
    private func createButton(named: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: named), for: .normal)
		button.tintColor = .Icons.iconAccentThemed
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pullToRefreshView.didScrollCallback(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pullToRefreshView.didEndDraggingCallcback(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - States
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: operationStatusView, in: view)
        )
    }
    
    private func update(with state: State) {
        switch state {
            case .loading:
                tableView.isHidden = true
                operationStatusView.isHidden = false
                
                let state: OperationStatusView.State = .info(.init(
                    title: "",
                    description: NSLocalizedString("notifications_list_loading_state_description", comment: ""),
                    icon: .Illustrations.searchEmpty
                ))
                operationStatusView.notify.updateState(state)
            case .data:
                let notificationsIsEmpty = notificationItems.isEmpty
                
                tableView.isHidden = notificationsIsEmpty
                operationStatusView.isHidden = !notificationsIsEmpty
                
                if !notificationsIsEmpty {
                    updateNotificationCounter { [weak self] counterValue in
                        self?.updateReadAllButtonVisibility(by: counterValue)
                    }
                } else {
                    let state: OperationStatusView.State = .info(.init(
                        title: NSLocalizedString("notifications_list_empty_state_title", comment: ""),
                        description: NSLocalizedString("notifications_list_empty_state_description", comment: ""),
                        icon: .Illustrations.searchEmpty
                    ))
                    
                    operationStatusView.notify.updateState(state)
                }
        }
    }
                        
    struct Constants {
        static let notificationDescriptionCharactersLimit = 86
        static let maxNotificationCounter = 99
        static let titleViewSpacing: CGFloat = 8
        static let minCounterViewWidth: CGFloat = 22
        static let pageSize = 32
    }
}
