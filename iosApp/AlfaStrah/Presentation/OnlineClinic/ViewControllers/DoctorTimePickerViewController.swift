//
//  DoctorTimePickerViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 08/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

final class DoctorTimePickerViewController: ViewController {
    @IBOutlet private var doctorInfoView: DoctorInfoView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var timeStackView: UIStackView!
    @IBOutlet private var calendarView: HorizontalCalendarView!
    
    private let operationStatusView = OperationStatusView()

    private lazy var operationStatusViewTopToViewConstraint: NSLayoutConstraint = {
        return operationStatusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    }()
    
    private lazy var operationStatusViewTopToCalendarViewConstraint: NSLayoutConstraint = {
        return operationStatusView.topAnchor.constraint(equalTo: calendarView.bottomAnchor)
    }()
    
    struct Input {
        let selectedDate: () -> Date
        let startScheduleDate: () -> Date?
        var data: () -> NetworkData<FullDoctor>
        var canCreateAppointment: () -> Bool
        var showDoctorPicker: Bool
    }

    struct Output {
        var scheduleInterval: (_ timeInterval: DoctorScheduleInterval?, _ doctor: FullDoctor?) -> Void
        var doctorPicker: (DoctorSpeciality) -> Void
        var calendar: (_ completion: @escaping (Date) -> Void) -> Void
        var goToChat: () -> Void
        var retry: () -> Void
        let confirmAppointment: (_ timeInterval: DoctorScheduleInterval?, _ doctor: FullDoctor?) -> Void
        let selectedDateChanged: (_ selectedDate: Date) -> Void
    }

    struct Notify {
        var changed: (_ reload: Bool) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] reload in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(reload: reload)
        }
    )

    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .hour, .minute ]
        formatter.zeroFormattingBehavior = .pad
        formatter.calendar = AppLocale.calendar
        return formatter
    }()
    
    private lazy var calendarButon: UIBarButtonItem = UIBarButtonItem(
        image: UIImage(named: "online-clinic-nav-calendar-icon"), style: .plain,
        target: self,
        action: #selector(calendarTap)
    )

    private var doctor: FullDoctor?
    private var currentDoctorSchedule: DoctorSchedule?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update(reload: false) // fix empty state flashing
    }
    
    override func viewDidAppear(_ animated: Bool) { // for lotie animations
        super.viewDidAppear(animated)
        
        update(reload: false)
    }

    // MARK: - Setup UI
    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("clinics_doctor_time_picker_title", comment: "")
        if input.showDoctorPicker {
            addDoctorsPickerButton()
        }

        navigationItem.rightBarButtonItem = calendarButon

        timeStackView.isLayoutMarginsRelativeArrangement = true
        timeStackView.layoutMargins = UIEdgeInsets(top: 22, left: 16, bottom: 22, right: 16)
        stackView.axis = .vertical
        timeStackView.spacing = 19
        
        calendarView.openCalendar = calendarHandler
        calendarView.activeDateCallback = { [weak self] selectedDate, _ in
            guard let self = self
            else { return }
            
            self.calendarView.updateInCurrentInterval(selectedDate: selectedDate)

            self.updateCurrentSchedule(for: selectedDate)
            
            self.updateDoctorTimeSelector()
            
            self.output.selectedDateChanged(selectedDate)
        }
        
        setupOperationStatusView()
    }
    
    private func updateCurrentSchedule(for date: Date) {
        currentDoctorSchedule = self.doctor?.schedules.first {
            AppLocale.calendar.compare($0.date, to: date, toGranularity: .day) == .orderedSame
        }
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            operationStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            operationStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            operationStatusView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func calendarTap(_ sender: UIBarButtonItem) {
        calendarHandler()
    }
    
    private func calendarHandler() {
        output.calendar{ [weak self] date in
            self?.calendarView.set(activeDate: date)
        }
    }

    private func addDoctorsPickerButton() {
        let separatorView = HairLineView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let doctorsPickerButton = UIButton(type: .custom)
        doctorsPickerButton <~ Style.Button.ActionWhite(title: NSLocalizedString("clinics_doctor_picker_button", comment: ""))
        doctorsPickerButton.addTarget(self, action: #selector(doctorPickerTap(_:)), for: .touchUpInside)
    }

    private func update(reload: Bool) {
        switch input.data() {
            case .loading:
                operationStatusView.isHidden = false
                operationStatusViewTopToCalendarViewConstraint.isActive = false
                operationStatusViewTopToViewConstraint.isActive = true
                
                self.doctor = nil
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("clinic_appointment_loading_title", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
                
            case .data(let doctor):
                self.doctor = doctor
                
                operationStatusView.isHidden = true
                operationStatusViewTopToCalendarViewConstraint.isActive = false
                operationStatusViewTopToViewConstraint.isActive = true
                
                let currentDate = input.selectedDate()
                
                if reload {
                    if let startScheduleDate = input.startScheduleDate() {
                        calendarView.set(
                            activeDate: currentDate,
                            startDate: startScheduleDate
                        )
                    } else {
                        calendarView.set(
                            activeDate: currentDate
                        )
                    }
                    
                    doctorInfoView.set(doctor: doctor)
                    
                    updateCurrentSchedule(for: currentDate)
                }
                
                if currentDoctorSchedule?.scheduleIntervals == nil {
                    operationStatusView.isHidden = false
                    
                    operationStatusViewTopToCalendarViewConstraint.isActive = true
                    operationStatusViewTopToViewConstraint.isActive = false
                    
                    let state: OperationStatusView.State = .info(.init(
                        title: NSLocalizedString("clinic_no_time_slots_available_on_this_day", comment: ""),
                        description: NSLocalizedString("clinic_check_another_date_for_slot", comment: ""),
                        icon: nil
                    ))

                    operationStatusView.notify.buttonConfiguration([])
                    operationStatusView.notify.updateState(state)
                }
            case .error:
                operationStatusViewTopToCalendarViewConstraint.isActive = false
                operationStatusViewTopToViewConstraint.isActive = true
                operationStatusView.isHidden = false
                
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("common_error_title", comment: ""),
                    description: NSLocalizedString("common_error_description", comment: ""),
                    icon: UIImage(named: "icon-common-failure")
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("clinic_appointment_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: { [weak self] in
                            self?.output.goToChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("clinic_appointment_retry", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            self?.output.retry()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
                
                navigationItem.rightBarButtonItem = nil
        }

        if reload {
            updateDoctorTimeSelector()
        }
    }

    private struct TimeButtonInfo {
        let button: UIButton
        let scheduleInterval: DoctorScheduleInterval
    }

    private var timeButtonsInfo: [TimeButtonInfo] = []

    private func updateDoctorTimeSelector() {
        timeButtonsInfo = []
        timeStackView.subviews.forEach { $0.removeFromSuperview() }
        output.scheduleInterval(nil, doctor)
        
        guard let scheduleIntervals = currentDoctorSchedule?.scheduleIntervals
        else { return }

        let rows = 4

        func addSchedule(_ scheduleIntervals: [DoctorScheduleInterval]) {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 9
            stackView.distribution = .fillEqually
            stackView.alignment = .center

            for schedule in scheduleIntervals {
                guard let time = timeFormatter.string(from: schedule.start) else { continue }

                let button = timeButton(title: time, enabled: schedule.status == .available)
                timeButtonsInfo.append(.init(button: button, scheduleInterval: schedule))
                stackView.addArrangedSubview(button)
            }

            // Add missing buttons to keep same button size in row
            for _ in 0 ..< rows - scheduleIntervals.count {
                stackView.addArrangedSubview(UIView())
            }

            timeStackView.addArrangedSubview(stackView)
        }

        let chunckedSchedule = stride(from: 0, to: scheduleIntervals.count, by: rows).map {
            Array(scheduleIntervals[$0 ..< min($0 + rows, scheduleIntervals.count)])
        }

        chunckedSchedule.forEach(addSchedule)
    }

    private func timeButton(title: String, enabled: Bool) -> UIButton {
        let button = RoundEdgeButton(type: .custom)
        if enabled {
            button <~ Style.RoundedButton.timeRedBordered
        } else {
            button <~ Style.RoundedButton.timeDisabledBordered
        }
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(timeButtonTap(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = enabled
        return button
    }

    // MARK: - Actions

    @objc private func timeButtonTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        timeButtonsInfo.forEach { timeButtonInfo in
            if timeButtonInfo.button === sender {
                let scheduleInterval = sender.isSelected ? timeButtonInfo.scheduleInterval : nil
                output.confirmAppointment(scheduleInterval, doctor)
            } else {
                timeButtonInfo.button.isSelected = false
            }
        }
    }

    @objc func doctorPickerTap(_ sender: UIButton) {
        guard let speciality = doctor?.speciality else { return }

        output.doctorPicker(speciality)
    }
}
