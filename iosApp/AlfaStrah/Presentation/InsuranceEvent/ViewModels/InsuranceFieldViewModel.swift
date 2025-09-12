//
// Created by Roman Churkin on 03/08/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

struct InsuranceFieldViewModel {
    var insuranceField: InfoField
    var tapHandler: (() -> Void)?

    var title: String {
        insuranceField.title
    }

    var info: String {
        insuranceField.text
    }
}
