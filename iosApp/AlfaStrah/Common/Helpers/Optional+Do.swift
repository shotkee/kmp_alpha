//
//  Optional+Do
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

public extension Optional {
    @discardableResult
    func `do`(_ action: (Wrapped) throws -> Void) rethrows -> Optional {
        if let value = self {
            try action(value)
        }
        return self
    }
}
