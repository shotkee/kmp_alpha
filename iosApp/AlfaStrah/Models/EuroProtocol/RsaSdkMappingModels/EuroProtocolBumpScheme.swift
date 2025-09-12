//
//  EuroProtocolBumpScheme.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

// swiftlint:disable identifier_name

protocol EuroProtocolFirstBumpScheme {
    var sdkFirstBumpType: FirstBumpSchemeType { get }
    init?(viewTags: [Int])
    var viewTags: [Int] { get }
    // TODO: Remove this init after SDK is updated accordingly
    init?(sectionValue: String)
}

enum EuroProtocolTruckScheme: EuroProtocolFirstBumpScheme, RsaSdkConvertableType {
    case pos_2
    case pos_3
    case pos_4
    case pos_5
    case pos_6
    case pos_7
    case pos_8
    case pos_9
    case pos_10
    case pos_11
    case pos_12
    case pos_1
    case pos_2_3
    case pos_3_4
    case pos_4_5
    case pos_5_6
    case pos_6_7
    case pos_7_8
    case pos_8_9
    case pos_9_10
    case pos_10_11
    case pos_11_12
    case pos_12_1
    case pos_1_2

    var sdkType: RSASDK.TruckSchemeType {
        switch self {
            case .pos_2:
                return .pos_2
            case .pos_3:
                return .pos_3
            case .pos_4:
                return .pos_4
            case .pos_5:
                return .pos_5
            case .pos_6:
                return .pos_6
            case .pos_7:
                return .pos_7
            case .pos_8:
                return .pos_8
            case .pos_9:
                return .pos_9
            case .pos_10:
                return .pos_10
            case .pos_11:
                return .pos_11
            case .pos_12:
                return .pos_12
            case .pos_1:
                return .pos_1
            case .pos_2_3:
                return .pos_2_3
            case .pos_3_4:
                return .pos_3_4
            case .pos_4_5:
                return .pos_4_5
            case .pos_5_6:
                return .pos_5_6
            case .pos_6_7:
                return .pos_6_7
            case .pos_7_8:
                return .pos_7_8
            case .pos_8_9:
                return .pos_8_9
            case .pos_9_10:
                return .pos_9_10
            case .pos_10_11:
                return .pos_10_11
            case .pos_11_12:
                return .pos_11_12
            case .pos_12_1:
                return .pos_12_1
            case .pos_1_2:
                return .pos_1_2
        }
    }

    var sdkFirstBumpType: FirstBumpSchemeType {
        sdkType
    }

    static func convert(from sdkType: RSASDK.TruckSchemeType) -> EuroProtocolTruckScheme {
        switch sdkType {
            case .pos_2:
                return .pos_2
            case .pos_3:
                return .pos_3
            case .pos_4:
                return .pos_4
            case .pos_5:
                return .pos_5
            case .pos_6:
                return .pos_6
            case .pos_7:
                return .pos_7
            case .pos_8:
                return .pos_8
            case .pos_9:
                return .pos_9
            case .pos_10:
                return .pos_10
            case .pos_11:
                return .pos_11
            case .pos_12:
                return .pos_12
            case .pos_1:
                return .pos_1
            case .pos_2_3:
                return .pos_2_3
            case .pos_3_4:
                return .pos_3_4
            case .pos_4_5:
                return .pos_4_5
            case .pos_5_6:
                return .pos_5_6
            case .pos_6_7:
                return .pos_6_7
            case .pos_7_8:
                return .pos_7_8
            case .pos_8_9:
                return .pos_8_9
            case .pos_9_10:
                return .pos_9_10
            case .pos_10_11:
                return .pos_10_11
            case .pos_11_12:
                return .pos_11_12
            case .pos_12_1:
                return .pos_12_1
            case .pos_1_2:
                return .pos_1_2
            @unknown default:
                fatalError("Unknown type")
        }
    }
}

public enum EuroProtocolCarScheme: EuroProtocolFirstBumpScheme, RsaSdkConvertableType {
    case pos_3
    case pos_4
    case pos_5
    case pos_6
    case pos_7
    case pos_8
    case pos_9
    case pos_10
    case pos_11
    case pos_12
    case pos_13
    case pos_14
    case pos_1
    case pos_2
    case pos_3_4
    case pos_4_5
    case pos_5_6
    case pos_6_7
    case pos_7_8
    case pos_8_9
    case pos_9_10
    case pos_10_11
    case pos_11_12
    case pos_12_13
    case pos_13_14
    case pos_14_1
    case pos_1_2
    case pos_2_3

    var sdkType: RSASDK.CarSchemeType {
        switch self {
            case .pos_3:
                return .pos_3
            case .pos_4:
                return .pos_4
            case .pos_5:
                return .pos_5
            case .pos_6:
                return .pos_6
            case .pos_7:
                return .pos_7
            case .pos_8:
                return .pos_8
            case .pos_9:
                return .pos_9
            case .pos_10:
                return .pos_10
            case .pos_11:
                return .pos_11
            case .pos_12:
                return .pos_12
            case .pos_13:
                return .pos_13
            case .pos_14:
                return .pos_14
            case .pos_1:
                return .pos_1
            case .pos_2:
                return .pos_2
            case .pos_3_4:
                return .pos_3_4
            case .pos_4_5:
                return .pos_4_5
            case .pos_5_6:
                return .pos_5_6
            case .pos_6_7:
                return .pos_6_7
            case .pos_7_8:
                return .pos_7_8
            case .pos_8_9:
                return .pos_8_9
            case .pos_9_10:
                return .pos_9_10
            case .pos_10_11:
                return .pos_10_11
            case .pos_11_12:
                return .pos_11_12
            case .pos_12_13:
                return .pos_12_13
            case .pos_13_14:
                return .pos_13_14
            case .pos_14_1:
                return .pos_14_1
            case .pos_1_2:
                return .pos_1_2
            case .pos_2_3:
                return .pos_2_3
        }
    }

    var sdkFirstBumpType: FirstBumpSchemeType {
        sdkType
    }

    static func convert(from sdkType: RSASDK.CarSchemeType) -> EuroProtocolCarScheme {
        switch sdkType {
            case .pos_3:
                return .pos_3
            case .pos_4:
                return .pos_4
            case .pos_5:
                return .pos_5
            case .pos_6:
                return .pos_6
            case .pos_7:
                return .pos_7
            case .pos_8:
                return .pos_8
            case .pos_9:
                return .pos_9
            case .pos_10:
                return .pos_10
            case .pos_11:
                return .pos_11
            case .pos_12:
                return .pos_12
            case .pos_13:
                return .pos_13
            case .pos_14:
                return .pos_14
            case .pos_1:
                return .pos_1
            case .pos_2:
                return .pos_2
            case .pos_3_4:
                return .pos_3_4
            case .pos_4_5:
                return .pos_4_5
            case .pos_5_6:
                return .pos_5_6
            case .pos_6_7:
                return .pos_6_7
            case .pos_7_8:
                return .pos_7_8
            case .pos_8_9:
                return .pos_8_9
            case .pos_9_10:
                return .pos_9_10
            case .pos_10_11:
                return .pos_10_11
            case .pos_11_12:
                return .pos_11_12
            case .pos_12_13:
                return .pos_12_13
            case .pos_13_14:
                return .pos_13_14
            case .pos_14_1:
                return .pos_14_1
            case .pos_1_2:
                return .pos_1_2
            case .pos_2_3:
                return .pos_2_3
            @unknown default:
                fatalError("Unknown type")
        }
    }
}

enum EuroProtocolBikeScheme: EuroProtocolFirstBumpScheme, RsaSdkConvertableType {
    case pos_1
    case pos_2
    case pos_3
    case pos_4

    var sdkType: RSASDK.BikeSchemeType {
        switch self {
            case .pos_1:
                return .pos_1
            case .pos_2:
                return .pos_2
            case .pos_3:
                return .pos_3
            case .pos_4:
                return .pos_4
        }
    }

    var sdkFirstBumpType: FirstBumpSchemeType {
        sdkType
    }

    static func convert(from sdkType: RSASDK.BikeSchemeType) -> EuroProtocolBikeScheme {
        switch sdkType {
            case .pos_1:
                return .pos_1
            case .pos_2:
                return .pos_2
            case .pos_3:
                return .pos_3
            case .pos_4:
                return .pos_4
            @unknown default:
                fatalError("Unknown type")
        }
    }
}
