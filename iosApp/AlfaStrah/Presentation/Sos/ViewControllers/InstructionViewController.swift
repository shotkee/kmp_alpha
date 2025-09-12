//
//  InstructionViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/29/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InstructionViewController: ViewController {
    private enum Constants {
        static let headerMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
    }

    struct Input {
        let instruction: Instruction
    }

    @IBOutlet private var fullDescriptionContainerView: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!

    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    private func setupUI() {
        title = NSLocalizedString("instructions_title", comment: "")
    }

    private func updateUI() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        if input.instruction.fullDescription.isEmpty {
            fullDescriptionContainerView.isHidden = true
        } else {
            fullDescriptionContainerView.isHidden = false
            let fullDescriptionLabel = UILabel()
            fullDescriptionLabel <~ Style.Label.primaryHeadline1
            fullDescriptionLabel.numberOfLines = 0
            fullDescriptionLabel.text = input.instruction.fullDescription
            fullDescriptionContainerView.addSubview(fullDescriptionLabel)
            let constraints = NSLayoutConstraint.fill(
                view: fullDescriptionLabel,
                in: fullDescriptionContainerView,
                margins: Constants.headerMargins
            )
            NSLayoutConstraint.activate(constraints)
        }
        for step in input.instruction.steps {
            let stepView: InstructionStepView = .fromNib()
            stepView.configure(step: step)
            stackView.addArrangedSubview(stepView)
        }
        scrollView.scrollRectToVisible(.zero, animated: false)
    }
}
