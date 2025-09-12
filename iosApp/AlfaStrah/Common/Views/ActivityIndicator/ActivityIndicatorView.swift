//
// ActivityIndicatorView
// AlfaStrah
//
// Created by Roman Churkin on 22/07/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit
import Lottie

/// Индикатор загрузки, аналогичный UIActivityIndicatorView
class ActivityIndicatorView: UIView {
    private let animationTiming: TimeInterval = 0.25
    private let animationViewSize: CGSize = CGSize(width: 54, height: 54)
    private let titleLabel = UILabel()
    
	private var spinnerCustomColor: UIColor = .Icons.iconAccent

    @objc var animating = false {
        didSet {
            if animating {
                startSpinnerAnimation()
            } else {
                stopSpinnerAnimation()
            }
        }
    }

    /// Функция, которая будет выполнена после запуска анимации
    var onShow: (() -> Void)?

    /// Функция, которая будет выполнена после остановки анимации
    var onHide: (() -> Void)?

    private var animationView: AnimationView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        animationView = prepareAnimationView()
        
        setupTitleLabel()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        animationView = prepareAnimationView()
        
        setupTitleLabel()
    }

    override var intrinsicContentSize: CGSize {
        animationViewSize
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        animationView = prepareAnimationView()
        animationView.alpha = 1.0
    }

    private func prepareAnimationView() -> AnimationView {
        backgroundColor = .clear
        let animation = Animation.named("red-spinning-loader")
        let animationView = AnimationView(animation: animation)
        animationView.backgroundColor = .clear
        animationView.loopMode = .loop
        animationView.alpha = 0.0
        animationView.contentMode = .scaleAspectFill
        animationView.layer.masksToBounds = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let resistantPriority = UILayoutPriority(rawValue: 990)
        animationView.setContentCompressionResistancePriority(resistantPriority, for: .horizontal)
        animationView.setContentCompressionResistancePriority(resistantPriority, for: .vertical)
        animationView.setContentHuggingPriority(resistantPriority, for: .horizontal)
        animationView.setContentHuggingPriority(resistantPriority, for: .vertical)
        
        animationView.backgroundBehavior = .pauseAndRestore

        return animationView
    }
    
    private func setupTitleLabel() {
        titleLabel.numberOfLines = 0

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        titleLabel.isHidden = true
        
        titleLabel <~ Style.Label.secondaryText
    }
    
    func set(title: String) {
        titleLabel.text = title
    }

    private func startSpinnerAnimation() {
        updateSpinnerColor()
        animationView.play()
        
        titleLabel.isHidden = false
        
        UIView.animate(
            withDuration: animationTiming,
            animations: {
                self.animationView.alpha = 1.0
            },
            completion: { _ in
                self.onShow?()
            }
        )
    }

    private func stopSpinnerAnimation() {
        titleLabel.isHidden = true
        
        UIView.animate(
            withDuration: animationTiming,
            animations: {
                self.animationView.alpha = 0.0
            },
            completion: { _ in
                self.animationView.stop()
                self.onHide?()
            }
        )
    }
    
    func clearBackgroundColor() {
        let keypath = AnimationKeypath(keypath: "Слой-фигура 4.Прямоугольник 1.Заливка 1.Color")
        let colorProvider = ColorValueProvider(UIColor.clear.lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
    }
    
    func setSpinnerColor(_ color: UIColor) {
        spinnerCustomColor = color
    }
    
	private func updateSpinnerColor() {        
        let colorProvider = ColorValueProvider(spinnerCustomColor.lottieColorValue)
        
        let primarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 3.Эллипс 1.Обводка 1.Color")
        animationView.setValueProvider(colorProvider, keypath: primarySpinnerColorKeypath)
        
        let secondarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 2.Эллипс 1.Обводка 1.Color")
        animationView.setValueProvider(colorProvider, keypath: secondarySpinnerColorKeypath)
    }
    
    func setInitialState() {
        animationView.play(fromFrame: 82, toFrame: 82, completion: nil)
        animationView.alpha = 1
        titleLabel.isHidden = false
    }
	
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateSpinnerColor()
    }
}
