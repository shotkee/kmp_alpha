//
// UIWindow (ContentHidden)
// AlfaStrah
//
// Created by Eugene Egorov on 07 December 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

extension UIWindow {
    static private let hiddenViewTag = 171215

    var contentHidden: Bool {
        // swiftlint:disable:next implicit_getter
        get {
            viewWithTag(UIWindow.hiddenViewTag) != nil
        }

        set {
            viewWithTag(UIWindow.hiddenViewTag)?.removeFromSuperview()

            if newValue {
                let view = HideView.fromNib()
                view.frame = frame
                view.tag = UIWindow.hiddenViewTag
                addSubview(view)
            }
        }
    }
}
