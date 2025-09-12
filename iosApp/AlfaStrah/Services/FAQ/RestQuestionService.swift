//
//  RestQuestionService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class RestQuestionService: QuestionService {
    private let rest: FullRestClient
    private let store: Store

    init(rest: FullRestClient, store: Store) {
        self.rest = rest
        self.store = store
    }

    func cachedQuestionCategorys() -> [QuestionCategory] {
        var questionCategory: [QuestionCategory] = []
        try? store.read { transaction in
            questionCategory = try transaction.select()
        }
        return questionCategory
    }

    func askQuestion(
        _ question: String,
        phone: String,
        destination: String?,
        questionId: Int?,
        completion: @escaping (Result<String, AlfastrahError>
    ) -> Void) {
        rest.create(
            path: "/questions/ask",
            id: nil,
            object: AskQuestionRequest(text: question, phone: phone, destination: destination, questionId: questionId),
            headers: [:],
            requestTransformer: AskQuestionRequestTransformer(),
            responseTransformer: ResponseTransformer(
                key: "message",
                transformer: CastTransformer<Any, String>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func questionList(useCache: Bool, completion: @escaping (Result<[QuestionCategory], AlfastrahError>) -> Void) {
        let cache = cachedQuestionCategorys()
        if useCache, !cache.isEmpty {
            completion(.success(cache))
        } else {
            rest.read(
                path: "questions",
                id: nil,
                parameters: [:],
                headers: [:],
                responseTransformer: ResponseTransformer(
                    key: "question_category_list",
                    transformer: ArrayTransformer(transformer: QuestionCategoryTransformer())
                ),
                completion: mapCompletion {  [weak self] result in
                    guard let self = self else { return }

                    if case .success(let questionCategorys) = result {
                        try? self.store.write { transaction in
                            try transaction.delete(type: QuestionCategory.self)
                            try transaction.insert(questionCategorys)
                        }
                    }
                    completion(result)
                }
            )
        }
    }
    
    func voteAnswer(questionId: Int, isUsefull: VoteAnswer.Answer, completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        let request = VoteAnswer(questionId: questionId, answer: isUsefull)
        rest.create(
            path: "api/questions/vote",
            id: nil,
            object: request,
            headers: [:],
            requestTransformer: VoteAnswerTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        questionList(useCache: false, completion: mapUpdateCompletion(completion))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        // No need to delete questions, because they do not depend on particular user
    }
}
