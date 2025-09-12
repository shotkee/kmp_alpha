//
//  QuestionViewController.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class QuestionViewController: ViewController, UITextViewDelegate {
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerForVoteView: UIStackView!
    @IBOutlet private var bottomVoteButtonConstraint: NSLayoutConstraint!

    private lazy var voteView: CardView = {		
        let yesButton = RoundEdgeButton()
        yesButton <~ Style.RoundedButton.whiteGrayBackground
        yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        yesButton.setTitle(NSLocalizedString("question_yes_response", comment: ""), for: .normal)

        let noButton = RoundEdgeButton()
        noButton <~ Style.RoundedButton.whiteGrayBackground
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        noButton.setTitle(NSLocalizedString("question_no_response", comment: ""), for: .normal)

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("question_vote_title", comment: "")

        let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.alignment = .center
            stack.spacing = 9
            return stack
        }()

        let whitebackground = UIView()
		whitebackground.backgroundColor = .Background.backgroundSecondary
        whitebackground.addSubview(titleLabel)
        whitebackground.addSubview(stackView)

        stackView.addArrangedSubview(yesButton)
        stackView.addArrangedSubview(noButton)

        whitebackground.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: whitebackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: whitebackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: whitebackground.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: whitebackground.bottomAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        ])

        return CardView(contentView: whitebackground)
    }()

    private lazy var positiveResponseView: CardView = {
        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("question_vote_yes_answer_title", comment: "")

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.primarySubhead
        descriptionLabel.text = NSLocalizedString("question_vote_yes_answer_description", comment: "")

        let whitebackground = UIView()
		whitebackground.backgroundColor = .Background.backgroundSecondary
        whitebackground.addSubview(titleLabel)
        whitebackground.addSubview(descriptionLabel)

        whitebackground.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: whitebackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: whitebackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: whitebackground.topAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: whitebackground.bottomAnchor, constant: -16),
            descriptionLabel.leadingAnchor.constraint(equalTo: whitebackground.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: whitebackground.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])

        return CardView(contentView: whitebackground)
    }()
    
    private lazy var negativeResponseView: CardView = {
        let chatButton = RoundEdgeButton()
        chatButton <~ Style.RoundedButton.redBackground
        chatButton.setTitle(NSLocalizedString("common_write_to_chat", comment: ""), for: .normal)
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("question_vote_no_answer_title", comment: "")

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.primarySubhead
        descriptionLabel.text = NSLocalizedString("question_vote_no_answer_description", comment: "")

        let whitebackground = UIView()
		whitebackground.backgroundColor = .Background.backgroundSecondary
        whitebackground.addSubview(titleLabel)
        whitebackground.addSubview(descriptionLabel)
        whitebackground.addSubview(chatButton)

        whitebackground.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: whitebackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: whitebackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: whitebackground.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chatButton.heightAnchor.constraint(equalToConstant: 36),
            chatButton.bottomAnchor.constraint(equalTo: whitebackground.bottomAnchor, constant: -16),
            chatButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            chatButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            chatButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
        ])

        return CardView(contentView: whitebackground)
    }()

    var input: Input!
    var output: Output!

    struct Input {
		let isDemoMode: Bool
        let question: Question
    }
    struct Output {
        let openChat: () -> Void
        let voteAnswer: (Int, VoteAnswer.Answer) -> Void
    }

    struct Notify {
        let updateVoteResult: (VoteAnswer.Answer?) -> Void
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateVoteResult: { [weak self] result in
            guard let self
            else { return }

            if let result {
                self.voteView.isHidden = true
                switch result {
                    case .positive:
                        self.positiveResponseView.isHidden = false
                    case .negative:
                        self.negativeResponseView.isHidden = false
                }
            }
            self.containerForVoteView.isUserInteractionEnabled = true
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Background.backgroundContent
		
        scrollView.contentInset.bottom = bottomVoteButtonConstraint.constant + containerForVoteView.frame.height + 10
		if !input.isDemoMode
		{
			addRightButton(title: NSLocalizedString("chat_title", comment: ""), action: output.openChat)
		}
        configurateStackView()
        configureContainerForVoteView()
    }

    private func configurateStackView() {
        let questionLabel = UILabel()
        questionLabel <~ Style.Label.primaryTitle1
        questionLabel.numberOfLines = 0
        questionLabel.text = input.question.questionText
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(questionLabel)
        
        let answerLabel = UITextView()
		answerLabel.backgroundColor = .clear
		
		let htmlText = input.question.answerHtml
		let mutableAttributedString = TextHelper.html(from: htmlText).mutable
		let range = NSRange(location: 0, length: mutableAttributedString.length)
		mutableAttributedString.addAttributes(Style.TextAttributes.oldPrimaryText, range: range)
		answerLabel.attributedText = mutableAttributedString
		answerLabel.linkTextAttributes = Style.TextAttributes.link
		
        answerLabel.delegate = self
        answerLabel.isEditable = false
        answerLabel.isScrollEnabled = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(answerLabel)
    }

    private func configureContainerForVoteView() {
        containerForVoteView.addArrangedSubview(voteView)
        containerForVoteView.addArrangedSubview(positiveResponseView)
        containerForVoteView.addArrangedSubview(negativeResponseView)
        voteView.isHidden = false
        negativeResponseView.isHidden = true
        positiveResponseView.isHidden = true
    }
    
    @objc func yesButtonTapped() {
        guard let questionId = Int(input.question.id)
        else { return }
        containerForVoteView.isUserInteractionEnabled = false
        output.voteAnswer(questionId, VoteAnswer.Answer.positive)
    }
    
    @objc func noButtonTapped() {
        guard let questionId = Int(input.question.id)
        else { return }
        containerForVoteView.isUserInteractionEnabled = false
        output.voteAnswer(questionId, VoteAnswer.Answer.negative)
    }
    
    @objc func chatButtonTapped() {
        output.openChat()
    }

    // MARK: - UITextViewDelegate

    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
		if url.scheme == "mailto" {
			UIApplication.shared.open(url)
		} else {
			SafariViewController.open(url, from: self)
		}
        return false
    }
}
