//
//  InsuredPersonResultTableCell.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 08.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class InsuredPersonResultTableCell: UITableViewCell
{
    @IBOutlet private var personFullNameLabel: UILabel!
    @IBOutlet private var transitionStatusImageView: UIImageView!
    @IBOutlet private var transitionStatusDescriptionLabel: UILabel!
    
    static let id: Reusable<InsuredPersonResultTableCell> = .fromNib()
    
    func configure(person: FranchiseTransitionResultInsuredPerson)
    {
		personFullNameLabel <~ Style.Label.primaryText
		transitionStatusDescriptionLabel <~ Style.Label.secondaryText
		
        personFullNameLabel.text = formatInsuredPersonName(
            firstName: person.firstName,
            lastName: person.lastName,
            patronymic: person.patronymic
        )
        transitionStatusDescriptionLabel.text = person.transitionStatusDescription
        
        let statusImage = person.isTransitionSuccessful
            ? UIImage(named: "tick-franchise-transition")
            : UIImage(named: "cross-franchise-transition")
        
        transitionStatusImageView.image = statusImage
    }
}
