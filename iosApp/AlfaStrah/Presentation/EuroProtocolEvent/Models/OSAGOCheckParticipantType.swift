//
//  OSAGOCheckParticipantType.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 08.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

enum OSAGOCheckParticipantType {
    case participantA(defaultDocument: SeriesAndNumberDocument?)
    case participantB(defaultDocument: SeriesAndNumberDocument?)

    var sectionTitle: String {
        switch self {
            case .participantA:
                return NSLocalizedString("insurance_euro_protocol_osago_main_participant_a_section_title", comment: "")
            case .participantB:
                return NSLocalizedString("insurance_euro_protocol_osago_main_participant_b_section_title", comment: "")
        }
    }

    var cardTitle: String {
        switch self {
            case .participantA:
                return NSLocalizedString("insurance_euro_protocol_osago_main_participant_a_title", comment: "")
            case .participantB:
                return NSLocalizedString("insurance_euro_protocol_osago_main_participant_b_title", comment: "")
        }
    }

    var cardPlaceholder: String {
        NSLocalizedString("insurance_euro_protocol_osago_main_participant_placeholder", comment: "")
    }

    var defaultSeriesAndNumber: SeriesAndNumberDocument? {
        switch self {
            case .participantA(let defaultDocument):
                return defaultDocument
            case .participantB(let defaultDocument):
                return defaultDocument
        }
    }

    var euroProtocolParticipant: EuroProtocolParticipant {
        switch self {
            case .participantA:
                return .participantA
            case .participantB:
                return .participantB
        }
    }

    func getParticipantInfo(_ dataSource: OSAGOCheckParticipants) -> OSAGOCheckParticipant? {
        switch self {
            case .participantA:
                return dataSource.participantA
            case .participantB:
                return dataSource.participantB
        }
    }

    func getPolicyNumber(_ dataSource: EuroProtocolCurrentDraftContentModel?) -> String? {
        switch self {
            case .participantA:
                return dataSource?.participantA.policy.seriesAndNumber?.description
            case .participantB:
                return dataSource?.participantB.policy.seriesAndNumber?.description
        }
    }
}
