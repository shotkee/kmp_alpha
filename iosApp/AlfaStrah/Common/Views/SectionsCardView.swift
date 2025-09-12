//
//  SectionsCardView.swift
//  AlfaStrah
//
//  Created by vit on 12.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class SectionsCardView: UIView {
    struct Item {
        let title: String
        let placeholder: String
        let value: String?
        let icon: SmallValueCardView.IconPositionStyle
        let stateAppearance: SmallValueCardView.StateAppearance
        let isEnabled: Bool
        let tapHandler: (() -> Void)?
        
        init(
            title: String,
            placeholder: String,
            value: String?,
            icon: SmallValueCardView.IconPositionStyle,
            stateAppearance: SmallValueCardView.StateAppearance = .regular,
            isEnabled: Bool,
            tapHandler: (() -> Void)?
        )
        {
            self.title = title
            self.placeholder = placeholder
            self.value = value
            self.icon = icon
            self.stateAppearance = stateAppearance
            self.isEnabled = isEnabled
            self.tapHandler = tapHandler
        }
    }
        
    private var items: [Item] = [] {
        didSet {
            contentStackView.subviews.forEach{ $0.removeFromSuperview() }
            
            for (index, item) in items.enumerated() {
                guard !item.placeholder.isEmpty || item.value?.isEmpty == false
                else { continue }
                
                let smallValueCardView = SmallValueCardView()
                
                smallValueCardView.set(
                    title: item.title,
                    placeholder: item.placeholder,
                    value: item.value,
                    error: nil,
                    icon: item.icon,
                    stateAppearance: item.stateAppearance,
                    isEnabled: item.isEnabled,
                    showSeparator: index != items.count - 1
                )
                
                smallValueCardView.tapHandler = item.tapHandler
                
                contentStackView.addArrangedSubview(smallValueCardView)
            }
        }
    }
    
    private let contentStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.axis = .vertical
        
        let containerView = CardView(contentView: contentStackView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        NSLayoutConstraint.activate(
            [
                containerView.topAnchor.constraint(equalTo: self.topAnchor),
                containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ]
        )
    }
    
    func updateItems(_ items: [Item]) {
        self.items = items
    }
}
