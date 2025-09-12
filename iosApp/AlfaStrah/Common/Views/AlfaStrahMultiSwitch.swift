//
//  AlfaStrahMultiSwitch.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 28.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

/**
 Сырой вариант замены DGRunkeeperSwitch который сейчас используется.

 Оповещает о том какой вариант выбрал пользователем передвижением бегунка.

 Требует доработки для возможности использования в более общих сценариях, например добавление
 состояний, произвольное количество опций и/или возможности анимации различных состояний

 Переопределяет intrinsicContentSize для высоты по умолчанию равной 36.0
 */
class AlfaStrahMultiSwitch: UIControl {
    var options: [String] = [] {
        didSet {
            update()
        }
    }

    private(set) var selectedOption: Int?
    var onSelectOption: ((_ newOption: Int, _ oldOption: Int?) -> Void)?

    private let defaultHeight: CGFloat = 36.0

    private let backgroundView = UIView()
    private let slider = DraggableControl()
    private let optionsContainer = UIView()
    private let optionsStack = UIStackView()

    private let maskedContainer = UIView()
    private let maskedStack = UIStackView()
    private let stackMask = UIView()

    private lazy var sliderAnimator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self)
    private lazy var maskAnimator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self)

    struct Button {
        let normal: UIButton
        let masked: UIButton
    }
    private var buttons: [Button] = []

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateSliderAndMaskFrame()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: defaultHeight, height: defaultHeight)
    }

    func selectOption(at index: Int) {
        guard options.indices.contains(index) else { return }

        let newCenter = buttons[index].normal.center
        selectedOption = index
        updateAnimators(for: newCenter)
    }

    // MARK: - Private methods

    private func setup() {
        layer.cornerRadius = floor(bounds.height / 2.0)
        layer.masksToBounds = true

        // background
        backgroundView.backgroundColor = UIColor(white: 0.698, alpha: 1.0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        // options container
        optionsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(optionsContainer)

        // options stack
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(optionsStack)
        optionsStack.alignment = .center
        optionsStack.axis = .horizontal
        optionsStack.distribution = .fillEqually

        // masked container
        maskedContainer.translatesAutoresizingMaskIntoConstraints = false
        maskedContainer.isUserInteractionEnabled = false
        maskedContainer.backgroundColor = UIColor.white
        addSubview(maskedContainer)

        // masked stack
        maskedStack.translatesAutoresizingMaskIntoConstraints = false
        maskedContainer.addSubview(maskedStack)
        maskedStack.alignment = .center
        maskedStack.axis = .horizontal
        maskedStack.distribution = .fillEqually

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: backgroundView.topAnchor),
            bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            rightAnchor.constraint(equalTo: backgroundView.rightAnchor),

            topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor),
            leftAnchor.constraint(equalTo: optionsContainer.leftAnchor),
            rightAnchor.constraint(equalTo: optionsContainer.rightAnchor),

            optionsContainer.topAnchor.constraint(equalTo: optionsStack.topAnchor),
            optionsContainer.bottomAnchor.constraint(equalTo: optionsStack.bottomAnchor),
            optionsContainer.leftAnchor.constraint(equalTo: optionsStack.leftAnchor),
            optionsContainer.rightAnchor.constraint(equalTo: optionsStack.rightAnchor),

            topAnchor.constraint(equalTo: maskedContainer.topAnchor),
            bottomAnchor.constraint(equalTo: maskedContainer.bottomAnchor),
            leftAnchor.constraint(equalTo: maskedContainer.leftAnchor),
            rightAnchor.constraint(equalTo: maskedContainer.rightAnchor),

            maskedContainer.topAnchor.constraint(equalTo: maskedStack.topAnchor),
            maskedContainer.bottomAnchor.constraint(equalTo: maskedStack.bottomAnchor),
            maskedContainer.leftAnchor.constraint(equalTo: maskedStack.leftAnchor),
            maskedContainer.rightAnchor.constraint(equalTo: maskedStack.rightAnchor),
        ])

        // slider
        addSubview(slider)
        slider.frame = CGRect(x: 0, y: 0, width: defaultHeight - 1, height: bounds.height - 2)
        slider.center = center
        slider.backgroundColor = UIColor.clear
        slider.layer.cornerRadius = floor(slider.bounds.height / 2.0)
        slider.layer.masksToBounds = true
        slider.onDragStart = { [unowned self] _, _ in
            self.onDragStart()
        }
        slider.onDragMove = { [unowned self] deltaX, deltaY in
            self.onDragMove(for: CGPoint(x: deltaX, y: deltaY))
        }
        slider.onDragEnd = { [unowned self] _, _ in
            self.onDragEnd()
        }

        stackMask.frame = slider.frame
        stackMask.layer.cornerRadius = slider.layer.cornerRadius
        stackMask.layer.masksToBounds = true
        stackMask.backgroundColor = .white

        maskedContainer.mask = stackMask

        selectedOption = !options.isEmpty ? 0 : nil
    }

    private func onDragStart() {
        sliderAnimator.removeAllBehaviors()
        maskAnimator.removeAllBehaviors()
    }

    private func onDragMove(for offset: CGPoint) {
        var center = slider.center
        let target = center.x + offset.x
        let maxX = (bounds.width - 1) - slider.bounds.width / 2
        let minX = 1 + slider.bounds.width / 2
        let result = min(max(target, minX), maxX)
        center.x = result
        slider.center = center
        stackMask.center = center
    }

    private func onDragEnd() {
        let closest = closestOptionForSlider()

        let newCenter = CGPoint(x: closest.button.normal.center.x, y: slider.center.y)
        updateAnimators(for: newCenter)

        onSelectOption?(closest.index, selectedOption)
        selectedOption = closest.index
    }

    private func closestOptionForSlider() -> (button: Button, index: Int) {
        let sliderCenter = slider.center

        var closestIndex = 0
        var closest: Button = buttons[closestIndex]

        buttons.enumerated().forEach { index, button in
            let buttonCenter = button.normal.center
            let closesDist = abs(closest.normal.center.x - slider.center.x)
            let dist = abs(buttonCenter.x - sliderCenter.x)
            if dist < closesDist {
                closest = button
                closestIndex = index
            }
        }

        return (closest, closestIndex)
    }

    private func update() {
        // Запрещаем взаимодействие для пустого набора опций.
        isUserInteractionEnabled = !options.isEmpty

        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        maskedStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        buttons = options.map { option in
            let normalButton = UIButton(type: .custom)
            normalButton.setTitle(option, for: .normal)
            normalButton.setTitleColor(UIColor.white, for: .normal)
            normalButton.addTarget(self, action: #selector(optionSelected(sender:)), for: .touchUpInside)
            normalButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            normalButton.titleLabel?.adjustsFontSizeToFitWidth = true

            let maskedButton = UIButton(type: .custom)
            maskedButton.setTitle(option, for: .normal)
            maskedButton.setTitleColor(UIColor.red, for: .normal)
            maskedButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            maskedButton.titleLabel?.adjustsFontSizeToFitWidth = true

            return Button(normal: normalButton, masked: maskedButton)
        }

        buttons.forEach { button in
            optionsStack.addArrangedSubview(button.normal)
            maskedStack.addArrangedSubview(button.masked)
        }

        layoutIfNeeded()

        selectedOption = !options.isEmpty ? 0 : nil

        updateSliderAndMaskFrame()
    }

    private func updateSliderAndMaskFrame() {
        guard let selectedOption = selectedOption else { return }

        let button = buttons[selectedOption]
        slider.bounds.size.width = button.normal.bounds.size.width
        slider.center = button.normal.center
        stackMask.frame = slider.frame
    }

    private func updateAnimators(for newCenter: CGPoint) {
        sliderAnimator.removeAllBehaviors()
        maskAnimator.removeAllBehaviors()

        let disableSliderRotation = UIDynamicItemBehavior(items: [ slider ])
        disableSliderRotation.allowsRotation = false
        let disableMaskRotation = UIDynamicItemBehavior(items: [ stackMask ])
        disableMaskRotation.allowsRotation = false

        let sliderSnapBehavior = UISnapBehavior(item: slider, snapTo: newCenter)
        sliderAnimator.addBehavior(sliderSnapBehavior)
        sliderAnimator.addBehavior(disableSliderRotation)

        let maskSnapBehavior = UISnapBehavior(item: stackMask, snapTo: newCenter)
        maskAnimator.addBehavior(maskSnapBehavior)
        maskAnimator.addBehavior(disableMaskRotation)
    }

    @objc private func optionSelected(sender: UIButton) {
        guard let selectedIndex = buttons.firstIndex(where: { $0.normal == sender }) else { return }

        let newCenter = CGPoint(x: sender.center.x, y: slider.center.y)
        updateAnimators(for: newCenter)
        onSelectOption?(selectedIndex, selectedOption)
        selectedOption = selectedIndex
    }
}

class DraggableControl: UIControl {
    var onDragStart: ((_ touch: UITouch?, _ event: UIEvent?) -> Void)?
    var onDragMove: ((_ deltaX: CGFloat, _ deltaY: CGFloat) -> Void)?
    var onDragEnd: ((_ touch: UITouch?, _ event: UIEvent?) -> Void)?

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard touch.view == self else { return false }

        onDragStart?(touch, event)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard touch.view == self else { return false }

        updateDrag(forTouchPosition: touch.location(in: self), previousPosition: touch.previousLocation(in: self))
        setNeedsDisplay()
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        onDragEnd?(touch, event)
    }

    private func updateDrag(forTouchPosition position: CGPoint, previousPosition previous: CGPoint) {
        let deltaX = position.x - previous.x
        let deltaY = position.y - previous.y
        onDragMove?(deltaX, deltaY)
    }
}
