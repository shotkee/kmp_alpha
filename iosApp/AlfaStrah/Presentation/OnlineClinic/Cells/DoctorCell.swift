//
//  DoctorCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import Legacy

class DoctorCell: UITableViewCell {
    static let id: Reusable<DoctorCell> = .fromClass()
    
    private struct TimeButtonInfo {
        let button: RoundEdgeButton
        let scheduleInterval: DoctorScheduleInterval
    }

    private var timeButtonsInfo: [TimeButtonInfo] = []

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let timeButtonsStackView = UIStackView()
    private let containerStackView = UIStackView()

    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .hour, .minute ]
        formatter.zeroFormattingBehavior = .pad
        formatter.calendar = AppLocale.calendar
        return formatter
    }()

    var scheduleIntervalTap: ((_ scheduleInterval: DoctorScheduleInterval?, _ selected: Bool) -> Void)?
    var otherTap: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupContainerView()
        setupTitle()
        setupDescription()
        setupTimeButtons()
    }
    
    private func setupContainerView() {
        containerStackView.alignment = .leading
        containerStackView.axis = .vertical
        containerStackView.spacing = 9
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = insets(18)
        
		containerStackView.backgroundColor = .Background.backgroundSecondary
        
		let viewWithShadow = containerStackView.embedded(hasShadow: true)
        viewWithShadow.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(viewWithShadow)
        
        NSLayoutConstraint.activate([
            viewWithShadow.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            viewWithShadow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            viewWithShadow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            viewWithShadow.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupTitle() {
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.numberOfLines = 0
        containerStackView.addArrangedSubview(titleLabel)
    }
    
    private func setupDescription() {
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.numberOfLines = 0
        containerStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupTimeButtons() {
        timeButtonsStackView.alignment = .leading
        timeButtonsStackView.axis = .horizontal
        timeButtonsStackView.spacing = 9
        
        containerStackView.addArrangedSubview(spacer(9))
        containerStackView.addArrangedSubview(timeButtonsStackView)
    }

    func set(
        doctor: FullDoctor,
        scheduleIntervals: [DoctorScheduleInterval],
        selectedIntervalId: String?
    ) {
        titleLabel.text = doctor.title
        
        if let yearsOfExperience = doctor.yearsOfExperience {
            let expirienceFormat = NSLocalizedString("clinic_doctor_picker_cell_expirience", comment: "")
            descriptionLabel.text = String.localizedStringWithFormat(expirienceFormat, String(yearsOfExperience))
            
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        timeButtonsStackView.subviews.forEach { $0.removeFromSuperview() }

        var iterator = scheduleIntervals.makeIterator()

        while let scheduleInterval = iterator.next(), timeButtonsStackView.subviews.count < 3 {
            if scheduleInterval.status == .available, let time = timeFormatter.string(from: scheduleInterval.start) {
                let button = timeButton(title: time)
                let isSelected = scheduleInterval.id == selectedIntervalId
                button.isSelected = isSelected
                timeButtonsInfo.append(.init(button: button, scheduleInterval: scheduleInterval))
                timeButtonsStackView.addArrangedSubview(button)
            }
        }

        let otherButton = RoundEdgeButton()
        otherButton <~ Style.RoundedButton.timeRedBordered
        otherButton.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .horizontal)
        otherButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 700), for: .horizontal)
        otherButton.setTitle(NSLocalizedString("clinics_doctor_time_picker_other", comment: ""), for: .normal)
        otherButton.addTarget(self, action: #selector(otherButtonTap(_:)), for: .touchUpInside)
        timeButtonsStackView.addArrangedSubview(otherButton)
    }

    func deselectScheduleInterval() {
        timeButtonsInfo.forEach { timeButtonInfo in
            timeButtonInfo.button.isSelected = false
        }
    }

    private func timeButton(title: String) -> RoundEdgeButton {
        let button = RoundEdgeButton()
        button <~ Style.RoundedButton.timeRedBordered
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(timeButtonTap(_:)), for: .touchUpInside)
        return button
    }

    @objc private func timeButtonTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        timeButtonsInfo.forEach { timeButtonInfo in
            if timeButtonInfo.button === sender {
                scheduleIntervalTap?(timeButtonInfo.scheduleInterval, sender.isSelected)
            } else {
                timeButtonInfo.button.isSelected = false
            }
        }
    }

    @objc private func otherButtonTap(_ sender: UIButton) {
        otherTap?()
    }
}
