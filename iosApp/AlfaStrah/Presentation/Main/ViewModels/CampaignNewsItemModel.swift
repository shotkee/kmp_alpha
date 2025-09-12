//
// CampaignNewsItemModel
// AlfaStrah
//
// Created by Eugene Egorov on 23 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit

struct CampaignNewsItemModel: NewsItemModel {
    let title: String
    let info: String
    let alfaPoints: Int
    let actionTitle: String
    let tagTitle: String?
    let iconImageURL: String?
    let iconImage: UIImage?
    let badgeImage: UIImage?
    let removable: Bool

    let campaign: Campaign

    init(campaign: Campaign) {
        self.campaign = campaign

        title = campaign.title
        info = campaign.annotation
        alfaPoints = 0
        actionTitle = NSLocalizedString("main_banner_details", comment: "")
        tagTitle = nil
        iconImageURL = campaign.imageUrl
        iconImage = nil
        badgeImage = nil
        removable = false
    }
}
