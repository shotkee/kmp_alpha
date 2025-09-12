//
//  MainQAView.swift
//  AlfaStrah
//
//  Created by mac on 24.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class MainQAView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var viewForHorizontalScroll: UIView!
    @IBOutlet private var allQuestionsButton: UIButton!

    struct Input {
        let title: String?
        let horizontalScrollView: HorizontalScrollView?
    }
    
    struct Output {
        let tapAllQuestions: (() -> Void)?
    }
    
    var output: Output!

    var input: Input! {
        didSet {
            setup()
        }
    }
    
    private func setup() {
        backgroundColor = .clear
        viewForHorizontalScroll.backgroundColor = .clear
        
        allQuestionsButton.titleLabel?.font = Style.Font.subhead
        allQuestionsButton.setTitleColor(.Text.textAccent, for: .normal)
        allQuestionsButton.setTitle(NSLocalizedString("common_all_button", comment: ""), for: .normal)
        titleLabel.text = input.title
        titleLabel <~ Style.Label.primaryTitle1
        guard let horizontalScrollView = input.horizontalScrollView else {
            return
        }

        viewForHorizontalScroll.addSubview(horizontalScrollView)
        viewForHorizontalScroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: horizontalScrollView, in: viewForHorizontalScroll)
        )
    }
    
    @IBAction private func allQuestionsTap(_ sender: UIButton) {
        output.tapAllQuestions?()
    }
}
