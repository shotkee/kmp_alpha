//
//  LayoutUtils.swift
//  AlfaStrah
//
//  Created by vit on 27.03.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

func spacer(_ height: CGFloat, color: UIColor = .clear) -> UIView {
    let view = UIView()
    view.backgroundColor = color
    view.translatesAutoresizingMaskIntoConstraints = false
    view.heightAnchor.constraint(equalToConstant: height).isActive = true
    return view
}

func separator() -> UIView {
	let separator = spacer(1, color: .Stroke.divider)
    return separator
}

func insets(_ value: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
}

func insets(v vertical: CGFloat, h horizontal: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
}

func setupLayout(
    scrollView: UIScrollView,
    contentStackView: UIStackView? = nil,
    actionButtonsStackView: UIStackView,
    for viewController: UIViewController
) {
    guard let view = viewController.view
    else { return }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }
        
    func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)
        
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear
        
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    setupScrollView()
    setupActionButtonStackView()
    
    if let contentStackView = contentStackView {
        func setupContentStackView() {
            scrollView.addSubview(contentStackView)
            
            contentStackView.isLayoutMarginsRelativeArrangement = true
            contentStackView.layoutMargins = UIEdgeInsets(top: 21, left: 18, bottom: 0, right: 18)
            contentStackView.alignment = .fill
            contentStackView.distribution = .fill
            contentStackView.axis = .vertical
            contentStackView.spacing = 0
            contentStackView.backgroundColor = .clear
            
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate( NSLayoutConstraint.fill(view: contentStackView, in: scrollView) + [
                contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }
        
        setupContentStackView()
    }
}

func is7IphoneOrLess() -> Bool {
    return UIScreen.main.bounds.height <= 667.0
}
