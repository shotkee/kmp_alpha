//
//  TelemedicineInfoViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class TelemedicineInfoViewController: ViewController {
    struct Output {
        var telemedicine: () -> Void
    }

    var output: Output!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var telemedicineButton: RoundEdgeButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("telemedicine_title", comment: "")

		telemedicineButton.setTitle(NSLocalizedString("telemedicine_start", comment: ""), for: .normal)
		telemedicineButton <~ Style.RoundedButton.redBackground
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Style.Margins.defaultInsets
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 30

        [
            (NSLocalizedString("telemedicine_about_1", comment: ""), UIImage(named: "icon-telemedicine-location")),
            (NSLocalizedString("telemedicine_about_2", comment: ""), UIImage(named: "icon-telemedicine-watch")),
            (NSLocalizedString("telemedicine_about_3", comment: ""), UIImage(named: "icon-telemedicine-stopwatch")),
        ].map(infoStackView).forEach(stackView.addArrangedSubview)
    }

    private func infoStackView(title: String, icon: UIImage?) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10

        let image = UIImageView(image: icon)
        stackView.addArrangedSubview(image)

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryText
		titleLabel.numberOfLines = 0
        titleLabel.text = title
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)

        return stackView
    }

    @IBAction func showTelemedicineTap(_ sender: UIButton) {
        output.telemedicine()
    }
}
