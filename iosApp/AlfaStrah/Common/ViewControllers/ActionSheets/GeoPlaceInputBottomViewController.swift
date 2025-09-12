//
//  GeoPlaceInputBottomViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 11.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class GeoPlaceInputBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let geoPlace: GeoPlace
    }
    struct Output {
        let close: () -> Void
        let done: (_ driverLicense: GeoPlace) -> Void
        let enterAddress: (String, String?, @escaping (Result<[GeoPlace], AlfastrahError>) -> Void) -> Void
        let buyPolicy: (ViewController) -> Void
    }

    var output: Output!
    var input: Input!

    private lazy var regionNoteLabelView: CommonNoteLabelView = .init(frame: .zero)
    private lazy var cityNoteLabelView: CommonNoteLabelView = .init(frame: .zero)
    private lazy var streetNoteLabelView: CommonNoteLabelView = .init(frame: .zero)
    private lazy var houseNumberNoteLabelView: CommonNoteLabelView = .init(frame: .zero)
    private lazy var appartamentNumberInputView: CommonFieldView = .init(frame: .zero)

    private lazy var noteViews: [CommonNoteProtocol] = [
        regionNoteLabelView,
        cityNoteLabelView,
        streetNoteLabelView,
        houseNumberNoteLabelView,
        appartamentNumberInputView
    ]

    private lazy var selectedPlace: GeoPlace = input.geoPlace

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            guard self.isValid else { return }

            self.output.done(selectedPlace)
        }
    }

    var isValid: Bool {
        noteViews.allSatisfy { $0.isValid }
    }

    override func setupUI() {
        super.setupUI()

        set(title: NSLocalizedString("osago_prolongation_adress_input_title", comment: ""))
        set(views: [ regionNoteLabelView, cityNoteLabelView, streetNoteLabelView, houseNumberNoteLabelView, appartamentNumberInputView ])

        regionNoteLabelView.set(
            title: nil,
            note: input.geoPlace.region ?? "",
            placeholder: NSLocalizedString(
                "osago_prolongation_adress_placeholder_region",
                comment: ""
            ),
            style: .center(UIImage(named: "icon-checkmark-red-small")),
            margins: Style.Margins.defaultInsets,
            showSeparator: true
        )

        cityNoteLabelView.set(
            title: nil,
            note: input.geoPlace.city ?? "",
            placeholder: NSLocalizedString(
                "osago_prolongation_adress_placeholder_city",
                comment: ""
            ),
            style: .center(UIImage(named: "icon-checkmark-red-small")),
            margins: Style.Margins.defaultInsets,
            showSeparator: true
        )

        streetNoteLabelView.set(
            title: nil,
            note: input.geoPlace.street ?? "",
            margins: Style.Margins.defaultInsets,
            showSeparator: true,
            validationRules: [ RequiredValidationRule() ]
        )

        houseNumberNoteLabelView.set(
            title: nil,
            note: input.geoPlace.house ?? "",
            placeholder: NSLocalizedString(
                "osago_prolongation_adress_placeholder_house",
                comment: ""
            ),
            margins: Style.Margins.defaultInsets,
            showSeparator: true,
            validationRules: [ RequiredValidationRule() ]
        )

        appartamentNumberInputView.set(
            text: input.geoPlace.apartment ?? "",
            placeholder: NSLocalizedString(
                "osago_prolongation_adress_placeholder_appartament_number",
                comment: ""
            ),
            margins: Style.Margins.defaultInsets,
            showSeparator: true,
            keyboardType: .numberPad,
            validationRules: [ RequiredValidationRule(), OnlyNumbersValidationRule() ]
        )

        appartamentNumberInputView.textFieldChangedCallback = { [unowned self] _ in
            appartamentNumberInputView.validate()
            self.selectedPlace.apartment = appartamentNumberInputView.currentText ?? ""
            self.set(doneButtonEnabled: self.isValid)
        }

        streetNoteLabelView.tapHandler = { [weak self] in
            guard let `self` = self else { return }

            self.showPlacePicker(place: self.selectedPlace, type: .street) { [weak self] value in
                guard let `self` = self else { return }

                self.streetNoteLabelView.updateText(value.street ?? "")
                self.houseNumberNoteLabelView.updateText("")
                self.appartamentNumberInputView.updateText("")
                self.selectedPlace = value
                self.set(doneButtonEnabled: self.isValid)
            }
        }

        houseNumberNoteLabelView.tapHandler = { [weak self] in
            guard let `self` = self else { return }

            self.showPlacePicker(place: self.selectedPlace, type: .house) { [weak self] value in
                guard let `self` = self else { return }

                self.houseNumberNoteLabelView.updateText(value.house ?? "")
                self.appartamentNumberInputView.updateText("")
                self.selectedPlace = value
                self.set(doneButtonEnabled: self.isValid)
            }
        }

        set(doneButtonEnabled: self.isValid)
    }

    private func showPlacePicker(
        place: GeoPlace,
        type: OSAGOAdressInputViewController.ContentType,
        completion: @escaping (GeoPlace) -> Void
    ) {
        let controller: OSAGOAdressInputViewController = .init()
        controller.input = .init(geoPlace: place)
        controller.output = .init(
            enterAddress: output.enterAddress,
            selectAddress: { place in
                controller.dismiss(animated: true) {
                    completion(place)
                }
            },
            buyPolicy: { [weak self] from in
                self?.output.buyPolicy(from)
            }
        )

        controller.type = type

        controller.addCloseButton {
            self.dismiss(animated: true)
        }

        let navigationController = RMRNavigationController(rootViewController: controller)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()

        present(navigationController, animated: true)
    }
}
