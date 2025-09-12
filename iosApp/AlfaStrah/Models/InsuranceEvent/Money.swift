//
//  Money
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct Money {
    var currency: String

    /**
     Количество денег в валюте currency.
     Содержит цифру, измеренную наименьшим юнитом денег для данной валюты.
     Например, для валюты RUR наименьшим юнитом будут копейки, для USD — центы.
     Сто рублей будут переданы, как 10000 RUR (десять тысяч копеек).
     Сто долларов будут переданы, как 10000 USD (десять тысяч центов).
     */
    var amount: Int64
}
