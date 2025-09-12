//
//  RealmInsuranceGroup.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 11/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmInsuranceGroup: RealmEntity {
    @objc dynamic var objectName: String = ""
    @objc dynamic var objectType: String = ""
    let insuranceGroupCategoryList: List<RealmInsuranceGroupCategory> = .init()
}

class RealmInsuranceGroupCategory: RealmEntity {
    @objc dynamic var insuranceCategory: RealmInsuranceCategoryMain?
    @objc dynamic var sosActivity: RealmSosActivityModel?
    let insuranceList: List<RealmInsuranceShort> = .init()
}

class RealmInsuranceCategoryMain: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var categoryDescription: String = ""
    @objc dynamic var type: Int = 1
    @objc dynamic var icon: String?
	@objc dynamic var iconThemed: RealmThemedValue?
}
