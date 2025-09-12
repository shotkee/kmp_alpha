//
//  UIView+subviews.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 23/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

extension UIView {
    class func getAllSubviews<T: UIView>(view: UIView) -> [T] {
        view.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(view: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }

    func getAllSubviews<T: UIView>() -> [T] {
        UIView.getAllSubviews(view: self) as [T]
    }
}
