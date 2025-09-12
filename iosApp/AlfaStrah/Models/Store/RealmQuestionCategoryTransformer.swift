//
//  RealmQuestionCategoryTransformer.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmQuestionCategoryTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = QuestionCategory
    typealias RealmEntityType = RealmQuestionCategory

    private let groupTransformer: RealmQuestionGroupTransformer<QuestionGroup> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        try (entity.questionGroupList).forEach {
            realmEntity.questionGroupList.append(try groupTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            title: object.title,
            questionGroupList: try object.questionGroupList.map(groupTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
