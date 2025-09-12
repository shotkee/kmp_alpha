//
// Configurator
// AlfaStrah
//
// Created by Eugene Egorov on 21 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

protocol Configurator {
    func create() -> DependencyInjectionContainer
}
