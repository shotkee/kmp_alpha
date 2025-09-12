//
//  AutoEventPhotoDamagePickerViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class AutoEventPhotoDamagePickerViewController: ViewController {
    @IBOutlet private var continueButton: RoundEdgeButton!
    @IBOutlet private var tipLabel: UILabel!
    @IBOutlet private var photosCountLabel: UILabel!
    @IBOutlet private var damageButtons: [UIButton]!
	@IBOutlet private var autoDamageSchemeImageView: UIImageView!
	
	struct Input {
        var photoGroup: PhotoGroup
    }

    struct Output {
        var addPhoto: (AutoPhotoStep) -> Void
        var goBack: () -> Void
    }

    struct Notify {
        var photosUpdated: () -> Void
    }

    private struct ButtonInfo {
        let button: UIButton
        var step: AutoPhotoStep
    }

    private var buttonsDictionary: [Int: ButtonInfo] = [:]

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        photosUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    // MARK: - Setup UI

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = input.photoGroup.title
		
		autoDamageSchemeImageView.image = UIImage(named: "ico-kasko-scheme")?.tintedImage(withColor: .Icons.iconPrimary)

		continueButton <~ Style.RoundedButton.redBackground
		continueButton.setTitle(NSLocalizedString("auto_event_save_photos", comment: ""), for: .normal)
		
        tipLabel <~ Style.Label.secondarySubhead
        photosCountLabel <~ Style.Label.secondarySubhead
        for damageButton in damageButtons {
            damageButton.addTarget(self, action: #selector(damageButtomTap(damageButtom:)), for: .touchUpInside)
            if let step = input.photoGroup.steps.first(where: { $0.stepId == damageButton.tag }) {
                buttonsDictionary[step.stepId] = ButtonInfo(button: damageButton, step: step)
            }
        }
    }

    private func updateUI() {
        for buttonInfo in buttonsDictionary.values {
            let image: UIImage?
            switch buttonInfo.step.status {
                case .ready:
					image = UIImage(named: "ico-place-photo-ok")?.tintedImage(withColor: .Pallete.accentGreen)
                case .required:
					image = UIImage(named: "ico-place-photo-ok-pressed")?.tintedImage(withColor: .Icons.iconAccent)
                case .optional:
					image = UIImage(named: "ico-place-photo-ok-empty")?.tintedImage(withColor: .Icons.iconSecondary)
            }
            buttonInfo.button.setImage(image, for: .normal)
			buttonInfo.button.tintColor = .Icons.iconSecondary
        }
    }

    @IBAction private func damageButtomTap(damageButtom: UIButton) {
        if let step = buttonsDictionary[damageButtom.tag]?.step {
            output.addPhoto(step)
        }
    }

    @IBAction private func closeTap() {
        output.goBack()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		updateUI()
		
		let autoDamageSchemeImage = autoDamageSchemeImageView.image
		autoDamageSchemeImageView.image = autoDamageSchemeImage?.tintedImage(withColor: .Icons.iconPrimary)
	}
}
