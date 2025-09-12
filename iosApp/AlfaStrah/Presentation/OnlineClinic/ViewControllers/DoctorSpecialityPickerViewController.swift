//
//  DoctorKindPickerViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

final class DoctorSpecialityPickerViewController: ViewController,
                                                  UITableViewDataSource,
                                                  UITableViewDelegate,
                                                  UISearchBarDelegate {
    struct Input {
        var data: () -> NetworkData<[DoctorSpeciality]>
    }

    struct Output {
        var selected: (DoctorSpeciality) -> Void
        var refresh: () -> Void
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
    
    private let stateView = ZeroView()
    
    private lazy var stateViewTopToViewConstraint: NSLayoutConstraint = {
        return stateView.topAnchor.constraint(equalTo: view.topAnchor)
    }()
    
    private lazy var stateViewTopToSearchBarConstraint: NSLayoutConstraint = {
        return stateView.topAnchor.constraint(equalTo: searchBar.bottomAnchor)
    }()
    
    private lazy var stateViewBottomToViewConstraint: NSLayoutConstraint = {
        return stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    }()

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!

    private var specialities: [DoctorSpeciality] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update(reload: false)
        output.refresh()
        
        subscribeForKeyboardNotifications()
    }

    // MARK: - Setup UI

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("clinics_specialties_picker_title", comment: "")

        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        setupStateView()
        searchBar.placeholder = NSLocalizedString("clinic_search_speciality", comment: "")
    }
    
    private func setupStateView() {
        view.addSubview(stateView)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stateViewTopToViewConstraint,
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateViewBottomToViewConstraint
        ])
        
        self.zeroView = stateView
        hideZeroView()
    }

    private func update(reload: Bool) {
        stateViewTopToSearchBarConstraint.isActive = false
        stateViewTopToViewConstraint.isActive = true
        switch input.data() {
            case .loading:
                self.specialities = []
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let specialities):
                self.specialities = specialities
                if specialities.isEmpty {
                    showZeroView()
                    zeroView?.update(viewModel: .init(kind: .emptyList))
                } else {
                    hideZeroView()
                }
                filterSpecialities()
            case .error(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.output.refresh() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
        view.endEditing(true)

        if reload {
            tableView.reloadData()
        }
    }

    // MARK: - TableView delegate and data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSpecialities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DoctorSpecialityCell.id)
        let speciality = filteredSpecialities[indexPath.row]
        cell.set(title: speciality.title)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < filteredSpecialities.count {
            output.selected(filteredSpecialities[indexPath.row])
        }
    }

    // MARK: - Search
    private var searchString: String = "" {
        didSet {
            filterSpecialities()
            
            if searchString.isEmpty {
                filteredSpecialities = specialities
				hideZeroView()
                tableView.reloadData()
            } else {
                if filteredSpecialities.isEmpty {
                    showZeroView()
                    zeroView?.update(viewModel: .init(kind: .emptyList))
                } else {
                    hideZeroView()
                    tableView.reloadData()
                }
                
                stateViewTopToSearchBarConstraint.isActive = filteredSpecialities.isEmpty
                stateViewTopToViewConstraint.isActive = !filteredSpecialities.isEmpty
            }
        }
    }
    
    private var filteredSpecialities: [DoctorSpeciality] = []

    private func filterSpecialities() {
        filteredSpecialities = searchString.isEmpty
            ? specialities
            : specialities.filter {
                $0.title.localizedCaseInsensitiveContains(searchString) ||
                    ($0.description ?? "").localizedCaseInsensitiveContains(searchString)
            }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
        searchString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    // MARK: - Keyboard notifications handling
    private func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification)
    }
        
    @objc func keyboardWillHide(_ notification: NSNotification) {
        stateViewBottomToViewConstraint.constant = 0
    }
    
    func moveViewWithKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        let constraintConstant = -keyboardHeight
        
        if  stateViewBottomToViewConstraint.constant != constraintConstant {
            stateViewBottomToViewConstraint.constant = constraintConstant
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
