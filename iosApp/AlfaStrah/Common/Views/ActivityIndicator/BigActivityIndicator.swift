//
// Created by Roman Churkin on 09/09/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit

class BigActivityIndicator: UIView {
    private static let kAnimationTiming: TimeInterval = 0.25
    private static let kRotateAnimationKey = "rmr_rotate_animation"

    @IBInspectable var subColor: UIColor? = Style.Color.Palette.whiteGray {
        didSet {
            strokeLayer.strokeColor = subColor?.cgColor
            backgroundLayer.fillColor = subColor?.cgColor
        }
    }

    @IBInspectable var strokeLineWidth: CGFloat = 2.0 {
        didSet {
            progressLayer.lineWidth = strokeLineWidth
            strokeLayer.lineWidth = strokeLineWidth
            self.layoutIfNeeded()
        }
    }

    @objc var animating = false {
        didSet {
            if animating { startSpinnerAnimation() } else { stopSpinnerAnimation() }
        }
    }

    /// Функция, которая будет выполнена после запуска анимации
    var indicatorShow: (() -> Void)?

    /// Функция, которая будет выполнена после остановки анимации
    var indicatorHide: (() -> Void)?

    private var progressLayer = CAShapeLayer()
    private var strokeLayer = CAShapeLayer()
    private var backgroundLayer = CAShapeLayer()

    private var strokeLineWidthHalf: CGFloat {
        strokeLineWidth / 2.0
    }
    private var strokeLineWidthDouble: CGFloat {
        strokeLineWidth * 2.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureSubLayers()
    }

    override func tintColorDidChange() {
        progressLayer.strokeColor = tintColor.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let strokeLayersRect = bounds.insetBy(dx: strokeLineWidthHalf, dy: strokeLineWidthHalf)

        progressLayer.path = UIBezierPath(ovalIn: strokeLayersRect).cgPath
        progressLayer.position = center
        progressLayer.frame = bounds

        strokeLayer.path = UIBezierPath(ovalIn: strokeLayersRect).cgPath
        strokeLayer.position = center
        strokeLayer.frame = bounds

        let backgroundLayerRect = bounds.insetBy(dx: strokeLineWidthDouble, dy: strokeLineWidthDouble)
        backgroundLayer.path = UIBezierPath(ovalIn: backgroundLayerRect).cgPath
        backgroundLayer.position = center
        backgroundLayer.frame = bounds
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        configureSubLayers()
        progressLayer.opacity = 1.0
    }

    // MARK: - Приватные методы

    private func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        degrees * CGFloat.pi / 180.0
    }

    private func configureSubLayers() {
        let strokeLayersRect = bounds.insetBy(dx: strokeLineWidthHalf, dy: strokeLineWidthHalf)
        progressLayer.frame = bounds
        progressLayer.path = UIBezierPath(ovalIn: strokeLayersRect).cgPath
        progressLayer.position = center
        progressLayer.strokeColor = tintColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = strokeLineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.25
        progressLayer.lineCap = .round
        progressLayer.opacity = 0.0
        progressLayer.setAffineTransform(CGAffineTransform(rotationAngle: degreesToRadians(270.0)))
        layer.insertSublayer(progressLayer, at: 0)

        strokeLayer.frame = bounds
        strokeLayer.path = UIBezierPath(ovalIn: strokeLayersRect).cgPath
        strokeLayer.position = center
        strokeLayer.strokeColor = subColor?.cgColor
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.lineWidth = strokeLineWidth
        strokeLayer.strokeStart = 0.0
        strokeLayer.strokeEnd = 1.0
        layer.insertSublayer(strokeLayer, below: progressLayer)

        let backgroundLayerRect = bounds.insetBy(dx: strokeLineWidthDouble, dy: strokeLineWidthDouble)
        backgroundLayer.frame = bounds
        backgroundLayer.path = UIBezierPath(ovalIn: backgroundLayerRect).cgPath
        backgroundLayer.position = center
        backgroundLayer.fillColor = subColor?.cgColor
        layer.insertSublayer(backgroundLayer, above: progressLayer)
    }

    private func startSpinnerAnimation() {
        UIView.animate(
            withDuration: BigActivityIndicator.kAnimationTiming,
            animations: {
                self.progressLayer.opacity = 1.0
            },
            completion: { _ in
                let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                rotateAnimation.fromValue = self.degreesToRadians(270.0)
                rotateAnimation.toValue = self.degreesToRadians(270.0) + 2.0 * .pi
                rotateAnimation.duration = 1.2
                rotateAnimation.repeatCount = Float.infinity
                self.progressLayer.add(rotateAnimation, forKey: BigActivityIndicator.kRotateAnimationKey)
                self.indicatorShow?()
            }
        )
    }

    private func stopSpinnerAnimation() {
        UIView.animate(
            withDuration: BigActivityIndicator.kAnimationTiming,
            animations: {
                self.progressLayer.opacity = 0.0
            },
            completion: { _ in
                self.progressLayer.removeAnimation(forKey: BigActivityIndicator.kRotateAnimationKey)
                self.indicatorHide?()
            }
        )
    }
}
