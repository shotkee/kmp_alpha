//
//  OsagoProlongationCalculate.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongation {
    var state: OsagoProlongation.StateType

    // sourcery: transformer.name = "calc_info"
    var calculateInfo: OsagoProlongationCalculateInfo?

    // sourcery: transformer.name = "error_info"
    var errorInfo: OsagoProlongationErrorInfo?

    // sourcery: transformer.name = "edit_info"
    var editInfo: OsagoProlongationEditInfo?

    var info: OsagoProlongation.OsagoProlongationInfo {
        switch state {
            case .unsupported:
                return .unsupported

            case .inProcessed:
                return .inProcessed

            case .success:
                guard let calculateInfo = calculateInfo else { return .unsupported }

                return .success(info: calculateInfo)

            case .failure:
                guard let errorInfo = errorInfo else { return .unsupported }

                return .failure(errorInfo: errorInfo)

            case .error:
                guard let errorInfo = errorInfo, let editInfo = editInfo else { return .unsupported }

                return .error(errorInfo: errorInfo, editInfo: editInfo)
        }
    }

    // sourcery: enumTransformer
    enum StateType: Int {
        // sourcery: defaultCase
        case unsupported = -1
        case success = 0
        case failure = 1
        case error = 2
        case inProcessed = 3
    }

    enum OsagoProlongationInfo {
        case unsupported
        case inProcessed
        case success(info: OsagoProlongationCalculateInfo)
        case failure(errorInfo: OsagoProlongationErrorInfo)
        case error(errorInfo: OsagoProlongationErrorInfo, editInfo: OsagoProlongationEditInfo)

    }
}
