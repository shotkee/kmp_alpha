//
//  MainInsuranceView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 09/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class MainInsuranceView: UIView {
    @IBOutlet private var archiveView: UIButton!
    @IBOutlet private var buyButton: RoundEdgeButton!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var resetButton: UIButton!
    @IBOutlet private var filterButtonImageView: UIImageView!
    @IBOutlet private var filterButton: RoundEdgeButton!
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var filterView: UIView!
    @IBOutlet private var insuranceButtonsView: UIView!
    @IBOutlet private var insuranceSearchView: UIImageView!
    @IBOutlet private var insuranceActivateView: UIImageView!
    @IBOutlet private var labels: [UILabel]!
    @IBOutlet private var insuranceTitleLabel: UILabel!
    @IBOutlet private var insuranceStackView: UIStackView!
    @IBOutlet private var archiveListLabel: UILabel!
    @IBOutlet private var searchButtonLabel: UILabel!
    @IBOutlet private var activateButtonLabel: UILabel!
    @IBOutlet private var insuranceCardView: CardView!
    private var input: Input!
    private var output: Output!

    private enum Constants {
        static let countForSeparate = 2
        static let bigSpace = 15
        static let smallSpace = 3
    }

    // MARK: - Actions

    @IBAction private func buyInsuranceClick(_ sender: Any) {
        output.buy()
    }
    @IBAction private func archiveClick(_ sender: Any) {
        output.archive()
    }
    @IBAction private func searchClick(_ sender: Any) {
        output.search()
    }
    @IBAction private func insuranceActivateClick(_ sender: Any) {
        output.activate()
    }
    @IBAction private func filterClick(_ sender: Any) {
        output.filter()
    }
    @IBAction private func resetClick(_ sender: Any) {
        output.resetFilter()
    }

    struct Input {
        var filters: [InsuranceCategoryMain.CategoryType]
        let insurances: [InsuranceGroup]
        let isAuthorized: Bool
        let isAlphaLife: Bool
    }

    struct Output {
        let search: () -> Void
        let activate: () -> Void
        let archive: () -> Void
        let buy: () -> Void
        let signIn: () -> Void
        let chat: () -> Void
        let insurance: (InsuranceShort) -> Void
        let prolong: (InsuranceShort) -> Void
        let filter: () -> Void
        let resetFilter: () -> Void
        let sos: (InsuranceGroupCategory) -> Void
        let openDraft: () -> Void
    }

    func set(input: Input, output: Output) {
        self.input = input
        self.output = output
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupStyle()
    }

    private func setup() {
        filterButtonImageView.image = .Icons.more.tintedImage(withColor: .Icons.iconPrimary)
		insuranceSearchView.image = .Icons.search.tintedImage(withColor: .Icons.iconAccent)
        insuranceActivateView.image = .Icons.lock.tintedImage(withColor: .Icons.iconAccent)
        setFilterButton()
        filterView.isHidden = !input.isAuthorized || input.insurances.isEmpty || input.isAlphaLife
        insuranceButtonsView.isHidden = !input.isAuthorized
        archiveView.isHidden = !input.isAuthorized

        guard input.isAuthorized else {
            contentStackView.addArrangedSubview(signInView())
            return
        }
        
        let draftSection = MainDraftSectionView()
        draftSection.input = .init(
            tapOnView: output.openDraft
        )
        contentStackView.insertArrangedSubview(draftSection, at: 1)

        if input.insurances.isEmpty {
            contentStackView.addArrangedSubview(chatView())
        } else {
            insuranceView(with: input.insurances).forEach(insuranceStackView.addArrangedSubview)
        }
        resetButton.isHidden = input.filters.isEmpty
    }

    private func setFilterButton() {
        if input.filters.isEmpty {
            filterLabel.text = NSLocalizedString("main_all_category", comment: "")
        } else {
            filterLabel.text = input.filters.map { $0.title }.joined(separator: ", ")
        }
    }

    private func signInView() -> UIView {
        let view = IllustratedNotifyWithButton.fromNib()
        view.set(
            input: .init(
                text: NSLocalizedString("main_auth_text", comment: ""),
                buttonTitle: NSLocalizedString("auth_sign_in_sign_in", comment: "")
            ),
            action: output.signIn
        )
        return view
    }

    private func chatView() -> UIView {
        let view = IllustratedNotifyWithButton.fromNib()
        view.set(
            input: .init(
                text: NSLocalizedString("main_chat_text", comment: ""),
                buttonTitle: NSLocalizedString("main_chat_button", comment: "")
            ),
            action: output.chat
        )
        return view
    }

    private func filtration(insuranceGroups: [InsuranceGroup]) -> [InsuranceGroup] {
        var filterGroup: [InsuranceGroup] = []

        for group in insuranceGroups {
            let categorys = group.insuranceGroupCategoryList.filter { input.filters.contains($0.insuranceCategory.type) }
                if categorys.isEmpty {
                    continue
                }
            let newGroup = InsuranceGroup(
                objectName: group.objectName,
                objectType: group.objectType,
                insuranceGroupCategoryList: categorys
            )
            filterGroup.append(newGroup)
        }
        return filterGroup
    }

    private func insuranceView(with insuranceGroups: [InsuranceGroup]) -> [UIView] {
        var sections: [UIView] = []
        let filteredGroups = input.filters.isEmpty ? insuranceGroups : filtration(insuranceGroups: insuranceGroups)
        let needSeparatedCardViews = filteredGroups.count <= Constants.countForSeparate

        for group in filteredGroups where group.isSupported {
            let section = InsuranceSectionView.fromNib()
            let childViews = addCategoryViews(categories: group.insuranceGroupCategoryList)
            section.set(
                type: group.objectType,
                object: group.objectName,
                renewCount: group.renewInsuranceCount,
                children: childViews,
                isOpen: true
            )

            let cardSections = needSeparatedCardViews ? addCardView(with: section) : section
            insuranceCardView.contentColor = needSeparatedCardViews ? .Background.backgroundSecondary : .Stroke.divider
            insuranceStackView.spacing = CGFloat(needSeparatedCardViews ? Constants.bigSpace : Constants.smallSpace)
            insuranceCardView.hideShadow = needSeparatedCardViews

            sections.append(cardSections)
        }
        return sections
    }
	
	private var categoryViews: [InsuranceCategoryView] = []

    private func addCategoryViews(categories: [InsuranceGroupCategory]) -> [UIView] {
        var childViews: [UIView] = []
        let categories = categories.filter { $0.isSupported }
        for (index, category) in categories.enumerated() {
            let categoryView = InsuranceCategoryView.fromNib()
            var insuranceViews: [UIView] = []
            let daysCountStyleChange = 30
            let now = Date()
            
            for insurance in category.insuranceList {
                let insuranceView = ShortInsuranceView.fromNib()
                insuranceView.set(
                    title: insurance.title,
                    subtitle: {
                        if insurance.startDate > now {
                            return startedFromString(insurance.startDate)
                        }
                        return expireString(from: insurance.endDate, daysCount: daysCountStyleChange)
                    }(),
                    styleChange: {
                        if insurance.startDate > now {
                            return true
                        }
                        return countDays(to: insurance.endDate) > daysCountStyleChange
                    }(),
                    tag: insurance.label,
                    showRenewButton: insurance.renewAvailable,
                    warning: insurance.warning,
                    output: .init(
                        insuranceTap: {
                            self.output.insurance(insurance)
                        },
                        prolongTap: {
                            self.output.prolong(insurance)
                        }
                    )
                )
                insuranceViews.append(insuranceView)
            }
            if let actionView = addActionButton(category) {
                insuranceViews.append(actionView)
            }

            categoryView.set(
                title: category.insuranceCategory.title,
                image: InsuranceHelper.image(for: category.insuranceCategory.type),
				imageThemed: category.insuranceCategory.iconThemed,
                isFirst: index == 0,
                childs: insuranceViews
            )
			categoryViews.append(categoryView)
            childViews.append(categoryView)
        }
        return childViews
    }

    private func addCardView(with view: UIView) -> UIView {
        let cardView = CardView(contentView: view)
        cardView.contentColor = .Background.backgroundTertiary
        return cardView
    }

    private func addActionButton(_ category: InsuranceGroupCategory) -> UIView? {
        if let activity = category.sosActivity, activity.isSupported {
            let actionButtonView = InsuranceCaseButtonView.fromNib()
            actionButtonView.set(title: activity.title) {
                self.output.sos(category)
            }
            return actionButtonView
        }
        return nil
    }

    private func setupStyle() {
        insuranceTitleLabel <~ Style.Label.primaryTitle1
        resetButton <~ Style.Button.labelButton
        buyButton <~ Style.Button.redInvertRoundButton
        labels.forEach { $0 <~ Style.Label.secondaryText }
        filterButton <~ Style.RoundedButton.mainFilterButton
        
        filterLabel.textColor = .Text.textPrimary
        
        archiveListLabel.text = NSLocalizedString("common_archive_list", comment: "")
        archiveListLabel.textColor = .Text.textPrimary
        
        searchButtonLabel.text = NSLocalizedString("common_search", comment: "")
        searchButtonLabel.textColor = .Text.textPrimary
        
        activateButtonLabel.text = NSLocalizedString("common_activate", comment: "")
        activateButtonLabel.textColor = .Text.textPrimary
    }
    
    private func expireString(from date: Date, daysCount: Int) -> String {
        let validUntil: String
        let days = countDays(to: date)
        
        if days < 0 {
            validUntil = NSLocalizedString("insurance_expired", comment: "") + AppLocale.dateString(date)
            return validUntil
        }
        
        if days >= daysCount {
            validUntil = NSLocalizedString("insurance_expiration_until", comment: "") + AppLocale.dateString(date)
        } else {
            let format = NSLocalizedString("insurance_expiration_days", comment: "")
        
            let correctDaysCount = days < 0 ? 1 : days + 1

            let insuranceCount = String.localizedStringWithFormat(format, correctDaysCount)
            let filterFormat = NSLocalizedString("insurance_expiration", comment: "")
            validUntil = String.localizedStringWithFormat(filterFormat, insuranceCount)
        }
        return validUntil
    }
    
    private func startedFromString(_ date: Date) -> String {
        return NSLocalizedString("insurance_started_from", comment: "") + AppLocale.dateString(date)
    }
    
    private func countDays(to: Date) -> Int {
        Calendar.current.dateComponents([ .day ], from: Date(), to: to).day ?? 1
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        filterButtonImageView.image = .Icons.more.tintedImage(withColor: .Icons.iconPrimary)
        insuranceSearchView.image = .Icons.search.tintedImage(withColor: .Icons.iconAccent)
        insuranceActivateView.image = .Icons.lock.tintedImage(withColor: .Icons.iconAccent)
        
		categoryViews.forEach { $0.updateColors(theme: traitCollection.userInterfaceStyle) }
		
        buyButton <~ Style.Button.redInvertRoundButton
        filterButton <~ Style.RoundedButton.mainFilterButton
        resetButton <~ Style.Button.labelButton
    }
}
