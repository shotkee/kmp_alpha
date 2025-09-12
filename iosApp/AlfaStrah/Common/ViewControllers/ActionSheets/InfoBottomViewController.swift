//
//  InfoBottomViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class InfoBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let description: String
        let primaryButtonTitle: String
        let secondaryButtonTitle: String?
        let additionalInputs: [UIView]
            
        init(
            title: String,
            description: String,
            primaryButtonTitle: String,
            secondaryButtonTitle: String?,
            additionalInputs: [UIView] = []
        ) {
            self.title = title
            self.description = description
            self.primaryButtonTitle = primaryButtonTitle
            self.secondaryButtonTitle = secondaryButtonTitle
            self.additionalInputs = additionalInputs
        }
    }

    struct Output {
        let close: () -> Void
        let primaryAction: () -> Void
        var secondaryAction: (() -> Void)?
    }

    var input: Input!
    var output: Output!

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(infoText: input.description)
        set(
            style:
                .actions(
                    primaryButtonTitle: input.primaryButtonTitle,
                    secondaryButtonTitle: input.secondaryButtonTitle
                )
        )
        set(doneButtonEnabled: true)

        closeTapHandler = output.close
        primaryTapHandler = output.primaryAction
        secondaryTapHandler = output.secondaryAction
        
        if !input.additionalInputs.isEmpty {
            add(views: input.additionalInputs)
        }
    }
}
