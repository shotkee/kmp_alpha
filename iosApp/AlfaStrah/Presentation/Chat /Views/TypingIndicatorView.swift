//
//  TypingIndicatorView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 17.03.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import SlackTextViewController

class TypingIndicatorView: UIView, SLKTypingIndicatorProtocol
{
    // MARK: - SLKTypingIndicatorProtocol
    
    var isVisible: Bool = false
    
    // MARK: - Instantiation
    
    init()
    {
        super.init(frame: .zero)
        
        buildUI()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func buildUI()
    {
        // background
        
        backgroundColor = .clear
        
        // text
        
        let textLabel = UILabel()
        textLabel.text = "Оператор набирает сообщение"
        textLabel.font = Style.Font.caption1
        textLabel.textColor = Style.Color.Palette.darkGray
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 24
            ),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textLabel.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 11
            ),
            textLabel.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -11
            )
        ])
    }
}
