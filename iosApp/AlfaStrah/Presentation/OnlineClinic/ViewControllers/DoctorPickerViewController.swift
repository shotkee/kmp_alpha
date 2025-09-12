//
//  DoctorPickerViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class DoctorPickerViewController: ViewController,
                                  UITableViewDelegate,
                                  UITableViewDataSource,
                                  UISearchBarDelegate {
    enum State {
        case data(_ doctors: [FullDoctor], _ selectedDate: Date)
        case loading
        case failure
    }
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    private let searchBar = UISearchBar()
    private let calendarView = HorizontalCalendarView()
    private let operationStatusView = OperationStatusView()
    
    private let selectedDateLabel = UILabel()
    
    private var firstAppear = true
    
    private lazy var operationStatusViewTopToViewConstraint: NSLayoutConstraint = {
        return operationStatusView.topAnchor.constraint(equalTo: view.topAnchor)
    }()
    
    private lazy var operationStatusViewTopToSearchBarConstraint: NSLayoutConstraint = {
        return operationStatusView.topAnchor.constraint(equalTo: searchBar.bottomAnchor)
    }()

    struct Input {
        let speciality: DoctorSpeciality
        let load: () -> Void
        let appear: () -> Void
        let selectedIntervalId: () -> String?
    }

    struct Output {
        let calendar: (_ completion: @escaping (Date) -> Void) -> Void
        let doctor: (_ doctor: FullDoctor) -> Void
        var scheduleInterval: (_ timeInterval: DoctorScheduleInterval?, _ doctor: FullDoctor?) -> Void
        let retry: () -> Void
        let goToChat: () -> Void
        let doctorsListForDate: (_ selectedDate: Date, _ startScheduleDate: Date) -> Void
    }

    struct Notify {
        var updateWithState: (_ state: State) -> Void
    }

    var input: Input!
    var output: Output!
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWithState: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        }
    )

    private lazy var calendarButon: UIBarButtonItem = UIBarButtonItem(
        image: .Icons.calendar, style: .plain,
        target: self,
        action: #selector(calendarTap)
    )
    
    private var searchString: String = "" {
        didSet {
            if searchString.isEmpty {
                filteredDoctors = doctors
            } else {
                filteredDoctors = doctors.filter{
                    String($0.title.split(separator: " ")[0].lowercased()).contains(searchString.lowercased())
                }
            }
            
            navigationItem.rightBarButtonItem = filteredDoctors.isEmpty ? nil : calendarButon
            
            tableView.reloadData()
        }
    }
    
    private var doctors: [FullDoctor] = []
    private var filteredDoctors: [FullDoctor] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        input.load()    //fix flashing layout before content is loaded
    }
        
    override func viewDidAppear(_ animated: Bool) {     // did appear for lottie correct animation start
        super.viewDidAppear(animated)
        
        if firstAppear {
            input.appear()
            
            firstAppear = false
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    private func update(with state: State) {
        switch state {
            case .loading:
                operationStatusView.isHidden = false
                
                operationStatusViewTopToSearchBarConstraint.isActive = false
                operationStatusViewTopToViewConstraint.isActive = true
                
                navigationItem.rightBarButtonItem = calendarButon
                
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("clinic_appointment_loading_title", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)

            case .data(let doctors, let date):
                operationStatusViewTopToSearchBarConstraint.isActive = true
                operationStatusViewTopToViewConstraint.isActive = false
                                                
                self.doctors = doctors
                
                self.filteredDoctors = doctors
                
                navigationItem.rightBarButtonItem = calendarButon
                
                if self.filteredDoctors.isEmpty {
                    operationStatusView.isHidden = false
                    
                    let state: OperationStatusView.State = .info(.init(
                        title: NSLocalizedString("clinic_no_time_slots_available_on_this_day", comment: ""),
                        description: NSLocalizedString("clinic_look_other_date", comment: ""),
                        icon: nil
                    ))

                    operationStatusView.notify.buttonConfiguration([])
                    operationStatusView.notify.updateState(state)
                } else {
                    calendarView.updateInCurrentInterval(selectedDate: date)
                    
                    operationStatusView.isHidden = true
                    tableView.reloadData()
                }
                
            case .failure:
                operationStatusViewTopToSearchBarConstraint.isActive = false
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
        view.endEditing(true)
    }

    // MARK: - Setup UI
    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
        navigationItem.titleView = createTitleView()
        
        setupCalendarView()
        setupSearchBar()
        setupTableView()
        
        setupOperationStatusView()
    }
    
    private func createTitleView() -> UIView {
        let titleStackView = UIStackView()
        
        titleStackView.alignment = .center
        titleStackView.axis = .vertical
        titleStackView.distribution = .fill
        titleStackView.spacing = 2
        
        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = input.speciality.title
        
        selectedDateLabel <~ Style.Label.secondaryText
        selectedDateLabel.text = dateFormatter.string(from: Date())
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(selectedDateLabel)
        
        return titleStackView
    }
    
    private func updateSelectedDateLabel(with selectedDate: Date) {
        selectedDateLabel.text = dateFormatter.string(from: selectedDate)
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
    
    private func setupCalendarView() {
        view.addSubview(calendarView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        calendarView.set(activeDate: Date())
        calendarView.openCalendar = calendarHandler
        calendarView.activeDateCallback = { [weak self] selectedDate, startScheduleDate in
            guard let self = self
            else { return }
            
            self.resetSearch()
            self.updateSelectedDateLabel(with: selectedDate)
            self.output.doctorsListForDate(selectedDate, startScheduleDate)
        }
    }
    
    private func calendarHandler() {
        self.output.calendar{ [weak self] date in
            guard let self = self
            else { return }
            
            self.updateSelectedDateLabel(with: date)
            self.calendarView.set(activeDate: date)
        }
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("clinic_search_name", comment: "")
        searchBar.returnKeyType = .search
        searchBar.backgroundImage = UIImage()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.registerReusableCell(DoctorCell.id)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 7),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.backgroundColor = .clear
    }
    
    @objc func calendarTap(_ sender: UIBarButtonItem) {
        calendarHandler()
    }
    
    // MARK: - TableView delegate and data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredDoctors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DoctorCell.id)
        
        let doctor = filteredDoctors[indexPath.row]
        
        cell.scheduleIntervalTap = { [weak self, weak cell] scheduleInterval, selected in
            guard let self = self
            else { return }

            let interval = selected ? scheduleInterval : nil
            let doctor = selected ? doctor : nil
            self.output.scheduleInterval(interval, doctor)
            let visibleCells = self.tableView.visibleCells.compactMap { $0 as? DoctorCell }.filter { $0 !== cell }
            visibleCells.forEach { $0.deselectScheduleInterval() }
        }
        
        cell.otherTap = { [weak self] in
            self?.output.doctor(doctor)
        }
        
        cell.set(
            doctor: doctor,
            scheduleIntervals: doctor.schedules[0].scheduleIntervals,
            selectedIntervalId: input.selectedIntervalId()
        )

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = !(searchBar.text?.isEmpty ?? true)
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearch()
    }
    
    private func resetSearch() {
        searchBar.text = nil
        searchString = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchString != searchBar.text {
            searchString = searchBar.text ?? ""
        }

        searchBar.resignFirstResponder()
    }
}
