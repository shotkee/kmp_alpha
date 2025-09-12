//
//  VzrOnOffDashboardInfo.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/8/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct VzrOnOffDashboardInfo {
    var balance: Int
    // sourcery: transformer.name = "active_trip_list"
    var activeTripList: [VzrOnOffTrip]
}
