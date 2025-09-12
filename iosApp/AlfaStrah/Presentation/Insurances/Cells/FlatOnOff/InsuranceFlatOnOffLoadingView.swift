//
//  InsuranceFlatOnOffLoadingView.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 03.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceFlatOnOffLoadingView: ShimmerContainerView {
    @IBOutlet private var loadingView1: UIView!
    @IBOutlet private var loadingView2: UIView!
    @IBOutlet private var loadingView3: UIView!
    @IBOutlet private var loadingView4: UIView!

    private var loadingViews: [UIView] {
        [ loadingView1, loadingView2, loadingView3, loadingView4 ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        loadingViews.forEach { $0.layer.cornerRadius = $0.frame.height * 0.5 }
    }

    private func setup() {
        loadingViews.forEach { $0.backgroundColor = Style.Color.Palette.whiteGray }
    }
}
