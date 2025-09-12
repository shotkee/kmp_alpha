//
//  InsuredPersonTableCell.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class InsuredPersonTableCell: UITableViewCell
{
    private var onCheckboxChanged: ((Bool) -> Void)?
    private var showInsuranceProgramPdf: (() -> Void)?
    private var showClinicsListPdf: (() -> Void)?

    // MARK: - UI

    @IBOutlet private var checkbox: CommonCheckboxButton!
    @IBOutlet private var horizontalSeparatorView: UIView!
    @IBOutlet private var personNameLabel: UILabel!
    @IBOutlet private var viewInsuranceProgramButton: UIButton!
    @IBOutlet private var viewClinicsListButton: UIButton!

    // MARK: - Instantiation

    static let id: Reusable<InsuredPersonTableCell> = .fromNib()

    // MARK: - Configuration

    func configure(
        person: FranchiseTransitionInsuredPerson,
        isChecked: Bool,
        onCheckboxChanged: @escaping (Bool) -> Void,
        isFirstInList: Bool,
        showInsuranceProgramPdf: (() -> Void)?,
        showClinicsListPdf: (() -> Void)?
    )
    {
		viewInsuranceProgramButton.titleLabel?.font = Style.Font.caption1
		viewInsuranceProgramButton.tintColor = .Text.textAccent
		
		viewClinicsListButton.titleLabel?.font = Style.Font.caption1
		viewClinicsListButton.tintColor = .Text.textAccent
        horizontalSeparatorView.isHidden = isFirstInList

        checkbox.isSelected = isChecked
        checkbox.isEnabled = !person.isCheckboxReadonly

		personNameLabel <~ Style.Label.primaryText
        personNameLabel.text = formatInsuredPersonName(
            firstName: person.firstName,
            lastName: person.lastName,
            patronymic: person.patronymic
        )

        viewInsuranceProgramButton.isHidden = !person.hasProgramPdf
        viewClinicsListButton.isHidden = !person.hasClinicsPdf

        self.onCheckboxChanged = onCheckboxChanged
        
        self.showInsuranceProgramPdf = showInsuranceProgramPdf
        self.showClinicsListPdf = showClinicsListPdf
    }

    @IBAction private func checkboxButtonTap()
    {
        checkbox.isSelected.toggle()
        onCheckboxChanged?(checkbox.isSelected)
    }

    @IBAction private func viewInsuranceProgramButtonTap()
    {
        showInsuranceProgramPdf?()
    }

    @IBAction private func viewClinicsListButtonTap()
    {
        showClinicsListPdf?()
    }
}
