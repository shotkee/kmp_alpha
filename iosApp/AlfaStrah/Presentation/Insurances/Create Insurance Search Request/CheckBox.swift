//
//  CheckBox.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 04.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class CheckBox: UIControl {
    @IBOutlet private var imageView: UIImageView!
    @IBInspectable private var checkedImage: UIImage!
    @IBInspectable private var uncheckedImage: UIImage!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        checked = !checked
    }

    private var checked: Bool = false {
        didSet {
            sendActions(for: .valueChanged)
            update(for: checked)
        }
    }

    var value: Bool {
        checked
    }

    func toggle(checked newValue: Bool) {
        checked = newValue
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateImageViewIfNeeded()
    }

    private func update(for checked: Bool) {
        switch checked {
            case true:
                imageView.image = checkedImage
            case false:
                imageView.image = uncheckedImage
        }
    }

    private func updateImageViewIfNeeded() {
        imageView.isUserInteractionEnabled = false
        if imageView == nil {
            imageView = UIImageView(frame: bounds)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)

            imageView.contentMode = .scaleAspectFit
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
            imageView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
            imageView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
            imageView.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true

            layoutIfNeeded()
        }

        update(for: checked)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        updateImageViewIfNeeded()
    }
}
