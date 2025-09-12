//
//  CommonCheckboxWithRedBorderButton.swift
//  AlfaStrah
//
//  Created by Makson on 29.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class CommonCheckboxWithRedBorderButton: UIButton
{
    // MARK: - UIButton and Instantiation
    
    init()
    {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        setup()
    }
    
    override var intrinsicContentSize: CGSize
    {
        let side: CGFloat = 24
        return .init(
            width: side,
            height: side
        )
    }
    
    // MARK: - Setup
    
    private func setup()
    {
        setImage(
            UIImage(named: "ico-unchecked-red-border-checkbox"),
            for: .normal
        )
        setImage(
            UIImage(named: "ico-checked-checkbox"),
            for: .selected
        )
        
        setImage(
            UIImage(named: "ico-checked-disabled-checkbox"),
            for: [.selected, .disabled]
        )
        
        setImage(
            UIImage(named: "ico-unchecked-disabled-checkbox"),
            for: [.disabled]
        )
    }
}
