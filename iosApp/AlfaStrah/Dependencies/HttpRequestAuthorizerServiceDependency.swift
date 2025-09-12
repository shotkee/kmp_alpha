//
//  HttpRequestAuthorizerServiceDependency.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 13.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

protocol HttpRequestAuthorizerServiceDependency {
    var httpRequestAuthorizer: HttpRequestAuthorizer! { get set }
}
