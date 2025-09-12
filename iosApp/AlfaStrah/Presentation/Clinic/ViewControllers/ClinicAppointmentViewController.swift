//
//  ClinicAppointmentViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ClinicAppointmentViewController: ViewController, UITextFieldDelegate {
    struct Input {
        var data: () -> NetworkData<ClinicOfflineAppointmentViewController.Kind>
        var insurance: Insurance
        var minimumDate: Date
    }

    struct Output {
        var createAppointment: (OfflineAppointment) -> Void
        var phoneTap: (Phone) -> Void
        var createCalendarEvent: (OfflineAppointment) -> Void
        var refresh: () -> Void
    }

    struct Notify {
        var changed: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let `self` = self, self.isViewLoaded else { return }

            self.update()
        }
    )

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var createAppointmentButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private var buttonHeightLayoutConstraint: NSLayoutConstraint!

    private var reasonView: CommonNoteView?
    private var dateInfoView: CommonInfoView?
    private let keyboardBehavior = KeyboardBehavior()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        datePicker.locale = AppLocale.currentLocale
        datePicker.minimumDate = self.input.minimumDate
        datePicker.maximumDate = AppLocale.calendar.date(byAdding: .year, value: 1, to: self.input.minimumDate)
        return datePicker
    }()

    private lazy var datePickerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 216).with(priority: .required - 1),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        view.isHidden = true
        view.clipsToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundContent

        title = NSLocalizedString("clinic_appointment_title", comment: "")

        buttonHeightLayoutConstraint.constant = 0
        createAppointmentButton <~ Style.Button.ActionRed(title: NSLocalizedString("clinic_appointment_confirm", comment: ""))

        addZeroView()

        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let `self` = self, let reasonView = self.reasonView else { return }

            let frameInView = self.view.convert(frame, from: nil)
            let offset = max(self.view.bounds.maxY - frameInView.minY - self.view.safeAreaInsets.bottom, 0)
            self.bottomLayoutConstraint.constant = offset
            self.view.layoutIfNeeded()

            if offset >= 0.1 {
                let frame = reasonView.convert(reasonView.bounds, to: self.scrollView)
                self.scrollView.scrollRectToVisible(frame, animated: true)
            }
        }

        update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        output.refresh()
        keyboardBehavior.subscribe()
        if case .confirmAppointment? = appointmentKind {
            reasonView?.becomeActive()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(false)
        keyboardBehavior.unsubscribe()
    }

    // MARK: - Setup UI

    private func update() {
        switch input.data() {
            case .loading:
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let kind):
                appointmentKind = kind
                updateInfo(kind: kind)
                hideZeroView()
            case .error(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.output.refresh() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
    }

    private var appointmentKind: ClinicOfflineAppointmentViewController.Kind?
    private var dateSelectionEnabled: Bool = false

    private func updateInfo(kind: ClinicOfflineAppointmentViewController.Kind) {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        switch kind {
            case .confirmAppointment(let appointment):
                buttonHeightLayoutConstraint.isActive = false
                createAppointmentButton.isHidden = false
                updateCreateButton(!appointment.reason.isEmpty)
                dateSelectionEnabled = true
                addAttentionInfo()
                addInsuranceInfo()
                appointment.clinic.map(addClinicInfo)
                addDateInfo()
                stackView.addArrangedSubview(datePickerContainerView)
                addSeparator()
                updateAppointmentDateInfo(appointment.date)
                addReasonView(appointment.reason, editable: true)
            case .viewAppointment(let appointment):
                buttonHeightLayoutConstraint.isActive = true
                createAppointmentButton.isHidden = true
                dateSelectionEnabled = false
                addAttentionInfo()
                addAppoinmentNumberInfo(appointment.appointmentNumber)
                addInsuranceInfo()
                appointment.clinic.map(addClinicInfo)
                addDateInfo()
                addSeparator()
                updateAppointmentDateInfo(appointment.date)
                addCalendarAction()
                addReasonView(appointment.reason, editable: false)
        }
    }

    private func addAttentionInfo() {
        let attentionView = CommonAttentionView()
        let message = NSLocalizedString("clinic_appointment_operator_confirm_alert", comment: "")
        attentionView.set(message: message, appearance: .yellow)
        stackView.addArrangedSubview(attentionView)
    }

    private func addAppoinmentNumberInfo(_ number: String) {
        let appoinmentNumberInfoView = CommonInfoView.fromNib()
        appoinmentNumberInfoView.set(
            title: NSLocalizedString("clinic_appointment_number", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: number) ]
        )
        stackView.addArrangedSubview(appoinmentNumberInfoView)
    }

    private func addInsuranceInfo() {
        let insuranceInfoView = CommonInfoView.fromNib()
        let insuranceTextBlock = CommonInfoView.TextBlock(text: input.insurance.title + " " + input.insurance.insuredObjectTitle)
        insuranceInfoView.set(title: NSLocalizedString("common_insurance_title", comment: ""), textBlocks: [ insuranceTextBlock ])
        stackView.addArrangedSubview(insuranceInfoView)
    }

    private func addClinicInfo(_ clinic: Clinic) {
        let clinicInfoView = CommonInfoView.fromNib()
        clinicInfoView.set(title: NSLocalizedString("clinic_appointment_clinic", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: clinic.title) ])
        stackView.addArrangedSubview(clinicInfoView)

        let fullInfo = input.insurance.accessClinicPhone ?? false
        if fullInfo, !(clinic.phoneList ?? []).isEmpty {
            let textBlocks = (clinic.phoneList ?? []).map { phone in
                CommonInfoView.TextBlock(text: phone.humanReadable) { [weak self] in
                    guard let `self` = self else { return }

                    self.view.endEditing(true)
                    self.output.phoneTap(phone)
                }
            }
            let phoneInfoView = CommonInfoView.fromNib()
            phoneInfoView.set(title: NSLocalizedString("clinic_appointment_phone", comment: ""), textBlocks: textBlocks,
                icon: UIImage(named: "icon-phone"))
            stackView.addArrangedSubview(phoneInfoView)
        }
    }

    private func addCalendarAction() {
        let textBlock = CommonInfoView.TextBlock(text: NSLocalizedString("info_add_to_calendar", comment: "")) { [weak self] in
            guard let self = self, let appointment = self.appointmentKind?.appointment else { return }

            self.output.createCalendarEvent(appointment)
        }

        let calendarInfoView = CommonInfoView.fromNib()
        calendarInfoView.set(title: nil, textBlocks: [ textBlock ], icon: UIImage(named: "icon-add-calendar"))
        stackView.addArrangedSubview(calendarInfoView)
    }

    private func addDateInfo() {
        let dateInfoView = CommonInfoView.fromNib()
        self.dateInfoView = dateInfoView
        stackView.addArrangedSubview(dateInfoView)
    }

    private func addSeparator() {
        let separatorContainerView = UIView()
        let separatorView = HairLineView()
        separatorContainerView.addSubview(separatorView)
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: separatorView, in: separatorContainerView,
            margins: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)))
        stackView.addArrangedSubview(separatorContainerView)
    }

    private func addReasonView(_ reason: String, editable: Bool) {
        let reasonView: CommonNoteView = .init()
        self.reasonView = reasonView
        reasonView.isEnabled = editable
        reasonView.textViewChangedCallback = { [weak self] textView in
            guard let self = self, var appointment = self.appointmentKind?.appointment else { return }

            appointment.reason = textView.text
            self.appointmentKind?.updateAppointment(appointment)
            self.updateCreateButton(!textView.text.isEmpty)
        }
        reasonView.set(
            title: NSLocalizedString("clinic_appointment_reason", comment: ""),
            note: reason,
            placeholder: NSLocalizedString("clinic_appointment_reason_placeholder", comment: ""),
            margins: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        )
        stackView.addArrangedSubview(reasonView)
    }

    private func updateCreateButton(_ isEnabled: Bool) {
        createAppointmentButton.isEnabled = isEnabled
    }

    private func updateAppointmentDateInfo(_ date: Date) {
        let textBlock = CommonInfoView.TextBlock(text: AppLocale.dateString(date)) { [weak self] in
            guard let self = self, self.dateSelectionEnabled else { return }

            self.view.endEditing(false)
            UIView.animate(withDuration: 0.25) {
                self.datePickerContainerView.isHidden = !self.datePickerContainerView.isHidden
                self.datePickerContainerView.alpha = self.datePickerContainerView.isHidden ? 0 : 1
            }
        }
        dateInfoView?.set(title: NSLocalizedString("clinic_appointment_date", comment: ""), textBlocks: [ textBlock ],
            appearance: CommonInfoView.Appearance(separator: false))
    }

    @IBAction func createAppointmentTap(_ sender: UIButton) {
        view.endEditing(false)
        guard let appointment = self.appointmentKind?.appointment else { return }

        output.createAppointment(appointment)
    }

    @objc private func dateSelected(_ datePicker: UIDatePicker) {
        updateAppointmentDateInfo(datePicker.date)
        guard var appointment = appointmentKind?.appointment else { return }

        appointment.date = datePicker.date
        appointmentKind?.updateAppointment(appointment)
    }
}
