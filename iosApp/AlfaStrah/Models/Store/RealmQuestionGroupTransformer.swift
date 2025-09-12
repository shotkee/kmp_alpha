//
//  RealmQuestionGroupTransformer.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmQuestionGroupTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = QuestionGroup
    typealias RealmEntityType = RealmQuestionGroup

    private let questionTransformer: RealmQuestionTransformer<Question> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        try (entity.questionList).forEach {
            realmEntity.questionList.append(try questionTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            questionList: try object.questionList.map(questionTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
