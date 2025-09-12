//
//  SosPhoneListViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 25/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class SosPhoneListViewController: ViewController {
    struct Input {
        var categoryKind: InsuranceCategoryMain.CategoryType
        var sosActivity: SosActivityModel
        var voipCall: Bool
    }

    struct Output {
        var phone: (SosPhone) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 28, left: 19, bottom: 28, right: 19)
        stackView.spacing = 18

        switch input.categoryKind {
            case .health, .property:
                title = NSLocalizedString("sos_phonecall_title", comment: "")
            case .travel:
                title = NSLocalizedString("sos_insurance_title", comment: "")
            case .auto, .life, .passengers, .unsupported:
                break
        }
        updateUI()
    }
    
    private func updateUI() {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        let phones = input.voipCall
            ? input.sosActivity.sosPhoneList.filter { $0.voipCall != nil }
            : input.sosActivity.sosPhoneList

        for phone in phones {
            let sosInfoView = SosInfoView.fromNib()
            sosInfoView.set(
                mode: .header,
                title: NSLocalizedString(
                    "sos_travel_online_call_title",
                    comment: ""
                ),
                description: phone.title,
                icon: UIImage(named: "icon-accessory-arrow"),
                isActive: true
            ) { [weak self] in
                self?.output.phone(phone)
            }

            let cardView = CardView(contentView: sosInfoView)
            stackView.addArrangedSubview(cardView)
        }
    }
}
