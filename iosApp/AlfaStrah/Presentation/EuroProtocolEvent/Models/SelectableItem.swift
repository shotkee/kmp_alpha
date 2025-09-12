//
//  SelectableItem.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 09.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

protocol SelectableItem {
    var id: String { get }
    var title: String { get }
    var isSelected: Bool { get set }
    var activateUserInput: Bool { get set }
}

struct CommonSelectable: SelectableItem {
	let id: String
	let title: String
	var isSelected: Bool = false
	var activateUserInput: Bool
}

struct DriverLicenseCategorySelectable: SelectableItem {
    var id: String = UUID().uuidString
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
}

struct VehicleTypeSelectable: SelectableItem {
    let id: String = UUID().uuidString
    let title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
}

struct VehiclePartSelectable: SelectableItem {
    let id: String = UUID().uuidString
    let title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
}

struct AccidentTypeSelectable: SelectableItem {
    var id: String = UUID().uuidString
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
}

struct ClinicSpecialitySelectable: SelectableItem {
    let speciality: ClinicSpeciality
    init(clinicSpeciality: ClinicSpeciality, isSelected: Bool = false) {
        speciality = clinicSpeciality
        self.isSelected = isSelected
        self.activateUserInput = speciality.userInputRequired
    }
    var id: String { String(speciality.id) }
    var title: String { return speciality.title }
    var isSelected: Bool = false
    
    var activateUserInput: Bool
}

struct PersonSelectable: SelectableItem, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
    
    static func == (lhs: PersonSelectable, rhs: PersonSelectable) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}

struct CurrencySelectable: SelectableItem, Equatable {
    var id: String
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
    
    static func == (lhs: CurrencySelectable, rhs: CurrencySelectable) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}

struct MedicalServiceSelectable: SelectableItem, Equatable {
    var id: String
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
    
    static func == (lhs: MedicalServiceSelectable, rhs: MedicalServiceSelectable) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}

struct QuestionnaireDateSelectable: SelectableItem, Equatable {
    var id: String
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
    
    static func == (lhs: QuestionnaireDateSelectable, rhs: QuestionnaireDateSelectable) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}

struct RecoveryTypeSelectable: SelectableItem, Equatable {
    var id: String
    var title: String
    var isSelected: Bool = false
    var activateUserInput: Bool = false
    
    static func == (lhs: RecoveryTypeSelectable, rhs: RecoveryTypeSelectable) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
