//
//  MobileGuidService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 06.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

protocol MobileGuidService: Updatable {
    var mobileGuid: String? { get }

    func updateMobileGuid(completion: @escaping (Result<String, AlfastrahError>) -> Void)
}
