//
//  SosEmergencyCommunication.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct SosEmergencyCommunication: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "information"
    let information: SosEmergencyConnectionScreenInformation?
    // sourcery: transformer.name = "emergency_connection_block"
    let communicationBlock: SosEmergencyCommunicationBlock?
	// sourcery: transformer.name = "confidant"
	let confidant: Confidant?
	// sourcery: transformer.name = "confidant_banner"
	let confidantBanner: ConfidantBanner?
}

// sourcery: transformer
struct SosEmergencyConnectionScreenInformation: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "icon"
    let icon: String
	// sourcery: transformer.name = "icon_themed"
	let iconThemed: ThemedValue?
}

// sourcery: transformer
struct SosEmergencyCommunicationBlock: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "emergency_connection_list"
    let itemList: [SosEmergencyCommunicationItem]
}

// sourcery: transformer
struct SosEmergencyCommunicationItem: Entity {
    // sourcery: transformer.name = "icon"
    let icon: String
	// sourcery: transformer.name = "icon_themed"
	let iconThemed: ThemedValue?
    // sourcery: transformer.name = "icon_call"
    let rightIcon: String
	// sourcery: transformer.name = "icon_call_themed"
	let rightIconThemed: ThemedValue?
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "title_popup"
    let titlePopup: String
    // sourcery: transformer.name = "phone"
    let phone: SosUXPhone
}

// sourcery: transformer
struct SosUXPhone: Entity {
    // sourcery: transformer.name = "call_phone"
    let phoneNumber: String
}
