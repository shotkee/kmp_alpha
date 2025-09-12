//
//  OfficesService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

protocol OfficesService {
    func offices(completion: @escaping (Result<[Office], AlfastrahError>) -> Void)
    func cities(completion: @escaping (Result<[City], AlfastrahError>) -> Void)
}
