//
//  AnalyticsParam.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 15.07.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

enum AnalyticsParam {
    enum Launch {
        static let authorizationType: String = "authorization_type"
    }

    enum Clinic {
        static let clinicName: String = "clinic_name"
        static let clinicType: String = "clinic_type"
    }

    enum Auto {
        static let sentFromDraft: String = "sent_from_draft"
    }

    enum SOS {
        static let phoneNumber: String = "phone_number"
        static let succeed: String = "succeed"
    }

    enum Profile {
        static let authorized: String = "authorized"
		static let insurerFirstname: String = "insurer_f_name"
		static let insuranceGroupName: String = "group_name"
    }

    static func string(_ bool: Bool) -> String {
        bool ? "yes" : "no"
    }
    
	enum NavigationSource: String {
		case archives = "archives"
		case main = "main"
		case anotherStory = "stories"
		case dmsDetails = "dms_details"
		case notifications = "notifications"
		case clinics = "clinics"
		case appointmentInfo = "appointment_info"
		case billsList = "bills_list"
	}
	
	enum Key {
		static let navigationSource = "sourсe"
		static let insuranceId = "insurance_id"
		static let authorized = "authorized"
		static let contentType = "content_type"
		static let content = "content"
	}
	
	enum Stories {
        enum PageNavigationTrigger: String {
            case timer = "time"
            case userAction = "tap"
            case initial = "stories_opening"
        }
        
        enum PageStatus: String {
            case normal = "normal"
            case loading = "loading"
            case error = "error"
        }
        
        enum PageAction: String {
            case close = "cross"
            case leftTap = "left_tap"
            case rightTap = "right_tap"
            case swipeLeft = "left_swipe"
            case swipeRight = "right_swipe"
            case button = "button"
            case pause = "pause"
        }
        
        static let storyId = "id"
        static let storyTitle = "title"
        static let pageIndex = "slide_number"
        static let storySeen = "watched_before"
        static let pageHasLoading = "loading"
        static let pageNavigationTrigger = "reason"
        static let pageStatus = "slide_status"
        static let pageAction = "action"
        static let pageActionLink = "link"
        static let pageActionTime = "time"
    }
}
