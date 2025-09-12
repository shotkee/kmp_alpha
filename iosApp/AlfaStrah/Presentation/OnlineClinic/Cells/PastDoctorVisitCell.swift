//
//  PastDoctorVisitCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class PastDoctorVisitCell: UITableViewCell {
    static let id: Reusable<PastDoctorVisitCell> = .fromClass()

	@IBOutlet private var cardView: CardView!
    @IBOutlet private var clinicLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var doctorLabel: UILabel!
    @IBOutlet private var doctorSpecialityTitleLabel: UILabel!
    @IBOutlet private var doctorSpecialityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        clinicLabel <~ Style.Label.secondaryCaption1
        timeLabel <~ Style.Label.primaryText
        doctorLabel <~ Style.Label.primaryText
        doctorSpecialityTitleLabel <~ Style.Label.secondaryCaption1
        doctorSpecialityLabel <~ Style.Label.primaryText
        
		cardView.contentColor = .Background.backgroundSecondary
		cardView.highlightedColor = .Background.backgroundSecondary
    }

    func set(appointment: CommonAppointment, dateFormatter: DateFormatter) {
        clinicLabel.text = appointment.clinic?.title ?? ""
                
        timeLabel.text = appointment.appointmentDate.map { dateFormatter.string(from: $0) }
        
        doctorLabel.text = appointment.doctorFullName
        
        doctorSpecialityTitleLabel.text = NSLocalizedString("clinic_info_referral_or_department", comment: "")
        doctorSpecialityLabel.text = appointment.description
    }
}
