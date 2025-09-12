//
//  OfficesFiltersViewController.swift
//  AlfaStrah
//
//  Created by Darya Viter on 13.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class OfficesFiltersViewController: ViewController {
    private enum Constants {
        static let allCities = NSLocalizedString("office_filters_list_position_all_cases", comment: "")
    }

    struct Input {
        let preselectedFilters: () -> OfficesFilter
    }

    struct Output {
        let modify: (OfficesFilter) -> Void
        let closeFilterScreen: () -> Void
        let openCitiesScreen: (_ preselectedCities: [City], _ completion: @escaping ([City]) -> Void) -> Void
        let backWithFilters: () -> Void
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var buttonsStackView: UIStackView!

    // Position

    private lazy var positionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.accessibilityIdentifier = #function
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 15

        return stackView
    }()

    private lazy var valueCardView: ValueCardView = {
        let cityValue: String = preselectedCities.isEmpty
            ? Constants.allCities
            : preselectedCities.map { $0.title }.joined(separator: ", ")
        let valueCardView = ValueCardView()
        valueCardView.set(
            title: NSLocalizedString("office_filters_list_city_card_title", comment: ""),
            placeholder: "",
            value: cityValue,
            error: nil,
            icon: .rightArrow,
            stateAppearance: .regular,
            isEnabled: true
        )
        valueCardView.tapHandler = { self.cityFilterDidTap() }
        return valueCardView
    }()

    // Services
    private var servicesCollectionContent: [(filter: OfficesFilter.OfficeFilterType, isSelected: Bool)] {
        filters[..<(filters.count - 1)].map { service in
            (filter: service, isSelected: preselectedServices.contains { $0.filterName == service.filterName })
        }
    }
    private lazy var servicesCollection: FilterChipsCollectionView = {
        let collection = FilterChipsCollectionView()
        collection.accessibilityIdentifier = #function
        collection.setup(
            with: NSLocalizedString("office_filters_list_services_section_title", comment: ""),
            content: servicesCollectionContent
        ) { self.serviceButtonDidTap(with: $0) }

        return collection
    }()

    // Time
    private var timeCollectionContent: [(filter: OfficesFilter.OfficeFilterType, isSelected: Bool)] {
        [.openNow].map { service in
            (filter: service, isSelected: preselectedServices.contains { $0.filterName == service.filterName })
        }
    }
    private lazy var timeCollection: FilterChipsCollectionView = {
        let collection = FilterChipsCollectionView()
        collection.accessibilityIdentifier = #function
        collection.setup(
            with: NSLocalizedString("office_filters_list_time_section_title", comment: ""),
            content: timeCollectionContent
        ) { self.serviceButtonDidTap(with: $0) }

        return collection
    }()

    // Bottom buttons

    private lazy var firstButton: RoundEdgeButton = {
        let button = RoundEdgeButton()
        button.setTitle(
            NSLocalizedString("office_filters_list_clean_all_button_title", comment: ""),
            for: .normal
        )
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        button.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        return button
    }()

    private lazy var secondButton: RoundEdgeButton = {
        let button = RoundEdgeButton()
        button.setTitle(
            NSLocalizedString("office_filters_list_apply_button_title", comment: ""),
            for: .normal
        )
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        button.addTarget(self, action: #selector(saveFiltersAndBack), for: .touchUpInside)
        return button
    }()

    private lazy var gradientView: GradientView = {
        var value: GradientView = .init(frame: .zero)
        value.startPoint = CGPoint(x: 0.5, y: 0)
        value.endPoint = CGPoint(x: 0.5, y: 1)

		value.startColor = .Background.backgroundContent.withAlphaComponent(0)
		value.endColor = .Background.backgroundContent
        value.update()
        return value
    }()

    var input: Input!
    var output: Output!

    private var preselectedCities: [City] {
        var citiesInInput: [City] = []
        input.preselectedFilters().officeFilters.forEach {
            switch $0 {
                case .city(let cities):
                    citiesInInput = cities
                default:
                    break
            }
        }
        return citiesInInput
    }

    private let filters: [OfficesFilter.OfficeFilterType] = [
        .sale, .claim, .cardPay, .osagoClaim, .telematicsInstall,
        .openNow
    ]
    private var preselectedServices: [OfficesFilter.OfficeFilterType] {
        var servicesInput: [OfficesFilter.OfficeFilterType] = []
        input.preselectedFilters().officeFilters.forEach {
            switch $0 {
                case .city, .searchString:
                    break
                default:
                    servicesInput.append($0)
            }
        }
        return servicesInput
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
		
		addCloseButton { self.output.closeFilterScreen() }
    }
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: gradientView.frame.height, right: 0)
    }

    // MARK: - Setup UI

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("office_filters_list_title", comment: "")
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
        addCitySection()
        addServicesSection()
        addTimeSection()
        setupButtonStackView()

        addCloseButton(action: { self.output.closeFilterScreen() })
    }

    private func addCitySection() {
        let cardTypeTitle = UILabel()
        cardTypeTitle.text = NSLocalizedString("office_filters_list_position_title", comment: "")
        cardTypeTitle <~ Style.Label.secondaryHeadline2

        positionStackView.addArrangedSubview(cardTypeTitle)
        positionStackView.addArrangedSubview(CardView(contentView: valueCardView))

        stackView.addArrangedSubview(positionStackView)
    }

    private func addServicesSection() {
        stackView.addArrangedSubview(servicesCollection)
    }

    private func addTimeSection() {
        stackView.addArrangedSubview(timeCollection)
    }

    private func setupButtonStackView() {
        buttonsStackView.addArrangedSubview(firstButton)
        buttonsStackView.addArrangedSubview(secondButton)
    }

    // MARK: Actions

    private func cityFilterDidTap() {
        output.openCitiesScreen(preselectedCities) { self.setSelectedCities($0) }
    }

    private func serviceButtonDidTap(with service: OfficesFilter.OfficeFilterType) {
        var filter = input.preselectedFilters()
        filter.officeFilters.contains { service.filterName == $0.filterName }
            ? filter.remove([ service ])
            : filter.addFilter(service)
        output.modify(filter)
    }

    @objc private func saveFiltersAndBack() {
        output.backWithFilters()
    }

    @objc private func clearFilters() {
        valueCardView.update(value: Constants.allCities)
        var filter = input.preselectedFilters()
        let filterTypes = filters + [.city([])]
        filter.remove(filterTypes)
        output.modify(filter)
        servicesCollection.reloadData(with: servicesCollectionContent)
        timeCollection.reloadData(with: timeCollectionContent)
    }

    private func setSelectedCities(_ cities: [City]) {
        var filter = input.preselectedFilters()
        filter.addFilter(.city(cities))
        output.modify(filter)
        let value = cities.map { $0.title }.joined(separator: ", ")
        valueCardView.update(value: value.isEmpty ? Constants.allCities : value )
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		gradientView.startColor = .Background.backgroundContent.withAlphaComponent(0)
		gradientView.endColor = .Background.backgroundContent
		gradientView.update()
	}
}
