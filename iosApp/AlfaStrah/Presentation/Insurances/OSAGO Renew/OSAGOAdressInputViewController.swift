//
//  OSAGOAdressInputViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 11.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OSAGOAdressInputViewController: ViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Init UI

    private lazy var tableView: UITableView = {
        let tableView: UITableView = .init(frame: .zero)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

        tableView.registerReusableCell(OSAGOAdressInputTableViewCell.id)

        return tableView
    }()

    private lazy var containerStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 6

        return stack
    }()

    private lazy var containerContentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 0

        return stack
    }()

    private lazy var noLocationContentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 12

        return stack
    }()

    private lazy var containerContentView: UIView = {
        let view: UIView = .init(frame: .zero)

        return view
    }()

    private lazy var noLocationFoundView: UIView = {
        let view: UIView = .init(frame: .zero)
        let gesture: UITapGestureRecognizer = .init(target: self, action: #selector(notFoundViewTap(_:)))

        view.isHidden = true
        view.addGestureRecognizer(gesture)
        view.backgroundColor = Style.Color.Palette.white

        return view
    }()

    private lazy var hairLineView: HairLineView = {
        let view: HairLineView = .init(frame: .zero)

        return view
    }()

    private lazy var noLocationImageView: UIImageView = {
        let imageView: UIImageView = .init(frame: .zero)
        let image = UIImage(named: "ico-location-not-found")

        imageView.contentMode = .scaleAspectFit
        imageView.image = image

        return imageView
    }()

    private lazy var noLocationTitleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.primaryHeadline1
        label.text = NSLocalizedString("text_address_input_not_found_title", comment: "")
        label.textAlignment = .center

        return label
    }()

    private lazy var noLocationInfoLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.secondaryText
        label.text = NSLocalizedString("osago_prolongation_adress_search_error", comment: "")
        label.textAlignment = .center

        return label
    }()

    private lazy var addressInputTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero)
        textField.delegate = self
        textField.placeholder = type.placeholderText
        textField.addTarget(self, action: #selector(addressInputEditingChanged(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(addressInputDoneTap(_:)), for: .primaryActionTriggered)

        return textField
    }()

    private lazy var clearButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        let image = UIImage(named: "icon-close-white")

        button.addTarget(self, action: #selector(clearButtonTap(_:)), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.tintColor = Style.Color.Palette.lightGray

        return button
    }()

    private lazy var noLocationBuyButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        button.setTitle(NSLocalizedString("insurance_new_buy", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(noLocationBuy(_:)), for: .touchUpInside)

        return button
    }()

    enum ContentType {
        case street
        case house

        var title: String {
            switch self {
                case .street:
                    return NSLocalizedString("osago_prolongation_adress_search_street_title", comment: "")
                case .house:
                    return NSLocalizedString("osago_prolongation_adress_search_house_title", comment: "")
            }
        }

        var placeholderText: String {
            switch self {
                case .street:
                    return NSLocalizedString("osago_prolongation_adress_placeholder_street", comment: "")
                case .house:
                    return NSLocalizedString("osago_prolongation_adress_placeholder_house", comment: "")
            }
        }

        func value(_ place: GeoPlace) -> String {
            switch self {
                case .street:
                    return place.street ?? ""
                case .house:
                    return place.house ?? ""
            }
        }
    }

    struct Input {
        let geoPlace: GeoPlace
    }

    struct Output {
        let enterAddress: (String, String?, @escaping (Result<[GeoPlace], AlfastrahError>) -> Void) -> Void
        let selectAddress: (GeoPlace) -> Void
        let buyPolicy: (ViewController) -> Void
    }

    private let debouncer = Debouncer(milliseconds: 1000)
    private var places: [GeoPlace] = []
    private var isInitialSearch: Bool = true
    private var searchString: String? {
        guard let text = addressInputTextField.text, !text.isEmpty else { return nil }

        switch type {
            case .street:
                return "\(input.geoPlace.city ?? "") \(text)"
            case .house:
                return "\(input.geoPlace.city ?? "") \(input.geoPlace.street ?? "") \(text)"
        }
    }

    var input: Input!
    var output: Output!
    var type: ContentType = .street

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(containerStackView)
        view.addSubview(tableView)
        view.addSubview(noLocationFoundView)

        containerStackView.addArrangedSubview(containerContentView)
        containerStackView.addArrangedSubview(hairLineView)

        containerContentStackView.addArrangedSubview(addressInputTextField)
        containerContentStackView.addArrangedSubview(clearButton)

        noLocationContentStackView.addArrangedSubview(noLocationImageView)
        noLocationContentStackView.addArrangedSubview(noLocationTitleLabel)
        noLocationContentStackView.addArrangedSubview(noLocationInfoLabel)

        containerContentView.addSubview(containerContentStackView)
        containerContentView.addSubview(hairLineView)

        noLocationFoundView.addSubview(noLocationContentStackView)
        noLocationFoundView.addSubview(noLocationBuyButton)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerContentStackView.translatesAutoresizingMaskIntoConstraints = false
        noLocationContentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerContentView.translatesAutoresizingMaskIntoConstraints = false
        noLocationFoundView.translatesAutoresizingMaskIntoConstraints = false
        hairLineView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        noLocationBuyButton.translatesAutoresizingMaskIntoConstraints = false
        addressInputTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: containerStackView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),

            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -18),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),

            containerContentStackView.topAnchor.constraint(equalTo: containerContentView.topAnchor),
            containerContentStackView.bottomAnchor.constraint(equalTo: containerContentView.bottomAnchor),
            containerContentStackView.rightAnchor.constraint(equalTo: containerContentView.rightAnchor),
            containerContentStackView.leadingAnchor.constraint(equalTo: containerContentView.leadingAnchor),

            noLocationContentStackView.centerYAnchor.constraint(equalTo: noLocationFoundView.centerYAnchor, constant: -48),
            noLocationContentStackView.rightAnchor.constraint(equalTo: noLocationFoundView.rightAnchor, constant: -32),
            noLocationContentStackView.leadingAnchor.constraint(equalTo: noLocationFoundView.leadingAnchor, constant: 32),

            noLocationFoundView.topAnchor.constraint(equalTo: containerStackView.bottomAnchor),
            noLocationFoundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            noLocationFoundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            noLocationFoundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),

            hairLineView.heightAnchor.constraint(equalToConstant: 1),

            containerContentView.heightAnchor.constraint(equalToConstant: 54),

            clearButton.heightAnchor.constraint(equalToConstant: 44),
            clearButton.widthAnchor.constraint(equalToConstant: 44),

            noLocationBuyButton.heightAnchor.constraint(equalToConstant: 48),
            noLocationBuyButton.bottomAnchor.constraint(equalTo: noLocationFoundView.bottomAnchor, constant: -6),
            noLocationBuyButton.rightAnchor.constraint(equalTo: noLocationFoundView.rightAnchor, constant: -18),
            noLocationBuyButton.leadingAnchor.constraint(equalTo: noLocationFoundView.leadingAnchor, constant: 18),

            addressInputTextField.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    private func setupUI() {
        title = type.title
        view.backgroundColor = Style.Color.Palette.white

        addressInputTextField.becomeFirstResponder()

        updateUI()
    }

    private func updateUI() {
        let isTextEmpty = (searchString ?? "").isEmpty
        clearButton.isHidden = isTextEmpty

        guard !isInitialSearch else {
            isInitialSearch = false
            return
        }

        debouncer.debounce { [weak self] in
            guard let self = self else { return }

            self.searchAddress(textField: self.addressInputTextField)
        }
    }

    private func searchAddress(textField: UITextField) {
        guard let text = searchString else { return }

        output.enterAddress(text, nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let places):
                    switch self.type {
                        case .street:
                            self.places = places.filter { $0.street != nil }
                        case .house:
                            self.places = places.filter { $0.house != nil }
                    }
                case .failure(let error):
                    self.places = []
                    self.alertPresenter.show(alert: BasicNotificationAlert(text: error.displayValue ?? ""))
            }
            self.tableView.reloadData()
            self.noLocationFoundView.isHidden = !self.places.isEmpty || text.isEmpty
        }
    }

    // MARK: - Actions

    @objc private func noLocationBuy(_ sender: UIButton) {
        output.buyPolicy(self)
    }

    @objc private func addressInputEditingChanged(_ sender: UITextField) {
        updateUI()
    }

    @objc private func addressInputDoneTap(_ sender: UITextField) {
        searchAddress(textField: sender)
    }

    @objc private func clearButtonTap(_ sender: UIButton) {
        addressInputTextField.text = nil
        updateUI()
    }

    @objc func notFoundViewTap(_ sender: UITapGestureRecognizer) {
        addressInputTextField.resignFirstResponder()
    }

    // MARK: - Table View Delegate & Data Source

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.selectAddress(places[indexPath.row])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(OSAGOAdressInputTableViewCell.id)
        let place = places[indexPath.row]

        cell.set(value: self.type.value(place))

        return cell
    }

    // MARK: - Text Field Delegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateUI()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateUI()
    }
}
