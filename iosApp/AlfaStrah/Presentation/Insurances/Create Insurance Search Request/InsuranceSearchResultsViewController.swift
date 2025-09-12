//
//  InsuranceSearchResultsViewController.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 04.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class InsuranceSearchResultsViewController: RMRViewController {
    @IBOutlet private var checkBox: CheckBox?
    @IBOutlet private var emailSubscriptionLabel: UILabel?
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var hintLabel: UILabel?
    @IBOutlet private var mainButton: RoundEdgeButton!
    @IBOutlet private var secondaryButton: RoundEdgeButton?

    var checked: Bool {
        checkBox?.value ?? false
    }

    var primaryAction: ((InsuranceSearchResultsViewController) -> Void)?
    var secondaryAction: ((InsuranceSearchResultsViewController) -> Void)?

    var titleText: String? {
        didSet {
            update()
        }
    }

    var hintText: String? {
        didSet {
            update()
        }
    }

    var attributedHint: NSAttributedString? {
        if let attributed = hintLabel?.attributedText {
            return attributed
        } else if let text = hintLabel?.text {
            return NSAttributedString(string: text)
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		titleLabel <~ Style.Label.primaryHeadline1

		view.backgroundColor = .Background.backgroundContent
        mainButton <~ Style.RoundedButton.redBordered
        if let secondaryButton = secondaryButton {
            secondaryButton <~ Style.RoundedButton.grayBorderGrayTitle
        }

        // checkbox enabled by default
        checkBox?.toggle(checked: true)

        update()
    }

    private func update() {
        if let titleText = titleText {
			titleLabel?.text = titleText
        }
        if let hintText = hintText {
            hintLabel?.text = hintText
        }
    }

    @IBAction private func togglePrimaryAction() {
        primaryAction?(self)
    }

    @IBAction private func toggleSecondaryAction() {
        secondaryAction?(self)
    }

    func set(attributedHint: NSAttributedString?) {
        hintLabel?.attributedText = attributedHint
    }

    func toggleCheckBox(hidden: Bool) {
        checkBox?.isHidden = hidden
        emailSubscriptionLabel?.isHidden = hidden
    }
}
