// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct BackendComponentTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendComponentType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "Bottom-Widgets":
                return .success(.bottomWidgets)
            case "Header-OneButton":
                return .success(.headerOneButton)
            case "Header-AlignLeftOneButtonDescription":
                return .success(.headerAlignLeftOneButtonDescription)
            case "Header-TwoButtons":
                return .success(.headerTwoButtons)
            case "Layout-OneColumn":
                return .success(.layoutOneColumn)
            case "Layout-TwoColumns":
                return .success(.layoutTwoColumns)
            case "Layout-HorizontalScroll":
                return .success(.layoutHorizontalScroll)
            case "Layout-Collapse":
                return .success(.layoutCollapse)
            case "Layout-HorizontalCarousel":
                return .success(.layoutHorizontalCarousel)
            case "Bottom-Layout":
                return .success(.layoutBottom)
            case "Screen-Basic":
                return .success(.screenBasic)
            case "Screen-BottomToolbar":
                return .success(.screenBottomToolbar)
            case "Screen-Modal":
                return .success(.screenModal)
            case "Widget-BlockTag":
                return .success(.widgetBlockTag)
            case "Widget-BlockSquareIconHeaderDescription":
                return .success(.widgetBlockSquareIconHeaderDescription)
            case "Widget-Button":
                return .success(.widgetButton)
            case "Widget-Information":
                return .success(.widgetInformation)
            case "Widget-InsuranceBlock":
                return .success(.widgetInsuranceBlock)
            case "Widget-Header":
                return .success(.widgetHeader)
            case "Widget-RowIconBlock":
                return .success(.widgetRowIconBlock)
            case "Widget-RowIcons":
                return .success(.widgetRowIcons)
            case "Widget-IconCounter":
                return .success(.widgetIconCounter)
            case "Widget-RowIconBlockDescription":
                return .success(.widgetRowIconDescription)
            case "Widget-StoriesBlock":
                return .success(.widgetStories)
            case "Widget-FilterBlockItem":
                return .success(.widgetFilterItem)
            case "Widget-FilterBlockEventItem":
                return .success(.widgetFilterEventItem)
            case "Widget-TextButtonArrowBlock":
                return .success(.widgetTextButtonArrow)
            case "Widget-SquaredButton":
                return .success(.widgetSquaredButton)
            case "Widget-BannerBlock":
                return .success(.widgetBanner)
            case "Widget-BlockSquareLeftIconHeader":
                return .success(.widgetSquareLeftIconHeader)
            case "Widget-BlockSquareIconHeaderCenter":
                return .success(.widgetSquareIconHeaderCenter)
            case "Widget-BlockImageTextLink":
                return .success(.widgetImageTextLink)
            case "Widget-RowImageHeaderDescriptionButtonBlock":
                return .success(.widgetRowImageHeaderDescriptionButton)
            case "Widget-DraftCalculation":
                return .success(.widgetDraftCalculation)
            case "Widget-RowImagesTitleBlock":
                return .success(.widgetRowImagesTitleBlock)
            case "Widget-Image":
                return .success(.widgetImage)
            case "Widget-NavigateBlock":
                return .success(.widgetNavigate)
            case "Widget-TitleImageButtonLeftAlignBlock":
                return .success(.widgetTitleImageButtonLeftAlign)
            case "Widget-BlockTagImage":
                return .success(.widgetTagImage)
            case "Widget-List":
                return .success(.widgetList)
            case "Widget-BlockLinkedText":
                return .success(.widgetLinkedText)
            case "Widget-TextButtonCheckboxBlock":
                return .success(.widgetTextButtonCheckbox)
            case "Widget-BlockImageTextDescriptionButton":
                return .success(.widgetImageTextDescriptionButton)
            case "Widget-RowImageHeaderDescriptionArrowBlock":
                return .success(.widgetRowImageHeaderDescriptionArrow)
            case "Widget-TitleButtonBlock":
                return .success(.widgetTitleButton)
            case "Widget-ButtonListBlock":
                return .success(.widgetButtonList)
            case "Widget-HeaderIcon":
                return .success(.widgetHeaderIcon)
            case "Widget-TwoColumnListBlock":
                return .success(.widgetTwoColumnListBlock)
            case "Widget-InputCheckbox":
                return .success(.widgetInputCheckbox)
            case "Widget-BlockIconTextTagCircle":
                return .success(.widgetBlockIconTextTagCircle)
            case "Widget-Tag":
                return .success(.widgetTag)
            case "Widget-VerticalCustomRadiobuttonBlock":
                return .success(.widgetVerticalCustomRadioButtonBlock)
            case "Widget-BlockIconTitleDescriptionArrow":
                return .success(.widgetBlockIconTitleDescriptionArrow)
            case "Widget-InputText":
                return .success(.widgetInputText)
            case "Widget-InputNumbers":
                return .success(.widgetInputNumbers)
            case "Widget-InputPhone":
                return .success(.widgetInputPhone)
            case "Widget-InputEmail":
                return .success(.widgetInputEmail)
            case "Widget-InputTextarea":
                return .success(.widgetInputTextarea)
            case "Widget-InputDate":
                return .success(.widgetInputDate)
            case "Widget-InputTime":
                return .success(.widgetInputTime)
            case "Widget-InputTextHeaderLeft":
                return .success(.widgetInputTextHeaderLeft)
            case "Widget-InputLocation":
                return .success(.widgetInputLocation)
            case "Widget-InputLocation":
                return .success(.widgetTitleIconsTextList)
            case "Widget-InputList":
                return .success(.widgetInputList)
            case "Widget-InputListSearchable":
                return .success(.widgetInputListSearchable)
            case "Widget-InputBankDadata":
                return .success(.widgetInputBankDadata)
            case "InlineWidget-ImageButton":
                return .success(.inlineWidgetImageButton)
            case "InlineWidget-TextButton":
                return .success(.inlineWidgetTextButton)
            case "Action-FlowBills":
                return .success(.actionFlowBills)
            case "Action-FlowClinics":
                return .success(.actionFlowClinics)
            case "Action-FlowGaranteeLetters":
                return .success(.actionFlowGaranteeLetters)
            case "Action-FlowDoctorAppointments":
                return .success(.actionFlowDoctorAppointments)
            case "Action-FlowDoctorAppointment":
                return .success(.actionFlowDoctorAppointment)
            case "Action-FlowInstruction":
                return .success(.actionFlowInstruction)
            case "Action-FlowMedicalFileStorage":
                return .success(.actionFlowMedicalFileStorage)
            case "Action-ScreenRender":
                return .success(.actionScreenRender)
            case "Action-Phone":
                return .success(.actionPhone)
            case "Action-Webview":
                return .success(.actionWebView)
            case "Action-ScreenRequest":
                return .success(.actionScreenRequest)
            case "Action-FlowChat":
                return .success(.actionFlowChat)
            case "Action-FlowTelemed":
                return .success(.actionFLowTelemed)
            case "Action-FlowVirtualAssistant":
                return .success(.actionFlowVirtualAssistant)
            case "Action-FlowFranchise":
                return .success(.actionFlowFranchise)
            case "Action-FlowHelpBlocks":
                return .success(.actionFlowHelpBlocks)
            case "Action-FlowCompensation":
                return .success(.actionFlowCompensation)
            case "Action-FlowNotifications":
                return .success(.actionFlowNotifications)
            case "Action-Multi":
                return .success(.actionMulti)
            case "Action-LayoutReplace":
                return .success(.actionLayoutReplace)
            case "Action-LayoutReplaceAsync":
                return .success(.actionLayoutReplaceAsync)
            case "Action-LayoutRequest":
                return .success(.actionLayoutRequest)
            case "Action-LayoutFilter":
                return .success(.actionLayoutFilter)
            case "Action-FlowLoyalty":
                return .success(.actionFlowLoyalty)
            case "Action-NavigateBack":
                return .success(.actionNavigateBack)
            case "Action-FlowInsurance":
                return .success(.actionFlowInsurance)
            case "Action-FlowBillsPay":
                return .success(.actionFlowBillsPay)
            case "Action-FlowBill":
                return .success(.actionFlowBill)
            case "Action-FlowActivation":
                return .success(.actionFlowActivation)
            case "Action-FlowFindInsurance":
                return .success(.actionFlowFindInsurance)
            case "Action-ActionRequest":
                return .success(.actionActionRequest)
            case "Action-FlowDraftCalculations":
                return .success(.actionFlowDraftCalculations)
            case "Action-FlowQuestion":
                return .success(.actionFlowQuestion)
            case "Action-FlowQuestions":
                return .success(.actionFlowQuestions)
            case "Action-MainPageToNativeRender":
                return .success(.actionMainPageToNativeRender)
            case "Action-FlowOffices":
                return .success(.actionFlowOffices)
            case "Action-NavigateToProducts":
                return .success(.actionFlowProducts)
            case "Action-DraftDelete":
                return .success(.actionDraftDelete)
            case "Action-FlowEventReport-NS":
                return .success(.actionFlowEventReportNS)
            case "Action-FlowEventReport-Osago":
                return .success(.actionFlowEventReportOsago)
            case "Action-FlowEventReport-Kasko":
                return .success(.actionFlowEventReportKasko)
            case "Action-FlowEuroprotocol-Osago":
                return .success(.actionFlowEuroprotocolOsago)
            case "Action-FlowInternetCall":
                return .success(.actionFlowInternetCall)
            case "Action-FlowProlongation-Osago":
                return .success(.actionFlowProlongationOsago)
            case "Action-FlowProlongation-Kasko":
                return .success(.actionFlowProlongationKasko)
            case "Action-FlowProlongation-AlfaRepair":
                return .success(.actionFlowProlongationAlfaRepair)
            case "Action-FlowProlongation-KindNeighbors":
                return .success(.actionFlowProlongationKindNeighbors)
            case "Action-FlowDoctorHomeRequest":
                return .success(.actionFlowDoctorHomeRequest)
            case "Action-Nothing":
                return .success(.actionNothing)
            case "Action-Alert":
                return .success(.actionAlert)
            case "Action-FlowEditProfile":
                return .success(.actionEditProfile)
            case "Action-FlowChangeSessionType":
                return .success(.actionFlowChangeSessionType)
            case "Action-FlowExit":
                return .success(.actionFlowExit)
            case "Action-FlowAboutApp":
                return .success(.actionFlowAboutApp)
            case "Action-FlowAppSettings":
                return .success(.actionFlowAppSettings)
            case "Action-FlowTheme":
                return .success(.actionFlowTheme)
            case "Action-FlowViewEventReports-Auto":
                return .success(.actionFlowViewEventReportsAuto)
            case "Action-ScreenReplace":
                return .success(.actionScreenReplace)
            case "Action-FlowOsagoPhotoUpload":
                return .success(.actionFlowOsagoPhotoUpload)
            case "Action-FlowOsagoSchemeAuto":
                return .success(.actionFlowOsagoSchemeAuto)
            case "localActionStories":
                return .success(.localActionStories)
            case "none":
                return .success(.none)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .bottomWidgets:
                return transformer.transform(destination: "Bottom-Widgets")
            case .headerOneButton:
                return transformer.transform(destination: "Header-OneButton")
            case .headerAlignLeftOneButtonDescription:
                return transformer.transform(destination: "Header-AlignLeftOneButtonDescription")
            case .headerTwoButtons:
                return transformer.transform(destination: "Header-TwoButtons")
            case .layoutOneColumn:
                return transformer.transform(destination: "Layout-OneColumn")
            case .layoutTwoColumns:
                return transformer.transform(destination: "Layout-TwoColumns")
            case .layoutHorizontalScroll:
                return transformer.transform(destination: "Layout-HorizontalScroll")
            case .layoutCollapse:
                return transformer.transform(destination: "Layout-Collapse")
            case .layoutHorizontalCarousel:
                return transformer.transform(destination: "Layout-HorizontalCarousel")
            case .layoutBottom:
                return transformer.transform(destination: "Bottom-Layout")
            case .screenBasic:
                return transformer.transform(destination: "Screen-Basic")
            case .screenBottomToolbar:
                return transformer.transform(destination: "Screen-BottomToolbar")
            case .screenModal:
                return transformer.transform(destination: "Screen-Modal")
            case .widgetBlockTag:
                return transformer.transform(destination: "Widget-BlockTag")
            case .widgetBlockSquareIconHeaderDescription:
                return transformer.transform(destination: "Widget-BlockSquareIconHeaderDescription")
            case .widgetButton:
                return transformer.transform(destination: "Widget-Button")
            case .widgetInformation:
                return transformer.transform(destination: "Widget-Information")
            case .widgetInsuranceBlock:
                return transformer.transform(destination: "Widget-InsuranceBlock")
            case .widgetHeader:
                return transformer.transform(destination: "Widget-Header")
            case .widgetRowIconBlock:
                return transformer.transform(destination: "Widget-RowIconBlock")
            case .widgetRowIcons:
                return transformer.transform(destination: "Widget-RowIcons")
            case .widgetIconCounter:
                return transformer.transform(destination: "Widget-IconCounter")
            case .widgetRowIconDescription:
                return transformer.transform(destination: "Widget-RowIconBlockDescription")
            case .widgetStories:
                return transformer.transform(destination: "Widget-StoriesBlock")
            case .widgetFilterItem:
                return transformer.transform(destination: "Widget-FilterBlockItem")
            case .widgetFilterEventItem:
                return transformer.transform(destination: "Widget-FilterBlockEventItem")
            case .widgetTextButtonArrow:
                return transformer.transform(destination: "Widget-TextButtonArrowBlock")
            case .widgetSquaredButton:
                return transformer.transform(destination: "Widget-SquaredButton")
            case .widgetBanner:
                return transformer.transform(destination: "Widget-BannerBlock")
            case .widgetSquareLeftIconHeader:
                return transformer.transform(destination: "Widget-BlockSquareLeftIconHeader")
            case .widgetSquareIconHeaderCenter:
                return transformer.transform(destination: "Widget-BlockSquareIconHeaderCenter")
            case .widgetImageTextLink:
                return transformer.transform(destination: "Widget-BlockImageTextLink")
            case .widgetRowImageHeaderDescriptionButton:
                return transformer.transform(destination: "Widget-RowImageHeaderDescriptionButtonBlock")
            case .widgetDraftCalculation:
                return transformer.transform(destination: "Widget-DraftCalculation")
            case .widgetRowImagesTitleBlock:
                return transformer.transform(destination: "Widget-RowImagesTitleBlock")
            case .widgetImage:
                return transformer.transform(destination: "Widget-Image")
            case .widgetNavigate:
                return transformer.transform(destination: "Widget-NavigateBlock")
            case .widgetTitleImageButtonLeftAlign:
                return transformer.transform(destination: "Widget-TitleImageButtonLeftAlignBlock")
            case .widgetTagImage:
                return transformer.transform(destination: "Widget-BlockTagImage")
            case .widgetList:
                return transformer.transform(destination: "Widget-List")
            case .widgetLinkedText:
                return transformer.transform(destination: "Widget-BlockLinkedText")
            case .widgetTextButtonCheckbox:
                return transformer.transform(destination: "Widget-TextButtonCheckboxBlock")
            case .widgetImageTextDescriptionButton:
                return transformer.transform(destination: "Widget-BlockImageTextDescriptionButton")
            case .widgetRowImageHeaderDescriptionArrow:
                return transformer.transform(destination: "Widget-RowImageHeaderDescriptionArrowBlock")
            case .widgetTitleButton:
                return transformer.transform(destination: "Widget-TitleButtonBlock")
            case .widgetButtonList:
                return transformer.transform(destination: "Widget-ButtonListBlock")
            case .widgetHeaderIcon:
                return transformer.transform(destination: "Widget-HeaderIcon")
            case .widgetTwoColumnListBlock:
                return transformer.transform(destination: "Widget-TwoColumnListBlock")
            case .widgetInputCheckbox:
                return transformer.transform(destination: "Widget-InputCheckbox")
            case .widgetBlockIconTextTagCircle:
                return transformer.transform(destination: "Widget-BlockIconTextTagCircle")
            case .widgetTag:
                return transformer.transform(destination: "Widget-Tag")
            case .widgetVerticalCustomRadioButtonBlock:
                return transformer.transform(destination: "Widget-VerticalCustomRadiobuttonBlock")
            case .widgetBlockIconTitleDescriptionArrow:
                return transformer.transform(destination: "Widget-BlockIconTitleDescriptionArrow")
            case .widgetInputText:
                return transformer.transform(destination: "Widget-InputText")
            case .widgetInputNumbers:
                return transformer.transform(destination: "Widget-InputNumbers")
            case .widgetInputPhone:
                return transformer.transform(destination: "Widget-InputPhone")
            case .widgetInputEmail:
                return transformer.transform(destination: "Widget-InputEmail")
            case .widgetInputTextarea:
                return transformer.transform(destination: "Widget-InputTextarea")
            case .widgetInputDate:
                return transformer.transform(destination: "Widget-InputDate")
            case .widgetInputTime:
                return transformer.transform(destination: "Widget-InputTime")
            case .widgetInputTextHeaderLeft:
                return transformer.transform(destination: "Widget-InputTextHeaderLeft")
            case .widgetInputLocation:
                return transformer.transform(destination: "Widget-InputLocation")
            case .widgetTitleIconsTextList:
                return transformer.transform(destination: "Widget-InputLocation")
            case .widgetInputList:
                return transformer.transform(destination: "Widget-InputList")
            case .widgetInputListSearchable:
                return transformer.transform(destination: "Widget-InputListSearchable")
            case .widgetInputBankDadata:
                return transformer.transform(destination: "Widget-InputBankDadata")
            case .inlineWidgetImageButton:
                return transformer.transform(destination: "InlineWidget-ImageButton")
            case .inlineWidgetTextButton:
                return transformer.transform(destination: "InlineWidget-TextButton")
            case .actionFlowBills:
                return transformer.transform(destination: "Action-FlowBills")
            case .actionFlowClinics:
                return transformer.transform(destination: "Action-FlowClinics")
            case .actionFlowGaranteeLetters:
                return transformer.transform(destination: "Action-FlowGaranteeLetters")
            case .actionFlowDoctorAppointments:
                return transformer.transform(destination: "Action-FlowDoctorAppointments")
            case .actionFlowDoctorAppointment:
                return transformer.transform(destination: "Action-FlowDoctorAppointment")
            case .actionFlowInstruction:
                return transformer.transform(destination: "Action-FlowInstruction")
            case .actionFlowMedicalFileStorage:
                return transformer.transform(destination: "Action-FlowMedicalFileStorage")
            case .actionScreenRender:
                return transformer.transform(destination: "Action-ScreenRender")
            case .actionPhone:
                return transformer.transform(destination: "Action-Phone")
            case .actionWebView:
                return transformer.transform(destination: "Action-Webview")
            case .actionScreenRequest:
                return transformer.transform(destination: "Action-ScreenRequest")
            case .actionFlowChat:
                return transformer.transform(destination: "Action-FlowChat")
            case .actionFLowTelemed:
                return transformer.transform(destination: "Action-FlowTelemed")
            case .actionFlowVirtualAssistant:
                return transformer.transform(destination: "Action-FlowVirtualAssistant")
            case .actionFlowFranchise:
                return transformer.transform(destination: "Action-FlowFranchise")
            case .actionFlowHelpBlocks:
                return transformer.transform(destination: "Action-FlowHelpBlocks")
            case .actionFlowCompensation:
                return transformer.transform(destination: "Action-FlowCompensation")
            case .actionFlowNotifications:
                return transformer.transform(destination: "Action-FlowNotifications")
            case .actionMulti:
                return transformer.transform(destination: "Action-Multi")
            case .actionLayoutReplace:
                return transformer.transform(destination: "Action-LayoutReplace")
            case .actionLayoutReplaceAsync:
                return transformer.transform(destination: "Action-LayoutReplaceAsync")
            case .actionLayoutRequest:
                return transformer.transform(destination: "Action-LayoutRequest")
            case .actionLayoutFilter:
                return transformer.transform(destination: "Action-LayoutFilter")
            case .actionFlowLoyalty:
                return transformer.transform(destination: "Action-FlowLoyalty")
            case .actionNavigateBack:
                return transformer.transform(destination: "Action-NavigateBack")
            case .actionFlowInsurance:
                return transformer.transform(destination: "Action-FlowInsurance")
            case .actionFlowBillsPay:
                return transformer.transform(destination: "Action-FlowBillsPay")
            case .actionFlowBill:
                return transformer.transform(destination: "Action-FlowBill")
            case .actionFlowActivation:
                return transformer.transform(destination: "Action-FlowActivation")
            case .actionFlowFindInsurance:
                return transformer.transform(destination: "Action-FlowFindInsurance")
            case .actionActionRequest:
                return transformer.transform(destination: "Action-ActionRequest")
            case .actionFlowDraftCalculations:
                return transformer.transform(destination: "Action-FlowDraftCalculations")
            case .actionFlowQuestion:
                return transformer.transform(destination: "Action-FlowQuestion")
            case .actionFlowQuestions:
                return transformer.transform(destination: "Action-FlowQuestions")
            case .actionMainPageToNativeRender:
                return transformer.transform(destination: "Action-MainPageToNativeRender")
            case .actionFlowOffices:
                return transformer.transform(destination: "Action-FlowOffices")
            case .actionFlowProducts:
                return transformer.transform(destination: "Action-NavigateToProducts")
            case .actionDraftDelete:
                return transformer.transform(destination: "Action-DraftDelete")
            case .actionFlowEventReportNS:
                return transformer.transform(destination: "Action-FlowEventReport-NS")
            case .actionFlowEventReportOsago:
                return transformer.transform(destination: "Action-FlowEventReport-Osago")
            case .actionFlowEventReportKasko:
                return transformer.transform(destination: "Action-FlowEventReport-Kasko")
            case .actionFlowEuroprotocolOsago:
                return transformer.transform(destination: "Action-FlowEuroprotocol-Osago")
            case .actionFlowInternetCall:
                return transformer.transform(destination: "Action-FlowInternetCall")
            case .actionFlowProlongationOsago:
                return transformer.transform(destination: "Action-FlowProlongation-Osago")
            case .actionFlowProlongationKasko:
                return transformer.transform(destination: "Action-FlowProlongation-Kasko")
            case .actionFlowProlongationAlfaRepair:
                return transformer.transform(destination: "Action-FlowProlongation-AlfaRepair")
            case .actionFlowProlongationKindNeighbors:
                return transformer.transform(destination: "Action-FlowProlongation-KindNeighbors")
            case .actionFlowDoctorHomeRequest:
                return transformer.transform(destination: "Action-FlowDoctorHomeRequest")
            case .actionNothing:
                return transformer.transform(destination: "Action-Nothing")
            case .actionAlert:
                return transformer.transform(destination: "Action-Alert")
            case .actionEditProfile:
                return transformer.transform(destination: "Action-FlowEditProfile")
            case .actionFlowChangeSessionType:
                return transformer.transform(destination: "Action-FlowChangeSessionType")
            case .actionFlowExit:
                return transformer.transform(destination: "Action-FlowExit")
            case .actionFlowAboutApp:
                return transformer.transform(destination: "Action-FlowAboutApp")
            case .actionFlowAppSettings:
                return transformer.transform(destination: "Action-FlowAppSettings")
            case .actionFlowTheme:
                return transformer.transform(destination: "Action-FlowTheme")
            case .actionFlowViewEventReportsAuto:
                return transformer.transform(destination: "Action-FlowViewEventReports-Auto")
            case .actionScreenReplace:
                return transformer.transform(destination: "Action-ScreenReplace")
            case .actionFlowOsagoPhotoUpload:
                return transformer.transform(destination: "Action-FlowOsagoPhotoUpload")
            case .actionFlowOsagoSchemeAuto:
                return transformer.transform(destination: "Action-FlowOsagoSchemeAuto")
            case .localActionStories:
                return transformer.transform(destination: "localActionStories")
            case .none:
                return transformer.transform(destination: "none")
        }
    }
}
