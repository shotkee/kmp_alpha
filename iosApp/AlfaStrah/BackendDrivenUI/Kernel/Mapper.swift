//
//  Mapper.swift
//  AlfaStrah
//
//  Created by vit on 27.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	enum Mapper {
		typealias WidgetEntry = (dtoType: ComponentDTO.Type, viewType: (any Widget.Type)?)
		typealias HeaderEntry = (dtoType: ComponentDTO.Type, viewType: (any Header.Type)?)
		typealias FooterEntry = (dtoType: ComponentDTO.Type, viewType: (any Footer.Type)?)
		typealias ActionEntry = (dtoType: ComponentDTO.Type, handler: (any Action.Type)?)
		
		static let widgetEntries: [BackendComponentType: WidgetEntry] = [
			.widgetInsuranceBlock: (InsuranceWidgetDTO.self, InsuranceWidgetView.self),
			.widgetHeader: (HeaderWidgetDTO.self, HeaderWidgetView.self),
			.layoutHorizontalScroll: (HorizontalScrollLayoutDTO.self, HorizontalScrollLayoutView.self),
			.widgetBlockTag: (TagBLockWidgetDTO.self, TagBlockWidgetView.self),
			.widgetBlockSquareIconHeaderDescription: (SquareIconHeaderDescriptionWidgetDTO.self, SquareIconHeaderCenterWidgetView.self),
			.widgetRowIconBlock: (RowWithIconBlockWidgetDTO.self, RowWithIconBlockWidgetView.self),
			.layoutTwoColumns: (TwoColumnsLayoutDTO.self, TwoColumnsLayoutView.self),
			.widgetInformation: (InformationWidgetDTO.self, InformationWidgetView.self),
			.layoutOneColumn: (OneColumnLayoutDTO.self, OneColumnLayoutView.self),
			.widgetRowIcons: (RowIconsWidgetDTO.self, RowWithIconsWidgetView.self),
			.widgetIconCounter: (IconWithCounterWidgetDTO.self, IconWithCounterWidgetView.self),
			.widgetRowIconDescription: (RowIconDescriptionWidgetDTO.self, RowIconDescriptionWidgetView.self),
			.widgetStories: (StoriesWidgetDTO.self, StoriesWrapperView.self),
			.widgetFilterItem: (FilterItemWidgetDTO.self, FilterItemWidgetView.self),
			.widgetFilterEventItem: (FilterEventItemWidgetDTO.self, FilterEventItemWidgetView.self),
			.layoutCollapse: (CollapseLayoutDTO.self, CollapseLayoutView.self),
			.widgetTextButtonArrow: (TextButtonArrowWidgetDTO.self, SectionViewWidget.self),
			.widgetBanner: (BannerWidgetDTO.self, BannerWidgetView.self),
			.widgetSquareLeftIconHeader: (SquareLeftIconHeaderWidgetDTO.self, SquareLeftIconHeaderWidgetView.self),
			.widgetSquareIconHeaderCenter: (SquareIconHeaderCenterWidgetDTO.self, SquareIconHeaderCenterWidgetView.self),
			.widgetImageTextLink: (ImageTextLinkWidgetDTO.self, ImageTextLinkWidgetView.self),
			.widgetRowImageHeaderDescriptionButton: (RowImageHeaderDescriptionButtonWidgetDTO.self, RowImageHeaderDescriptionButtonWidgetView.self),
			.widgetButton: (ButtonWidgetDTO.self, ButtonWidgetView.self),
			.widgetDraftCalculation: (DraftCalculationWidgetDTO.self, DraftCalculationWidgetView.self),
			.widgetRowImagesTitleBlock: (RowImagesTitleBlockWidgetDTO.self, RowImagesTitleBlockWidgetView.self),
			.widgetImage: (ImageWidgetDTO.self, ImageWidgetView.self),
			.widgetNavigate: (NavigateWidgetDTO.self, NavigateWidgetView.self),
			.widgetTitleImageButtonLeftAlign: (TitleImageButtonLeftAlignWidgetDTO.self, TitleImageButtonLeftAlignWidgetView.self),
			.widgetTagImage: (TagImageWidgetDTO.self, TagImageWidgetView.self),
			.widgetList: (ListWidgetDTO.self, ListWidgetView.self),
			.widgetLinkedText: (LinkedTextWidgetDTO.self, LinkedTextWidgetView.self),
			.widgetTextButtonCheckbox: (TextButtonCheckboxWidgetDTO.self, TextButtonCheckboxWidgetView.self),
			.widgetImageTextDescriptionButton: (ImageTextDescriptionButtonWidgetDTO.self, ImageTextDescriptionButtonWidgetView.self),
			.widgetRowImageHeaderDescriptionArrow: (RowImageHeaderDescriptionArrowWidgetDTO.self, RowImageHeaderDescriptionArrowWidgetView.self),
			.widgetTitleButton: (TitleButtonWidgetDTO.self, TitleButtonWidgetView.self),
			.widgetButtonList: (ButtonListWidgetDTO.self, ButtonListWidgetView.self),
			.widgetHeaderIcon: (HeaderIconWidgetDTO.self, HeaderIconWidgetView.self),
			.widgetTwoColumnListBlock: (TwoColumnListWidgetDTO.self, HeaderIconWidgetView.self),
			.widgetInputCheckbox: (CheckboxInputWidgetDTO.self, CheckboxInputWidgetView.self),
			.widgetBlockIconTextTagCircle: (IconTextTagCircleWidgetDTO.self, IconTextTagCircleWidgetView.self),
			.widgetTag: (TagWidgetDTO.self, TagWidgetView.self),
			.widgetVerticalCustomRadioButtonBlock: (VerticalCustomRadioButtonWidgetDTO.self, VerticalCustomRadioButtonWidgetView.self),
			.widgetBlockIconTitleDescriptionArrow: (IconTitleDescriptionArrowWidgetDTO.self, IconTitleDescriptionArrowWidgetView.self),
			.widgetInputText: (TextInputWidgetDTO.self, TextInputWidgetView.self),
			.widgetInputNumbers: (NumbersInputWidgetDTO.self, NumbersInputWidgetView.self),
			.widgetInputPhone: (PhoneInputWidgetDTO.self, PhoneInputWidgetView.self),
			.widgetInputEmail: (EmailInputWidgetDTO.self, EmailInputWidgetView.self),
			.widgetInputTextarea: (TextAreaInputWidgetDTO.self, TextAreaInputWidgetView.self),
			.widgetInputDate: (DateInputWidgetDTO.self, DateInputWidgetView.self),
			.widgetInputTime: (TimeInputWidgetDTO.self, TimeInputWidgetView.self),
			.widgetInputTextHeaderLeft: (TextHeaderLeftInputWidgetDTO.self, TextHeaderLeftInputWidgetView.self),
			.widgetInputLocation: (LocationInputWidgetDTO.self, LocationInputWidgetView.self),
			.widgetTitleIconsTextList: (TitleIconsTextListWidgetDTO.self, TitleIconsTextListWidgetView.self),
			.layoutHorizontalCarousel: (HorizontalCarouselLayoutDTO.self, HorizontalCarouselLayoutView.self),
			.widgetInputList: (ListInputWidgetDTO.self, ListInputWidgetView.self),
			.widgetInputListSearchable: (ListInputSearchableWidgetDTO.self, ListInputSearchableWidgetView.self),
			.widgetInputBankDadata: (BankDadataInputWidgetDTO.self, BankDadataInputWidgetView.self)
		]
		
		static let headerEntries: [BackendComponentType: HeaderEntry] = [
			.headerAlignLeftOneButtonDescription: (AlignLeftOneButtonDescriptionHeaderDTO.self, AlignLeftOneButtonDescriptionHeaderView.self),
			// navigation (not used as separate view)
			.headerOneButton: (OneButtonHeaderDTO.self, HeaderView.self),
			.headerTwoButtons: (TwoButtonsHeaderDTO.self, HeaderView.self)
		]
		
		static let footerEntries: [BackendComponentType: FooterEntry] = [
			.bottomWidgets: (BottomWidgetsFooterDTO.self, BottomWidgetsFooterView.self),
			.layoutBottom: (BottomLayoutFooterDTO.self, BottomLayoutFooterView.self)
		]
		
		static let actionEntries: [BackendComponentType: ActionEntry] = [
			.actionFlowBill: (BillFlowActionDTO.self, BillFlowActionHandler.self),
			.actionFlowClinics: (ClinicsFlowActionDTO.self, ClinicsFlowActionHandler.self),
			.actionFlowGaranteeLetters: (GaranteeLettersActionDTO.self, GaranteeLettersActionHandler.self),
			.actionFlowDoctorAppointments: (DoctorAppointmentsFlowActionDTO.self, DoctorAppointmentsFlowActionHandler.self),
			.actionFlowDoctorAppointment: (DoctorAppointmentFlowActionDTO.self, DoctorAppointmentFlowActionHandler.self),
			.actionFlowInstruction: (InstructionFlowActionDTO.self, InstructionFlowActionHandler.self),
			.actionFlowMedicalFileStorage: (MedicalFileStorageFlowActionDTO.self, MedicalFileStorageFlowActionHandler.self),
			.actionScreenRender: (ScreenRenderActionDTO.self, ScreenRenderActionHandler.self),
			.actionPhone: (PhoneActionDTO.self, PhoneActionHandler.self),
			.actionWebView: (WebViewActionDTO.self, WebViewActionHandler.self),
			.actionFlowChat: (ChatFlowActionDTO.self, ChatFlowActionHandler.self),
			.actionScreenRequest: (ScreenRequestActionDTO.self, ScreenRequestActionHandler.self),
			.actionFLowTelemed: (TelemedFlowActionDTO.self, TelemedFlowActionHandler.self),
			.actionFlowVirtualAssistant: (VirtualAssistantFlowActionDTO.self, VirtualAssistantFlowActionHandler.self),
			.actionFlowFranchise: (FranchiseFlowActionDTO.self, FranchiseFlowActionHandler.self),
			.actionFlowHelpBlocks: (HelpBlocksFlowActionDTO.self, HelpBlocksFlowActionHandler.self),
			.actionFlowCompensation: (CompensationFlowActionDTO.self, CompensationFlowActionHandler.self),
			.actionFlowNotifications: (NotificationsListActionDTO.self, NotificationsListActionHandler.self),
			.actionMulti: (MultipleActionsActionDTO.self, MultipleActionsActionHandler.self),
			.actionLayoutReplace: (LayoutReplaceActionDTO.self, LayoutReplaceActionHandler.self),
			.actionLayoutReplaceAsync: (LayoutReplaceAsyncActionDTO.self, LayoutReplaceAsyncActionHandler.self),
			.actionLayoutRequest: (LayoutRequestActionDTO.self, LayoutRequestActionHandler.self),
			.actionLayoutFilter: (LayoutFilterActionDTO.self, LayoutFilterActionHandler.self),
			.actionFlowLoyalty: (LoyaltyFlowActionDTO.self, LoyaltyFlowActionHandler.self),
			.actionNavigateBack: (NavigateBackToActionDTO.self, NavigateBackToActionHandler.self),
			.actionFlowInsurance: (InsuranceFlowActionDTO.self, InsuranceFlowActionHandler.self),
			.actionFlowBillsPay: (BillsPayFlowActionDTO.self, BillsPayFlowActionHandler.self),
			.actionFlowActivation: (ActivationFlowActionDTO.self, ActivationFlowActionHandler.self),
			.actionFlowFindInsurance: (FindInsuranceFlowActionDTO.self, FindInsuranceFlowActionHadler.self),
			.actionActionRequest: (ActionRequestActionDTO.self, ActionRequestActionHandler.self),
			.actionFlowDraftCalculations: (DraftCalculationsActionDTO.self, DraftCalculationsActionHandler.self),
			.actionFlowQuestion: (QuestionFlowActionDTO.self, QuestionFlowActionHandler.self),
			.actionFlowQuestions: (QuestionsFlowActionDTO.self, QuestionsFlowActionHandler.self),
			.actionMainPageToNativeRender: (MainPageToNativeRenderActionDTO.self, MainPageToNativeRenderActionHandler.self),
			.actionFlowOffices: (OfficesFlowActionDTO.self, OfficesFlowActionHandler.self),
			.actionFlowProducts: (ProductsFlowActionDTO.self, ProductsFlowActionHandler.self),
			.actionDraftDelete: (DeleteDraftActionDTO.self, DeleteDraftActionHandler.self),
			.actionFlowEventReportNS: (EventReportNsFlowActionDTO.self, EventReportNsFlowActionHandler.self),
			.actionFlowEventReportOsago: (EventReportOsagoFlowActionDTO.self, EventReportOsagoFlowActionHandler.self),
			.actionFlowEventReportKasko: (EventReportKaskoFlowActionDTO.self, EventReportKaskoFlowActionHandler.self),
			.actionFlowEuroprotocolOsago: (EuroprotocolOsagoFlowActionDTO.self, EuroprotocolOsagoFlowActionHandler.self),
			.actionFlowInternetCall: (InternetCallActionDTO.self, InternetCallActionHandler.self),
			.actionFlowProlongationOsago: (ProlongationOsagoFlowActionDTO.self, ProlongationOsagoFlowActionHandler.self),
			.actionFlowProlongationKasko: (ProlongationKaskoFlowActionDTO.self, ProlongationKaskoFlowActionHandler.self),
			.actionFlowProlongationAlfaRepair: (ProlongationAlfaRepairFlowActionDTO.self, ProlongationAlfaRepairFlowActionHandler.self),
			.actionFlowProlongationKindNeighbors: (ProlongationKindNeighborsFlowActionDTO.self, ProlongationKindNeighborsFlowActionHandler.self),
			.actionFlowDoctorHomeRequest: (DoctorHomeRequestFlowActionDTO.self, DoctorHomeRequestFlowActionHandler.self),
			.actionNothing: (NothingActionDTO.self, NothingActionHandler.self),
			.actionAlert: (AlertActionDTO.self, AlertActionHandler.self),
			.actionEditProfile: (EditProfileActionDTO.self, EditProfileActionHandler.self),
			.actionFlowChangeSessionType: (ChangeSessionTypeFlowActionDTO.self, ChangeSessionTypeFlowActionHandler.self),
			.actionFlowExit: (ExitFlowActionDTO.self, ExitFlowActionHandler.self),
			.actionFlowAboutApp: (AboutAppFlowActionDTO.self, AboutAppFlowActionHandler.self),
			.actionFlowAppSettings: (AppSettingsFlowActionDTO.self, AppSettingsFlowActionHandler.self),
			.actionFlowTheme: (ThemeFlowActionDTO.self, ThemeFlowActionHandler.self),
			.actionFlowViewEventReportsAuto: (ViewEventReportsAutoFlowActionDTO.self, ViewEventReportsAutoFlowActionHandler.self),
			.actionScreenReplace: (ScreenReplaceActionDTO.self, ScreenReplaceActionHandler.self),
			.actionFlowOsagoPhotoUpload: (OsagoPhotoUploadFlowActionDTO.self, OsagoPhotoUploadFlowActionHandler.self),
			.actionFlowOsagoSchemeAuto: (OsagoSchemeAutoFlowActionDTO.self, OsagoSchemeAutoFlowActionHandler.self),
			.actionFlowBills: (BillsFlowActionDTO.self, BillsFlowActionHandler.self)
		]
	}
}
