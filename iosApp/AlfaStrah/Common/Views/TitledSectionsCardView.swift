//
//  TitledSectionsCardView.swift
//  AlfaStrah
//
//  Created by vit on 27.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class TitledSectionsCardView: UIView {
    private let sectionsCardView = SectionsCardView()
    private let titleLabel = UILabel()
        
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
        
        sectionsCardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sectionsCardView)
        
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),

                sectionsCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
                sectionsCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                sectionsCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                sectionsCardView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
            ]
        )
    }
    
    func set(
        title: String,
        items: [SectionsCardView.Item],
        isRequiredField: Bool = false
    ) {
        if !title.isEmpty {
            let attributedTitle = NSMutableAttributedString(string: title)
            
            if isRequiredField {
                let attributedStarSymbol = NSMutableAttributedString(
                    string: "*",
                    attributes: [
                        .foregroundColor: Style.Color.Palette.red
                    ]
                )
                attributedTitle.append(attributedStarSymbol)
            }
            
            titleLabel.attributedText = attributedTitle
        }
        
        sectionsCardView.updateItems(items)
    }
    
    func updateItems(_ items: [SectionsCardView.Item]) {
        sectionsCardView.updateItems(items)
    }
}
