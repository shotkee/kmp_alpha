//
//  AppointmentsListViewController.swift
//  AlfaStrah
//
//  Created by Vasyl Kotsiuba on 21.08.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

final class AppointmentsListViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    struct Input {
        var data: () -> NetworkData<VisitsData>
        var imageLoader: ImageLoader
    }

    struct Output {
        var refresh: () -> Void
        var futureOnlineDoctorVisit: (DoctorVisit) -> Void
        var pastOnlineDoctorVisit: (DoctorVisit) -> Void
        var futureOfflineAvisAppointment: (AVISAppointment) -> Void
        var pastOfflineAvisAppointment: (AVISAppointment) -> Void
    }

    struct Notify {
        var changed: (_ reload: Bool) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] _ in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update()
        }
    )

    struct VisitsData {
        let future: [DoctorVisit]
        let past: [DoctorVisit]
        let offline: [AVISAppointment]
    }

    private enum Section {
        case future([CommonAppointment])
        case past([CommonAppointment])
        case notice

        var appointments: [CommonAppointment]? {
            switch self {
                case .future(let appointments):
                    return appointments
                case .past(let appointments):
                    return appointments
                case .notice:
                    return nil
            }
        }
    }

    private var sections: [Section] {
        return [
            .notice,
            .future(commonAppointmentsInFuture),
            .past(commonAppointmentsInPast)
        ]
    }
    
    private var visitsData: VisitsData?
    
    private var commonAppointmentsInPast: [CommonAppointment] = []
    private var commonAppointmentsInFuture: [CommonAppointment] = []

    private lazy var pageLoadingView: PageLoadingTableViewCell = {
        let pageLoadingView = PageLoadingTableViewCell(style: .default, reuseIdentifier: nil)
        pageLoadingView.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: PageLoadingTableViewCell.cellHeight)
        pageLoadingView.startAnimating()
        return pageLoadingView
    }()

    private lazy var utcDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
    
    private lazy var localDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update()
        output.refresh()
    }

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        addZeroView()
		
		tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 132

        // Harcoded table view inset for action button (66 = 16 bottom inset from safe areа + 48 button height + extra 2 points).
        // This is needed because there is a layout bug in iOS<14 with stack view and table view clip to bounds = false
        tableView.contentInset = .init(top: 0, left: 0, bottom: 66, right: 0)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.registerReusableCell(AppointmentsNoticeCell.id)
    }

    private func update() {
        switch input.data() {
            case .loading:
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let visitsData):
                self.visitsData = visitsData
                
                let now = Date()
               
                commonAppointmentsInFuture.removeAll()
                commonAppointmentsInPast.removeAll()
                
                commonAppointmentsInFuture.append(contentsOf: visitsData.future)
                commonAppointmentsInPast.append(contentsOf: visitsData.past)
                
                for appointment in visitsData.offline {
                    let date = appointment.localDate.date
                                        
                    if date < now {
                        commonAppointmentsInPast.append(appointment)
                    } else {
                        commonAppointmentsInFuture.append(appointment)
                    }
                }

                commonAppointmentsInPast.sort(
                    by: { $0.compareDate ?? .distantPast > $1.compareDate ?? .distantPast }
                )
                
                commonAppointmentsInFuture.sort(
                    by: { $0.compareDate ?? .distantFuture < $1.compareDate ?? .distantFuture }
                )
                
                tableView.reloadData()
                
                let zeroViewModel = ZeroViewModel(
                    kind: .custom(
                        title: NSLocalizedString("zero_no_doctor_appointments", comment: ""),
                        message: nil,
                        iconKind: .search
                    )
                )
                zeroView?.update(viewModel: zeroViewModel)
                (commonAppointmentsInFuture.isEmpty && commonAppointmentsInPast.isEmpty)
                    ? showZeroView()
                    : hideZeroView()
            case .error(let error):
                var zeroViewModel: ZeroViewModel
                if let error = error as? AlfastrahError, error.apiErrorKind == .notAvailableInDemoMode {
                    zeroViewModel = ZeroViewModel(kind: .demoMode(.common))
                } else {
                    zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.output.refresh() }))
                    )
                }

                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
    }

    // MARK: - TableView delegate and data source

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
            case .future(let doctorVisits):
                return doctorVisits.isEmpty ? 0 : 1
            case .past(let doctorVisits):
                return doctorVisits.count
            case .notice:
                return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
            case .future:
                return nil
            case .past:
                return NSLocalizedString("clinic_appointment_history", comment: "")
            case .notice:
                return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
            case .future:
                return CGFloat.leastNonzeroMagnitude
            case .past:
                return 24
            case .notice:
                return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView
        else { fatalError("Invalid header view") }

        header.textLabel?.font = Style.Font.headline1
		header.textLabel?.textColor = .Text.textPrimary
		header.backgroundView?.backgroundColor = .Background.background
        
        header.textLabel?.text = header.textLabel?.text?.lowercased()
        header.textLabel?.text = header.textLabel?.text?.capitalizingFirstLetter()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
            case .notice:
                let cell = tableView.dequeueReusableCell(AppointmentsNoticeCell.id)
                return cell
            case .future(let appointments):
                let cell = tableView.dequeueReusableCell(ActiveDoctorVisitCell.id)
                cell.set(
                    appointments: appointments,
                    getDateFormatter: getDateFormatter,
                    imageLoader: input.imageLoader,
                    appointmentTapCallback: { [weak self] appointment in
                        guard let self = self
                        else { return }

                        switch appointment.type {
                            case .offline(let id):
                                guard let avisAppointment = self.visitsData?.offline.first(
                                    where: { $0.id == id }
                                )
                                else { return }

                                self.output.futureOfflineAvisAppointment(avisAppointment)
                            case .infoClinic(let visitId):
                                guard let futureVisit = self.visitsData?.future.first(
                                    where: { $0.id == visitId }
                                )
                                else { return }
                                
                                self.output.futureOnlineDoctorVisit(futureVisit)
                        }
                    }
                )
                return cell
            case .past(let appointments):
                let cell = tableView.dequeueReusableCell(PastDoctorVisitCell.id)
                guard let appointment = appointments[safe: indexPath.row]
                else { return UITableViewCell() }
                
                cell.set(
                    appointment: appointment,
                    dateFormatter: getDateFormatter(appointment)
                )
                cell.clipsToBounds = false
                return cell
        }
    }
    
    private func getDateFormatter(_ appointment: CommonAppointment) -> DateFormatter {
        switch appointment.type {
            case .offline:
                return self.utcDateFormatter
            case .infoClinic:
                return self.localDateFormatter
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
            case .notice:
                break
            case .future:
                break
            case .past(let appointments):
                guard let appointment = appointments[safe: indexPath.row]
                else { return }
                
                switch appointment.type {
                    case .offline(let id):
                        guard let avisAppointment = self.visitsData?.offline.first(
                            where: { $0.id == id }
                        )
                        else { return }
                        
                        output.pastOfflineAvisAppointment(avisAppointment)
                    case .infoClinic(let visitId):
                        guard let pastVisit = self.visitsData?.past.first(
                            where: { $0.id == visitId }
                        )
                        else { return }
                        
                        output.pastOnlineDoctorVisit(pastVisit)
                }
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
