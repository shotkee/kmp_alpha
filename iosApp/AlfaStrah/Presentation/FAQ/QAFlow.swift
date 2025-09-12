//
//  QAFlow.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class QAFlow: BaseFlow,
              QuestionServiceDependency,
              AccountServiceDependency {
    var accountService: AccountService!
    var questionService: QuestionService!

    private let storyboard = UIStoryboard(name: "FAQ", bundle: nil)
    private var questionCategories: [QuestionCategory] = []

    func startModaly() {
        let viewController: QAViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.output = .init(
            openChat: { [weak viewController] in
                guard let viewController = viewController
                else { return }

                self.openChatFullscreen(from: viewController)
            },
            selectGroup: showQuestionGroup,
            selectQuestion: { question in
                self.showQuestion(question)
            }
        )
        viewController.input = .init(
			isDemo: self.accountService.isDemo,
            questionCategories: getQuestionCategories
        )

        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        self.createAndShowNavigationController(viewController: viewController, mode: .modal)
    }
    
    private func getQuestionCategories(completion: @escaping ([QuestionCategory]) -> Void) {
        if !questionCategories.isEmpty {
            completion(questionCategories)
            return
        }
        questionService.questionList(useCache: true) { [weak self] result in
            guard let self = self
            else { return }

            switch result {
                case .success(let categories):
                    self.questionCategories = categories
                    completion(categories)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                }
        }
    }
    
    private func showErrorBanner() {
        showStateInfoBanner(
            title: NSLocalizedString("question_vote_error_title", comment: ""),
            description: NSLocalizedString("question_try_again", comment: ""),
            hasCloseButton: true,
            iconImage: UIImage(named: "ico-error-banner"),
            titleFont: Style.Font.text,
            appearance: .standard
        )
    }
    
    func showQuestion(_ question: Question, from: ViewController? = nil) {
        let viewController: QuestionViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
			isDemoMode: accountService.isDemo,
            question: question
        )
        viewController.output = .init(
            openChat: { [weak viewController] in
                guard let viewController = viewController
                else { return }
				
				self.accountService.isDemo
					? DemoBottomSheet.presentInfoDemoSheet(from: viewController)
					: self.openChatFullscreen(from: viewController)
            },
            voteAnswer: { [weak viewController] questionId, isUsefull in
                guard let viewController = viewController
                else { return }
                
                self.questionService.voteAnswer(questionId: questionId, isUsefull: isUsefull) { result in
                    switch result {
                        case .success:
                            viewController.notify.updateVoteResult(isUsefull)
                        case .failure:
                            self.showErrorBanner()
                            viewController.notify.updateVoteResult(nil)
                    }
                }
            }
        )
        if let from {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true)
            }
            self.createAndShowNavigationController(viewController: viewController, mode: .modal)
        } else {
            self.createAndShowNavigationController(viewController: viewController, mode: .push)
        }
    }

    private func showQuestionGroup(_ group: QuestionGroup) {
        let viewController: QuestionListViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.output = .init(
            selectQuestion: { question in
                self.showQuestion(question)
            },
            openChat: { [weak viewController] in
                guard let viewController = viewController
                else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else
				{
					self.openChatFullscreen(from: viewController)
				}
            }
        )
        viewController.input = .init(questions: group)
        self.createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func openChatFullscreen(from: ViewController) {
        let chatFlow = ChatFlow()
        container?.resolve(chatFlow)
        chatFlow.show(from: from, mode: .fullscreen)
    }
}
