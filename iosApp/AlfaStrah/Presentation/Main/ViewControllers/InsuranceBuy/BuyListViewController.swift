//
//  BuyListViewController.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 08/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class BuyListViewController: ViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             UICollectionViewDelegate,
                             UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout {
    enum State {
        case loading
        case failure
        case filled([InsuranceProductCategory])
    }
    
    private var tableView: UITableView = .init(frame: .zero, style: .grouped)
    private let operationStatusView = OperationStatusView()
    private var containerCollectionView = UIView()
    private lazy var collectionView: UICollectionView = {
        let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        value.backgroundColor = .clear
        value.delegate = self
        value.dataSource = self
        value.showsHorizontalScrollIndicator = false
        value.showsVerticalScrollIndicator = false
        value.registerReusableCell(InsuranceProductFilterCollectionViewCell.id)
        
        return value
    }()
    
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let value: UICollectionViewFlowLayout = .init()
        value.scrollDirection = .horizontal
        value.minimumInteritemSpacing = 9
        value.minimumLineSpacing = 9
        value.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        return value
    }()
    
    var input: Input!
    var output: Output!
    
    // MARK: - Variables
    private var insuranceProductCategory: [InsuranceProductCategory] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var filterArray: [String] = []
    private var firstWillAppear = true
    private var firstDidAppear = true
    private var state: State?
    
    struct Input {
        let showButtonsAndHeader: Bool
        let title: String
        let insurances: () -> Void
        let filterCategoryInsurances: (String) -> [InsuranceProductCategory]
    }

    struct Output {
        var goToChat: () -> Void
        var openChatTab: () -> Void
        var openOffices: () -> Void
        var pushToAboutInsuranceProduct: (InsuranceProduct) -> Void
    }
    
    struct Notify {
        var updateWithState: (_ state: State) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWithState: { [weak self] in
            self?.update(with: $0)
        }
    )
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstWillAppear {
            getInsuranceProductCategory()
            firstWillAppear = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update must be placed here because the lottie-animation can only be started from didAppear method
        // https://github.com/airbnb/lottie-ios/issues/510#issuecomment-1092509674
        
        if firstDidAppear && state == nil {
            update(with: .loading)
            firstDidAppear = false
        }
		
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func getInsuranceProductCategory() {
        input.insurances()
    }
    
    private func update(with state: State) {
        self.state = state
        
        switch state {
            case .loading:
                self.operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString(
                        "buy_insurance_loading_text",
                        comment: ""
                    ),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
                self.tableView.isHidden = true
                self.containerCollectionView.isHidden = true
            
            case .failure:
                self.operationStatusView.isHidden = false
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString(
                        "buy_insurance_error_text",
                        comment: ""
                    ),
                    description: NSLocalizedString(
                        "buy_insurance_error_description",
                        comment: ""
                    ),
                    icon: UIImage(named: "icon-common-failure")
                ))
            
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("buy_insurance_error_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: { [weak self] in
                            self?.output.goToChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("buy_insurance_retry_title_button", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            self?.update(with: .loading)
                            self?.getInsuranceProductCategory()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
                self.tableView.isHidden = true
                self.containerCollectionView.isHidden = true
            
            case .filled(let insuranceProductCategory):
                self.insuranceProductCategory = insuranceProductCategory
                if insuranceProductCategory.isEmpty {
                    let state: OperationStatusView.State = .info(.init(
                        title: NSLocalizedString("buy_insurance_empty_title", comment: ""),
                        description: NSLocalizedString("buy_insurance_empty_description", comment: ""),
						icon: .Illustrations.searchEmpty
                    ))
                    operationStatusView.notify.updateState(state)
                    self.operationStatusView.isHidden = false
                    self.tableView.isHidden = true
                    self.containerCollectionView.isHidden = true
                } else {
                    self.operationStatusView.isHidden = true
                    self.tableView.isHidden = false
                    setupFiltersArray()
                }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .Background.backgroundContent
        title = NSLocalizedString("tabbar_products_title", comment: "")
        navigationItem.title = input.title
        setupTableView()
        setupContainerCollectionView()
        setupCollectionView()
        setupOperationStatusView()
        selectedFirstFilter()
    }
    
    private func setupButtonViews() -> UIView {
        let officeView = createButtonView(
            image: UIImage.Icons.location2,
            title: NSLocalizedString("offices_button_title", comment: ""),
            action: #selector(officeButtonTap)
        )
                
        let chatView = createButtonView(
            image: UIImage.Icons.chat,
            title: NSLocalizedString("chat_title", comment: ""),
            action: #selector(chatButtonTap)
        )

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.addArrangedSubview(officeView)
        stackView.addArrangedSubview(chatView)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        backgroundView.addSubview(stackView)
        stackView.horizontalToSuperview(insets: .horizontal(18))
        stackView.verticalToSuperview()
        stackView.height(73)
        
        return backgroundView
    }
    
    private func createButtonView(image: UIImage?, title: String, action: Selector?) -> CardView {
        let buttonView = UIView()
        buttonView.backgroundColor = .clear
        
        let imageContainerView = UIView()
        imageContainerView.layer.cornerRadius = 10
        imageContainerView.backgroundColor = .Background.backgroundTertiary
        
        let imageView = UIImageView(image: image)
        imageView.tintColor = .Icons.iconAccent
        
        let label = UILabel()
        label <~ Style.Label.primaryHeadline1
        label.text = title
        buttonView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        buttonView.addSubview(label)
        
        imageContainerView.edgesToSuperview(excluding: .trailing, insets: insets(16))
        imageView.edgesToSuperview(insets: insets(8))
        imageView.height(24)
        imageView.aspectRatio(1)
        
        label.edgesToSuperview(excluding: .leading, insets: insets(16))
        label.leadingToTrailing(of: imageContainerView, offset: 12)
 
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
        buttonView.addGestureRecognizer(tapGestureRecognizer)
        
        let cardView = CardView(contentView: buttonView)
        cardView.contentColor = .Background.backgroundSecondary
        cardView.highlightedColor = .States.backgroundSecondaryPressed
        return cardView
    }
    
    @objc private func chatButtonTap() {
        output.openChatTab()
    }
    
    @objc private func officeButtonTap() {
        output.openOffices()
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(InsuranceProductTableViewCell.id)
        view.addSubview(tableView)
        tableView.edgesToSuperview()
    }

    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.edgesToSuperview()
    }
    
    private func setupContainerCollectionView() {
        containerCollectionView.backgroundColor = .clear
        containerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerCollectionView)
        NSLayoutConstraint.activate([
            containerCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            containerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerCollectionView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: containerCollectionView.topAnchor, constant: 18),
            collectionView.leadingAnchor.constraint(equalTo: containerCollectionView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerCollectionView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerCollectionView.bottomAnchor, constant: -12),
            collectionView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupFiltersArray() {        
        filterArray += insuranceProductCategory.filter { $0.showInFilters }.map { $0.title }
        containerCollectionView.isHidden = filterArray.count < 1
        collectionView.reloadData()
        selectedFirstFilter()
    }
    
    private func selectedFirstFilter() {
        guard let filterName = filterArray.first else {
            return
        }
        
        insuranceProductCategory = input.filterCategoryInsurances(filterName)
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        insuranceProductCategory[section].productList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        insuranceProductCategory.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let stackView = UIStackView()
            stackView.axis = .vertical
            
            if input.showButtonsAndHeader {
                let labelBackgroundView = UIView()
                let label = UILabel()
                label <~ Style.Label.primaryTitle1
                label.text = NSLocalizedString("buy_insurance_title", comment: "")
                labelBackgroundView.addSubview(label)
                label.horizontalToSuperview(insets: .horizontal(18))
                label.verticalToSuperview(insets: .vertical(4))
                let buttonViews = setupButtonViews()
                stackView.addArrangedSubview(buttonViews)
                stackView.setCustomSpacing(20, after: buttonViews)
                stackView.addArrangedSubview(labelBackgroundView)
            }
            
            stackView.addArrangedSubview(containerCollectionView)
            
            return stackView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let insuranceProduct = insuranceProductCategory[safe: indexPath.section]?.productList[safe: indexPath.row]
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(InsuranceProductTableViewCell.id)
        cell.selectionStyle = .none
        cell.configure(insuranceProduct: insuranceProduct)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let insuranceProduct = insuranceProductCategory[safe: indexPath.section]?.productList[safe: indexPath.row]
        else { return }
        
        output.pushToAboutInsuranceProduct(insuranceProduct)
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterArray.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let widthLabel = filterArray[indexPath.item].width(
            withConstrainedHeight: 18,
            font: Style.Font.text
        )
        
        return CGSize(
            width: widthLabel + 30,
            height: 30
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            InsuranceProductFilterCollectionViewCell.id,
            indexPath: indexPath
        )
        
        cell.configure(
            title: filterArray[indexPath.item]
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let filter = filterArray[safe: indexPath.item]
        else { return }
        
        self.insuranceProductCategory = input.filterCategoryInsurances(filter)
    }
}
