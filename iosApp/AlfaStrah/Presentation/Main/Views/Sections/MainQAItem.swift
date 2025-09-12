//
//  MainQAItem.swift
//  AlfaStrah
//
//  Created by mac on 24.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class MainQAItem: UIView {
    @IBOutlet private var image: UIImageView!
    @IBOutlet private var iconContainer: UIView!
    @IBOutlet private var textDescription: UILabel!
    
    struct Input {
        let image: UIImage?
        let text: String
    }
    
    struct Output {
        let tapOnView: () -> Void
    }

    var input: Input! {
        didSet {
            setupUI()
            setupStyle()
        }
    }
    
    var output: Output!
    
    @objc private func tapOnView() {
        output.tapOnView()
    }

    private func setupUI() {
        image.image = input.image
        textDescription.text = input.text
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupStyle() {
        textDescription <~ Style.Label.primarySubhead
        iconContainer.backgroundColor = .Background.backgroundTertiary
        iconContainer.layer.cornerRadius = 8
        image.tintColor = .Icons.iconAccent
    }
}
