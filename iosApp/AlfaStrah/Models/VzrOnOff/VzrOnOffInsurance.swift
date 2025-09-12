//
//  TravelOnOffInsurance.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/9/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct VzrOnOffInsurance: Entity {
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    var insuranceId: String
    // sourcery: transformer.name = "active_trip_list"
    var activeTripList: [VzrOnOffTrip]
}
