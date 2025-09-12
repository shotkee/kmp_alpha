//
//  DamageDirectionButton.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 29.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class DamageDirectionControl: UIControl {
    enum Direction {
        // swiftlint:disable:next identifier_name
        case up
        case down
        case left
        case right
        case upLeft
        case upRight
        case downLeft
        case downRight
    }

    var direction: Direction = .right {
        didSet {
            updateDirection()
        }
    }
	
	private static let icon: UIImage? = UIImage(named: "direction-arrow-up")?
        .withRenderingMode(.alwaysTemplate)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override var isHighlighted: Bool {
        didSet {
            updateStateAppearance()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateStateAppearance()
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateStateAppearance()
        }
    }

    var isCircleVisible: Bool = true {
        didSet {
            updateStateAppearance()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateDashBorder()
    }

    private func commonSetup() {
        backgroundColor = .clear
        circleView.isUserInteractionEnabled = false
        addSubview(circleView)
        circleView.addSubview(arrowImageView)
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: Self.icon)
		imageView.tintColor = .Icons.iconPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var circleView: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 21
        view.layer.masksToBounds = false
		view.layer <~ ShadowAppearance.buttonShadow
        view.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: CGSize(width: 42, height: 42)),
            cornerRadius: bounds.height / 2
        ).cgPath

        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 42).isActive = true
        view.heightAnchor.constraint(equalToConstant: 42).isActive = true

        return view
    }()

    private func updateDirection() {
        updateArrowRotation()
        updateCircleViewPosition()
        updateDashBorder()
    }

    private func updateArrowRotation() {
        var angle = CGFloat.pi / 180
        switch direction {
            case .up:
                angle *= 0
            case .upRight:
                angle *= 45
            case .right:
                angle *= 90
            case .downRight:
                angle *= 135
            case .down:
                angle *= 180
            case .downLeft:
                angle *= 225
            case .left:
                angle *= 270
            case .upLeft:
                angle *= 315
        }
        arrowImageView.transform = .init(rotationAngle: angle)
    }

    private func updateCircleViewPosition() {
        // remove old constraints
        circleView.removeFromSuperview()
        addSubview(circleView)

        switch direction {
            case .up:
                NSLayoutConstraint.activate([
                    centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
                    bottomAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 4)
                ])
            case .down:
                NSLayoutConstraint.activate([
                    centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
                    circleView.topAnchor.constraint(equalTo: topAnchor, constant: 4)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
                    circleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
                ])
            case .left:
                NSLayoutConstraint.activate([
                    centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
                    trailingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 20)
                ])
            default:
                NSLayoutConstraint.activate([
                    centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
                    centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
                ])
        }
    }

    private var dashBorder: CAShapeLayer?

    private func updateDashBorder() {
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = 1
		dashBorder.strokeColor = UIColor.Icons.iconPrimary.cgColor
        dashBorder.lineDashPattern = [2, 2] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = dashBorderPath
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }

    private var dashBorderPath: CGPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        let topRightPoint = CGPoint(x: bounds.width, y: 0)
        let bottomLeftPoint = CGPoint(x: 0, y: bounds.height)
        let bottomRightPoint = CGPoint(x: bounds.width, y: bounds.height)
        switch direction {
            case .up, .down:
                path.move(to: bottomLeftPoint)
                path.addLine(to: .zero)
                path.move(to: bottomRightPoint)
                path.addLine(to: topRightPoint)
            case .right, .left:
                path.addLine(to: topRightPoint)
                path.move(to: bottomLeftPoint)
                path.addLine(to: bottomRightPoint)
            case .upRight:
                path.addLine(to: topRightPoint)
                path.move(to: bottomRightPoint)
                path.addLine(to: topRightPoint)
            case .upLeft:
                path.addLine(to: topRightPoint)
                path.move(to: bottomLeftPoint)
                path.addLine(to: .zero)
            case .downRight:
                path.move(to: bottomLeftPoint)
                path.addLine(to: bottomRightPoint)
                path.move(to: bottomRightPoint)
                path.addLine(to: topRightPoint)
            case .downLeft:
                path.move(to: bottomLeftPoint)
                path.addLine(to: .zero)
                path.move(to: bottomLeftPoint)
                path.addLine(to: bottomRightPoint)
        }
        return path.cgPath
    }

    private func updateStateAppearance() {
        circleView.isHidden = !isCircleVisible
        guard isEnabled else {
			arrowImageView.tintColor = .Icons.iconSecondary
            return
        }

        if isSelected {
			circleView.backgroundColor = .Icons.iconAccent
			arrowImageView.tintColor = .Icons.iconContrast
            return
        }

        circleView.backgroundColor = isHighlighted
			? .Icons.iconAccent
			: .clear
        arrowImageView.tintColor = isHighlighted
			? .Icons.iconContrast
			: .clear
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		updateDashBorder()
		updateStateAppearance()
		circleView.layer <~ ShadowAppearance.buttonShadow
	}
}
