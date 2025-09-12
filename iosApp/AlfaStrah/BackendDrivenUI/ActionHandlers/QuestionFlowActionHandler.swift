//
//  QuestionFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class QuestionFlowActionHandler: ActionHandler<QuestionFlowActionDTO>,
									 AlertPresenterDependency,
									 QuestionServiceDependency {
		var alertPresenter: AlertPresenter!
		var questionService: QuestionService!
		
		required init(
			block: QuestionFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let questionId = block.questionId
				else {
					syncCompletion()
					return
				}
				
				self.openQuestion(by: questionId, from: from)
					
				syncCompletion()
			}
		}
		
		private func openQuestion(by questionId: Int, from viewController: ViewController) {
			self.questionService.questionList(useCache: true) { [weak viewController] result in
				guard let viewController
				else { return }
				
				switch result {
					case .success(let categories):
						let questionList = categories.flatMap {
							$0.questionGroupList.flatMap {
								$0.questionList
							}
						}
						
						if let question = questionList.first(where: { $0.id == String(questionId) }) {
							let flow = QAFlow(rootController: viewController)
							ApplicationFlow.shared.container.resolve(flow)
							flow.showQuestion(question, from: viewController)
						} else {
							ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
	}
}
