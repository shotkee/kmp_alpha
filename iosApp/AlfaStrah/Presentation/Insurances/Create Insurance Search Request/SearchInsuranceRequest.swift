//
//  SearchInsuranceRequest.swift
//  AlfaStrah
//
//  Created by Станислав Старжевский on 04.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Foundation

/// https://redmadrobot.atlassian.net/wiki/spaces/AL/pages/217546825/21+InsuranceSearchPolicyRequest
struct SearchInsuranceRequest: Codable {
    enum State: String, RawRepresentable, Codable {
        case unconfirmed = "UNCONFIRMED"
        case confirmed = "CONFIRMED"
        case confirmedWithDelay = "CONFIRMED_DELAY"
        case processing = "PROCESSING"
        case wrongNumber = "NUMBER_WRONG"
        case notFound = "POLICY_NOT_FOUND"
        case personNotFound = "PERSON_NOT_FOUND"
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case insuranceNumber = "insurance_number"
        case imageURL = "image_url"
        case issueDate = "issue_date"
        case requestDate = "request_datetime"
        case state = "state"
        case plannedDate = "planned_date"
        case plannedDateMin = "planned_date_min"
        case productID = "type"
    }

    var id: ObjectId
    var insuranceNumber: String
    var imageURL: URL?
    var issueDate: Date?
    var requestDate: Date?
    var state: State
    var plannedDate: Date?
    var plannedDateMin: Date?
    var productID: Int

    init(from decoder: Decoder) throws {
        let dateFormatter = SearchInsuranceRequest.dateFormatter
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ObjectId.self, forKey: .id)
        insuranceNumber = try container.decode(String.self, forKey: .insuranceNumber)
        imageURL = try container.decode(URL?.self, forKey: .imageURL)
        state = try container.decode(State.self, forKey: .state)

        if let issueDateString = try container.decode(String?.self, forKey: .issueDate) {
            dateFormatter.dateFormat = SearchInsuranceRequest.issueDateFormat
            issueDate = dateFormatter.date(from: issueDateString)
        }

        if let plannedDateString = try container.decode(String?.self, forKey: .plannedDate) {
            dateFormatter.dateFormat = SearchInsuranceRequest.issueDateFormat
            plannedDate = dateFormatter.date(from: plannedDateString)
        }

        if let plannedDateMinString = try container.decode(String?.self, forKey: .plannedDateMin) {
            dateFormatter.dateFormat = SearchInsuranceRequest.issueDateFormat
            plannedDateMin = dateFormatter.date(from: plannedDateMinString)
        }

        if let requestDateString = try container.decode(String?.self, forKey: .requestDate) {
            dateFormatter.dateFormat = SearchInsuranceRequest.requestDateFormat
            requestDate = dateFormatter.date(from: requestDateString)
        }

        productID = try container.decode(Int.self, forKey: .productID)
    }

    init(
        id: String, insuranceNumber: String, imageURL: URL?, issueDate: Date?, requestDate: Date?, state: State, plannedDate: Date?,
        plannedDateMin: Date?, productID: Int
    ) {
        self.id = ObjectId(id)
        self.insuranceNumber = insuranceNumber
        self.imageURL = imageURL
        self.issueDate = issueDate
        self.requestDate = requestDate
        self.state = state
        self.plannedDate = plannedDate
        self.plannedDateMin = plannedDateMin
        self.productID = productID
    }

    static let requestDateFormat = "yyyy-MM-dd HH:mm:ss"
    static let issueDateFormat = "yyyy-MM-dd"
    static let outDateFormat = "dd.MM.yyyy"
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    var statusText: String? {
        switch state {
            case .unconfirmed:
                return "Неподтвержденный"
            case .processing:
                return "На обработке специалиста"
            case .notFound:
                return "Договор не найден"
            default:
                return nil
        }
    }

    var statusHintText: String? {
        let formatter = SearchInsuranceRequest.dateFormatter
        switch state {
            case .unconfirmed, .processing:
                guard let plannedDate = plannedDate else { return nil }

                formatter.dateFormat = SearchInsuranceRequest.outDateFormat
                let dateText = formatter.string(from: plannedDate)
                return "Ожидается подтверждение: \(dateText)"
            case .notFound:
                return "Обратитесь в место приобретения полиса"
            default:
                return nil
        }
    }

    var shouldBeShown: Bool {
        switch state {
            case .unconfirmed, .processing, .notFound:
                return true
            default:
                return false
        }
    }
}
