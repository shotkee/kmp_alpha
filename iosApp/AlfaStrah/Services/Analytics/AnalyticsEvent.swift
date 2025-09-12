//
//  AnalyticsEvent.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 14.07.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

enum AnalyticsEvent {
    enum App {
        static let openChat: String = "open_chat"
		static let openSOS: String = "open_SOS"
        static let openShowcase: String = "open_showcase"
        static let openProfile: String = "open_profile"
        static let openMain: String = "open_main"
        static let openShop: String = "open_shop"
        static let openSearch: String = "open_search"
        static let openArchive: String = "open_archive"
		static let chatError: String = "chat.error"
    }
	
	enum Auto {
		static let reportAutoSOS: String = "report_auto_SOS"
		static let reportAutoMain: String = "report_auto_main"
		static let reportAutoMainProceed: String = "report_auto_main_proceed"
		static let reportAutoPolicy: String = "report_auto_policy"
		static let reportAutoSaveDraft: String = "report_auto_save_draft"
		static let reportAutoExitSaveDraft: String = "report_auto_exit_save_draft"
		static let reportAutoExitDeleteDraft: String = "report_auto_exit_delete_draft"
		static let reportAutoExitCancel: String = "report_auto_exit_cancel"
		static let reportAutoDone: String = "report_auto_done"
		static let reportAutoOpenDraftPolicy: String = "report_auto_open_draft_policy"
		static let reportAutoOpenDraftMain: String = "report_auto_open_draft_main"
		static let openReportAutoStatusPolicy: String = "open_report_auto_status_policy"
		static let openReportAutoStatusMain: String = "open_report_auto_status_main"
		static let reportAutoStatusAdd: String = "report_auto_status_add"
	}
	
	enum Clinic {
		static let appointmentSOS: String = "appointment_SOS"
		static let appointmentMain: String = "appointment_main"
		static let appointmentPolicy: String = "appointment_policy"
		static let offlineAppointmentDone: String = "offline_appointment_done"
		static let offlineAppointmentError: String = "offline_appointment_error"
		static let onlineAppointmentDone: String = "online_appointment_done"
		static let onlineAppointmentError: String = "online_appointment_error"
		static let openClinic: String = "open_clinic"
	}
	
	enum Dms {
		static let details = "dms.details"
		static let clinics = "dms.clinics"
		static let interactiveSupport = "dms.virtual_assistance"
		static let onlineAppointmentCreate = "dms.doctor_visit_booked"
		static let offlineAppointmentCreate = "dms.doctor_visit_booked_offline"
		static let bills = "dms.invoices"
		static let insuranceDetails = "dms.insurance_details"
		static let insuranceProgram = "dms.loss_statement"
		static let franchise = "dms.franchise_program"
		static let vzrBonuses = "dms.vzr_bonuses"
		static let costRecovery = "dms.refund_expenses"
		static let medicalCard = "dms.medical_card"
		static let vzrRefundCertificate = "dms.refund_advance"
		static let telemedicine = "dms.telemed"
		static let disagreement = "dms.invoices_disagreement"
		static let guaranteeLetters = "dms.guarantee_letter"
		static let guaranteeLetterRequest = "dms.guarantee_letter_request"
		static let appointmentsList = "dms.doctor_visits"
		static let medicalService = "dms_medical_service"
	}
	
	enum Launch {
		static let skipSignIn: String = "skip_sign_in"
		static let signInDemo: String = "sign_in_demo"
		static let openActivate: String = "open_activate"
		static let openSignIn: String = "open_sign_in"
		static let signInProceed: String = "sign_in_proceed"
		static let signInError: String = "sign_in_error"
		static let signInSuccess: String = "sign_in_success"
		static let openRegister: String = "open_register"
		static let registerProceed: String = "register_proceed"
		static let registerSuccess: String = "register_success"
		static let registerError: String = "register_error"
	}
	
	enum Passenger {
		static let reportPassengersSOS: String = "report_passengers_SOS"
		static let reportPassengersMain: String = "report_passengers_main"
		static let reportPassengersMainProceed: String = "report_passengers_main_proceed"
		static let reportPassengersPolicy: String = "report_passengers_policy"
		static let reportPassengersSaveDraft: String = "report_passengers_save_draft"
		static let reportPassengersExitSaveDraft: String = "report_passengers_exit_save_draft"
		static let reportPassengersExitDeleteDraft: String = "report_passengers_exit_delete_draft"
		static let reportPassengersExitCancel: String = "report_passengers_exit_cancel"
		static let reportPassengersDone: String = "report_passengers_done"
		static let reportPassengersOpenDraftPolicy: String = "report_passengers_open_draft_policy"
		static let reportPassengersOpenDraftMain: String = "report_passengers_open_draft_main"
		static let openReportPassengersStatusPolicy: String = "open_report_passengers_status_policy"
		static let reportPassengersStatusAdd: String = "report_passengers_status_add"
	}

    enum Vzr {
        static let reportVzrSOS: String = "reportVZR_SOS"
        static let reportVzrMain: String = "reportVZR_main"
        static let reportVzrPolicy: String = "reportVZR_policy"
    }

    enum SOS {
        static let sosAuto: String = "SOS_auto"
        static let sosHealth: String = "SOS_health"
        static let sosProperty: String = "SOS_property"
        static let sosTrip: String = "SOS_trip"
        static let sosPassengers: String = "SOS_passengers"
        static let sosAutoInstructions: String = "SOS_auto_instructions"
        static let sosAutoCall: String = "SOS_auto_call"
        static let sosAutoCallChoose: String = "SOS_auto_call_choose"
        static let sosAutoCallbackOpen: String = "SOS_auto_callback_open"
        static let sosAutoCallbackDone: String = "SOS_auto_callback_done"
        static let sosHealthInstructions: String = "SOS_health_instructions"
        static let sosHealthCall: String = "SOS_health_call"
        static let sosHealthCallChoose: String = "SOS_health_call_choose"
        static let sosPropertyInstructions: String = "SOS_property_instructions"
        static let sosPropertyCall: String = "SOS_property_call"
        static let sosPropertyCallChoose: String = "SOS_property_call_choose"
        static let sosPropertyCallbackOpen: String = "SOS_property_callback_open"
        static let sosPropertyCallbackDone: String = "SOS_property_callback_done"
        static let sosTripInstructions: String = "SOS_trip_instructions"
        static let sosTripCall: String = "SOS_trip_call"
        static let sosTripCallChoose: String = "SOS_trip_call_choose"
        static let sosTripCallbackOpen: String = "SOS_trip_callback_open"
        static let sosTripCallbackDone: String = "SOS_trip_callback_done"
        static let sosTripInternetCall: String = "SOS_trip_internet_call"
        static let sosPassengersInstructions: String = "SOS_passengers_instructions"
        static let sosPassengersCall: String = "SOS_passengers_call"
        static let sosPassengersCallChoose: String = "SOS_passengers_call_choose"
        static let sosPassengersCallbackOpen: String = "SOS_passengers_callback_open"
        static let sosPassengersCallbackDone: String = "SOS_passengers_callback_done"
    }
    
    enum Stories {
        static let storyOpen = "stories.open"
        static let storyPageOpen = "stories.slide_open"
        static let storyPageAction = "stories.slide_actions"
    }
}
