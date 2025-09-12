//
//  InteractiveSupportService.swift
//  AlfaStrah
//
//  Created by vit on 18.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol InteractiveSupportService: Updatable {
    func onboarding(
        insuranceIds: [String],
        completion: @escaping (Result<[InteractiveSupportData], AlfastrahError>) -> Void
    )

    func questions(
        insuranceId: String,
        completion: @escaping (Result<InteractiveSupportQuestionsResponse, AlfastrahError>) -> Void
    )
    
    func applyResult(
        insuranceId: String,
        onboardingResultKey: String,
        completion: @escaping (Result<[InteractiveSupportQuestionnaireResult], AlfastrahError>) -> Void
    )
    
    func showOnboarding(insuranceId: String) -> Bool
    func onboardingWasShownForInsurance(with insuranceId: String)
}
