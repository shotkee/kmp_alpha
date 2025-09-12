//
//  DisagreementServiceTableCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 13.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DisagreementServiceTableCell: UITableViewCell
{
    // MARK: - UI
    
    @IBOutlet private var checkbox: CommonCheckboxButton!
    
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var dateHeaderLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var clinicNameHeaderLabel: UILabel!
    @IBOutlet private var clinicNameLabel: UILabel!
    @IBOutlet private var costHeaderLabel: UILabel!
    @IBOutlet private var costLabel: UILabel!
    @IBOutlet private var quantityHeaderLabel: UILabel!
    @IBOutlet private var quantityLabel: UILabel!
    @IBOutlet private var franchisePercentHeaderLabel: UILabel!
    @IBOutlet private var franchisePercentLabel: UILabel!
    @IBOutlet private var toPayHeaderLabel: UILabel!
    @IBOutlet private var toPayLabel: UILabel!
    
    // MARK: - Instantiation
    
    static let id: Reusable<DisagreementServiceTableCell> = .fromNib()
    
    // MARK: - UITableViewCell
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
		numberLabel <~ Style.Label.tertiaryCaption1
        
        let detailsLabels = [
            dateHeaderLabel,
            dateLabel,
            clinicNameHeaderLabel,
            clinicNameLabel,
            costHeaderLabel,
            costLabel,
            quantityHeaderLabel,
            quantityLabel,
            franchisePercentHeaderLabel,
            franchisePercentLabel,
            toPayHeaderLabel,
            toPayLabel
        ]
        detailsLabels.forEach { label in
			if let label {
				label <~ Style.Label.tertiaryCaption1
			}
        }
        
        dateHeaderLabel.text = NSLocalizedString("disagreement_with_services_service_date_header", comment: "")
        clinicNameHeaderLabel.text = NSLocalizedString("disagreement_with_services_service_clinic_header", comment: "")
        costHeaderLabel.text = NSLocalizedString("disagreement_with_services_service_cost_header", comment: "")
        quantityHeaderLabel.text = NSLocalizedString("disagreement_with_services_service_quantity_header", comment: "")
        franchisePercentHeaderLabel.text = NSLocalizedString("disagreement_with_services_service_franchise_header", comment: "")
        toPayHeaderLabel.text = NSLocalizedString("disagreement_with_services_service_to_pay_header", comment: "")
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
    
    // MARK: - Configuration
    
    func configure(
        index: Int,
        service: InsuranceBillDisagreementService
    )
    {
        numberLabel.text = String(
            format: NSLocalizedString("disagreement_with_services_service_number_format", comment: ""),
            index + 1
        )
        titleLabel.text = service.serviceName

        clinicNameLabel.text = service.clinicName
        dateLabel.text = AppLocale.shortDateString(service.date)
        costLabel.text = formatPaymentAmount(service.sumWithFranchise)
        quantityLabel.text = "\(Int(service.quantity))"
        franchisePercentLabel.text = service.franchisePercentage
        toPayLabel.text = formatPaymentAmount(service.paymentAmount)
    }
}
