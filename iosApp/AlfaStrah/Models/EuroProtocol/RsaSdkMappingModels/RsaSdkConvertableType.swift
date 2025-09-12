//
//  RsaSdkConvertableType.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

protocol RsaSdkConvertableType: AlfaToRsaConvertableType, AlfaFromRsaConvertableType {}

protocol AlfaToRsaConvertableType {
    associatedtype SdkType

    var sdkType: SdkType { get }
}

protocol AlfaFromRsaConvertableType {
    associatedtype SdkType

    static func convert(from sdkType: SdkType) -> Self
}
