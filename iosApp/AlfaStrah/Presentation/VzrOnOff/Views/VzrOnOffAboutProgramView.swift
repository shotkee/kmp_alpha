//
//  VzrOnOffAboutProgramView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffAboutProgramView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        textLabel <~ Style.Label.primaryText
    }

    func configure(with image: UIImage?, text: String) {
        imageView.image = image
        textLabel.text = text
    }
}
