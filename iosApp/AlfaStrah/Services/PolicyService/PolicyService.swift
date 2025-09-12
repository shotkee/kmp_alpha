//
//  PolicyService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 18/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import Legacy

protocol PolicyService: Updatable {
    func loadTelematicsPolicyHTML(completion: @escaping (Result<String, AlfastrahError>) -> Void)

    func getPersonalDataUsageTermsUrl(
        on screen: PolicyServiceScreen,
        completion: @escaping (Result<PersonalDataUsageAndPrivacyPolicyURLs, AlfastrahError>) -> Void
    )
    
    func registerTerms(completion: @escaping (Result<LinkedText, AlfastrahError>) -> Void)
}

enum PolicyServiceScreen: Int {
    case signUp = 1
    case osagoProlongation = 2
    case kaskoProlongation = 3
    case goodNeighborsAndAlphaRemontProlongation = 4
    case aboutApp = 5
}
