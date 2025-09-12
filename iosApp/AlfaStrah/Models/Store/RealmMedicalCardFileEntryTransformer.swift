//
//  RealmMedicalCardFileEntryTransformer.swift
//  AlfaStrah
//
//  Created by vit on 29.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import RealmSwift

class RealmMedicalCardFileEntryTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = MedicalCardFileEntry
    typealias RealmEntityType = RealmMedicalCardFileEntry
    
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType
        else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.status = entity.status.rawValue
        realmEntity.localStorageFilename = entity.localStorageFilename
        realmEntity.originalFilename = entity.originalFilename
        realmEntity.creationDate = entity.creationDate
        realmEntity.sizeInBytes = entity.sizeInBytes
        realmEntity.fileExtension = entity.fileExtension
        realmEntity.fileId.value = entity.fileId
		realmEntity.errorType = entity.errorType?.rawValue
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType,
              let status = MedicalCardFileEntry.Status(rawValue: object.status)
        else { throw RealmError.typeMismatch }
        
		var objectErrorType: MedicalCardFileEntry.ErrorType?
		
		if let errorType = object.errorType {
			objectErrorType = MedicalCardFileEntry.ErrorType(rawValue: errorType)
		}
		
        let entity = EntityType(
            id: object.id,
            status: status,
            localStorageFilename: object.localStorageFilename,
            originalFilename: object.originalFilename,
            creationDate: object.creationDate,
            sizeInBytes: object.sizeInBytes,
            fileExtension: object.fileExtension,
            fileId: object.fileId.value,
			errorType: objectErrorType
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
