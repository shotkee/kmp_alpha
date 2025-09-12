// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceServiceAvailabiltyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Insurance.ServiceAvailabilty

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "vzr_bonus_site":
                return .success(.vzrBonusPolicy)
            case "vzr_bonus_franchise_certificate_site":
                return .success(.vzrFranchiseCerificate)
            case "termination":
                return .success(.vzrTermination)
            case "kasko_expansion_site":
                return .success(.kaskoPolicyExtension)
            case "vzr_bonus_prepaid_refund":
                return .success(.vzrBonusRefundCertificate)
            case "web_termination":
                return .success(.osagoTermination)
            case "web_change":
                return .success(.osagoChange)
            case "dms_compensation_request":
                return .success(.dmsCostRecovery)
            case "academzdrav":
                return .success(.healthAcademy)
            case "medicalfilestorage":
                return .success(.medicalCard)
            case "ns_manage_subscription_site":
                return .success(.manageSubscription)
            case "ns_appoint_beneficiary_site":
                return .success(.appointBeneficiary)
            case "insurance_change_site":
                return .success(.editInsuranceAgreement)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .vzrBonusPolicy:
                return transformer.transform(destination: "vzr_bonus_site")
            case .vzrFranchiseCerificate:
                return transformer.transform(destination: "vzr_bonus_franchise_certificate_site")
            case .vzrTermination:
                return transformer.transform(destination: "termination")
            case .kaskoPolicyExtension:
                return transformer.transform(destination: "kasko_expansion_site")
            case .vzrBonusRefundCertificate:
                return transformer.transform(destination: "vzr_bonus_prepaid_refund")
            case .osagoTermination:
                return transformer.transform(destination: "web_termination")
            case .osagoChange:
                return transformer.transform(destination: "web_change")
            case .dmsCostRecovery:
                return transformer.transform(destination: "dms_compensation_request")
            case .healthAcademy:
                return transformer.transform(destination: "academzdrav")
            case .medicalCard:
                return transformer.transform(destination: "medicalfilestorage")
            case .manageSubscription:
                return transformer.transform(destination: "ns_manage_subscription_site")
            case .appointBeneficiary:
                return transformer.transform(destination: "ns_appoint_beneficiary_site")
            case .editInsuranceAgreement:
                return transformer.transform(destination: "insurance_change_site")
        }
    }
}
