//
//  DGRunkeeperSwitch.swift
//  DGRunkeeperSwitchExample
//
//  Created by Danil Gontovnik on 9/3/15.
//  Copyright © 2015 Danil Gontovnik. All rights reserved.
//

import UIKit

// MARK: - DGRunkeeperSwitchRoundedLayer

class DGRunkeeperSwitchRoundedLayer: CALayer {
    override var frame: CGRect {
        didSet { cornerRadius = bounds.height / 2.0 }
    }
}

// MARK: - DGRunkeeperSwitch

class DGRunkeeperSwitch: UIControl, UIGestureRecognizerDelegate {
    // MARK: - Public vars

	var onTryToSwitchTab: (() -> Bool)?
	
    var leftTitle: String {
        get {
            leftTitleLabel.text ?? ""
        }
        set {
            leftTitleLabel.text = newValue
            selectedLeftTitleLabel.text = newValue
        }
    }

    var rightTitle: String {
        get {
            rightTitleLabel.text ?? ""
        }
        set {
            rightTitleLabel.text = newValue
            selectedRightTitleLabel.text = newValue
        }
    }

    private(set) var selectedIndex: Int = 0

    var selectedBackgroundInset: CGFloat = 2.0 {
        didSet {
            setNeedsLayout()
        }
    }

    var selectedBackgroundColor: UIColor! {
        get {
            selectedBackgroundView.backgroundColor
        }
        set {
            selectedBackgroundView.backgroundColor = newValue
        }
    }

    var titleColor: UIColor! {
        get {
            leftTitleLabel.textColor
        }
        set {
            leftTitleLabel.textColor = newValue
            rightTitleLabel.textColor = newValue
        }
    }

    var selectedTitleColor: UIColor! {
        get {
            selectedLeftTitleLabel.textColor
        }
        set {
            selectedLeftTitleLabel.textColor = newValue
            selectedRightTitleLabel.textColor = newValue
        }
    }

    var titleFont: UIFont! {
        get {
            leftTitleLabel.font
        }
        set {
            leftTitleLabel.font = newValue
            rightTitleLabel.font = newValue
            selectedLeftTitleLabel.font = newValue
            selectedRightTitleLabel.font = newValue
        }
    }

    var animationDuration: TimeInterval = 0.3
    var animationSpringDamping: CGFloat = 0.75
    var animationInitialSpringVelocity: CGFloat = 0.0

    // MARK: -
    // MARK: Private vars

    private var titleLabelsContentView = UIView()
    private var leftTitleLabel = UILabel()
    private var rightTitleLabel = UILabel()

    private var selectedTitleLabelsContentView = UIView()
    private var selectedLeftTitleLabel = UILabel()
    private var selectedRightTitleLabel = UILabel()

    private(set) var selectedBackgroundView = UIView()

    private var titleMaskView: UIView = UIView()

    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!

    private var initialSelectedBackgroundViewFrame: CGRect?

    // MARK: -
    // MARK: Constructors

    init(leftTitle: String!, rightTitle: String!) {
        super.init(frame: CGRect.zero)

        self.leftTitle = leftTitle
        self.rightTitle = rightTitle

        finishInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        finishInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        finishInit()
    }

    private func finishInit() {
        // Setup views
        leftTitleLabel.lineBreakMode = .byTruncatingTail
        rightTitleLabel.lineBreakMode = .byTruncatingTail

        titleLabelsContentView.addSubview(leftTitleLabel)
        titleLabelsContentView.addSubview(rightTitleLabel)
        addSubview(titleLabelsContentView)

        object_setClass(selectedBackgroundView.layer, DGRunkeeperSwitchRoundedLayer.self)
        addSubview(selectedBackgroundView)

        selectedTitleLabelsContentView.addSubview(selectedLeftTitleLabel)
        selectedTitleLabelsContentView.addSubview(selectedRightTitleLabel)
        addSubview(selectedTitleLabelsContentView)

        leftTitleLabel.textAlignment = .center
        rightTitleLabel.textAlignment = .center
        selectedLeftTitleLabel.textAlignment = .center
        selectedRightTitleLabel.textAlignment = .center

        object_setClass(titleMaskView.layer, DGRunkeeperSwitchRoundedLayer.self)
        titleMaskView.backgroundColor = .black
        selectedTitleLabelsContentView.layer.mask = titleMaskView.layer

        // Setup default colors
        backgroundColor = .black
        selectedBackgroundColor = .white
        titleColor = .white
        selectedTitleColor = .black

        // Gestures
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }

    // MARK: -

    override class var layerClass: AnyClass {
        DGRunkeeperSwitchRoundedLayer.self
    }

    @objc func tapped(_ gesture: UITapGestureRecognizer!) {
		if onTryToSwitchTab?() ?? true {
			let location = gesture.location(in: self)
			if location.x < bounds.width / 2.0 {
				setSelectedIndex(0, animated: true)
			} else {
				setSelectedIndex(1, animated: true)
			}
		}
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer!) {
        if gesture.state == .began {
            initialSelectedBackgroundViewFrame = selectedBackgroundView.frame
        } else if gesture.state == .changed {
            var frame = initialSelectedBackgroundViewFrame ?? .zero
            frame.origin.x += gesture.translation(in: self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - selectedBackgroundInset - frame.width), selectedBackgroundInset)
            selectedBackgroundView.frame = frame
            titleMaskView.frame = selectedBackgroundView.frame
        } else if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
			if onTryToSwitchTab?() ?? true {
				let velocityX = gesture.velocity(in: self).x
				if velocityX > 500.0 {
					setSelectedIndex(1, animated: true)
				} else if velocityX < -500.0 {
					setSelectedIndex(0, animated: true)
				} else if selectedBackgroundView.center.x >= bounds.width / 2.0 {
					setSelectedIndex(1, animated: true)
				} else if selectedBackgroundView.center.x < bounds.size.width / 2.0 {
					setSelectedIndex(0, animated: true)
				}
			} else {
				layoutSubviews()
			}
        }
    }

    @objc func setSelectedIndex(_ selectedIndex: Int, animated: Bool) {
        self.selectedIndex = selectedIndex
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                usingSpringWithDamping: animationSpringDamping,
                initialSpringVelocity: animationInitialSpringVelocity,
                options: [ .beginFromCurrentState, .curveEaseOut ],
                animations: {
                    self.layoutSubviews()
                },
                completion: { [weak self] finished -> Void in
                    if finished {
                        self?.sendActions(for: .valueChanged)
                    }
                }
            )
        } else {
            layoutSubviews()
            sendActions(for: .valueChanged)
        }
    }
	
	func updateSelectedIndex(index: Int)
	{
		setSelectedIndex(index, animated: true)
	}

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let selectedBackgroundWidth = bounds.width / 2.0 - selectedBackgroundInset * 2.0
        selectedBackgroundView.frame = CGRect(
            x: selectedBackgroundInset + CGFloat(selectedIndex) * (selectedBackgroundWidth + selectedBackgroundInset * 2.0),
            y: selectedBackgroundInset, width: selectedBackgroundWidth, height: bounds.height - selectedBackgroundInset * 2.0
        )
        titleMaskView.frame = selectedBackgroundView.frame
        titleLabelsContentView.frame = bounds
        selectedTitleLabelsContentView.frame = bounds

        let titleLabelMaxWidth = selectedBackgroundWidth
        let titleLabelMaxHeight = bounds.height - selectedBackgroundInset * 2.0

        var leftTitleLabelSize = leftTitleLabel.sizeThatFits(CGSize(width: titleLabelMaxWidth, height: titleLabelMaxHeight))
        leftTitleLabelSize.width = min(leftTitleLabelSize.width, titleLabelMaxWidth)

        let leftTitleLabelOrigin = CGPoint(
            x: floor((bounds.width / 2.0 - leftTitleLabelSize.width) / 2.0),
            y: floor((bounds.height - leftTitleLabelSize.height) / 2.0)
        )
        let leftTitleLabelFrame = CGRect(origin: leftTitleLabelOrigin, size: leftTitleLabelSize)
        leftTitleLabel.frame = leftTitleLabelFrame
        selectedLeftTitleLabel.frame = leftTitleLabelFrame

        var rightTitleLabelSize = rightTitleLabel.sizeThatFits(CGSize(width: titleLabelMaxWidth, height: titleLabelMaxHeight))
        rightTitleLabelSize.width = min(rightTitleLabelSize.width, titleLabelMaxWidth)

        let rightTitleLabelOrigin = CGPoint(
            x: floor(bounds.size.width / 2.0 + (bounds.width / 2.0 - rightTitleLabelSize.width) / 2.0),
            y: floor((bounds.height - rightTitleLabelSize.height) / 2.0)
        )
        let rightTitleLabelFrame = CGRect(origin: rightTitleLabelOrigin, size: rightTitleLabelSize)
        rightTitleLabel.frame = rightTitleLabelFrame
        selectedRightTitleLabel.frame = rightTitleLabelFrame
    }

    // MARK: - UIGestureRecognizer Delegate

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            return selectedBackgroundView.frame.contains(gestureRecognizer.location(in: self))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
