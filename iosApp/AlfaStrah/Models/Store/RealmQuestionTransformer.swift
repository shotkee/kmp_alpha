//
//  RealmQuestionTransformer.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmQuestionTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Question
    typealias RealmEntityType = RealmQuestion

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.answerHtml = entity.answerHtml
        realmEntity.isFrequent = entity.isFrequent
        realmEntity.questionText = entity.questionText
        realmEntity.lastModified = entity.lastModified
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            isFrequent: object.isFrequent,
            questionText: object.questionText,
            answerHtml: object.answerHtml,
            lastModified: object.lastModified
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
