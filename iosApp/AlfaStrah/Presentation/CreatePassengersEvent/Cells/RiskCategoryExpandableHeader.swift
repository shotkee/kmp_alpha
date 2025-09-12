//
//  RiskCategoryExpandableHeader.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 17/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RiskCategoryExpandableHeader: UITableViewHeaderFooterView {
    static let id: Reusable<RiskCategoryExpandableHeader> = .fromNib()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    enum State {
        case opened
        case closed
    }

    var state: State = .closed {
        didSet {
            imageView.transform = state == .closed ? .identity : CGAffineTransform(rotationAngle: .pi)
        }
    }

    var tapHandler: (() -> Void)?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

		contentView.backgroundColor = .Background.backgroundContent
		
		setupUI()
    }
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.primaryHeadline1
		}
	}

    @IBAction private func tap() {
        tapHandler?()
    }
}
