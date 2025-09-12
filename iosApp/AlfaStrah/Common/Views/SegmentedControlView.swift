//
//  SegmentedControlView.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit

final class SegmentedSelectorView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()

    private let lineSelectionView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .Stroke.strokePrimary
        return lineView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        addSubview(stackView)
        addSubview(lineSelectionView)

        [stackView, lineSelectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: stackView, in: self)
        )

        set(items: [])
    }

    private func createItemButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Style.Font.buttonSmall
        button.setTitleColor(.Text.textSecondary, for: .normal)
        button.setTitleColor(.Text.textPrimary, for: .selected)
        button.setTitleColor(.States.backgroundSecondaryDisabled, for: .highlighted)
        button.addTarget(self, action: #selector(onTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(onTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(onTouchUpOutside), for: .touchUpOutside)
        return button
    }

    @objc private func onTouchDown() {
        lineSelectionView.isHidden = true
    }

    @objc private func onTouchUpInside(_ sender: UIButton) {
        guard let itemIndex = stackView.arrangedSubviews.firstIndex(of: sender)
        else { return }

        if self.selectedIndex != itemIndex {
            selectIndex(itemIndex)
        }

        lineSelectionView.isHidden = false
    }

    @objc private func onTouchUpOutside() {
        lineSelectionView.isHidden = false
    }

    // MARK: - API

    var onSelectedIndexChanged: ((Int) -> Void)?

    func set(items: [String]) {
        let oldArrangedSubviews = stackView.arrangedSubviews
        oldArrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.enumerated().forEach {
            let itemButton = createItemButton(title: $0.element)
            stackView.addArrangedSubview(itemButton)
        }

        selectedIndex = 0
    }

    private(set) var selectedIndex: Int = 0

    func selectIndex(_ newIndex: Int) {
        guard let itemButton = stackView.arrangedSubviews[safe: newIndex] as? UIButton
        else { return }

        selectedIndex = newIndex

        stackView.arrangedSubviews.forEach {
            ($0 as? UIButton)?.isSelected = false
        }
        itemButton.isSelected = true

        moveLineSelection(under: itemButton)

        onSelectedIndexChanged?(selectedIndex)
    }

    private func moveLineSelection(under view: UIView) {
        lineSelectionView.removeFromSuperview()
        lineSelectionView.removeConstraints(lineSelectionView.constraints)
        view.addSubview(lineSelectionView)
        NSLayoutConstraint.activate([
            lineSelectionView.heightAnchor.constraint(equalToConstant: 1),
            lineSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lineSelectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
