//
//  BackendDrivenDmsServiceDependency.swift
//  AlfaStrah
//
//  Created by vit on 27.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

protocol BackendDrivenServiceDependency {
	var backendDrivenService: BDUI.BackendDrivenService! { get set }
}
