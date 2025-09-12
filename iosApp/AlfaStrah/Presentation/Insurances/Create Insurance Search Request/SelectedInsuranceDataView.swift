//
//  SelectedInsuranceProductView.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 30.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class SelectedInsuranceDataView: UIView, EmptyHintToTopHintBottomValueAnimator {
    @IBOutlet private var emptyStateHintLabel: UILabel! // visible only in .empty state
	@IBOutlet private var emptyStateHintSubLabel: UILabel! {
		didSet {
			emptyStateHintSubLabel <~ Style.Label.accentHeadline2
		}
	}
    @IBOutlet private var valueLabel: UILabel! // visible only in .typeSelected state
    @IBOutlet private var hintLabel: UILabel! // visible only in .typeSelected state
	@IBOutlet private var iconImageView: UIImageView!
	
    var emptyHint: UIView {
        emptyStateHintLabel
    }
    var emptySubHint: UIView? {
        emptyStateHintSubLabel
    }
    var topHint: UIView {
        hintLabel
    }
    var bottomValue: UIView {
        valueLabel
    }

    enum State: Equatable {
        case typeSelected(value: String?)
        case empty

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
                case (.empty, .empty):
                    return true
                case (.typeSelected(let lhsVal), .typeSelected(let rhsVal)):
                    return lhsVal == rhsVal
                default:
                    return false
            }
        }
    }
	
	var isRequired: Bool = false {
		didSet {
			model.isRequired = isRequired
			updateLabels(for: model)
		}
	}

    private struct Model {
        var state: State
        var isRequired: Bool
        var emptyHint: String?
        var selectedHint: String?
        var value: String?

        static let empty = Model(state: .empty, isRequired: false, emptyHint: nil, selectedHint: nil, value: nil)
    }

    private var model = Model.empty

    var value: String? {
        model.value
    }

    func resetContents() {
        model = .empty
        updateLabels(for: model)
    }

    func set(emptyHint: String?, selectedHint: String?, isRequired: Bool) {
        model.emptyHint = emptyHint
        model.selectedHint = selectedHint
        model.isRequired = isRequired

        updateLabels(for: model)
    }

    func set(state newState: State) {
        let old = model.state
        model.state = newState
        switch newState {
            case .typeSelected(let value):
                model.value = value
            default:
                model.value = nil
        }
        update(for: newState, oldState: old)
        updateLabels(for: model)
    }

    private func update(for newState: State, oldState: State) {
        switch (newState, oldState) {
            case (.empty, .typeSelected):
                animateToEmptyHint()
            case (.typeSelected, .empty):
                animateToTopHintBottomValue()
            default:
                break
        }
    }

    private func changeValue(to newValue: String?) {
        self.updateValueLabel(text: newValue)
    }

    private func updateValueLabel(text: String?) {
        valueLabel.text = text
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        var newModel = model
        newModel.emptyHint = emptyStateHintLabel.text
        newModel.selectedHint = hintLabel.text
        model = newModel
		
		iconImageView?.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
		
		valueLabel <~ Style.Label.primaryHeadline1
		emptyStateHintLabel <~ Style.Label.primaryHeadline2
    }

    private func updateLabels(for model: Model) {
        if model.isRequired {
            let resultSelectedHint = model.selectedHint ?? "" + "  *"
            let resultEmptyHint = model.emptyHint ?? "" + "  *"
			
			let attributedSelectedHintStyle: [NSAttributedString.Key: Any] = [
				.foregroundColor: UIColor.Text.textSecondary,
				.font: Style.Font.caption1
			]
            let attributedSelectedHint = NSMutableAttributedString(string: resultSelectedHint) <~ attributedSelectedHintStyle
			
			let attributedEmptyHintStyle: [NSAttributedString.Key: Any] = [
				.foregroundColor: UIColor.Text.textPrimary,
				.font: Style.Font.caption1
			]
			
			let attributedEmptyHint = NSMutableAttributedString(string: resultEmptyHint) <~ attributedEmptyHintStyle

            let starRangeInSelectedHint = (resultSelectedHint as NSString).range(of: "*")
            let starRangeInEmptyHint = (resultEmptyHint as NSString).range(of: "*")

			attributedSelectedHint.addAttribute(.foregroundColor, value: UIColor.Text.textAccent, range: starRangeInSelectedHint)
            attributedEmptyHint.addAttribute(.foregroundColor, value: UIColor.Text.textAccent, range: starRangeInEmptyHint)

            hintLabel.attributedText = attributedSelectedHint
            emptyStateHintLabel.attributedText = attributedEmptyHint

            valueLabel.text = model.value
        } else {
            hintLabel.text = model.selectedHint
            emptyStateHintLabel.text = model.emptyHint
            valueLabel.text = model.value
        }
    }
		
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		let image = iconImageView?.image
		
		iconImageView?.image = image?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
