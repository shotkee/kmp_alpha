//
//  DmsCostRecoveryBankSearchViewController.swift
//  AlfaStrah
//
//  Created by vit on 26.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class DmsCostRecoveryBankSearchViewController: ViewController,
                                               UISearchBarDelegate,
                                               UITableViewDelegate,
                                               UITableViewDataSource
{
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    @IBOutlet private var noticeLabel: UILabel!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var headerView: UIView!
    
    private let doneButton = RoundEdgeButton()
        
    private var searchString: String = "" {
        didSet {
            input.searchBanks(searchString) { [weak self] foundBanks in
                guard let self = self
                else { return }
                
                if self.searchString.isEmpty {
                    self.banks = self.input.popularBanks
                    self.tableView.tableHeaderView = self.headerView
                } else {
                    self.tableView.tableHeaderView = nil
                    self.banks = foundBanks.filter{
                        $0.bik.contains(self.searchString)
                        || $0.title.lowercased().contains(self.searchString.lowercased())
                    }
                }
            }
        }
    }
    
    private var banks: [DmsCostRecoveryBank] = [] {
        didSet {
            selectedBank = nil
            tableView.reloadData()
        }
    }
    
    private var selectedBank: DmsCostRecoveryBank?
    
    struct Input {
        let selectedBank: DmsCostRecoveryBank?
        let popularBanks: [DmsCostRecoveryBank]
        let searchBanks: (String, @escaping ([DmsCostRecoveryBank]) -> Void) -> Void
    }
    
    var input: Input!
    
    struct Output {
        let doneButtonTap: () -> Void
        let bankSelectionUpdated: (DmsCostRecoveryBank?) -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Background.backgroundContent
        tableView.allowsMultipleSelection = false
        
        title = NSLocalizedString("dms_cost_recovery_bank_search_title", comment: "")
        
        setupSearchBar()
        
        noticeLabel <~ Style.Label.secondaryText
        noticeLabel.text = NSLocalizedString("dms_cost_recovery_bank_search_notice", comment: "")
        
        headerLabel.text = NSLocalizedString("dms_cost_recovery_bank_search_popular", comment: "")
        headerLabel <~ Style.Label.primaryHeadline1
        
        setupDoneButton()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        banks = input.popularBanks
        
        if let index = banks.firstIndex(where: { $0 == input.selectedBank }) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
            doneButton.isEnabled = true
            
            selectedBank = input.selectedBank
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchBar.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.contentInset.bottom != actionButtonsStackView.bounds.height {
            tableView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("dms_cost_recovery_bank_search_title", comment: "")
        searchBar.returnKeyType = .search
        searchBar.backgroundImage = UIImage() // remove borders
    }
    
    private func setupDoneButton() {
        doneButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        doneButton.setTitle(
            NSLocalizedString("common_done_button", comment: ""),
            for: .normal
        )
        doneButton.addTarget(self, action: #selector(doneButtonTap), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(doneButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
        
        doneButton.isEnabled = false
    }
    
    @objc func doneButtonTap(_ sender: UIButton) {        
        output.doneButtonTap()
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
        searchString = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DmsCostRecoveryBankSearchTableCell.id)

        if let bank = banks[safe: indexPath.row] {
            cell.configure(searchString: searchString, bank: bank)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bank = banks[safe: indexPath.row],
              let cell = tableView.cellForRow(at: indexPath) as? DmsCostRecoveryBankSearchTableCell
        else { return }
                
        if bank == selectedBank {
            tableView.deselectRow(at: indexPath, animated: true)
            selectedBank = nil
            doneButton.isEnabled = false
        } else {
            selectedBank = bank
            doneButton.isEnabled = true
        }
        output.bankSelectionUpdated(selectedBank)
        searchBar.resignFirstResponder()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
