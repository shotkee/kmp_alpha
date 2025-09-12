//
//  LoyaltyOperation.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 28/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct LoyaltyOperation: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    // sourcery: transformer.name = "product_id", transformer = IdTransformer<Any>()
    var productId: String?
    // sourcery: transformer.name = "category_id", transformer = IdTransformer<Any>()
    var categoryId: String?
    // sourcery: transformer.name = "category_type"
    var categoryType: Int?
    // sourcery: transformer.name = "insurance_deeplink_type"
    var insuranceDeeplinkTypeId: Int?
    // sourcery: transformer.name = "type"
    var loyaltyType: LoyaltyOperation.LoyaltyType?
    // sourcery: transformer.name = "operation_type"
    var operationType: LoyaltyOperation.OperationType?
    var amount: Double
    var description: String
    // sourcery: transformer.name = "date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var date: Date
    // sourcery: transformer.name = "status"
    var statusDescription: String?
    // sourcery: transformer.name = "status_id"
    var status: LoyaltyOperation.OperationStatus?
    // sourcery: transformer.name = "contract_number"
    var contractNumber: String?

    // sourcery: transformer.name = "icon_type"
    var iconType: LoyaltyOperation.IconType?
    // sourcery: enumTransformer
    enum LoyaltyType: Int {
        // sourcery: defaultCase
        case spending = 1
        case addition = 2
    }
    // sourcery: enumTransformer
    enum OperationType: Int {
        // sourcery: defaultCase
        case interview = 6
        case friendInvited = 7
        case registration = 8
    }
    // sourcery: enumTransformer
    enum IconType: Int {
        // sourcery: defaultCase
        case points = 1
        case friend = 2
        case phone = 3
        case car = 4
        case fly = 5
        case brush = 6
        case sofa = 7
        case trane = 8
    }
    // sourcery: enumTransformer
    enum OperationStatus: Int {
        // sourcery: defaultCase
        case processing = 0
        case completed = 1
        case canceled = 2
    }
}
