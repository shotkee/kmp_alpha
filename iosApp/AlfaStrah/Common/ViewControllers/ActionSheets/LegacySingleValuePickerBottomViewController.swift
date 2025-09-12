//
//  LegacySingleValuePickerBottomViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 06.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

/// Show list of values (SelectableItem). User can pick single value.
class LegacySingleValuePickerBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let dataSource: [SelectableItem]
    }

    struct Output {
        let close: () -> Void
        let done: (SelectableItem) -> Void
    }

    var input: Input!
    var output: Output!

    private var selectedItem: SelectableItem!

    private lazy var selectableInfoViews: [CommonSelectedInfoView] = {
        input.dataSource.map { createCommonSelectedInfoView(with: $0) }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedItem = input.dataSource.first(where: { $0.isSelected })
        closeTapHandler = output.close
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(views: selectableInfoViews)
        set(style: .empty)
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
            guard let item = self.input.dataSource.first(where: { $0.id == item.id }) else { return }

            self.output.done(item)
        }

        return value
    }
}
