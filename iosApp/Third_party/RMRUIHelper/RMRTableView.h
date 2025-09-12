//
//  RMRTableView.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 В реализацию зашита логика с автоматической загрузкой и регистрацией 
 в таблице ячеек в следующем порядке:

 — если в bundle существует nib с именем соответствующим cell identifier,
 то он будет зарегистрирован

 — если существует класс с именем соответствующем cell identifier,
 то он будет зарегистрирован
 
 — если ни одно из условий не выполнено, будет брошено исключение
 */
@interface RMRTableView : UITableView
@end
