//
//  OfficeTimetableHours.swift
//  AlfaStrah
//
//  Created by Darya Viter on 09.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Foundation

// sourcery: transformer
struct OfficeTimetableHours {
    // sourcery: transformer.name = "start_time"
    var startTime: String // Время начала работы "hh:mm"
    // sourcery: transformer.name = "close_time"
    var closeTime: String // Время окончания работы "hh:mm"
    // sourcery: transformer.name = "break_start_time"
    var breakStartTime: String? //  Начало перерыва "hh:mm"
    // sourcery: transformer.name = "break_end_time"
    var breakEndTime: String? // Окончание перерыва "hh:mm"
}
