//
//  RiskCategoryTableView.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 17/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length

class RiskCategoryTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var parentViewController: UIViewController?
    var inputAccessory: UIView?
    var dataIsReadyCallback: ((Bool) -> Void)?

    var risk: Risk?

    var categories: [RiskCategory] = [] {
        didSet {
            sections = categories.map {
                var values: [RiskDataValue] = []
                for field in $0.riskData {
                    // Select first option in decimalSelect controls by default
                    if field.kind == .decimalSelect, let options = field.options, let optionId = options.first?.id {
                        values.append(RiskDataValue(riskDataId: field.id, value: .decimalSelect(value: "", optionId: optionId)))
                    }
                }
                // By default all expandable categories are closed
                let opened = $0.kind == .expandable ? false : nil
                return Section(category: $0, values: values, opened: opened)
            }

            selectFirstRadioOption(visibleCategories: getVisibleCategories())
            visibleCategories = getVisibleCategories()
        }
    }

    var values: [RiskValue]? {
        didSet {
            guard let values = values else { return }

            for value in values {
                guard
                    let sectionIndex = sections.firstIndex(where: { $0.category.id == value.categoryId }),
                    let field = sections[sectionIndex].category.riskData.first(where: { $0.id == value.dataId })
                else { continue }

                let fieldValue: RiskDataValue.Value
                switch field.kind {
                    case .text:
                        fieldValue = .text(value.value)
                    case .checkbox:
                        fieldValue = .checkbox(value: value.value == "0" ? false : true)
                    case .radio:
                        fieldValue = .radio(optionId: value.optionId ?? "")
                    case .decimalSelect:
                        fieldValue = .decimalSelect(value: value.value, optionId: value.optionId ?? "")
                    case .date:
                        fieldValue = .date(value.value)
                    case .time:
                        fieldValue = .time(value.value)
                    case .decimal:
                        fieldValue = .decimal(value.value)
                }
                sections[sectionIndex][field.id] = RiskDataValue(riskDataId: field.id, value: fieldValue)
            }
        }
    }

    var outputValues: [RiskValue] {
        sections.flatMap { section in
            section.values.compactMap { value in
                var optionId: String?
                var riskValue: String?
                switch value.value {
                    case .text(let text):
                        riskValue = text
                    case .checkbox(value: let boolValue):
                        riskValue = boolValue ? "1" : "0"
                    case .radio(optionId: let optId):
                        optionId = optId
                    case .decimalSelect(value: let val, optionId: let optId):
                        riskValue = val
                        optionId = optId
                    case .date(let date):
                        riskValue = date
                    case .time(let time):
                        riskValue = time
                    case .decimal(let text):
                        riskValue = text
                }
                return RiskValue(riskId: risk?.id ?? "0", categoryId: section.category.id, dataId: value.riskDataId,
                                 optionId: optionId, value: riskValue ?? "")
            }
        }
    }

    private var visibleCategories: [RiskCategory] = []
    private var sections: [Section] = []

    struct Section {
        var category: RiskCategory
        var values: [RiskDataValue]
        var opened: Bool?

        subscript(id: String) -> RiskDataValue? {
            get {
                if let index = values.firstIndex(where: { id == $0.riskDataId }) {
                    return values[index]
                } else {
                    return nil
                }
            }
            set {
                let index = values.firstIndex { id == $0.riskDataId }
                if let newValue = newValue {
                    if let index = index {
                        values[index] = newValue
                    } else {
                        values.append(newValue)
                    }
                } else {
                    if let index = index {
                        values.remove(at: index)
                    }
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)

        commonInit()
    }

    private func commonInit() {
        registerReusableHeaderFooter(RMRTableSectionHeader.id)
        registerReusableHeaderFooter(RiskCategoryExpandableHeader.id)
        registerReusableCell(RadioControlCell.id)
        registerReusableCell(SwitchCell.id)
        registerReusableCell(DecimalAndSelectCell.id)
        registerReusableCell(TextFieldCell.id)
        delegate = self
        dataSource = self
        estimatedSectionHeaderHeight = 40
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 90
    }

    private func getVisibleCategories() -> [RiskCategory] {
        sections
            .map { $0.category }
            .filter {
                guard let dependency = $0.dependency else { return true }

                if let checkboxId = dependency.checkboxId, !checkboxId.isEmpty {
                    return sections.contains { section in
                        section.values.contains {
                            if $0.riskDataId == checkboxId, case .checkbox(value: let value) = $0.value, value {
                                return true
                            }
                            return false
                        }
                    }
                } else if let optionId = dependency.optionId, !optionId.isEmpty {
                    return sections.contains { section in
                        section.values.contains {
                            if case .radio(optionId: let value) = $0.value, value == optionId {
                                return true
                            }
                            return false
                        }
                    }
                }
                return true
            }
    }

    private func getInvisibleCategories() -> [RiskCategory] {
        let visibleCategories = getVisibleCategories()
        return sections
            .map { $0.category }
            .filter {
                !visibleCategories.contains($0)
            }
    }

    private func selectFirstRadioOption(visibleCategories: [RiskCategory]) {
        for (sectionIndex, section) in sections.enumerated() {
            guard visibleCategories.contains(section.category) else { continue }

            for field in section.category.riskData {
                // Select first option in radio controls by default
                guard field.kind == .radio, let options = field.options, let optionId = options.first?.id else { continue }

                let sectionHasValues = section.values.contains {
                    if case .radio(optionId: _) = $0.value {
                        return true
                    }
                    return false
                }
                if !sectionHasValues {
                    sections[sectionIndex][field.id] = RiskDataValue(riskDataId: field.id, value: .radio(optionId: optionId))
                    selectFirstRadioOption(visibleCategories: getVisibleCategories())
                }
            }
        }
    }

    private func deselectRadioOptions(invisibleCategories: [RiskCategory]) {
        for (sectionIndex, section) in sections.enumerated() {
            guard invisibleCategories.contains(section.category) else { continue }

            for field in section.category.riskData {
                // Deselect options in radio controls in hidden sections
                guard field.kind == .radio, let options = field.options, !options.isEmpty else { continue }

                let sectionHasValues = section.values.contains {
                    if case .radio(optionId: _) = $0.value {
                        return true
                    }
                    return false
                }
                if sectionHasValues {
                    sections[sectionIndex][field.id] = nil
                    deselectRadioOptions(invisibleCategories: getInvisibleCategories())
                }
            }
        }
    }

    private func updateSections() {
        selectFirstRadioOption(visibleCategories: getVisibleCategories())
        deselectRadioOptions(invisibleCategories: getInvisibleCategories())
        visibleCategories = getVisibleCategories()
    }

    func dataIsReady() -> Bool {
        for category in visibleCategories {
            guard let section = sections.first(where: { $0.category == category }) else { continue }

            let requiredFields = category.riskData.filter { $0.requiredStatus.isRequired }
            let emptyField = requiredFields.first { field in
                section[field.id] == nil
            }
            if emptyField != nil {
                return false
            }
        }
        return true
    }

    private func findNextField(currentIndexPath: IndexPath) -> UIView? {
        indexPathsForVisibleRows?
            .filter {
                $0.section == currentIndexPath.section && $0.row > currentIndexPath.row
            }
            .sorted()
            .compactMap {
                cellForRow(at: $0)?.getAllSubviews().first { $0 is UITextField || $0 is UITextView }
            }
            .first
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        visibleCategories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection index: Int) -> Int {
        let category = visibleCategories[index]
        let sectionIndex = sections.firstIndex { $0.category == category }
        let section = sectionIndex.map { sections[$0] }
        return (section?.opened ?? true) ? visibleCategories[index].riskData.count : 0
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = visibleCategories[indexPath.section]
        let field = category.riskData[indexPath.row]
        let sectionIndex = sections.firstIndex { $0.category == category }
        let section = sectionIndex.map { sections[$0] }
        let riskDataValue = section?[field.id]

        switch field.kind {
            case .text:
                let cell = tableView.dequeueReusableCell(TextFieldCell.id, indexPath: indexPath)
                cell.inputAccessory = inputAccessory
                cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
                    ? 16
                    : 0
                cell.editingStarted = { [weak self] cell in
                    cell.isLastField = self?.findNextField(currentIndexPath: indexPath) == nil
                    self?.scrollRectToVisible(cell.frame, animated: true)
                }
                cell.editingChanged = { [weak self] cell in
                    guard let self = self, let sectionIndex = sectionIndex else { return }

                    if let value = cell.textValue, !value.isEmpty {
                        self.sections[sectionIndex][field.id] = RiskDataValue(riskDataId: field.id, value: .text(value))
                    } else {
                        self.sections[sectionIndex][field.id] = nil
                    }

                    self.dataIsReadyCallback?(self.dataIsReady())
                }
                cell.returnKeyTap = { [weak self] _ in
                    self?.findNextField(currentIndexPath: indexPath)?.becomeFirstResponder()
                }

                cell.setHint(field.title ?? "", isRequired: field.requiredStatus.isRequired)
                cell.preset = .string

                var value: String?
                if case .text(let text)? = riskDataValue?.value {
                    value = text
                }
                cell.textValue = value
                cell.maxCharacters = field.maxSymbolsLength
                cell.validCharacters = field.validSymbols?.flatMap { $0 }

                return cell
            case .radio:
                let cell = tableView.dequeueReusableCell(RadioControlCell.id, indexPath: indexPath)
                let options = field.options ?? []
                cell.titles = options.map { $0.title }
                if case .radio(let optionId)? = riskDataValue?.value {
                    cell.selectedIndex = options.firstIndex { $0.id == optionId }
                } else {
                    cell.selectedIndex = nil
                }
                cell.selectionChanged = { [weak self] selectedIndex in
                    guard let self = self, let sectionIndex = sectionIndex else { return }

                    let optionId = options[selectedIndex].id
                    self.sections[sectionIndex][field.id] =
                        RiskDataValue(riskDataId: field.id, value: .radio(optionId: optionId))

                    self.updateSections()
                    self.dataIsReadyCallback?(self.dataIsReady())
                    self.reloadData()
                }
                return cell
            case .checkbox:
                let cell = tableView.dequeueReusableCell(SwitchCell.id, indexPath: indexPath)
                cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
                    ? 16
                    : 0
                cell.title = field.title
                cell.valueChanged = { [weak self] value in
                    guard let self = self, let sectionIndex = sectionIndex else { return }

                    cell.value = !cell.value
                    self.sections[sectionIndex][field.id] =
                        RiskDataValue(riskDataId: field.id, value: .checkbox(value: cell.value))

                    self.updateSections()
                    self.dataIsReadyCallback?(self.dataIsReady())
                    self.reloadData()
                }

                var checked: Bool?
                if case .checkbox(value: let value)? = riskDataValue?.value {
                    checked = value
                }
                cell.value = checked ?? false

                return cell
            case .decimalSelect:
                let cell = tableView.dequeueReusableCell(DecimalAndSelectCell.id, indexPath: indexPath)
                cell.inputAccessory = inputAccessory
                cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
                    ? 16
                    : 0
                cell.showHint(field.title ?? "", isRequired: field.requiredStatus.isRequired)
                let options = field.options ?? []
                cell.options = options.map { $0.title }
                cell.editingStarted = { [weak self] cell in
                    cell.isLastField = self?.findNextField(currentIndexPath: indexPath) == nil
                    self?.scrollRectToVisible(cell.frame, animated: true)
                }
                cell.returnKeyTap = { [weak self] _ in
                    self?.findNextField(currentIndexPath: indexPath)?.becomeFirstResponder()
                }

                var value: String?
                var selectButtonTitle: String?
                if case .decimalSelect(let text, let optionId)? = riskDataValue?.value {
                    value = text
                    if let index = options.firstIndex(where: { $0.id == optionId }) {
                        selectButtonTitle = options[index].title
                    }
                }
                cell.textValue = value
                cell.maxCharacters = field.maxSymbolsLength
                cell.validCharacters = field.validSymbols?.flatMap { $0 }
                cell.selectValue = selectButtonTitle ?? field.titleOptions
                cell.dataChangedCallback = { [weak self] textValue, selectValue in
                    guard let `self` = self, let sectionIndex = sectionIndex else { return }

                    let optionId = options.first { $0.title == selectValue }?.id
                    if let textValue = textValue, !textValue.isEmpty, let optionId = optionId {
                        self.sections[sectionIndex][field.id] =
                            RiskDataValue(riskDataId: field.id, value: .decimalSelect(value: textValue, optionId: optionId))
                    } else {
                        self.sections[sectionIndex][field.id] = nil
                    }

                    self.dataIsReadyCallback?(self.dataIsReady())
                }

                cell.showOptionsCallback = { [weak self] in
                    let popover = ICPassengersPopoverController(titles: cell.options)
                    popover.popoverPresentationController?.sourceView = cell
                    popover.popoverPresentationController?.sourceRect = cell.bounds
                    popover.selectedTitleIndex = { index in
                        guard let cell = tableView.cellForRow(at: indexPath) as? DecimalAndSelectCell else { return }

                        cell.selectValue = options[index].title
                    }
                    self?.parentViewController?.present(popover, animated: true, completion: nil)
                }

                return cell
            case .date:
                let cell = tableView.dequeueReusableCell(TextFieldCell.id, indexPath: indexPath)
                cell.inputAccessory = inputAccessory
                cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
                    ? 16
                    : 0
                cell.editingStarted = { [weak self] cell in
                    cell.isLastField = self?.findNextField(currentIndexPath: indexPath) == nil
                    self?.scrollRectToVisible(cell.frame, animated: true)
                }
                cell.editingChanged = { [weak self] cell in
                    guard let `self` = self, let sectionIndex = sectionIndex else { return }

                    if let value = cell.textValue, !value.isEmpty {
                        self.sections[sectionIndex][field.id] = RiskDataValue(riskDataId: field.id, value: .date(value))
                    } else {
                        self.sections[sectionIndex][field.id] = nil
                    }
                    self.dataIsReadyCallback?(self.dataIsReady())
                }
                cell.returnKeyTap = { [weak self] _ in
                    self?.findNextField(currentIndexPath: indexPath)?.becomeFirstResponder()
                }

                cell.setHint(field.title ?? "", isRequired: field.requiredStatus.isRequired)
                cell.preset = .date

                var value: String?
                if case .date(let text)? = riskDataValue?.value {
                    value = text
                }
                cell.textValue = value
                cell.maxCharacters = field.maxSymbolsLength
                cell.validCharacters = field.validSymbols?.flatMap { $0 }

                return cell
            case .time:
                let cell = tableView.dequeueReusableCell(TextFieldCell.id, indexPath: indexPath)
                cell.inputAccessory = inputAccessory
                cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
                    ? 16
                    : 0
                cell.editingStarted = { [weak self] cell in
                    cell.isLastField = self?.findNextField(currentIndexPath: indexPath) == nil
                    self?.scrollRectToVisible(cell.frame, animated: true)
                }
                cell.editingChanged = { [weak self] cell in
                    guard let self = self, let sectionIndex = sectionIndex else { return }

                    if let value = cell.textValue, !value.isEmpty {
                        self.sections[sectionIndex][field.id] = RiskDataValue(riskDataId: field.id, value: .time(value))
                    } else {
                        self.sections[sectionIndex][field.id] = nil
                    }
                    self.dataIsReadyCallback?(self.dataIsReady())
                }
                cell.returnKeyTap = { [weak self] _ in
                    self?.findNextField(currentIndexPath: indexPath)?.becomeFirstResponder()
                }

                cell.setHint(field.title ?? "", isRequired: field.requiredStatus.isRequired)
                cell.preset = .time

                var value: String?
                if case .time(let text)? = riskDataValue?.value {
                    value = text
                }
                cell.textValue = value
                cell.maxCharacters = field.maxSymbolsLength
                cell.validCharacters = field.validSymbols?.flatMap { $0 }

                return cell
            case .decimal:
                let cell = tableView.dequeueReusableCell(TextFieldCell.id, indexPath: indexPath)
                cell.inputAccessory = inputAccessory
                cell.separatorInset.left = indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
                    ? 16
                    : 0
                cell.editingStarted = { [weak self] cell in
                    cell.isLastField = self?.findNextField(currentIndexPath: indexPath) == nil
                    self?.scrollRectToVisible(cell.frame, animated: true)
                }
                cell.editingChanged = { [weak self] cell in
                    guard let self = self, let sectionIndex = sectionIndex else { return }

                    if let value = cell.textValue, !value.isEmpty {
                        self.sections[sectionIndex][field.id] = RiskDataValue(riskDataId: field.id, value: .decimal(value))
                    } else {
                        self.sections[sectionIndex][field.id] = nil
                    }

                    self.dataIsReadyCallback?(self.dataIsReady())
                }
                cell.returnKeyTap = { [weak self] _ in
                    self?.findNextField(currentIndexPath: indexPath)?.becomeFirstResponder()
                }

                cell.setHint(field.title ?? "", isRequired: field.requiredStatus.isRequired)
                cell.preset = .number

                var value: String?
                if case .decimal(let text)? = riskDataValue?.value {
                    value = text
                }
                cell.textValue = value
                cell.maxCharacters = field.maxSymbolsLength
                cell.validCharacters = field.validSymbols?.flatMap { $0 }

                return cell
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let category = visibleCategories[section]
        return category.title?.isEmpty ?? true
            ? 0
            : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        let category = visibleCategories[index]
        switch category.kind {
            case .normal:
                let header = tableView.dequeueReusableHeaderFooter(RMRTableSectionHeader.id)
                header.title = category.title
                return header
            case .expandable:
                let sectionIndex = sections.firstIndex { $0.category == category }
                let section = sectionIndex.map { sections[$0] }

                let header = tableView.dequeueReusableHeaderFooter(RiskCategoryExpandableHeader.id)
                header.title = category.title
                header.state = section?.opened ?? false ? .opened : .closed
                header.tapHandler = { [weak self, weak header] in
                    guard let self = self, let sectionIndex = sectionIndex, let opened = self.sections[sectionIndex].opened else { return }

                    let currentState = !opened
                    self.sections[sectionIndex].opened = currentState
                    header?.state = currentState ? .opened : .closed

                    let indexPaths: [IndexPath] = (0 ..< category.riskData.count).map { IndexPath(row: $0, section: index) }
                    if opened {
                        tableView.deleteRows(at: indexPaths, with: .automatic)
                    } else {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                    }
                }
                return header
        }
    }
}

// swiftlint:enable file_length
