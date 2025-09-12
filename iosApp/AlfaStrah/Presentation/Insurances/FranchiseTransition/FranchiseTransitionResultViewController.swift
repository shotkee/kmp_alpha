//
//  FranchiseChangeProgramResultViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 08.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class FranchiseTransitionResultViewController: ViewController,
                                               UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var operationStatusView: OperationStatusView!
    
    // MARK: - Input
    struct Input
    {
        let persons: [FranchiseTransitionResultInsuredPerson]
        let isFranchiseTransitionSuccessful: Bool
        let resultMessage: String?
        let doneButtonTap: (() -> Void)?
    }

    var input: Input!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setTableHeightUsingAutolayout(
            tableView: tableView,
            tableViewHeightContraint: tableViewHeightConstraint
        )
        
        setupOperationStatusView(isSucceeded: input.isFranchiseTransitionSuccessful)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return input.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(InsuredPersonResultTableCell.id)

        if let person = input.persons[safe: indexPath.row] {
            cell.configure(person: person)
        }
        
        return cell
    }
    
    // MARK: - Operation Status View
    private func setupOperationStatusView(isSucceeded: Bool)
    {
        let shouldShowOperationViewInsteadOfTable = input.persons.count < 2
        
        scrollView.isHidden = shouldShowOperationViewInsteadOfTable
        
        if shouldShowOperationViewInsteadOfTable {
            let operationStatusViewTitle = isSucceeded
                ? NSLocalizedString("common_success", comment: "")
                : NSLocalizedString("common_error_title", comment: "")
                        
            let operationStatusViewDescription = NSLocalizedString(input.resultMessage ?? "", comment: "")
            
            let image = UIImage()
            
            let operationStatusViewIcon: UIImage = isSucceeded
                ? .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate) ?? image
                : .init(named: "icon-common-failure") ?? image
            
            operationStatusView.notify.updateState(
                .info(
                    .init(
                        title: operationStatusViewTitle,
                        description: operationStatusViewDescription,
                        icon: operationStatusViewIcon
                    )
                )
            )
        }
        
        let resultButtonConfiguration: OperationStatusView.ButtonConfiguration = isSucceeded
            ? .init(
                title: NSLocalizedString("common_to_main_screen", comment: ""),
                style: Style.RoundedButton.oldOutlinedButtonSmall,
                action: {
                    ApplicationFlow.shared.show(
                        item: .tabBar(.home)
                    )
                }
            )
            : .init(
                title: NSLocalizedString("common_go_to_chat", comment: ""),
                style: Style.RoundedButton.oldOutlinedButtonSmall,
                action: {
                    ApplicationFlow.shared.show(
                        item: .tabBar(.chat)
                    )
                }
            )
        
        operationStatusView.notify.buttonConfiguration(
            [
                resultButtonConfiguration,
                .init(
                    title: NSLocalizedString("common_done_button", comment: ""),
                    style: Style.RoundedButton.oldPrimaryButtonSmall,
                    action: { [weak self] in
                        self?.input.doneButtonTap?()
                    }
                )
            ]
        )
    }
}
