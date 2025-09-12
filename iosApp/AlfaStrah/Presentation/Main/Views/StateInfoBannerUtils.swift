//
//  StateInfoBannerUtils.swift
//  AlfaStrah
//
//  Created by vit on 03.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

func showStateInfoBanner(
    title: String,
    description: String,
    hasCloseButton: Bool,
    iconImage: UIImage?,
    titleFont: UIFont,
    appearance: StateInfoBannerView.Appearance
) {
    guard let window = UIApplication.shared.delegate?.window ?? nil
    else { return }
    
    if let previousBannerView = window.subviews.first(where: { $0 is StateInfoBannerView }) {
        previousBannerView.removeFromSuperview()
    }
    
    let stateInfoBanner = StateInfoBannerView()
            
    stateInfoBanner.translatesAutoresizingMaskIntoConstraints = false
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    
    window.addSubview(stateInfoBanner)
    
    let bannerViewOriginOffset: CGFloat = statusBarHeight + 9
    
    NSLayoutConstraint.activate([
        stateInfoBanner.topAnchor.constraint(
            equalTo: window.topAnchor,
            constant: bannerViewOriginOffset
        ),
        stateInfoBanner.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 18),
        stateInfoBanner.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -18)
    ])
                
    stateInfoBanner.set(
        appearance: appearance,
        title: title,
        description: description,
        hasCloseButton: hasCloseButton,
        iconImage: iconImage,
        titleFont: titleFont,
        startBannerOffset: -bannerViewOriginOffset
    )

    stateInfoBanner.setupTimer()
}
