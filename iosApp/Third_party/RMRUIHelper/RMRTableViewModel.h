//
//  RMRTableViewModel.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 30/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

@import UIKit;


#pragma mark — Type def

/**
 Блок, который объект использует, чтобы вернуть полученные элементы
 */
typedef void(^RMRTableViewModelGetItemsSucces)(NSArray *items);

/**
 Блок, котороый объект использует в случае успешного удаления элемнтов
 */
typedef void(^RMRTableViewModelRemoveItemsSucces)(BOOL success);

/**
 Блок, который объект использует если возникла ошибка
 */
typedef void(^RMRTableViewModelFailure)(NSError *error);


/**
 Протокол для объектов, которые оборачивают бизнес логику для загрузки и удаления данных
 */
@protocol RMRTableViewModel <NSObject>

@required

/**
 Количество элементов на одной странице, при пострачиной загрузке.
 Если постраничная загрузка не требуется, необходимо возвращать 0.
 */
- (NSInteger)itemsRequestLimit;

/**
 Метод должен инициировать получение элементов с заданным offset
 */
- (void)getItemsOffset:(NSInteger)offset
            completion:(RMRTableViewModelGetItemsSucces)completion
               failure:(RMRTableViewModelFailure)failure;
/**
 Метод должен инициировать удаление указанных элементов
 */
- (void)removeItems:(NSArray *)itemsToRemove
        completion:(RMRTableViewModelRemoveItemsSucces)completion
           failure:(RMRTableViewModelFailure)failure;

@end
