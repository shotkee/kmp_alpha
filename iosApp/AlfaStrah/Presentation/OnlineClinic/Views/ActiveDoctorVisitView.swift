//
//  ActiveDoctorVisit.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ActiveDoctorVisitView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var specialityTitleLabel: UILabel!
    @IBOutlet private var specialityLabel: UILabel!
    @IBOutlet private var doctorImageView: NetworkImageView!
	@IBOutlet private var accessoryImageView: UIImageView!
    @IBOutlet private var statusView: UIView!
    @IBOutlet private var statusLabel: UILabel!
    
    var appointmentTapCalback: ((CommonAppointment) -> Void)?
    private var appointment: CommonAppointment?

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        titleLabel <~ Style.Label.secondaryCaption1
        dateLabel <~ Style.Label.primaryText
        nameLabel <~ Style.Label.primaryHeadline1
        specialityTitleLabel <~ Style.Label.secondaryCaption1
        specialityLabel <~ Style.Label.primaryText
		statusLabel <~ Style.Label.primarySubhead
		statusView.layer.cornerRadius = 6
		statusView.clipsToBounds = true

        specialityTitleLabel.text = NSLocalizedString("clinic_info_referral_or_department", comment: "")
        doctorImageView.placeholder = UIImage(named: "icon-doctor-avatar")
        doctorImageView.contentMode = .scaleAspectFill
		doctorImageView.layer.cornerRadius = doctorImageView.frame.size.width * 0.5
        doctorImageView.clipsToBounds = true

		accessoryImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
    }
    
    func set(
        appointment: CommonAppointment,
        getDateFormatter: (CommonAppointment) -> DateFormatter,
        imageLoader: ImageLoader,
        appointmentTapCallback: @escaping (CommonAppointment) -> Void
    ) {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
        self.appointment = appointment
        self.appointmentTapCalback = appointmentTapCallback
                
        let dateFormatter = getDateFormatter(appointment)
        
        dateLabel.text = dateFormatter.string(from: appointment.appointmentDate ?? Date())
        nameLabel.text = appointment.doctorFullName
        
        specialityLabel.text = appointment.description
        
        doctorImageView.imageLoader = imageLoader
        doctorImageView.imageUrl = appointment.doctorPhotoUrl
		
		if let status = appointment.status
		{
			statusView.isHidden = false
			statusLabel.text = status.title.text
			statusLabel.textColor = status.title.themedColor?.color(
				for: currentUserInterfaceStyle
			) ?? .Text.textPrimary
			statusView.backgroundColor = status.backgroundColor.color(for: currentUserInterfaceStyle
			) ?? .clear
			titleLabel.text = status.statusTitle
		}
		else
		{
			statusView.isHidden = true
			titleLabel.text = NSLocalizedString("clinic_active_appointment_send_title", comment: "")
		}
    }

    @objc private func viewTap() {
        appointment.map { appointmentTapCalback?($0) }
    }
}
