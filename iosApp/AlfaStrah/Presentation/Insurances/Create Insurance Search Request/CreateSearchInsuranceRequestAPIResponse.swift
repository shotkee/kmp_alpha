//
//  CreateSearchInsuranceRequestAPIResponse.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 05.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Foundation

struct CreateSearchInsuranceRequestAPIResponse: Codable {
    struct ResponseMap: Codable {
        enum CodingKeys: String, CodingKey {
            case request = "search_policy_request"
            case isNew = "is_new"
        }
        var request: SearchInsuranceRequest
        var isNew: Bool
    }
    var data: ResponseMap

    var request: SearchInsuranceRequest? {
        data.request
    }
}
