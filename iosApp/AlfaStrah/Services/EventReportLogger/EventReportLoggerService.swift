//
//  EventReportLoggerService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

protocol EventReportLoggerService: Updatable {
    func applicationDidBecomeActiveEvent()
    func applicationDidEnterBackgroundEvent()
    func applicationWillTerminateEvent()

    /// Collects logs for specified eventReportId and sends them to server
    func addLog(_ message: String, eventReportId: String?)
    /// Saves a log for an image saving failure and sends it with next created report
    func logAttachmentSavingFalure(_ message: String)
}
