//
//  CircumstancesAccidentDateViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 22.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class CircumstancesAccidentDateViewController: EuroProtocolBaseViewController {
    private lazy var contentStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill

        return value
    }()

    private lazy var dateInputView: SmallValueCardView = {
        let value = SmallValueCardView()
        value.set(
            title: NSLocalizedString("insurance_euro_protocol_accident_date_card_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_accident_date_card_title", comment: ""),
            value: input.date != nil ? AppLocale.dateString(input.date ?? Date()) : "",
            error: nil
        )

        value.tapHandler = { [unowned self] in
            self.openDateInputBottomViewController(
                currentDate: self.selectedDate ?? Date()
            ) { [unowned self] date in
                value.update(value: AppLocale.dateString(date))
                self.selectedDate = date
                self.updateUI()
            }
        }

        return value
    }()

    private lazy var timeInputView: SmallValueCardView = {
        let value = SmallValueCardView()
        value.set(
            title: NSLocalizedString("insurance_euro_protocol_accident_time_card_title", comment: ""),
            placeholder: NSLocalizedString("insurance_euro_protocol_accident_time_card_title", comment: ""),
            value: input.date != nil ? AppLocale.timeString(input.date ?? Date()) : "",
            error: nil
        )

        value.tapHandler = { [unowned self] in
            self.openTimeInputBottomViewController(
                currentDate: self.selectedDate ?? Date()
            ) { [unowned self] date in
                value.update(value: AppLocale.timeString(date))
                self.selectedDate = date
                self.updateUI()
            }
        }
        return value
    }()

    private lazy var cardView: CardView = {
        let stackView = UIStackView(arrangedSubviews: [dateInputView, timeInputView])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 1

        return CardView(contentView: stackView)
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    private var selectedDate: Date?

    struct Output {
        let save: (_ date: Date, _ completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) -> Void
    }

    struct Input {
        var date: Date?
    }

    var output: Output!
    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
        updateUI()
    }

    private func commonSetup() {
        view.addSubview(contentStackView)
        view.addSubview(saveButton)

        contentStackView.addArrangedSubview(cardView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_accident_date_title", comment: "")
        selectedDate = input.date
    }

    private func updateUI() {
        saveButton.isEnabled = selectedDate != nil && areInputsFilled()
    }

    private func openDateInputBottomViewController(currentDate: Date, completion: @escaping (Date) -> Void) {
        openBaseDateInputBottomViewController(
            title: NSLocalizedString("insurance_euro_protocol_accident_date_input_title", comment: ""),
            mode: .date,
            currentDate: currentDate,
            maximumDate: Date(),
            completion: completion
        )
    }

    private func openTimeInputBottomViewController(currentDate: Date, completion: @escaping (Date) -> Void) {
        openBaseDateInputBottomViewController(
            title: NSLocalizedString("insurance_euro_protocol_accident_time_input_title", comment: ""),
            mode: .time,
            currentDate: currentDate,
            completion: completion
        )
    }

    private func openBaseDateInputBottomViewController(
        title: String,
        mode: UIDatePicker.Mode,
        currentDate: Date = Date(),
        maximumDate: Date? = nil,
        completion: @escaping (Date) -> Void
    ) {
        let controller: DateInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: title,
            mode: mode,
            date: currentDate,
            maximumDate: dateByAdding(years: 1),
            minimumDate: dateByAdding(years: -1)
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },

            selectDate: { [unowned self] date in
                completion(date)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func dateByAdding(years: Int) -> Date? {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.year = years
        return AppLocale.calendar.date(byAdding: dateComponent, to: currentDate)
    }

    private func areInputsFilled() -> Bool {
        timeInputView.getValue() != "" && dateInputView.getValue() != ""
    }

    @objc private func saveButtonAction() {
        guard let date = selectedDate else { return }

        output.save(date) { [weak self] result in
            if case .failure(let error) = result {
                self?.processError(error)
            }
        }
    }
}
