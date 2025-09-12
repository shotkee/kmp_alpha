//
//  ApplicationSettingsService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 01/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

@objc protocol ApplicationSettingsService {
    // Environment
    var lastUsedEnvironmentIdentifier: String? { get set }
    
    // User
    @objc var userAuthType: AuthType { get set }
    @objc var accountType: AccountType { get set }
    var userTypeForSwitch: AccountType { get }
    @objc var wasAutorized: Bool { get set }
    var showFirstAlphaPoints: Bool { get set }
    var wasOndoarding: Bool { get set }
    @objc var session: UserSession? { get set }
    @objc var pin: String? { get set }
    @objc var login: String? { get set }
    @objc var password: String? { get set }

    @objc var haveAskedAboutTouchId: Bool { get set }
    @objc var deviceToken: String? { get set }

    @objc var haveAskedLocationAlwaysAuthorisation: Bool { get set }

    // Rate
    @objc var rateDeclined: Bool { get set }
    @objc var lastRatedVersion: String? { get set }
    @objc var runCounter: Int { get set }

    @objc func addRunCounter()
    func authTypeTitle(_ authType: AuthType) -> String?

    // cache
    var insuranceCacheExpDate: Date? { get set }
    var loyaltyCacheExpDate: Date? { get set }
    var vzrOnOffActiveTripCacheExpDate: Date? { get set }

    // vzr on off location based notifications
    var vzrOnOffLastVisitedCountry: String? { get set }
    var vzrOnOffIsLocationRequested: Bool { get set }

    // Mobile Guid
    var deviceIdentifier: String? { get set }
    var mobileGuid: String? { get set }
    var mobileDeviceToken: MobileDeviceToken? { get set }
	
	// Pin code
	var loginAttempts: Int { get set }

    // Euro Protocol constants
    var euroProtocolInviteBFirstName: String? { get set }
    var euroProtocolInviteBLastName: String? { get set }
    var euroProtocolInviteBMiddleName: String? { get set }
    var euroProtocolInviteBBirthDate: Date? { get set }
    var euroProtocolInviteBQRCode: UIImage? { get set }

    var hasDisagreements: ObjcOptionalBool { get set }
    var aisIdentifier: String? { get set }
    var aisAlfaRegistrationIdentifier: String? { get set }
    var euroProtocolClaimDate: Date? { get set }
    
    var lastKnownAppVersion: String? { get set }
    
    // Medical Card
    @objc var medicalCardToken: MedicalCardToken? { get set }
    
    // Chat
    @objc var chatSession: CascanaChatSession? { get set }
	@objc var lastVisibleScoreRequestMessageId: String? { get set }
	@objc var pinCodeScreenWasShownAfterChatScoreRequest: Bool { get set }
	
	// Application theme
	@objc var applicationTheme: UIUserInterfaceStyle { get set }
	var themeWasApplied: ObjcOptionalBool { get set }
	
	// BDUI
	var isNativeRender: ObjcOptionalBool { get set }
}

// swiftlint:disable identifier_name
// swiftlint:disable explicit_enum_raw_value
@objc enum ObjcOptionalBool: Int, Codable {
    case no
    case yes
    case none
}
