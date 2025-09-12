//
//  CircumstancesAccidentPhotoViewController
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 05.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class CircumstancesAccidentPhotoViewController: EuroProtocolBaseViewController, EuroProtocolServiceDependency {
    struct Output {
        let takePhoto: ( _ result: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void) -> Void
        let removePhoto: (_ result: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void) -> Void
        let save: () -> Void
    }

    struct Input {
        let currentImage: () -> (Result<UIImage?, EuroProtocolServiceError>)
    }

    var output: Output!
    var input: Input!

    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 26

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value <~ Style.Label.secondaryText
        value.textAlignment = .left
        value.numberOfLines = 0

        return value
    }()

    private lazy var nextButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var pickerView: PhotoPickerView = {
        let value = PhotoPickerView()
        value.output = .init(
            selected: { [unowned self] index in self.addPhoto(index: index, pickerView: value) },
            delete: { [unowned self]  _, completion in self.deletePhoto(completion: completion) },
            photosPicked: { [unowned self] amount in
                self.nextButton.isEnabled = amount == 1 ? true : false
            }
        )
        return value
    }()

    var euroProtocolService: EuroProtocolService!

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()

        euroProtocolService.subscribeForPermissionsStatusUpdates { [weak self] status in
            self?.handlePermissions(status: status)
        }.disposed(by: self.disposeBag)

        handlePermissions(status: euroProtocolService.permissionsStatus)
    }

    private func commonSetup() {
        view.addSubview(rootStackView)
        view.addSubview(nextButton)

        rootStackView.addArrangedSubview(infoLabel)
        rootStackView.addArrangedSubview(pickerView)

        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            rootStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_accident_photo_title", comment: "")
        infoLabel.text = NSLocalizedString("insurance_euro_protocol_accident_photo_info", comment: "")

        pickerView.configure(
            type: .camera,
            size: .small,
            numberOfCards: 1,
            shouldShowInfoString: true
        )

        switch input.currentImage() {
            case .success(let image):
                pickerView.set(image, at: 0)
            case .failure(let error):
                processError(error)
        }
    }

    private func handlePermissions(status: EuroProtocolServicePermissionsStatus) {
        switch status {
            case .unknown, .cameraAccessRequired, .locationPermissionRequired, .photoStoragePermissionRequired:
                let permissionsCards = CommonPermissionsView.PermissionCardInfo.euroProtocolPermissions
                zeroView?.update(viewModel: .init(kind: .permissionsRequired(permissionsCards)))
                showZeroView()
            case .permissionsGranted:
                hideZeroView()
        }
    }

    private func addPhoto(index: Int, pickerView: PhotoPickerView) {
        output.takePhoto { result in
            switch result {
                case .success(let image):
                    pickerView.set(image, at: index)
                case .failure(let error):
                    switch error {
                        case .sdkError(.didCancelCamera):
                            break
                        default:
                            self.processError(error)
                    }
            }
        }
    }

    private func deletePhoto(completion: @escaping (Bool) -> Void) {
        output.removePhoto { result in
            switch result {
                case .success:
                    completion(true)
                default:
                    completion(false)
            }
        }
    }

    @objc private func nextButtonAction() {
        output.save()
    }
}
