//
//  VoipCall.swift
//  AlfaStrah
//
//  Created by vit on 12.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct VoipCall: Entity, Equatable {
    // sourcery: transformer.name = "title"
    let title: String
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum InternalCallType: String {
        // sourcery: enumTransformer.value = "voximplant"
        case voximplant = "voximplant"
    }
    
    // sourcery: transformer.name = "type"
    let internalType: InternalCallType
    
    // sourcery: transformer.name = "data"
    let parameters: [String: Any]?
    
    enum ActionType: Equatable {
        case voxImplant(data: VoxImplantCallData)
        
        static func == (lhs: ActionType, rhs: ActionType) -> Bool {
            switch (lhs, rhs) {
                case (.voxImplant(let lhsData), .voxImplant(let rhsData)):
                    return lhsData == rhsData
                default:
                    return false
            }
        }
    }
    
    var type: ActionType? {
        guard let parameters
        else { return nil }
        
        switch internalType {
            case .voximplant:
                guard let voxImplantData = VoxImplantCallDataTransformer().transform(source: parameters).value
                else { return nil }
                
                return .voxImplant(data: voxImplantData)
        }
    }
    
    static func == (lhs: VoipCall, rhs: VoipCall) -> Bool {
        return lhs.internalType == rhs.internalType && lhs.type == rhs.type
    }
    
    init(title: String, type: ActionType) {
        self.title = title
        
        switch type {
            case .voxImplant(data: let voxImplantData):
               
                self.internalType = .voximplant
                
                let parametersResult = VoxImplantCallDataTransformer().transform(destination: voxImplantData)
                
                switch parametersResult {
                    case .success(let data):
                        if let parameters = data as? [String: Any] {
                            self.parameters = parameters
                        } else {
                            self.parameters = nil
                        }
                    case .failure:
                        self.parameters = nil
                }
        }
    }
    
    init(
        title: String,
        internalType: InternalCallType,
        parameters: [String: Any]?
    ) {
        self.title = title
        self.internalType = internalType
        self.parameters = parameters
    }
}
