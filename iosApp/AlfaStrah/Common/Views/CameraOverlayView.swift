//
//  CameraOverlayView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class CameraOverlayView: UIView {
    struct Input {
        var hint: Bool
        var flashAvailable: Bool
    }

    struct Output {
        var takePhotoTap: () -> Void
        var usePhotoTap: () -> Void
        var flashTap: () -> Void
        var cancelTap: () -> Void
        var showHintTap: () -> Void
    }

    struct Notify {
		var photosUpdated: (_ pickedCount: Int) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        photosUpdated: { [weak self] pickedCount in
			self?.updateUI(with: pickedCount)
        }
    )

    @IBOutlet private var usePhotoButton: RMRRedSubtitleButton!
    @IBOutlet private var flashButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var takePhotoButton: UIButton!
    @IBOutlet private var showHintButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        usePhotoButton.tintColor = Style.Color.Palette.white
        cancelButton.tintColor = Style.Color.Palette.white
        flashButton.tintColor = Style.Color.Palette.white
        takePhotoButton.tintColor = Style.Color.Palette.white
        flashButton.setImage(UIImage(named: "ico-camera-flash"), for: .normal)
        flashButton.setImage(UIImage(named: "ico-camera-flash-pressed"), for: .selected)
        usePhotoButton.title = NSLocalizedString("photos_use_title", comment: "")
		
		usePhotoButton.isHidden = true
    }

	private func updateUI(with pickedImagesCount: Int) {
        flashButton.isHidden = !input.flashAvailable
        showHintButton.isHidden = !input.hint
        usePhotoButton.isHidden = !(pickedImagesCount > 0)
        usePhotoButton.subtitle = String(
            format: NSLocalizedString("photos_count_value", comment: ""),
            "\(pickedImagesCount)"
        )
    }

    @IBAction private func usePhotoTap(_ sender: UIButton) {
        output.usePhotoTap()
    }

    @IBAction private func takePhotoTap(_ sender: UIButton) {
        output.takePhotoTap()
    }

    @IBAction private func flashTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        output.flashTap()
    }

    @IBAction private func cancelTap(_ sender: UIButton) {
        output.cancelTap()
    }

    @IBAction private func showHintTap(_ sender: UIButton) {
        output.showHintTap()
    }
}
