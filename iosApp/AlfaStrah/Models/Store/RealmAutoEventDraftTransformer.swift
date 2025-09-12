//
//  AutoEventDraft
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAutoEventDraftTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AutoEventDraft
    typealias RealmEntityType = RealmAutoEventDraft

    private let attachmentTransformer: RealmAutoPhotoAttachmentDraftTransformer<AutoPhotoAttachmentDraft> = .init()
    private let coordinateTransformer: RealmCoordinateTransformer<Coordinate> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.claimDate = entity.claimDate
        realmEntity.coordinate = try entity.coordinate.map(coordinateTransformer.transform(entity:))
        realmEntity.fullDescription = entity.fullDescription
        realmEntity.insuranceId = entity.insuranceId
        realmEntity.lastModify = entity.lastModify
		realmEntity.caseType = entity.caseType?.rawValue ?? -1
        try (entity.files).forEach {
                realmEntity.files.append(try attachmentTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            insuranceId: object.insuranceId,
            claimDate: object.claimDate,
            fullDescription: object.fullDescription,
            files: try object.files.map(attachmentTransformer.transform(object:)),
            coordinate: try object.coordinate.map(coordinateTransformer.transform(object:)),
            lastModify: object.lastModify,
			caseType: .init(rawValue: object.caseType)
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
