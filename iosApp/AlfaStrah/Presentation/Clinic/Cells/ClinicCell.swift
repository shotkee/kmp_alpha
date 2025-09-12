//
//  ClinicCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ClinicCell: UITableViewCell {
    static let id: Reusable<ClinicCell> = .fromNib()

    @IBOutlet private var topContainerStackView: UIView!
    @IBOutlet private var onlineAppointmentLabel: UILabel!
    @IBOutlet private var onlineAppointmentContainerView: UIView!
    @IBOutlet private var servicesWithFranchiseLabel: UILabel!
    @IBOutlet private var servicesWithFranchiseContainerView: UIView!
    @IBOutlet private var titleContainerView: UIView!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var clinicTitleLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var treatmentsLabel: UILabel!
    @IBOutlet private var webAddressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        onlineAppointmentLabel <~ Style.Label.primaryText
        onlineAppointmentLabel.text = NSLocalizedString("clinic_online_appointment_available", comment: "")
        servicesWithFranchiseLabel <~ Style.Label.primaryText
        servicesWithFranchiseLabel.text = NSLocalizedString("clinic_has_services_with_franchise", comment: "")
        clinicTitleLabel <~ Style.Label.primaryHeadline1
        distanceLabel <~ Style.Label.secondaryText
        addressLabel <~ Style.Label.primaryText
        treatmentsLabel <~ Style.Label.secondaryText
        webAddressLabel <~ Style.Label.accentText
    }

    func set(clinic: Clinic, showMetroDistance: Bool) {
		let hideOnlineAppointmentView = clinic.buttonAction == .appointmentOnline
		let hideServicesWithFranchiseView = !(clinic.franchise ?? false)
        onlineAppointmentContainerView.isHidden = hideOnlineAppointmentView
        servicesWithFranchiseContainerView.isHidden = hideServicesWithFranchiseView
        topContainerStackView.isHidden = hideOnlineAppointmentView && hideServicesWithFranchiseView

        clinicTitleLabel.text = clinic.title
		distanceLabel.text = nil
        addressLabel.text = clinic.address
        titleContainerView.layoutIfNeeded()
    }
}

func getTreatmentTextWithFranchise(_ treatment: ClinicTreatment) -> String
{
    let franchiseText = treatment.hasFranchise
        ? treatment.franchisePercentage.map { " (\($0))" }
        : nil
    return "\(treatment.title)\(franchiseText ?? "")"
}
