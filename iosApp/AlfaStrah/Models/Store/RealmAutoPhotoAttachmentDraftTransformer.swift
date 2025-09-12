//
//  RealmAutoPhotoAttachmentDraftTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAutoPhotoAttachmentDraftTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AutoPhotoAttachmentDraft
    typealias RealmEntityType = RealmAutoPhotoAttachmentDraft

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.filename = entity.filename
        realmEntity.fileType = entity.fileType.rawValue
        realmEntity.photoStepId = entity.photoStepId
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }
        guard let fileType = AttachmentPhotoType(rawValue: object.fileType) else { throw RealmError.typeMismatch }

        let entity = EntityType(filename: object.filename, fileType: fileType, photoStepId: object.photoStepId)
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
