//
//  ClinicPickerViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 06/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class ClinicPickerViewController: ViewController {
    struct Input {
        var selectedCity: () -> CityWithMetro?
        var hasActiveFilters: () -> Bool
        var clinicsListPickerView: UIView
        var mapPickerView: UIView
    }

    struct Output {
        var selectCity: () -> Void
        var selectTreatmentFilters: () -> Void
        var resetTreatmentFilters: () -> Void
    }

    struct Notify {
        var changed: () -> Void
		var updateVisibleRightBarButton: (Bool) -> Void
		var updateFilter: (SelectClinicFilter?) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let self = self, self.isViewLoaded else { return }

            self.update()
        },
		updateVisibleRightBarButton:
		{
			[weak self] isVisible in
			
			self?.updateVisibleRightButton(isVisible: isVisible)
		},
		updateFilter:
		{
			[weak self] newSelectClinicFilter in
			
			if let selectClinicFilter = newSelectClinicFilter
			{
				self?.selectClinicFilter = selectClinicFilter
			}
			else
			{
				self?.selectClinicFilter = .init()
			}
			
			self?.updateVisibleRightButton(isVisible: true)
		}
    )


    @IBOutlet weak var stateSegmentedControlView: RMRStyledSwitch!
    @IBOutlet private var clinicsListView: UIView!
    @IBOutlet private var mapView: UIView!

	private var selectClinicFilter: SelectClinicFilter = .init()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-close"), style: .plain, target: self,
                action: #selector(close))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    // MARK: - Setup UI

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
        title = NSLocalizedString("clinics_picker_title", comment: "")

        clinicsListView.addSubview(input.clinicsListPickerView)
        mapView.addSubview(input.mapPickerView)
        NSLayoutConstraint.activate(Array([
            NSLayoutConstraint.fill(view: input.clinicsListPickerView, in: clinicsListView),
            NSLayoutConstraint.fill(view: input.mapPickerView, in: mapView),
        ].joined()))
		updateVisibleRightButton(isVisible: false)
    }

    private func update() {
        updateSegmentedControl()
    }

    private func updateSegmentedControl() {
        let tabs: [State] = [.clinics, .map]

        guard availableStates != tabs 
		else { return }

        availableStates = tabs
		
		stateSegmentedControlView.style(
			leftTitle: NSLocalizedString("clinic_picker_cities_list", comment: ""),
			rightTitle: NSLocalizedString("clinic_picker_map", comment: ""),
			titleColor: .Text.textPrimary,
			backgroundColor: .Background.backgroundTertiary,
			selectedTitleColor: .Text.textContrast,
			selectedBackgroundColor: .Background.segmentedControlAccent
		)
		
		onStateIndexChanged(selectedIndex: 0)
    }
	
	@IBAction func switchTap(_ sender: RMRStyledSwitch) 
	{
		self.onStateIndexChanged(selectedIndex: sender.selectedIndex)
	}

    // MARK: - Updates

    private var availableStates: [State] = []

    private enum State {
        case clinics
        case map

        var title: String {
            switch self {
                case .clinics:
                    return NSLocalizedString("clinic_picker_cities_list", comment: "")
                case .map:
                    return NSLocalizedString("clinic_picker_map", comment: "")
            }
        }
    }
	
	func updateVisibleRightButton(isVisible: Bool)
	{
		if !isVisible
		{
			self.navigationItem.rightBarButtonItem = nil
		}
		else
		{
			addRightButton(
				image: selectClinicFilter.isEmpty
					? UIImage.Icons.filterSecondary
					: UIImage.Icons.filterActiveSecondary,
				action:
			 {
				 [weak self] in
				 
				 self?.output.selectTreatmentFilters()
			 }
			)
		}
	}

    private var state: State = .clinics {
        didSet {
            updateState()
        }
    }

    /// Updates UI according to state.
    private func updateState() {
        view.endEditing(true)
        clinicsListView.isHidden = state != .clinics
        mapView.isHidden = state != .map
    }

    // MARK: - Actions

    private func onStateIndexChanged(selectedIndex: Int) {
        guard let selectedState = availableStates[safe: selectedIndex]
        else { return }

        state = selectedState
    }
}
