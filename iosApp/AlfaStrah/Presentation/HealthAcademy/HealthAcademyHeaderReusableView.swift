//
//  HealthAcademyHeaderReusableView.swift
//  AlfaStrah
//
//  Created by mac on 01.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class HealthAcademyHeaderReusableView: UICollectionReusableView {
    static let id: Reusable<HealthAcademyHeaderReusableView> = .fromClass()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.textAlignment = .left
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18)
        ])
    }
        
    func setTitle(title: String) {
        titleLabel.text = title
    }
}
