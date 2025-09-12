//
//  PhoneCallsService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

protocol PhoneCallsService {
    func requestCallback(_ callback: Callback, completion: @escaping (Result<CallbackResponse, AlfastrahError>) -> Void)
    func phoneListFromCallCenter(completion: @escaping (Result<[Phone], AlfastrahError>) -> Void)
}
