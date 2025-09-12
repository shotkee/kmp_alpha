//
//  MedicalCardStorageSectionHeader.swift
//  AlfaStrah
//
//  Created by vit on 25.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class MedicalCardStorageSectionHeader: UITableViewHeaderFooterView {
    static let id: Reusable<MedicalCardStorageSectionHeader> = .fromClass()
    
    private let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    private func setupUI() {
        titleLabel <~ Style.Label.secondaryText
        
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: titleLabel,
                in: self,
                margins: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
            )
        )
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
}
