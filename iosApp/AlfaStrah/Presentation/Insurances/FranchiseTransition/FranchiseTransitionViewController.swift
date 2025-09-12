//
//  FranchiseTransitionViewController.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class FranchiseTransitionViewController: ViewController,
                                         UITableViewDataSource, UITableViewDelegate
{
    // MARK: - Input

    struct Input
    {
        let data: FranchiseTransitionData
    }
    var input: Input!

    // MARK: - Output

    struct Output
    {
        let changeProgram: (_ checkedPersonIds: [Int]) -> Void
        let showProgramTermsPdf: () -> Void
        let showInsuranceProgramPdf: ((_ personId: Int) -> Void)?
        let showClinicsListPdf: ((_ personId: Int) -> Void)?
    }

    var output: Output!

    // MARK: - Data

    private var personCheckboxStatuses: [Bool] = []

    // MARK: - UI

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var headerPromptTextView: UITextView!
    @IBOutlet private var insuredPersonsTable: UITableView!
    @IBOutlet private var insuredPersonsTableHeightConstraint: NSLayoutConstraint!

    @IBOutlet private var viewProgramTermsButton: UIButton!
    @IBOutlet private var personalDataAgreementView: CommonUserAgreementView!

    @IBOutlet private var submitButtonContainer: UIView!
    @IBOutlet private var submitButton: RoundEdgeButton!

    // MARK: - UIViewController

    override func viewDidLoad()
    {
        super.viewDidLoad()

        setup()
    }

    // MARK: - Setup

    private func setup()
    {
		view.backgroundColor = .Background.backgroundContent
		
        // screen title

        title = NSLocalizedString("change_insurance_program_screen_title", comment: "")

        // information

        let data = input.data
        headerPromptTextView <~ Style.TextView.secondaryText
        headerPromptTextView.text = data.promptText
        headerPromptTextView.sizeToFit()
        
        personCheckboxStatuses = data.persons.map { $0.isCheckedByDefault }

        // 'view program terms pdf' button

        viewProgramTermsButton.setTitle(data.programTermsButtonTitle, for: .normal)
        viewProgramTermsButton.isHidden = !data.hasPdfWithProgramTerms
		viewProgramTermsButton.titleLabel?.font = Style.Font.text

        // personal data

        personalDataAgreementView.set(
            text: data.confirmationText,
            userInteractionWithTextEnabled: false,
            links: [],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.updateBottomButtonState()
                }
            )
        )

        // 'go to franchise' button

        submitButton.setTitle(
            NSLocalizedString("change_insurance_program_go_to_franchise", comment: ""),
            for: .normal
        )
        submitButton <~ Style.RoundedButton.oldPrimaryButtonSmall

        updateBottomButtonState()

        setTableHeightUsingAutolayout(
            tableView: insuredPersonsTable,
            tableViewHeightContraint: insuredPersonsTableHeightConstraint
        )
    }

    private func updateBottomButtonState()
    {
        let hasCheckedOneOrMorePersons = personCheckboxStatuses.contains(true)

        submitButton.isEnabled = hasCheckedOneOrMorePersons
            && personalDataAgreementView.userConfirmedAgreement
    }

    // MARK: - Actions
    
    @IBAction func onViewProgramTermsButton()
    {
        output.showProgramTermsPdf()
    }

    @IBAction func onSubmitButton()
    {
        let checkedPersonsIds = input.data.persons
            .enumerated()
            .compactMap { personCheckboxStatuses[$0.offset] ? $0.element.id : nil }

        output.changeProgram(checkedPersonsIds)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return input.data.persons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(InsuredPersonTableCell.id)
        if let person = input.data.persons[safe: indexPath.row]
        {
            cell.configure(
                person: person,
                isChecked: personCheckboxStatuses[safe: indexPath.row] ?? false,
                onCheckboxChanged: { [weak self] isChecked in
                    self?.personCheckboxStatuses[indexPath.row] = isChecked
                    self?.updateBottomButtonState()
                },
                isFirstInList: indexPath.row == 0,
                showInsuranceProgramPdf: { [weak self] in
                    self?.output.showInsuranceProgramPdf?(person.id)
                },
                showClinicsListPdf: { [weak self] in
                    self?.output.showClinicsListPdf?(person.id)
                }
            )
        }
        return cell
    }
}
