//
//  WebAddressView.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 29/11/2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Foundation

class WebAddressView: UIView {
    @IBOutlet private var webAddressLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var contentView: UIControl!

    @objc var webAddress: String? {
        didSet {
            webAddressLabel.text = webAddress
            iconView.isHidden = (webAddress == nil)
        }
    }

    @objc var webAddressTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("WebAddressView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]

        contentView.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }

    @objc private func tap() {
        webAddressTap?()
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupUI()
	}
	
	private func setupUI() {
		if let webAddressLabel {
			webAddressLabel <~ Style.Label.accentText
		}
	}
}
