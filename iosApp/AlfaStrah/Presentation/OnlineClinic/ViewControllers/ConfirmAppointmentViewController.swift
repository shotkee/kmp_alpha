//
//  ConfirmAppointmentViewController.swift
//  AlfaStrah
//
//  Created by vit on 31.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class ConfirmAppointmentViewController: ViewController {
    enum State {
        case loading
        case failure(title: String, description: String)
        case success
        case data
    }
    
    struct Notify {
        let update: (_ state: State) -> Void
    }

    private(set) lazy var notify = Notify(
        update: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.update(with: state)
        }
    )
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    
    private let confirmButton = RoundEdgeButton()
    
    private let clinicSectionsCardView = SectionsCardView()
    private let doctorSectionsCardView = SectionsCardView()
    private let operationStatusView = OperationStatusView()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, HH:mm"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
    
    struct Input {
        let clinic: Clinic
        let doctor: FullDoctor
        let scheduleInterval: DoctorScheduleInterval
        let appear: () -> Void
    }

    struct Output {
        let confirmAppointment: () -> Void
        let done: () -> Void
        let chooseAnotherTimeInterval: () -> Void
    }

    var input: Input!
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
        
    private func setupUI() {
        title = NSLocalizedString("clinic_appointment_online_create_title", comment: "")
        
		view.backgroundColor = .Background.backgroundContent
        
        setupLayout(
            scrollView: scrollView,
            contentStackView: contentStackView,
            actionButtonsStackView: actionButtonsStackView,
            for: self
        )
        
        setupConfirmButton()
        setupSections()
        setupOperationStatusView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.appear()
        updateData()
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
    }
    
    private func setupConfirmButton() {
        confirmButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        confirmButton.setTitle(
            NSLocalizedString("common_confirm", comment: ""),
            for: .normal
        )
        confirmButton.addTarget(self, action: #selector(confirmTap), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        actionButtonsStackView.addArrangedSubview(confirmButton)
    }
    
    private func setupSections() {
        contentStackView.addArrangedSubview(clinicSectionsCardView)
        contentStackView.addArrangedSubview(spacer(21))
        contentStackView.addArrangedSubview(doctorSectionsCardView)
    }
    
    private func updateData() {
        let clinic = input.clinic
        let clinicPhonesString = (clinic.phoneList ?? []).map { $0.humanReadable }.joined(separator: "\n")
        
        let clinicItems = [
            SectionsCardView.Item(
                title: NSLocalizedString("clinic_title", comment: ""),
                placeholder: "",
                value: clinic.title,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            SectionsCardView.Item(
                title: NSLocalizedString("clinic_appointment_clinic_address", comment: ""),
                placeholder: "",
                value: clinic.address,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            SectionsCardView.Item(
                title: NSLocalizedString("clinic_appointment_phone", comment: ""),
                placeholder: "",
                value: clinicPhonesString,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
        ]
        
        clinicSectionsCardView.updateItems(clinicItems)
        
        let doctor = input.doctor
        let appointmentTimeSlotStartDate = input.scheduleInterval.startDate
        
        let doctorItems = [
            SectionsCardView.Item(
                title: NSLocalizedString("clinic_appointment_doctor", comment: ""),
                placeholder: "",
                value: doctor.title,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            SectionsCardView.Item(
                title: NSLocalizedString("clinic_appointment_speciality", comment: ""),
                placeholder: "",
                value: doctor.speciality.title,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            SectionsCardView.Item(
                title: NSLocalizedString("clinic_online_appointment_date", comment: ""),
                placeholder: "",
                value: dateFormatter.string(from: appointmentTimeSlotStartDate),
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
        ]
        
        doctorSectionsCardView.updateItems(doctorItems)
    }
    
    @objc func confirmTap() {
        output.confirmAppointment()
    }
    
    private func update(with state: State) {
        switch state {
            case .success:
                operationStatusView.isHidden = false
                scrollView.isHidden = true
                
                let operationStatusViewState: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("clinic_appointment_create_online_appointment_success_title", comment: ""),
                    description: NSLocalizedString("clinic_appointment_create_online_appointment_success_description", comment: ""),
                    icon: UIImage(named: "icon-check-success")
                ))
				
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_done_button", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.done()
                        }
                    )
                ]
                
                operationStatusView.notify.updateState(operationStatusViewState)
                operationStatusView.notify.buttonConfiguration(buttons)
                
            case .failure(let title, let description):
                operationStatusView.isHidden = false
                scrollView.isHidden = true
				
                let operationStatusViewState: OperationStatusView.State = .info(.init(
                    title: title,
                    description: description,
                    icon: .Icons.cross.resized(newWidth: 32)?.withRenderingMode(.alwaysTemplate)
                ))

                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("clinic_appointment_create_online_appointment_retry", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.chooseAnotherTimeInterval()
                        }
                    )
                ]
                operationStatusView.notify.updateState(operationStatusViewState)
                operationStatusView.notify.buttonConfiguration(buttons)
                
            case .loading:
                operationStatusView.isHidden = false
                scrollView.isHidden = true
                
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("clinic_appointment_loading_title", comment: ""),
                    description: nil,
                    icon: nil
                ))

                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration([])
            case .data:
                operationStatusView.isHidden = true
                scrollView.isHidden = false
                
                operationStatusView.notify.buttonConfiguration([])
        }
    }
}
