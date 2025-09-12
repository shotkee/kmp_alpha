//
//  ActiveTripShimmerView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/18/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ActiveTripShimmerView: ShimmerContainerView {
    @IBOutlet private var loadingView1: UIView!
    @IBOutlet private var loadingView2: UIView!
    @IBOutlet private var loadingView3: UIView!
    @IBOutlet private var loadingView4: UIView!

    private var loadingViews: [UIView] {
        [
            loadingView1,
            loadingView2,
            loadingView3,
            loadingView4
        ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        loadingViews.forEach { $0.layer.cornerRadius = $0.frame.height * 0.5 }
    }

    private func setupUI() {
        loadingView1.backgroundColor = Style.Color.Palette.lightGray
        loadingView2.backgroundColor = Style.Color.Palette.whiteGray
        loadingView3.backgroundColor = Style.Color.Palette.whiteGray
        loadingView4.backgroundColor = Style.Color.Palette.whiteGray
    }
}
