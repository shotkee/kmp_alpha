//
//  FlatOnOffConfirmActivationRequest.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 19.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FlatOnOffConfirmActivationRequest {
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    let insuranceId: String
    // sourcery: transformer.name = "protection_id"
    // sourcery: transformer = IdTransformer<Any>()
    let protectionId: String
}
