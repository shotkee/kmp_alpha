//
//  EuroPtotocolMultipleChoiceListViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 14.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class EuroProtocolMultipleChoiceListViewController: EuroProtocolBaseScrollViewController {
    struct Input {
        let canDeselectSingleItem: Bool
        let title: String
        let items: [SelectableItem]
        let maxSelectionNumber: Int
        let buttonTitle: String
    }

    struct Output {
        let save: (_ indices: [Int]) -> Void
        let userInputForSelectedItemHandler: (( _ itemIndex: Int, _ completion: @escaping (String) -> Void) -> Void)?
    }

    var input: Input!
    var output: Output!

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.axis = .vertical
        return stack
    }()

    private lazy var saveButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init()
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        button.setTitle(input.buttonTitle, for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()

    var inputViews: [SmallValueCardView] = []

    private lazy var selectedInfoViews: [CommonSelectedInfoView] = {
        input.items.map { createCommonSelectedInfoView(with: $0) }
    }()

    private var items: [SelectableItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func setupUI() {
        super.setupUI()

		view.backgroundColor = .Background.backgroundContent
        title = input.title

        items = input.items
        selectedInfoViews.forEach { contentStackView.addArrangedSubview($0) }

        addBottomButtonsContent(saveButton)

        scrollContentView.addSubview(contentStackView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 9),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updateUI() {
        saveButton.isEnabled = items.contains { $0.isSelected }
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
            guard let index = items.firstIndex(where: { $0.id == item.id })
            else { return }
                        
            let item = self.items[index]
                        
            let selectedCount = self.items.filter { $0.isSelected }.count
            let shouldApplyLimit = input.maxSelectionNumber > 0
            let hasReachedLimit = shouldApplyLimit && !item.isSelected && selectedCount >= input.maxSelectionNumber
            guard !hasReachedLimit else {
                if input.maxSelectionNumber == 1 {
                    if item.activateUserInput {
                        handleUserInputForSelectedItem(at: index, for: value)
                    } else {
                        resetItemsSelection()
                        self.items[index].isSelected = true
                        value.update(isSelected: true)
                    }
                }
                self.updateUI()
                return
            }

            if item.activateUserInput {
                handleUserInputForSelectedItem(at: index, for: value)
            } else {
                let newSelection = input.canDeselectSingleItem ? !item.isSelected : true
                value.update(isSelected: newSelection)
                self.items[index].isSelected = newSelection
            }
            self.updateUI()
        }
        return value
    }
    
    private func resetItemsSelection() {
        for idx in 0..<self.items.count {
            items[idx].isSelected = false
        }
        self.selectedInfoViews.forEach { $0.update(isSelected: false) }
    }
    
    private func handleUserInputForSelectedItem(at index: Int, for view: CommonSelectedInfoView) {
        output.userInputForSelectedItemHandler?(
            index,
            { [weak self] userInputText in
                guard let self = self
                else { return }
                
                if !userInputText.isEmpty {
                    if self.input.maxSelectionNumber == 1 {
                        self.resetItemsSelection()
                    }
                    view.update(title: userInputText)
                    view.update(isSelected: true)
                    self.items[index].isSelected = true
                }
                self.updateUI()
            }
        )
    }

    @objc private func saveButtonAction() {
        let indices = items.enumerated()
            .filter { $0.element.isSelected }
            .map { $0.offset }
        output.save(indices)
    }
}
