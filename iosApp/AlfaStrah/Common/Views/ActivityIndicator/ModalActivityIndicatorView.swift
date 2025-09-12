//
//  ModalActivityIndicatorView
//  AlfaStrah
//
//  Created by Roman Churkin on 22/07/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

import UIKit

/// Модальный индикатор загрузки
class ModalActivityIndicatorView: UIView {
    private let animationDuration: TimeInterval = 0.3

    /// Ссылка на View controller, который *держит* activity indicator
    @objc weak var viewContainer: UIViewController?

    /// Строка, которая отображается в модальном индикаторе
    @objc var infoString: String? {
        get {
            infoLabel?.text
        }
        set {
            configureLabel(newValue)
        }
    }

    /**
        Свойство отвечает за старт и остановку анимации
        - `true` запускает анимацию
        - `false` останавливает анимацию
    */
    @objc var animating = false {
        didSet {
            if animating {
                animateShow()
            } else {
                animateHide()
            }
        }
    }

    /// Функция, которая будет выполнена после остановки анимации
    @objc var onHide: (() -> Void)?

    /// Функция, которая будет выполнена после запуска анимации
    @objc var onShow: (() -> Void)? {
        get {
            activityIndicatorView.onShow
        }
        set {
            activityIndicatorView.onShow = newValue
        }
    }

    var cancellable: CancellableNetworkTaskContainer? {
        didSet {
            updateCloseButton()
        }
    }
    
    @IBOutlet private var indicatorContainer: UIView!
    @IBOutlet private var activityIndicatorContainer: UIView!
    @IBOutlet private var infoContainer: UIView!
    @IBOutlet private var activityIndicatorView: ActivityIndicatorView!
    @IBOutlet private var closeButton: UIButton!
    private var infoLabel: UILabel?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		backgroundColor = .Background.backgroundContent
        isOpaque = false

        makeContainerInvisible()
        updateCloseButton()
    }
	
    func updateCloseButton() {
        closeButton.isHidden = cancellable == nil
    }

    private func configureLabel(_ text: String?) {
        let binding = (label: infoLabel, text: text)
        switch binding {
            case (nil, nil):
                break
            case (let label?, nil):
                label.removeFromSuperview()
            case (nil, .some):
                let label = createLabel()
                infoLabel = label
                label.text = binding.text
            case (let label?, .some):
                label.text = binding.text
        }
        layoutIfNeeded()
    }

    private func createLabel() -> UILabel {
        let infoLabel = UILabel()
        infoLabel <~ Style.Label.primaryText
        infoLabel.numberOfLines = 3
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .center
        infoContainer.addSubview(infoLabel)
        
        let infoLabelKey = "infoLabel"
        infoContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-16-[\(infoLabelKey)]-16-|",
                metrics: nil,
                views: [ infoLabelKey: infoLabel ]
            )
        )
        
        infoContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-19-[\(infoLabelKey)]-29-|",
                metrics: nil,
                views: [ infoLabelKey: infoLabel ]
            )
        )
        
        return infoLabel
    }

    private func makeContainerVisible() {
        alpha = 1.0
        indicatorContainer.transform = .identity
    }

    private func makeContainerInvisible() {
        alpha = 0.0
        indicatorContainer.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }

    private func animateShow() {
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.makeContainerVisible()
            },
            completion: { _ in
                self.activityIndicatorView.animating = true
            }
        )
    }

    private func animateHide() {
        activityIndicatorView.onHide = { [weak self] in
            guard let self = self else { return }

            UIView.animate(
                withDuration: self.animationDuration,
                animations: {
                    self.makeContainerInvisible()
                },
                completion: { _ in
                    self.onHide?()
                }
            )
        }
        activityIndicatorView.animating = false
    }

    @IBAction private func closeTap(_ sender: UIButton) {
        cancellable?.cancel()
        animating = false
    }
    
    public func clearIndicatorBackground() {
        activityIndicatorView.clearBackgroundColor()
    }
}
