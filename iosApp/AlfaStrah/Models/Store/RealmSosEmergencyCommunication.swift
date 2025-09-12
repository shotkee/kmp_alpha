//
//  RealmSosEmergencyCommunication.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import RealmSwift

class RealmSosEmergencyCommunication: RealmEntity {
    @objc dynamic var title: String = ""
    @objc dynamic var information: RealmSosEmergencyConnectionScreenInformation?
    @objc dynamic var communicationBlock: RealmSosEmergencyCommunicationBlock?
	@objc dynamic var confidant: RealmConfidant?
	@objc dynamic var confidantBanner: RealmConfidantBanner?
}

class RealmSosEmergencyCommunicationBlock: RealmEntity {
    @objc dynamic var title: String = ""
    let itemList: List<RealmSosEmergencyCommunicationItem> = .init()
}

class RealmSosEmergencyConnectionScreenInformation: RealmEntity {
    @objc dynamic var title: String = ""
    @objc dynamic var icon: String = ""
	@objc dynamic var iconThemed: RealmThemedValue?
}

class RealmSosEmergencyCommunicationItem: RealmEntity {
    @objc dynamic var icon: String = ""
	@objc dynamic var iconThemed: RealmThemedValue?
    @objc dynamic var rightIcon: String = ""
	@objc dynamic var rightIconThemed: RealmThemedValue?
    @objc dynamic var title: String = ""
    @objc dynamic var titlePopup: String = ""
    @objc dynamic var phone: RealmSosUXPhone?
}

class RealmThemedValue: RealmEntity {
	@objc dynamic var light: String = ""
	@objc dynamic var dark: String = ""
}

class RealmSosUXPhone: RealmEntity {
    @objc dynamic var phoneNumber: String = ""
}
