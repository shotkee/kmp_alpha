//
//  SingleValuePickerBottomViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 06.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

/// Show list of values (SelectableItem). User can pick single value.
class SingleValuePickerBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
		let prompt: String
        let dataSource: [SelectableItem]
    }

    struct Output {
        let close: () -> Void
        let done: (SelectableItem) -> Void
    }

    var input: Input!
    var output: Output!
	
	private var items: [SelectableItem] = []
	
    private lazy var selectableInfoViews: [CommonSelectedInfoView] = {
		input.dataSource.enumerated().map { index, item in
			return createCommonSelectedInfoView(
				with: item,
				showSeparator: index != input.dataSource.count - 1
			)
		}
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundModal
		
		items = input.dataSource
		updateUI()
		
        closeTapHandler = output.close
		
		primaryTapHandler = { [weak self] in
			
			guard let self,
				  let item = items.first(where: { $0.isSelected })
			else { return }
			
			output.done(item)
		}
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
		set(infoText: input.prompt)
        set(views: selectableInfoViews)
		set(
			style: .actions(
				primaryButtonTitle: NSLocalizedString("common_save", comment: ""),
				secondaryButtonTitle: nil
			)
		)
    }
	
	private func updateUI() {
		set(
			doneButtonEnabled: items.contains { $0.isSelected }
		)
	}
	
    private func createCommonSelectedInfoView(
		with item: SelectableItem,
		showSeparator: Bool
	) -> CommonSelectedInfoView {
        let value: CommonSelectedInfoView = .init()
        value.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
		
        value.set(
            item: item,
            margins: Style.Margins.defaultInsets,
			appearance: .init(textStyle: Style.Label.primaryText),
            showSeparator: showSeparator
        )
		
		value.tapHandler = { [weak self, weak value] in
			
			guard let value
			else { return }
			
			self?.tapHandler(
				value: value,
				with: item
			)
		}
		
        return value
    }
	
	private func tapHandler(
		value: CommonSelectedInfoView,
		with item: SelectableItem
	) {
		for index in items.indices {
			items[index].isSelected = false
		}
		selectableInfoViews.forEach { $0.update(isSelected: false) }
		
		guard let index = items.firstIndex(where: { $0.id == item.id })
		else { return }
		
		items[index].isSelected = true
		value.update(isSelected: true)
		
		updateUI()
	}
}
