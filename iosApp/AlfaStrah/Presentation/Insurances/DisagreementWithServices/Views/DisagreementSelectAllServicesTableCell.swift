//
//  DisagreementSelectAllServicesTableCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 02.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DisagreementSelectAllServicesTableCell: UITableViewCell
{
    // MARK: - UI
    
    @IBOutlet private var checkbox: CommonCheckboxButton!
    @IBOutlet private var titleLabel: UILabel!
    
    // MARK: - Instantiation
    
    static let id: Reusable<DisagreementSelectAllServicesTableCell> = .fromNib()
    
    // MARK: - UITableViewCell
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.text = NSLocalizedString("disagreement_with_services_services_select_all", comment: "")
		titleLabel <~ Style.Label.primaryCaption1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        checkbox.isSelected = selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        
        checkbox.isHighlighted = highlighted
    }
}
