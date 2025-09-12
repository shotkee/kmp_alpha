//
// RestConfigurator
// AlfaStrah
//
// Created by Eugene Egorov on 21 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import YandexMapsMobile
import Legacy
import CoreLocation
import SDWebImage

// swiftlint:disable file_length

private enum Constants {
    static let uploadAttachmentsDirectory: String = "Upload_attachments"
    static let draftAttachmentsDirectory: String = "Draft_attachments"
    static let tempAttachmentsDirectory: String = "Attachments"
    static let storageName: String = "as.realm"
    static let backgroundSessionIdentifier: String = "com.alfastrahovanie.backgroundSession"
    static let timeout: TimeInterval = 60
}

struct RestConfigurator: Configurator {
    private let baseUrl: URL
    private let yandexMapsApiKey: String
    private let yandexMetricaApiKey: String
    private let secretKey: String
    private let useProdEuroprotocolEnvironment: Bool
    static let userAgent = UserAgent.main
	
    init(
        baseUrl: String,
        yandexMapsApiKey: String,
        yandexMetricaApiKey: String,
        secretKey: String,
        useProdEuroprotocolEnvironment: Bool
    ) {
        guard let baseUrl = URL(string: baseUrl) else { fatalError("Bad url") }

        self.baseUrl = baseUrl
        self.yandexMetricaApiKey = yandexMetricaApiKey
        self.yandexMapsApiKey = yandexMapsApiKey
        self.secretKey = secretKey
        self.useProdEuroprotocolEnvironment = useProdEuroprotocolEnvironment
    }

    // swiftlint:disable:next function_body_length
    func create() -> DependencyInjectionContainer {
        YMKMapKit.setApiKey(yandexMapsApiKey)
        YMKMapKit.sharedInstance()  // Warning! Without this line background of map will not be loaded

        let logger = appLogger()

        let http = apiHttp(logger: logger)
        let biometricAuthService = DeviceBiometricsAuthService()
        let applicationSettingsService: ApplicationSettingsService = MainApplicationSettingsService(
            biometricsAuthService: biometricAuthService,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: ApplicationSettingsService.self)) }
        )

        let authorizer = AlfastrahRequestAuthorizer(
			accessToken: applicationSettingsService.session?.accessToken,
			userAgent: RestConfigurator.userAgent
		)
		
        let imageLoader = CachingImageLoader(name: "ImagesLoader", imageLoader: HttpImageLoader(http: imagesHttp(logger: logger)))

        let storeUrl = Storage.documentsDirectory.appendingPathComponent(Constants.storageName, isDirectory: false)
        let store = RealmStore(fileUrl: storeUrl, mapper: RealmMapper())

        let alertPresenter: AlertPresenter = WindowAlertPresenter(soundPlayer: SystemSoundPlayer())
        let notificationService = restNotificationService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer, store: store,
            applicationSettingsService: applicationSettingsService)
        let officeService = restOfficesService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let osagoProlongationService = restOsagoProlongationService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let insurancesService = restInsurancesService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store,
            applicationSettingsService: applicationSettingsService
        )
        
        let insurancesProductCategoryService = restInsurancesProductCategoryService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
        
        let insuranceBillPaymentService = restInsuranceBillPaymentService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let insuranceBillDisagreementService = restInsuranceBillDisagreementService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let guaranteeLettersService = restGuaranteeLettersService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let franchiseTransitionService = restFranchiseTransitionService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let dmsCostRecoveryService = restDmsCostRecoveryService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let passbookService = restPassbookService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let clinicsService = restClinicsService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let calendarService = LocalCalendarService()
        let geoLocationService = CoreLocationService(applicationSettingsService: applicationSettingsService)
        let significantLocationChangesService = SignificantLocationChangesServiceDefault()
        let offlineReverseGeocodeService = OfflineReverseGeocodeServiceDefault()
        let policyService = restPolicyService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)
        let phoneCallsService = restPhoneCallsService(baseUrl: baseUrl, http: http, requestAuthorizer: authorizer)

        let localNotificationsService = DeviceNotificationsService(applicationSettingsService: applicationSettingsService)
        let eventReportLogger = restEventReportLogger(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store
        )
        let sessionService = restUserSessionService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            applicationSettingsService: applicationSettingsService,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: UserSessionService.self)) }
        )

        authorizer.tokenSubscription = sessionService.subscribeSession(listener: authorizer.sessionListener)

        let accountService = restAccountService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            sessionService: sessionService,
            applicationSettingsService: applicationSettingsService
        )
        
        let endpointsService = restEndpointsService(
            baseUrl: baseUrl,
            http: http
        )
        
        let loyaltyService = restLoyaltyService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer, store: store,
            applicationSettingsService: applicationSettingsService
        )
        let uploadAttachmentsDirectory = Storage.cachesDirectory.appendingPathComponent(Constants.uploadAttachmentsDirectory,
            isDirectory: true)
        let tempAttachmentsDirectory = Storage.tempDirectory.appendingPathComponent(Constants.tempAttachmentsDirectory,
            isDirectory: true)
        let draftAttachmentsDirectory = Storage.cachesDirectory.appendingPathComponent(Constants.draftAttachmentsDirectory,
            isDirectory: true)

        let transferManager = UrlSessionTransferManager(
            backgroundSessionIdentifier: Constants.backgroundSessionIdentifier,
            baseUrl: baseUrl,
            directory: uploadAttachmentsDirectory,
            authorizer: authorizer,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: TransferManager.self)) },
            eventReportLogger: eventReportLogger
        )

        let attachmentService = restAttachmentService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store,
            uploadDirectory: uploadAttachmentsDirectory,
            draftDirectory: draftAttachmentsDirectory,
            tempDirectory: tempAttachmentsDirectory,
            transferManager: transferManager,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: AttachmentService.self)) },
            eventReportLogger: eventReportLogger
        )

        let eventReportService = restEventReportService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store,
            notificationsService: localNotificationsService,
            attachmentService: attachmentService
        )

        let questionService = restQuestionService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer, store: store
        )

        let pushNotificationService = restPushNotificationService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )

        let vzrOnOffService = restVzrOnOffService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store,
            insurancesService: insurancesService,
            applicationSettingsService: applicationSettingsService,
            significantLocationChangesService: significantLocationChangesService,
            offlineReverseGeocodeService: offlineReverseGeocodeService,
            localNotificationsService: localNotificationsService,
            geoLocationService: geoLocationService
        )

        let analytics: AnalyticsService = YandexMetricaAnalytics(
            apiKey: yandexMetricaApiKey,
            settingsService: applicationSettingsService,
            accountService: accountService
        )
        
        let chatService = cascanaChatService(
            alfaBaseUrl: baseUrl,
            http: http,
            alfaRequestAuthorizer: authorizer,
            accountService: accountService,
            userSessionService: sessionService,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: CascanaChatService.self)) },
            applicationSettingsService: applicationSettingsService,
            notificationsService: notificationService,
            attachmentService: attachmentService,
            analyticsService: analytics,
            endpointsService: endpointsService,
			insurancesService: insurancesService,
			store: store
        )
		
        let flatOnOffService = restFlatOnOffService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            insurancesService: insurancesService
        )

        let voipService = commonVoipService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            alertPresenter: alertPresenter,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: VoipService.self)) }
        )
        
        let mobileGuidService = restMobileGuidService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            applicationSettingsService: applicationSettingsService
        )

        let mobileDeviceTokenService = restMobileDeviceTokenService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            applicationSettingsService: applicationSettingsService
        )

        let euroProtocolService = rsaEuroProtocolService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            geoLocationService: geoLocationService,
            mobileGuidService: mobileGuidService,
            accountService: accountService,
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: RsaEuroProtocolService.self)) },
            isProd: useProdEuroprotocolEnvironment,
            applicationSettingsService: applicationSettingsService
        )
        
        let medicalCardService = restMedicalCardService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store,
            applicationSettingsService: applicationSettingsService,
            endpointsService: endpointsService,
			logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: MedicalCardService.self)) }
        )
        
        let storiesService = restStoriesService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store,
            applicationSettingsService: applicationSettingsService
        )
        
        let interactiveSupportService = restInteractiveSupportService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            store: store
        )
        
        let doctorAppointmentService = restDoctorAppointmentService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
        
        let esiaService = restEsiaService(
            http: http,
            requestAuthorizer: authorizer
        )
        
        let serviceDataManager = ServiceDataManagerDefault(
            logger: logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: ServiceDataManager.self)) },
            accountService: accountService,
            analyticsService: analytics,
            services: [
                questionService,
                notificationService,
                loyaltyService,
                localNotificationsService,
                eventReportService,
                insurancesService,
                attachmentService,
                sessionService,
                accountService,
                vzrOnOffService,
                euroProtocolService,
                pushNotificationService,
                mobileGuidService,
                policyService,
                medicalCardService,
                storiesService,
                interactiveSupportService,
                esiaService
            ]
        )

        let campaignService = restCampaignService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )

        let daDataService = restDaDataService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer,
            geoLocationService: geoLocationService
        )
        
        let apiStatusService = restApiStatusService(
            baseUrl: baseUrl,
            http: http
        )
        
        let healthAcademyService = restHealthAcademyService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
		
		let insuranceLifeService = restInsuranceLifeService(
			baseUrl: baseUrl,
			http: http,
			requestAuthorizer: authorizer
		)
        
        let insuranceProgramService = restInsuranceProgramService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
        
        let draftCategoryService = restDraftCategoryService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
        
        let kaskoExtensionService = restKaskoExtensionService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
        
        let marksWebService = restMarksWebService(
            baseUrl: baseUrl,
            http: http,
            requestAuthorizer: authorizer
        )
		
		let backendDrivenService = restBackendDriven(
			http: http,
			requestAuthorizer: authorizer,
			userSessionService: sessionService,
			endpointsService: endpointsService
		)
			
		let bonusPointsService = restBonusPointsService(
			http: http,
			requestAuthorizer: authorizer,
			store: store
		)
                
        let container = Odin()
        container.register { (object: inout GeolocationServiceDependency) in
            object.geoLocationService = geoLocationService
        }
        container.register { (object: inout CalendarServiceDependency) in
            object.calendarService = calendarService
        }
        container.register { (object: inout ImageLoaderDependency) in
            object.imageLoader = imageLoader
        }
        container.register { (object: inout NotificationsServiceDependency) in
            object.notificationsService = notificationService
        }
        container.register { (object: inout OsagoProlongationServiceDependency) in
            object.osagoProlongationService = osagoProlongationService
        }
        container.register { (object: inout OfficesServiceDependency) in
            object.officesService = officeService
        }
        container.register { (object: inout InsurancesServiceDependency) in
            object.insurancesService = insurancesService
        }
        container.register { (object: inout InsurancesProductCategoryServiceDependency) in
            object.insurancesProductCategoryService = insurancesProductCategoryService
        }
        container.register { (object: inout InsuranceBillPaymentServiceDependency) in
            object.insuranceBillPaymentService = insuranceBillPaymentService
        }
        container.register { (object: inout InsuranceBillDisagreementServiceDependency) in
            object.insuranceBillDisagreementService = insuranceBillDisagreementService
        }
        container.register { (object: inout GuaranteeLettersServiceDependency) in
            object.guaranteeLettersService = guaranteeLettersService
        }
        container.register { (object: inout FranchiseTransitionServiceDependency) in
            object.franchiseTransitionService = franchiseTransitionService
        }
        container.register { (object: inout DmsCostRecoveryServiceDependency) in
            object.dmsCostRecoveryService = dmsCostRecoveryService
        }
        container.register { (object: inout AccountServiceDependency) in
            object.accountService = accountService
        }
        container.register { (object: inout ChatServiceDependency) in
            object.chatService = chatService
        }
        container.register { (object: inout PolicyServiceDependency) in
            object.policyService = policyService
        }
        container.register { (object: inout SessionServiceDependency) in
            object.sessionService = sessionService
        }
        container.register { (object: inout PassbookServiceDependency) in
            object.passbookService = passbookService
        }
        container.register { (object: inout ClinicsServiceDependency) in
            object.clinicsService = clinicsService
        }
        container.register { (object: inout LocalNotificationsServiceDependency) in
            object.localNotificationsService = localNotificationsService
        }
        container.register { (object: inout ApplicationSettingsServiceDependency) in
            object.applicationSettingsService = applicationSettingsService
        }
        container.register { (object: inout EuroProtocolServiceDependency) in
            object.euroProtocolService = euroProtocolService
        }
        container.register { (object: inout PhoneCallsServiceDependency) in
            object.phoneCallsService = phoneCallsService
        }
        container.register { (object: inout ServiceDataManagerDependency) in
            object.serviceDataManager = serviceDataManager
        }
        container.register { (object: inout EventReportServiceDependency) in
            object.eventReportService = eventReportService
        }
        container.register { (object: inout BiometricsAuthServiceDependecy) in
            object.biometricsAuthService = biometricAuthService
        }
        container.register { (object: inout AnalyticsServiceDependency) in
            object.analytics = analytics
        }
        container.register { (object: inout VoipServiceDependency) in
            object.voipService = voipService
        }
        container.register { (object: inout LoyaltyServiceDependency) in
            object.loyaltyService = loyaltyService
        }
        container.register { (object: inout QuestionServiceDependency) in
            object.questionService = questionService
        }
        container.register { (object: inout CampaignServiceDependency) in
            object.campaignService = campaignService
        }
        container.register { (object: inout AttachmentServiceDependency) in
            object.attachmentService = attachmentService
        }
        container.register { (object: inout TransferManagerDependency) in
            object.transferManager = transferManager
        }
        container.register { (object: inout EventReportLoggerDependency) in
            object.eventReportLogger = eventReportLogger
        }
        container.register { (object: inout PushNotificationServiceDependency) in
            object.pushNotificationService = pushNotificationService
        }
        container.register { (object: inout VzrOnOffServiceDependency) in
            object.vzrOnOffService = vzrOnOffService
        }
        container.register { (object: inout FlatOnOffServiceDependency) in
            object.flatOnOffService = flatOnOffService
        }
        container.register { (object: inout LoggerDependency) in
            object.logger = logger.map { SimpleTaggedLogger(logger: $0, tag: String(describing: type(of: object))) }
        }
        container.register { (object: inout AlertPresenterDependency) in
            object.alertPresenter = alertPresenter
        }
        container.register { (object: inout GeocodeServiceDependency) in
            object.geocodeService = daDataService
        }
        container.register { (object: inout MobileGuidServiceDependency) in
            object.mobileGuidService = mobileGuidService
        }
        container.register { (object: inout MobileDeviceTokenServiceDependency) in
            object.mobileDeviceTokenService = mobileDeviceTokenService
        }
        container.register { [unowned container] (object: inout DependencyContainerDependency) in
            object.container = container
        }
        container.register { (object: inout HttpRequestAuthorizerServiceDependency) in
            object.httpRequestAuthorizer = authorizer
        }
        container.register { (object: inout ApiStatusServiceDependency) in
            object.apiStatusService = apiStatusService
        }
        container.register { (object: inout HealthAcademyServiceDependency) in
            object.healthAcademyService = healthAcademyService
        }
		container.register { (object: inout InsuranceLifeServiceDependency) in
			object.insuranceAlfaLifeService = insuranceLifeService
		}
        container.register { (object: inout InsuranceProgramServiceDependency) in
            object.insuranceProgramService = insuranceProgramService
        }
        container.register { (object: inout DraftsCalculationsServiceDependency) in
            object.draftsCalculationsService = draftCategoryService
        }
        container.register { (object: inout KaskoExtensionServiceDependency) in
            object.kaskoExtensionService = kaskoExtensionService
        }
        container.register { (object: inout UserSessionServiceDependency) in
            object.userSessionService = sessionService
        }
        container.register { (object: inout MedicalCardServiceDependency) in
            object.medicalCardService = medicalCardService
        }
        container.register{ (object: inout StoriesServiceDependency) in
            object.storiesService = storiesService
        }
        container.register { (object: inout MarksWebServiceDependency) in
            object.marksWebService = marksWebService
        }
        
        container.register { (object: inout InteractiveSupportServiceDependency) in
            object.interactiveSupportService = interactiveSupportService
        }
        
        container.register { (object: inout DoctorAppointmentServiceDependency) in
            object.doctorAppointmentService = doctorAppointmentService
        }
        
        container.register { (object: inout EsiaServiceDependency) in
            object.esiaService = esiaService
        }
		
		container.register { (object: inout BackendDrivenServiceDependency) in
			object.backendDrivenService = backendDrivenService
		}
        
		container.register { (object: inout BonusPointsServiceDependency) in
			object.bonusPointsService = bonusPointsService
		}
		
        return container
    }

    private func apiHttp(logger: Logger?) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.timeout
        configuration.timeoutIntervalForResource = Constants.timeout * 2
        configuration.urlCache = nil

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger, loggerTag: "ApiHttp")
        switch environment {
            case .appStore, .testAdHoc, .stageAdHoc, .prodAdHoc:
                break
            case .test, .prod, .stage:
                http.maxLoggingBodySize = 131072
        }
        return http
    }

    private func imagesHttp(logger: Logger?) -> Http {
        let megabyte = 1024 * 1024
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.timeout
        configuration.timeoutIntervalForResource = Constants.timeout * 2
        configuration.urlCache = URLCache(memoryCapacity: 50 * megabyte, diskCapacity: 100 * megabyte, diskPath: nil)

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger, loggerTag: "ImagesHttp")
        return http
    }

    private func appLogger() -> Logger? {
        switch environment {
            case .appStore:
                return nil
            case .testAdHoc, .stageAdHoc, .prodAdHoc:
                return NSLogLogger()
            case .test, .stage, .prod:
                return PrintLogger()
        }
    }

    private func restNotificationService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        applicationSettingsService: ApplicationSettingsService
    ) -> NotificationsService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestNotificationsService(rest: rest, store: store, applicationSettingsService: applicationSettingsService)
        return service
    }

    private func restOfficesService(baseUrl: URL, http: Http, requestAuthorizer: HttpRequestAuthorizer) -> OfficesService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestOfficeService(rest: rest)
        return service
    }

    private func restOsagoProlongationService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestOsagoProlongationService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestOsagoProlongationService(rest: rest)
        return service
    }

    private func restInsurancesService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        applicationSettingsService: ApplicationSettingsService
    ) -> InsurancesService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestInsurancesService(rest: rest, store: store, applicationSettingsService: applicationSettingsService)
        return service
    }
    
    private func restInsurancesProductCategoryService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> InsurancesProductCategoryService {
        let queue = DispatchQueue.global(qos: .default)
        
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        
        let service = RestInsurancesProductCategoryService(
            rest: rest
        )
        
        return service
    }
    
    
    private func restMedicalCardService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        applicationSettingsService: ApplicationSettingsService,
        endpointsService: EndpointsService,
		logger: TaggedLogger?
    ) -> RestMedicalCardService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        
        let service = RestMedicalCardService(
            rest: rest,
			logger: logger,
            store: store,
            authorizer: requestAuthorizer,
            applicationSettingsService: applicationSettingsService,
            endpointsService: endpointsService
        )
        setupRequestModifierSDWebImageDownloader(
            restMedicalCardService: service
        )
        return service
    }
    
    private func mockMedicalCardService(
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        filesServerBaseUrl: String
    ) -> MockMedicalCardService {
        let service = MockMedicalCardService(
            authorizer: requestAuthorizer,
            store: store,
            filesServerBaseUrl: URL(string: filesServerBaseUrl)
        )
        return service
    }
    
    private func setupRequestModifierSDWebImageDownloader(
        restMedicalCardService: RestMedicalCardService
    ) {
        SDWebImageDownloader.shared.requestModifier = SDWebImageDownloaderRequestModifier { request -> URLRequest? in
            guard let url = request.url
            else { return request }
            
            if restMedicalCardService.isUrlPreviewImage(url: url) {
                var mutableRequest = request
                
                guard let token = restMedicalCardService.medicalCardToken?.token
                else { return mutableRequest }
                
                mutableRequest.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
                return mutableRequest
            }
            
            return request
        }
    }
    
    private func restInsuranceBillPaymentService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> InsuranceBillPaymentService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestInsuranceBillPaymentService(rest: rest)
        return service
    }

    private func restInsuranceBillDisagreementService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> InsuranceBillDisagreementsService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestInsuranceBillDisagreementsService(
            rest: rest,
            authorizer: requestAuthorizer
        )
        return service
    }

    private func restGuaranteeLettersService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> GuaranteeLettersService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestGuaranteeLettersService(rest: rest)
        return service
    }

    private func restFranchiseTransitionService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> FranchiseTransitionService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestFranchiseTransitionService(rest: rest)
        return service
    }
    
    private func restDmsCostRecoveryService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> DmsCostRecoveryService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestDmsCostRecoveryService(
            rest: rest,
            baseUrl: baseUrl,
            authorizer: requestAuthorizer
        )
        return service
    }
    
    private func restMobileGuidService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        applicationSettingsService: ApplicationSettingsService
    ) -> MobileGuidService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestMobileGuidService(rest: rest, applicationSettingsService: applicationSettingsService)
        return service
    }

    private func restMobileDeviceTokenService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        applicationSettingsService: ApplicationSettingsService
    ) -> MobileDeviceTokenService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestMobileDeviceTokenService(
            rest: rest,
            applicationSettingsService: applicationSettingsService
        )
        return service
    }

    private func restPassbookService(baseUrl: URL, http: Http, requestAuthorizer: HttpRequestAuthorizer) -> PassbookService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestPassbookService(rest: rest)
        return service
    }

    private func rsaEuroProtocolService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        geoLocationService: GeoLocationService,
        mobileGuidService: MobileGuidService,
        accountService: AccountService,
        logger: TaggedLogger?,
        isProd: Bool,
        applicationSettingsService: ApplicationSettingsService
    ) -> RsaEuroProtocolService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )

        return RsaEuroProtocolService(
            rest: rest, mobileGuidService: mobileGuidService,
            accountService: accountService, geoLocationService: geoLocationService,
            logger: logger, isProd: isProd, applicationSettingsService: applicationSettingsService
        )
    }

    private func restEventReportService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        notificationsService: LocalNotificationsService,
        attachmentService: AttachmentService
    ) -> EventReportService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestEventReportService(rest: rest, store: store,
            notificationsService: notificationsService, attachmentService: attachmentService)
        return service
    }

    private func restClinicsService(baseUrl: URL, http: Http, requestAuthorizer: HttpRequestAuthorizer) -> RestClinicsService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestClinicsService(rest: rest)
        return service
    }

    // swiftlint:disable function_parameter_count
    private func cascanaChatService(
        alfaBaseUrl: URL,
        http: Http,
        alfaRequestAuthorizer: HttpRequestAuthorizer,
        accountService: AccountService,
        userSessionService: UserSessionService,
        logger: TaggedLogger?,
        applicationSettingsService: ApplicationSettingsService,
        notificationsService: NotificationsService,
        attachmentService: AttachmentService,
        analyticsService: AnalyticsService,
        endpointsService: EndpointsService,
		insurancesService: InsurancesService,
		store: Store
    ) -> CascanaChatService? {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: alfaBaseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: alfaRequestAuthorizer
        )

        let service = CascanaChatService(
            rest: rest,
            logger: logger,
            accountService: accountService,
            userSessionService: userSessionService,
            applicationSettingsService: applicationSettingsService,
            notificationsService: notificationsService,
            attachmentService: attachmentService,
            analyticsService: analyticsService,
            endpointsService: endpointsService,
			insurancesService: insurancesService,
            http: http,
            baseUrl: {
                switch environment {
                    case .prod, .appStore, .prodAdHoc:
                        return alfaBaseUrl
                    case .stage, .test, .testAdHoc, .stageAdHoc:
                        return nil
                }
            }(),
			store: store
        )
        
        return service
    }
    // swiftlint:enable function_parameter_count

    private func restUserSessionService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        applicationSettingsService: ApplicationSettingsService,
        logger: TaggedLogger?
    ) -> RestUserSessionService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestUserSessionService(
            rest: rest,
            settingsService: applicationSettingsService,
            secretKey: secretKey
        )
        return service
    }

    private func restAccountService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        sessionService: UserSessionService,
        applicationSettingsService: ApplicationSettingsService
    ) -> RestAccountService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
		
        let service = RestAccountService(
            rest: rest,
            secretKey: secretKey,
            sessionService: sessionService,
            applicationSettingsService: applicationSettingsService
        )
        return service
    }

    private func restPolicyService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestPolicyService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestPolicyService(rest: rest)
        return service
    }

    private func restPhoneCallsService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestPhoneCallsService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestPhoneCallsService(rest: rest)
        return service
    }

    private func restLoyaltyService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        applicationSettingsService: ApplicationSettingsService
    ) -> RestLoyaltyService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestLoyaltyService(rest: rest, store: store, applicationSettingsService: applicationSettingsService)
        return service
    }

    private func restAttachmentService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        uploadDirectory: URL,
        draftDirectory: URL,
        tempDirectory: URL,
        transferManager: TransferManager,
        logger: TaggedLogger?,
        eventReportLogger: EventReportLoggerService
    ) -> RestAttachmentService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestAttachmentService(rest: rest, store: store,
            uploadDirectory: uploadDirectory, draftDirectory: draftDirectory, tempDirectory: tempDirectory,
            transferManager: transferManager, logger: logger, eventReportLogger: eventReportLogger)
        return service
    }

    private func urlSessionTransferManager(
        backgroundSessionIdentifier: String,
        baseUrl: URL,
        directory: URL,
        requestAuthorizer: HttpRequestAuthorizer,
        logger: TaggedLogger?,
        eventReportLogger: EventReportLoggerService
    ) -> UrlSessionTransferManager {
        let service = UrlSessionTransferManager(
            backgroundSessionIdentifier: backgroundSessionIdentifier,
            baseUrl: baseUrl,
            directory: directory,
            authorizer: requestAuthorizer,
            logger: logger,
            eventReportLogger: eventReportLogger
        )
        return service
    }

    private func restEventReportLogger(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store
    ) -> RestEventReportLoggerService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestEventReportLoggerService(rest: rest, store: store)
        return service
    }

    private func restCampaignService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestCampaignService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestCampaignService(rest: rest)
        return service
    }

    private func restDaDataService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: RequestAuthorizer,
        geoLocationService: GeoLocationService
    ) -> RestGeocodeService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = BaseRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestGeocodeService(rest: rest, geoLocationService: geoLocationService)
        return service
    }

    private func restQuestionService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store
    ) -> RestQuestionService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestQuestionService(rest: rest, store: store)
        return service
    }

    private func restPushNotificationService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestPushNotificationService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestPushNotificationService(rest: rest)
        return service
    }

    private func restVzrOnOffService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        insurancesService: InsurancesService,
        applicationSettingsService: ApplicationSettingsService,
        significantLocationChangesService: SignificantLocationChangesService,
        offlineReverseGeocodeService: OfflineReverseGeocodeService,
        localNotificationsService: LocalNotificationsService,
        geoLocationService: GeoLocationService
    ) -> RestVzrOnOffService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestVzrOnOffService(
            rest: rest,
            store: store,
            insurancesService: insurancesService,
            applicationSettingsService: applicationSettingsService,
            significantLocationChangesService: significantLocationChangesService,
            offlineReverseGeocodeService: offlineReverseGeocodeService,
            localNotificationsService: localNotificationsService,
            geoLocationService: geoLocationService
        )
        return service
    }

    private func restFlatOnOffService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        insurancesService: InsurancesService
    ) -> RestFlatOnOffService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        return RestFlatOnOffService(rest: rest, insurancesService: insurancesService)
    }
    
    private func restApiStatusService(
        baseUrl: URL,
        http: Http
    ) -> ApiStatusService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main
        )
        let service = RestApiStatusService(rest: rest, userAgent: RestConfigurator.userAgent)
        return service
    }
    
    private func restHealthAcademyService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> HealthAcademyService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestHealthAcademyService(rest: rest)
        return service
    }
	
	private func restInsuranceLifeService(
		baseUrl: URL,
		http: Http,
		requestAuthorizer: HttpRequestAuthorizer
	) -> InsuranceLifeService {
		let queue = DispatchQueue.global(qos: .default)
		let rest = AlfastrahRestClient(
			http: http,
			baseURL: baseUrl,
			workQueue: queue,
			completionQueue: .main,
			requestAuthorizer: requestAuthorizer
		)
		let service = RestInsuranceLifeService(rest: rest)
		return service
	}
    
    private func restInsuranceProgramService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> InsuranceProgramService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestInsuranceProgramService(rest: rest)
        return service
    }
    
    private func restDraftCategoryService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> DraftsCalculationsService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestDraftsCalculationsService(rest: rest)
        return service
    }
    
    private func restKaskoExtensionService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> KaskoExtensionService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestKaskoExtensionService(rest: rest)
        return service
    }
    
    private func restMarksWebService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> MarksWebService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
        let service = RestMarksWebService(rest: rest)
        return service
    }
    
    private func restEndpointsService(
        baseUrl: URL,
        http: Http
    ) -> EndpointsService {
        let queue = DispatchQueue.global(qos: .default)
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main
        )

        let service = RestEndpointsService(rest: rest)

        return service
    }
    
    private func restStoriesService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store,
        applicationSettingsService: ApplicationSettingsService
    ) -> RestStoriesService {
        let queue = DispatchQueue.global(qos: .default)
        
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
            
        let service = RestStoriesService(
            applicationSettingsService: applicationSettingsService,
            rest: rest,
            store: store,
            authorizer: requestAuthorizer
        )
        
        RestStoriesService.createImageCached()
        
        return service
    }
    
    private func restInteractiveSupportService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        store: Store
    ) -> RestInteractiveSupportService {
        let queue = DispatchQueue.global(qos: .default)
        
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
            
        let service = RestInteractiveSupportService(
            rest: rest,
            store: store,
            authorizer: requestAuthorizer
        )
        
        return service
    }
    
    private func restDoctorAppointmentService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestDoctorAppointmentlService {
        let queue = DispatchQueue.global(qos: .default)
        
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
            
        let service = RestDoctorAppointmentlService(
            rest: rest
        )
        
        return service
    }
    
    private func commonVoipService(
        baseUrl: URL,
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer,
        alertPresenter: AlertPresenter,
        logger: TaggedLogger?
    ) -> CommonVoipService {
        let queue = DispatchQueue.global(qos: .default)
        
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
            
        let service = CommonVoipService(
            rest: rest,
            alertPresenter: alertPresenter,
            logger: logger
        )
        
        return service
    }
    
    private func restEsiaService(
        http: Http,
        requestAuthorizer: HttpRequestAuthorizer
    ) -> RestEsiaService {
        let queue = DispatchQueue.global(qos: .default)
        
        let rest = AlfastrahRestClient(
            http: http,
            baseURL: baseUrl,
            workQueue: queue,
            completionQueue: .main,
            requestAuthorizer: requestAuthorizer
        )
            
        let service = RestEsiaService(
            rest: rest,
            secretKey: secretKey
        )
        
        return service
    }
	
	private func restBackendDriven(
		http: Http,
		requestAuthorizer: HttpRequestAuthorizer,
		userSessionService: UserSessionService,
		endpointsService: EndpointsService
	) -> BDUI.RestBackendDrivenService {
		return BDUI.RestBackendDrivenService(
			http: http,
			requestAuthorizer: requestAuthorizer,
			userSessionService: userSessionService,
			endpointsService: endpointsService
		)
	}

	private func restBonusPointsService(
		http: Http,
		requestAuthorizer: HttpRequestAuthorizer,
		store: Store
	) -> RestBonusPointsService {
		let queue = DispatchQueue.global(qos: .default)
		
		let rest = AlfastrahRestClient(
			http: http,
			baseURL: baseUrl,
			workQueue: queue,
			completionQueue: .main,
			requestAuthorizer: requestAuthorizer
		)
			
		let service = RestBonusPointsService(
			rest: rest,
			store: store
		)
		
		return service
	}
}
// swiftlint:enable file_length
