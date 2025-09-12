//
//  RateAppBehavior
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import StoreKit

class RateAppBehavior {
    func showSystemReviewUI() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first(
                where: { $0.activationState == .foregroundActive }
            ) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}
