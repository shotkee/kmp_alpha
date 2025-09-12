//
//  ServiceDataManager
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/18/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

protocol ServiceDataManager {
    func applicationDidEnterBackground()
    func applicationWillTerminate()

    func subscribeForServicesUpdates(listener: @escaping () -> Void) -> Subscription
    func performActionsAfterAppIsReady()
    func update(progressHandler: @escaping (Double) -> Void, completion: @escaping () -> Void)
    func erase(logout: Bool)
}
