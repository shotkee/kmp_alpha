//
//  UIButton+background.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControl.State) {
        let backgroundImage = UIImage.backgroundImage(withColor: color)
        setBackgroundImage(backgroundImage, for: state)
    }
}
