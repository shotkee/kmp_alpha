//
//  InsuranceMain.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceMain: Entity {
    // sourcery: transformer.name = "insurance_group_list"
    var insuranceGroupList: [InsuranceGroup]
    // sourcery: transformer.name = "sos_list"
    var sosList: [SosModel]
    
    // sourcery: transformer.name = "emergency_connection_screen"
    var sosEmergencyCommunication: SosEmergencyCommunication?
}
