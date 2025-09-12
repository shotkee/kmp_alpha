//
//  AutoEventPhotoStepsListViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class AutoEventPhotoStepsListViewController: ViewController,
											 AttachmentServiceDependency {
    var attachmentService: AttachmentService!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var continueButton: RoundEdgeButton!

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

		view.backgroundColor = .Background.backgroundContent
		continueButton <~ Style.RoundedButton.redBackground
		
        updateUI()
    }

    // MARK: - Setup UI

    private func updateUI() {
        title = input.photoGroup.title

        continueButton <~ Style.Button.ActionRed(title: NSLocalizedString("auto_event_save_photos", comment: ""))
        stackView.subviews.forEach { $0.removeFromSuperview() }

        if let hint = input.photoGroup.hint {
            let attentionView = CommonAttentionView()
            attentionView.set(message: hint, appearance: .gray)
            stackView.addArrangedSubview(attentionView)
        }

        input.photoGroup.steps.enumerated().forEach { index, step in
            let stepView = AddPhotoStepView.fromNib()
            let title = String(
                format: NSLocalizedString("auto_event_photo_step_value", comment: ""),
                "\(index + 1)"
            )
            let data = step.attachments.first.flatMap { attachmentService.load(attachment: $0) }
            let image = data.flatMap { UIImage(data: $0) }
            stepView.set(title: title, text: step.title, image: image) { [weak self] in
                self?.output.addPhoto(step)
            }
            stackView.addArrangedSubview(stepView)
        }
    }

    @IBAction private func closeTap() {
        output.goBack()
    }
}
