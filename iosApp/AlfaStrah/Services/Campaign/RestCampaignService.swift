//
//  RestCampaignService.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 29/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class RestCampaignService: CampaignService {
    typealias ResultCallback = (Result<[Campaign], AlfastrahError>) -> Void
    
    private let rest: FullRestClient
    private var campaigns: [Campaign]?
    private var isCampaignsRequestInProgress: Bool = false
    private var completions: [ResultCallback]?

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func campaigns(completion: @escaping ResultCallback) {
        if let campaigns = campaigns {
            completion(.success(campaigns))
        } else {
            if !isCampaignsRequestInProgress {
                isCampaignsRequestInProgress = true
                rest.read(
                    path: "campaigns",
                    id: nil,
                    parameters: [:],
                    headers: [:],
                    responseTransformer: ResponseTransformer(
                        key: "campaign_list",
                        transformer: ArrayTransformer(transformer: CampaignTransformer())
                    ),
                    completion: mapCompletion{ [weak self] result in
                        guard let self = self
                        else { return }
                        
                        self.isCampaignsRequestInProgress = false
                        
                        switch result {
                            case .success(let campaigns):
                                self.campaigns = campaigns
                            case .failure:
                                break
                        }
                        completion(result)
                        
                        guard let completions = self.completions
                        else { return }
                        
                        completions.forEach{ $0(result) }
                        
                        self.completions = nil
                    }
                )
            } else {
                if self.completions == nil {
                    self.completions = []
                }
                
                self.completions?.append(completion)
            }
        }
    }
}
