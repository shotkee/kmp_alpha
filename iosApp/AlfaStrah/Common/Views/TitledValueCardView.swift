//
//  TitledValueCardView.swift
//  AlfaStrah
//
//  Created by vit on 10.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class TitledValueCardView: UIView {
    private let valueCardView = ValueCardView()
    private let titleLabel = UILabel()
    
    var tapHandler: (() -> Void)? {
        didSet {
            valueCardView.tapHandler = tapHandler
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    private func setup() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel <~ Style.Label.secondaryHeadline2
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        let containerView = CardView(contentView: valueCardView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),

                containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
                containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
            ]
        )
    }
    
    func set(
        title: String? = nil,
        attributedTitle: NSMutableAttributedString? = nil,
        subTitle: String? = nil,
        attributedSubtitle: NSMutableAttributedString? = nil,
        placeholder: String? = nil,
        value: String? = nil,
        error: String? = nil,
        icon: ValueCardView.IconPositionStyle = .rightArrow,
        stateAppearance: ValueCardView.StateAppearance = .regular,
        showSeparator: Bool = false,
        isRequiredField: Bool = false
    ) {
        
        var resultAttributedTitle: NSMutableAttributedString? = nil
        
        if let attributedTitle = attributedTitle {
            resultAttributedTitle = attributedTitle
        } else {
            if let title = title {
                resultAttributedTitle = NSMutableAttributedString(string: title)
            }
        }
                
        if let resultAttributedTitle = resultAttributedTitle {
            if isRequiredField {
                let attributedStarSymbol = NSMutableAttributedString(
                    string: "*",
                    attributes: [
                        .foregroundColor: Style.Color.Palette.red
                    ]
                )
                resultAttributedTitle.append(attributedStarSymbol)
            }
            
            titleLabel.attributedText = resultAttributedTitle
        }
        
        valueCardView.resetAttributedSubtitle()
        valueCardView.set(
            title: subTitle ?? "",
            placeholder: placeholder ?? "",
            value: value,
            error: nil,
            icon: icon,
            stateAppearance: stateAppearance
        )
        
        if let attributedSubtitle = attributedSubtitle {
            valueCardView.set(attributedSubtitle: attributedSubtitle)
        }
    }
    
    func updateValue(_ value: String?) {
        valueCardView.update(value: value)
    }
    
    func updateSubtitle(with attributedText: NSMutableAttributedString) {
        valueCardView.update(title: attributedText)
    }
}
