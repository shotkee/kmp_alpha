//
//  MultipleValuePickerBottomViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 08.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

/// Show list of values (SelectableItem). User can pick multiple values.
class MultipleValuePickerBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let dataSource: [SelectableItem]
        let isMultiSelectAllowed: Bool
        let footerStyle: FooterStyle
        let tintColor: UIColor
        
        init(
            title: String,
            dataSource: [SelectableItem],
            isMultiSelectAllowed: Bool,
            footerStyle: FooterStyle = .keyboard,
            tintColor: UIColor = Style.Color.Palette.lightGray
        ) {
            self.title = title
            self.dataSource = dataSource
            self.isMultiSelectAllowed = isMultiSelectAllowed
            self.footerStyle = footerStyle
            self.tintColor = tintColor
        }
    }

    struct Output {
        let close: () -> Void
        let done: ([SelectableItem]) -> Void
    }

    var input: Input!
    var output: Output!

    private lazy var selectedInfoViews: [CommonSelectedInfoView] = {
        input.dataSource.map { createCommonSelectedInfoView(with: $0) }
    }()

    private var items: [SelectableItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        items = input.dataSource
        updateUI()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            self.output.done(items.filter { $0.isSelected })
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(views: selectedInfoViews)
        set(style: input.footerStyle)
    }

    private func updateUI() {
        set(doneButtonEnabled: !self.items.allSatisfy { !$0.isSelected })
    }

    private func createCommonSelectedInfoView(with item: SelectableItem) -> CommonSelectedInfoView {
        let value: CommonSelectedInfoView = .init()
        value.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true

        value.set(
            item: item,
            margins: Style.Margins.defaultInsets,
            showSeparator: true
        )

        value.tapHandler = { [unowned self] in
            if self.input.isMultiSelectAllowed {
                self.tapHandlerWithMultiSelect(value, with: item)
            } else {
                self.tapHandlerWithoutMultiSelect(value: value, with: item)
            }
        }

        return value
    }
    
    private func tapHandlerWithMultiSelect(_ value: CommonSelectedInfoView, with item: SelectableItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        let isSelected = !items[index].isSelected
        items[index].isSelected = isSelected
        value.update(isSelected: isSelected)
        updateUI()
    }
    
    private func tapHandlerWithoutMultiSelect( value: CommonSelectedInfoView, with item: SelectableItem) {
        selectedInfoViews.forEach { $0.update(isSelected: false) }
        
        for index in items.indices {
            items[index].isSelected = false
        }
        
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isSelected = true
        value.update(isSelected: true)
        updateUI()
    }
}
