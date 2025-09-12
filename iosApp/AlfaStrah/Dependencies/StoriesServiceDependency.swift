//
//  StoriesServiceDependency.swift
//  AlfaStrah
//
//  Created by Makson on 07.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

protocol StoriesServiceDependency {
    var storiesService: StoriesService! { get set }
}
