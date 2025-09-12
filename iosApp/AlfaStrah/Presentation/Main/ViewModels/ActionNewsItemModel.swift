//
// ActionNewsItemModel
// AlfaStrah
//
// Created by Eugene Egorov on 23 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit

struct ActionNewsItemModel: NewsItemModel {
    let title: String
    let info: String
    let alfaPoints: Int
    let actionTitle: String
    let tagTitle: String?
    let iconImageURL: String?
    let iconImage: UIImage?
    let badgeImage: UIImage?
    let removable: Bool

    let action: (_ controller: UIViewController) -> Void

    init(
        title: String,
        info: String,
        alfaPoints: Int = 0,
        actionTitle: String,
        iconImage: UIImage? = nil,
        badgeImage: UIImage? = nil,
        removable: Bool = false,
        iconImageURL: String? = nil,
        action: @escaping (UIViewController) -> Void
    ) {
        self.title = title
        self.info = info
        self.alfaPoints = alfaPoints
        self.actionTitle = actionTitle
        self.iconImage = iconImage
        self.badgeImage = badgeImage
        self.removable = removable
        self.action = action
        self.iconImageURL = iconImageURL
        tagTitle = nil
    }
}
