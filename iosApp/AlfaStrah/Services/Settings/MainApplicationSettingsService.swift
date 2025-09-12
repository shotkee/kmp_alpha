//
//  MainApplicationSettingsService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 08/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import KeychainAccess
import Legacy

class MainApplicationSettingsService: NSObject, ApplicationSettingsService {
    private let biometricsAuthService: BiometricsAuthService

    // UserDefaults keys
    private let lastUsedEnvironmentIdentifierKey = "RMRApplicationSettingsService.last_used_environment"
    private let authTypeKey = "RMRApplicationSettingsService.auth_type"
    private let deviceTokenKey = "RMRApplicationSettingsService.device_token"
    private let userTypeKey = "RMRApplicationSettingsService.userType"
    private let sessionIdkey = "RMRApplicationSettingsService.sessionId"
    private let runCounterKey = "RMRApplicationSettingsService.runCounter"
    private let ratedVersionKey = "RMRApplicationSettingsService.ratedVersion"
    private let rateDeclinedKey = "RMRApplicationSettingsService.rateDeclined"
    private let wasAuthorizedKey = "RMRApplicationSettingsService.was_auth"
    private let authHaveAskedAboutTouchIdKey = "RMRApplicationSettingsService.auth_have_asked_about_touch_id"
    private let apiInternalKey = "RMRApplicationSettingsService.api_internal"
    private let service = "RMRApplicationSettingsService.application_settings_service"
    private let showFirstAlphaPointsKey = "RMRApplicationSettingsService.showFirstAlphaPointsKey"
    private let alwaysAuthorisationForLocationKey = "RMRApplicationSettingsService.alwaysAuthorisationForLocationKey"

    private let wasOndoardingKey = "RMRApplicationSettingsService.wasOndoarding"

    // Keychain keys
    private let sessionKey = "RMRApplicationSettingsService.sessionAccessToken"
    private let pinCodeKey = "RMRApplicationSettingsService.userPinCode"
    private let userLoginKey = "RMRApplicationSettingsService.userLogin"
    private let userPasswordKey = "RMRApplicationSettingsService.userPassword"
    private let medicalCardTokenKey = "ApplicationSettingsService.medicalCardToken"
    private let medicalCardTokenCacheExpDateKey = "ApplicationSettingsService.medicalCardTokenCacheExpDate"
    // Old keys
    private let oldSessionKey = "RMRApplicationSettingsService.session"
    private let sessionIdOldKey = "id"
    private let sessionAccessTokenOldKey = "access_token"

    // Cache exp.
    private let insuranceCacheExpDateKey = "Insurance_Cache_Date"
    private let loyaltyCacheExpDateKey = "Loyalty_Cache_Date"
    private let vzrOnOffActiveTripCacheExpDateKey = "VZR_Active_Trip_Date"

    // Vzr on off last country key
    private let vzrOnOffLastVisitedCountryKey = "Vzr_On_Off_Last_Visited_Country"
    private let vzrOnOffIsLocationRequestedKey = "Vzr_On_Off_Is_Location_Requested"

    private let deviceIdentifierKey = "Device_identifier_key"
    private let mobileGuidKey = "Mobile_guid_key"
    private let mobileDeviceTokenKey = "Mobile_device_token_key"

    // Euro Protocol keys
    private let euroProtocolHasDisagreementsKey = "Euro_Protocol_Has_Disagreements"
    private let euroProtocolInviteBFirstNameKey = "Euro_Protocol_Invite_B_First_Name"
    private let euroProtocolInviteBLastNameKey = "Euro_Protocol_Invite_B_Last_Name"
    private let euroProtocolInviteBMiddleNameKey = "Euro_Protocol_Invite_B_Middle_Name"
    private let euroProtocolInviteBBirthDateKey = "Euro_Protocol_Invite_B_Birth_Date"
    private let euroProtocolInviteBQRCodeKey = "Euro_Protocol_Invite_B_QR_Code"
    private let euroProtocolAisIdentifierKey = "Euro_Protocol_Ais_Identifier_Key"
    // swiftlint:disable identifier_name
    private let euroProtocolAisAlfaRegistrationIdentifierKey = "Euro_Protocol_Ais_Alfa_Registration_Identifier_Key"
    private let euroProtocolClaimDateKey = "Euro_Protocol_Claim_Date_Key"
    private let lastKnownAppVersionKey = "Last_Known_App_Version"
    
    // Chat keys
    private let chatAccessTokenKey = "Chat_Access_Token_Key"
    private let chatRefreshTokenKey = "Chat_Refresh_Token_Key"
	private let lastVisibleScoreRequestMessageIdKey = "Chat_Last_Visible_Score_Request_Message_Id_key"
	private let pinCodeScreenWasShownAfterScoreRequestKey = "Chat_Pin_Code_Screen_Was_Shown_After_Score_Request"
	
	// Pin code keys
	private let numberOfLoginAttempts = "Number_Of_Login_Attempts"
	
	// Application theme
	private let applicationThemeKey = "Application_theme_Key"
	private let themeWasAppliedKey = "Theme_Was_Applied_Key"
	
	// BDUI
	private let activateBDUIKey = "Theme_Was_Applied_Key"
        
    var logger: TaggedLogger?
	
	private let defaults = UserDefaults.standard

    init(biometricsAuthService: BiometricsAuthService, logger: TaggedLogger?) {
        self.biometricsAuthService = biometricsAuthService
        self.logger = logger

        super.init()
    }
    
    var lastUsedEnvironmentIdentifier: String? {
        get {
            return defaults.string(forKey: lastUsedEnvironmentIdentifierKey)
        }
        set {
            defaults.set(newValue, forKey: lastUsedEnvironmentIdentifierKey)
        }
    }
    
    @objc var login: String? {
        get {
            let keychain = Keychain(service: service)
            return keychain[userLoginKey]
        }
        set {
            let keychain = Keychain(service: service)
            keychain[userLoginKey] = newValue
        }
    }

    @objc var password: String? {
        get {
            let keychain = Keychain(service: service)
            return keychain[userPasswordKey]
        }
        set {
            let keychain = Keychain(service: service)
            keychain[userPasswordKey] = newValue
        }
    }

    private var authSession: String? {
        get {
            let keychain = Keychain(service: service)
            return keychain[sessionKey]
        }
        set {
            let keychain = Keychain(service: service)
            keychain[sessionKey] = newValue
        }
    }

    @objc var pin: String? {
        get {
            let keychain = Keychain(service: service)
            return keychain[pinCodeKey]
        }
        set {
            let keychain = Keychain(service: service)
            keychain[pinCodeKey] = newValue
        }
    }
	
	@objc var loginAttempts: Int {
		get {
			defaults.integer(forKey: numberOfLoginAttempts)
		}
		set {
			defaults.set(newValue, forKey: numberOfLoginAttempts)
		}
	}

    var insuranceCacheExpDate: Date? {
        get {
            defaults.object(forKey: insuranceCacheExpDateKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: insuranceCacheExpDateKey)
        }
    }

    var loyaltyCacheExpDate: Date? {
        get {
            defaults.object(forKey: loyaltyCacheExpDateKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: loyaltyCacheExpDateKey)
        }
    }

    var vzrOnOffActiveTripCacheExpDate: Date? {
        get {
            defaults.object(forKey: vzrOnOffActiveTripCacheExpDateKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: vzrOnOffActiveTripCacheExpDateKey)
        }
    }

    var vzrOnOffLastVisitedCountry: String? {
        get {
            defaults.object(forKey: vzrOnOffLastVisitedCountryKey) as? String
        }
        set {
            defaults.set(newValue, forKey: vzrOnOffLastVisitedCountryKey)
        }
    }

    var vzrOnOffIsLocationRequested: Bool {
        get {
            defaults.bool(forKey: vzrOnOffIsLocationRequestedKey)
        }
        set {
            defaults.set(newValue, forKey: vzrOnOffIsLocationRequestedKey)
        }
    }

    var haveAskedLocationAlwaysAuthorisation: Bool {
           get {
               defaults.bool(forKey: alwaysAuthorisationForLocationKey)
           }
           set {
               defaults.set(newValue, forKey: alwaysAuthorisationForLocationKey)
           }
       }

    @objc func resetAuthentication() {
        authSession = nil
        pin = nil
        login = nil
        password = nil
    }

    @objc var userAuthType: AuthType {
        get {
            let integer = defaults.integer(forKey: authTypeKey)
            return AuthType(rawValue: integer) ?? .notDefined
        }
        set {
            defaults.set(newValue.rawValue, forKey: authTypeKey)
        }
    }

    @objc var deviceToken: String? {
        get {
            defaults.string(forKey: deviceTokenKey)
        }
        set {
            defaults.set(newValue, forKey: deviceTokenKey)
        }
    }

    var accountType: AccountType {
        get {
            let integer = defaults.integer(forKey: userTypeKey)
            return AccountType(rawValue: integer) ?? .alfaStrah
        }
        set {
            defaults.set(newValue.rawValue, forKey: userTypeKey)
        }
    }

    @objc var userTypeForSwitch: AccountType {
        switch accountType {
            case .alfaLife:
                return .alfaStrah
            case .alfaStrah:
                return .alfaLife
        }
    }

    @objc var session: UserSession? {
        get {
            guard let accessToken = authSession,
                  let sessionId = defaults.string(forKey: sessionIdkey)
            else { return nil }
            
            let session = UserSession(id: sessionId, accessToken: accessToken)
            return session
        }
        set {
            setSession(newValue)
        }
    }

    private func setSession(_ session: UserSession?) {
        authSession = session?.accessToken
        if let session = session {
            defaults.set(session.id, forKey: sessionIdkey)
        } else {
            defaults.removeObject(forKey: sessionIdkey)
        }
    }
    
   @objc var medicalCardToken: MedicalCardToken? {
        get {
            let keychain = Keychain(service: service)
            
            guard let token = keychain[medicalCardTokenKey],
                  let expirationDate = AppLocale.dateFromISO8601(keychain[medicalCardTokenCacheExpDateKey]),
                  defaults.string(forKey: sessionIdkey) != nil
            else { return nil }
            
            return MedicalCardToken(
                token: token,
                expirationDate: expirationDate
            )
        }
        set {
            let keychain = Keychain(service: service)
            if let date = newValue?.expirationDate {
                keychain[medicalCardTokenKey] = newValue?.token
                keychain[medicalCardTokenCacheExpDateKey] = AppLocale.iso8601DateToString(date)
            }
            else {
                keychain[medicalCardTokenKey] = nil
                keychain[medicalCardTokenCacheExpDateKey] = nil
            }
        }
    }
    
    @objc var chatSession: CascanaChatSession? {
        get {
            let keychain = Keychain(service: service)
            
            guard let accessToken = keychain[chatAccessTokenKey],
                  let refreshToken = keychain[chatRefreshTokenKey],
                  defaults.string(forKey: sessionIdkey) != nil
            else { return nil }
            
            return CascanaChatSession(accessToken: accessToken, refreshToken: refreshToken)
        }
        set {
            let keychain = Keychain(service: service)
            
            if  newValue?.accessToken != nil,
                newValue?.refreshToken != nil {
                keychain[chatAccessTokenKey] = newValue?.accessToken
                keychain[chatRefreshTokenKey] = newValue?.refreshToken
            } else {
                keychain[chatAccessTokenKey] = nil
                keychain[chatRefreshTokenKey] = nil
            }
        }
    }
	
	@objc var lastVisibleScoreRequestMessageId: String? {
		get {
			defaults.string(forKey: lastVisibleScoreRequestMessageIdKey)
		}
		set {
			defaults.set(newValue, forKey: lastVisibleScoreRequestMessageIdKey)
		}
	}
	
	@objc var pinCodeScreenWasShownAfterChatScoreRequest: Bool {
		get {
			defaults.bool(forKey: pinCodeScreenWasShownAfterScoreRequestKey)
		}
		set {
			defaults.set(newValue, forKey: pinCodeScreenWasShownAfterScoreRequestKey)
		}
	}

    @objc var runCounter: Int {
        get {
            defaults.integer(forKey: runCounterKey)
        }
        set {
            defaults.set(newValue, forKey: runCounterKey)
        }
    }

    @objc func addRunCounter() {
        let count = runCounter + 1
        defaults.set(count, forKey: runCounterKey)
    }

    @objc var lastRatedVersion: String? {
        get {
            defaults.string(forKey: ratedVersionKey)
        }
        set {
            defaults.set(newValue, forKey: ratedVersionKey)
        }
    }

    @objc var rateDeclined: Bool {
        get {
            defaults.bool(forKey: rateDeclinedKey)
        }
        set {
            defaults.set(newValue, forKey: rateDeclinedKey)
        }
    }

    @objc var wasAutorized: Bool {
        get {
            defaults.bool(forKey: wasAuthorizedKey)
        }
        set {
            defaults.set(newValue, forKey: wasAuthorizedKey)
        }
    }

    var wasOndoarding: Bool {
        get {
            defaults.bool(forKey: wasOndoardingKey)
        }
        set {
            defaults.set(newValue, forKey: wasOndoardingKey)
        }
    }

    var showFirstAlphaPoints: Bool {
        get {
            defaults.bool(forKey: showFirstAlphaPointsKey)
        }
        set {
            defaults.set(newValue, forKey: showFirstAlphaPointsKey)
        }
    }

    @objc var haveAskedAboutTouchId: Bool {
        get {
            defaults.bool(forKey: authHaveAskedAboutTouchIdKey)
        }
        set {
            defaults.set(newValue, forKey: authHaveAskedAboutTouchIdKey)
        }
    }

    @objc func authTypeTitle(_ authType: AuthType) -> String? {
        switch authType {
            case .notDefined:
                return nil
            case .demo:
                return NSLocalizedString("authtype_title_demo", comment: "")
            case .full:
                return NSLocalizedString("authtype_title_full", comment: "")
            case .auto:
                return NSLocalizedString("authtype_title_auto", comment: "")
            case .pin:
                return NSLocalizedString("authtype_title_fastcode", comment: "")
            case .biometric:
                return biometricsAuthService.type == .faceID
                    ? NSLocalizedString("authtype_title_face_id", comment: "")
                    : NSLocalizedString("authtype_title_touch_id", comment: "")
        }
    }

    var deviceIdentifier: String? {
        get {
            defaults.string(forKey: deviceIdentifierKey)
        }
        set {
            defaults.set(newValue, forKey: deviceIdentifierKey)
        }
    }

    var mobileGuid: String? {
        get {
            let keychain = Keychain(service: service)
            return keychain[mobileGuidKey]
        }
        set {
            let keychain = Keychain(service: service)
            keychain[mobileGuidKey] = newValue
        }
    }

    var mobileDeviceToken: MobileDeviceToken? {
        get {
            let keychain = Keychain(service: service)
            return keychain[mobileDeviceTokenKey]
        }
        set {
            let keychain = Keychain(service: service)
            keychain[mobileDeviceTokenKey] = newValue
        }
    }

    var hasDisagreements: ObjcOptionalBool {
        get {
            if let data = UserDefaults.standard.data(forKey: euroProtocolHasDisagreementsKey) {
                do {
                    let decoder = JSONDecoder()
                    let disagreements = try decoder.decode(ObjcOptionalBool.self, from: data)

                    return disagreements
                } catch {
                    logger?.debug("Unable to Decode OptionalBool (\(error))")
                }
            }
            return .none
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                UserDefaults.standard.set(data, forKey: euroProtocolHasDisagreementsKey)
            } catch {
                logger?.debug("Unable to Encode OptionalBool (\(error))")
            }
        }
    }

    var euroProtocolInviteBFirstName: String? {
        get {
            defaults.string(forKey: euroProtocolInviteBFirstNameKey)
        }
        set {
            defaults.set(newValue, forKey: euroProtocolInviteBFirstNameKey)
        }
    }

    var euroProtocolInviteBLastName: String? {
        get {
            defaults.string(forKey: euroProtocolInviteBLastNameKey)
        }
        set {
            defaults.set(newValue, forKey: euroProtocolInviteBLastNameKey)
        }
    }

    var euroProtocolInviteBMiddleName: String? {
        get {
            defaults.string(forKey: euroProtocolInviteBMiddleNameKey)
        }
        set {
            defaults.set(newValue, forKey: euroProtocolInviteBMiddleNameKey)
        }
    }

    var euroProtocolInviteBBirthDate: Date? {
        get {
            defaults.object(forKey: euroProtocolInviteBBirthDateKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: euroProtocolInviteBBirthDateKey)
        }
    }

    var euroProtocolInviteBQRCode: UIImage? {
        get {
            if let data = defaults.object(forKey: euroProtocolInviteBQRCodeKey) as? Data {
                return UIImage(data: data)
            } else {
                return nil
            }
        }
        set {
            defaults.set(newValue?.pngData(), forKey: euroProtocolInviteBQRCodeKey)
        }
    }

    var aisIdentifier: String? {
        get {
            defaults.string(forKey: euroProtocolAisIdentifierKey)
        }
        set {
            defaults.set(newValue, forKey: euroProtocolAisIdentifierKey)
        }
    }

    var aisAlfaRegistrationIdentifier: String? {
        get {
            defaults.string(forKey: euroProtocolAisAlfaRegistrationIdentifierKey)
        }
        set {
            defaults.set(newValue, forKey: euroProtocolAisAlfaRegistrationIdentifierKey)
        }
    }
    
    var euroProtocolClaimDate: Date? {
        get {
            defaults.object(forKey: euroProtocolClaimDateKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: euroProtocolClaimDateKey)
        }
    }
    
    var lastKnownAppVersion: String? {
        get {
            defaults.string(forKey: lastKnownAppVersionKey)
        }
        set {
            defaults.set(newValue, forKey: lastKnownAppVersionKey)
        }
    }
	
	@objc var applicationTheme: UIUserInterfaceStyle {
		get {
			let rawValue = defaults.integer(forKey: applicationThemeKey)
			return UIUserInterfaceStyle(rawValue: rawValue) ?? .unspecified
		}
		set {
			defaults.set(newValue.rawValue, forKey: applicationThemeKey)
		}
	}
	
	var themeWasApplied: ObjcOptionalBool {
		get {
			if let data = UserDefaults.standard.data(forKey: themeWasAppliedKey) {
				do {
					let decoder = JSONDecoder()
					return try decoder.decode(ObjcOptionalBool.self, from: data)
				} catch {
					logger?.debug("Unable to Decode OptionalBool (\(error))")
				}
			}
			return .none
		}
		set {
			do {
				let encoder = JSONEncoder()
				let data = try encoder.encode(newValue)
				UserDefaults.standard.set(data, forKey: themeWasAppliedKey)
			} catch {
				logger?.debug("Unable to Encode OptionalBool (\(error))")
			}
		}
	}
	
	var isNativeRender: ObjcOptionalBool {
		get {
			if let data = UserDefaults.standard.data(forKey: activateBDUIKey) {
				do {
					let decoder = JSONDecoder()
					return try decoder.decode(ObjcOptionalBool.self, from: data)
				} catch {
					logger?.debug("Unable to Decode OptionalBool (\(error))")
				}
			}
			return .none
		}
		
		set {
			do {
				let encoder = JSONEncoder()
				let data = try encoder.encode(newValue)
				UserDefaults.standard.set(data, forKey: activateBDUIKey)
			} catch {
				logger?.debug("Unable to Encode OptionalBool (\(error))")
			}
		}
	}
}
