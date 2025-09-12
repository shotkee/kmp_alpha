//
//  QuestionService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

protocol QuestionService: Updatable {
    func questionList(useCache: Bool, completion: @escaping (Result<[QuestionCategory], AlfastrahError>) -> Void)
    func askQuestion(_ question: String, phone: String, destination: String?, questionId: Int?,
        completion: @escaping (Result<String, AlfastrahError>) -> Void)
    func voteAnswer(questionId: Int, isUsefull: VoteAnswer.Answer, completion: @escaping (Result<Void, AlfastrahError>) -> Void)
}
