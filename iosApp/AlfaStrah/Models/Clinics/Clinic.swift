//
//  Clinic.swift
//  AlfaStrah
//
//  Created by Станислав Старжевский on 11.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct Clinic: Equatable {	
	// sourcery: enumTransformer, enumTransformer.type = "String"
	enum ButtonAction: String {
		// sourcery: enumTransformer.value = "appointment_online"
		case appointmentOnline = "appointment_online"
		// sourcery: enumTransformer.value = "appointment_offline"
		case appointmentOffline = "appointment_offline"
	}
	
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String
    var address: String
    var coordinate: Coordinate
    // sourcery: transformer.name = "service_hours"
    var serviceHours: String
	// sourcery: transformer.name = "label_list"
	var labelList: [ClinicLabelList]?
    // sourcery: transformer.name = "metro_list"
	var metroList: [ClinicMetro]?
	// sourcery: transformer.name = "service_list"
	var serviceList: [String]
	// sourcery: transformer.name = "url", transformer = "UrlTransformer<Any>()"
	var url: URL?
	// sourcery: transformer.name = "phone_list"
	var phoneList: [Phone]?
	// sourcery: transformer.name = "button_text"
	var buttonText: String?
	// sourcery: transformer.name = "button_action"
	var buttonAction: ButtonAction?
	// sourcery: transformer.name = "filter_list"
	var filterList: [Clinic.ClinicFilter]?
	// sourcery: transformer.name = "franchise"
	var franchise: Bool?

    init(
        id: String,
        title: String,
        address: String,
        coordinate: Coordinate,
        serviceHours: String,
		labelList: [ClinicLabelList]?,
		metroList: [ClinicMetro]?,
		serviceList: [String],
		url: URL?,
		phoneList: [Phone]?,
		buttonText: String?,
		buttonAction: ButtonAction?,
		filterList: [Clinic.ClinicFilter]?,
		franchise: Bool?
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.coordinate = coordinate
        self.serviceHours = serviceHours
		self.labelList = labelList
		self.metroList = metroList
		self.serviceList = serviceList
		self.url = url
		self.phoneList = phoneList
		self.buttonText = buttonText
		self.buttonAction = buttonAction
		self.filterList = filterList
		self.franchise = franchise
    }

    init(id: String) 
	{
        self.id = id
        title = ""
        address = ""
        coordinate = Coordinate(latitude: 0, longitude: 0)
        serviceHours = ""
		labelList = []
		metroList = []
		serviceList = []
		url = nil
		phoneList = []
		buttonText = ""
		buttonAction = .appointmentOffline
		filterList = []
		franchise = false
    }
    
    static func == (lhs: Clinic, rhs: Clinic) -> Bool {
        return lhs.id == rhs.id
    }
}
