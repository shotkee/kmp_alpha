//
//  FakeSosController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

/// Фейковый контроллер для кнопки СОС в таб баре (нельзя добавить таб без связанного с ним экрана)
class FakeSosController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fatalError("Фейковый контроллер для кнопки СОС в таб баре не должен быть показан")
    }
}
