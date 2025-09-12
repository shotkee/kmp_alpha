//
// NewsItemModel
// AlfaStrah
//
// Created by Eugene Egorov on 23 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit

protocol NewsItemModel {
    var title: String { get }
    var info: String { get }
    var alfaPoints: Int { get }
    var actionTitle: String { get }
    var tagTitle: String? { get }
    var iconImageURL: String? { get }
    var iconImage: UIImage? { get }
    var badgeImage: UIImage? { get }
    var removable: Bool { get }
}
