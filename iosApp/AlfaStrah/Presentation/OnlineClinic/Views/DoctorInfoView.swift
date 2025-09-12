//
//  DoctorInfoView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 08/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class DoctorInfoView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 22, right: 16)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6

        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)

        subtitleLabel <~ Style.Label.secondaryText
        subtitleLabel.numberOfLines = 0
        stackView.addArrangedSubview(subtitleLabel)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: stackView, in: self))
    }

    func set(doctor: FullDoctor) {
        titleLabel.text = doctor.title
        var aboutDoctor = ""
        if let yearsOfExperience = doctor.yearsOfExperience {
            let yearsFormat = NSLocalizedString("clinic_doctor_picker_cell_expirience", comment: "")
            aboutDoctor = "\(String.localizedStringWithFormat(yearsFormat, String(yearsOfExperience)))  •  "
        }
        
        aboutDoctor += "\(doctor.speciality.title.capitalizingFirstLetter())"
        
        subtitleLabel.text = aboutDoctor
    }
}
