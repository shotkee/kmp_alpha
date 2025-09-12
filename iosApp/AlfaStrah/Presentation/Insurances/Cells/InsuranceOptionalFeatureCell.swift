//
//  InsuranceOptionalFeatureCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 06/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceOptionalFeatureCell: UITableViewCell {
    struct Input {
        let title: String
        let description: String
        let buttonTitle: String
    }

    struct Output {
        let action: (() -> Void)?
    }

    var input: Input? {
        didSet {
            updateUI()
        }
    }

    var output: Output!

    static let id: Reusable<InsuranceOptionalFeatureCell> = .fromNib()

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButton: RoundEdgeButton!
    @IBOutlet private var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
        updateUI()
    }

    private func setupUI() {
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.textAlignment = .center
        
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.textAlignment = .center
        
        containerView.backgroundColor = .Background.backgroundContent
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 8
        
        actionButton <~ Style.RoundedButton.redBordered
		
		updateTheme()
    }

    private func updateUI() {
        titleLabel?.text = input?.title
        descriptionLabel?.text = input?.description
        actionButton?.setTitle(input?.buttonTitle, for: .normal)
    }

    @IBAction private func actionTap() {
        output.action?()
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
        
		updateTheme()
    }
	
	private func updateTheme() {
		containerView.layer.borderColor = UIColor.Stroke.strokeBorder.cgColor
	}
}
