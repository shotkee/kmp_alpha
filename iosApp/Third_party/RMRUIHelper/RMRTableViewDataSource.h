//
//  RMRTableViewDataSource.h
//  RMRUIHelper
//
//  Created by Roman Churkin on 30/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

@import UIKit;

#import "RMRTableViewModel.h"
#import "RMRSelfCalculateHeightView.h"

@class RMRCell;
@class RMRTableView;
@class RMRTableViewDataSource;


#pragma mark — Type def

/**
 Блок для определения идентификатора ячейки для dataSource
 */
typedef NSString *(^RMRGetCellIdentifier)(RMRTableViewDataSource *dataSource, RMRTableView *tableView, id item);

/**
 Блок для конфигурирования cell под конкретный item
 */
typedef void(^RMRCellConfiguration)(RMRTableViewDataSource *dataSource, RMRCell *cell, id item);


#pragma mark — Delegate protocol

@protocol RMRTableViewDataSourceDelegate <NSObject>

@required

/**
 Метод, для проброса наверх ошибки
 */
- (void)tableDataSource:(RMRTableViewDataSource *)tableDataSource processErorr:(NSError *)error;


@optional

/**
 Метод, в котором delegate должен произвести реакцию на выбор item
 */
- (void)tableDataSource:(RMRTableViewDataSource *)tableDataSource
          actionForItem:(id)item;

/**
 Метод будет вызван, когда потребуется показать zero screen
 */
- (void)showZeroScreenForTableDataSource:(RMRTableViewDataSource *)tableDataSource;

/**
 Методя для анимации появления ячеек при заполнении пустой таблицы
 */
- (void)tableDataSource:(RMRTableViewDataSource *)tableDataSource
      animateCellInsert:(UITableViewCell *)cell
                atIndex:(NSInteger)index
             completion:(void (^)(BOOL finished))completion;

/**
 Метод для анимации удаления ячеек при установке items = 0
 */
- (void)tableDataSource:(RMRTableViewDataSource *)tableDataSource
      animateCellDelete:(UITableViewCell *)cell
                atIndex:(NSInteger)index
             completion:(void (^)(BOOL finished))completion;

/**
 Метод будет вызван, когда потребуется показать activity indicator
 */
- (void)tableDataSource:(RMRTableViewDataSource *)tableDataSource
  showActivityIndicator:(void(^)(BOOL finished))completion;

/**
 Метод будет вызван, когда потребуется спрятать activity indicator
 */
- (void)tableDataSource:(RMRTableViewDataSource *)tableDataSource
  hideActivityIndicator:(void(^)(BOOL finished))completion;

/**
 Метод вызывается после того, как список items обновился
 */
- (void)tableDataSourceItemsUpdate:(RMRTableViewDataSource *)tableDataSource;

/**
 Метод вызывается, когда изменился список выделенных ячеек
 */
- (void)tableDataSourceSelectionUpdate:(RMRTableViewDataSource *)tableDataSource;

@end


@interface RMRTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

#pragma mark — Properties

/**
 Объект, который инкапсулирует бизнес логику.
 */
@property (nonatomic, strong) id<RMRTableViewModel> tableViewModel;

@property (nonatomic, weak) id<RMRTableViewDataSourceDelegate> delegate;

/**
 View для заголовка первой (и в этом случае — единственной) секции таблицы
 */
@property (nonatomic, strong) UIView <RMRSelfCalculateHeightView> *sectionHeaderView;

/**
 Блок, который должен вернуть identifier для получения ячейки от таблицы.
 Рекомендуется использовать в этой роли имя класса ячейки.
 */
@property (nonatomic, copy) RMRGetCellIdentifier getCellIdentifierBlock;

/**
 Блок, который будет выполняьтся для конфигурирования ячейки
 */
@property (nonatomic, copy) RMRCellConfiguration configureCellBlock;

/**
 Цвет UI элементов, которыми управляет Table Data Source
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 Нужно ли прятать sectionHeaderView, если в таблице 0 items
 */
@property (nonatomic, assign) BOOL hideHeaderOnZeroItemsCount;

/**
 Элементы, которые представляет таблица в данный момент
 */
@property (nonatomic, copy, readonly) NSArray *items;


#pragma mark — Methods

/**
 Метод для инициализации Table Data Source

 @param tableView    таблица, для которой нужен Data Source
 @param viewModel    объект, который будет отвечать за бизнес логику
 @param pull2refresh необходимость в pull2refresh
 */
+ (instancetype)tableViewDataSourceForTable:(RMRTableView *)tableView
                                  withModel:(id<RMRTableViewModel>)viewModel
                       pullToRefreshEnabled:(BOOL)pull2refresh;

/**
 Запросить загрузку элементов, с заданным offset
 */
- (void)requestItemsWithOffset:(NSInteger)offset;

/**
 Запросить получение больше элементов
 */
- (void)requestMoreItems;

/**
 Очистить таблицу от элементов. Сбросить Table Data Source
 */
- (void)clearDatasourceCompletion:(void(^)(void))completion;

/**
 Удалить выделенные элементы из Table Data Source
 */
- (void)deleteSelectedItems;

/**
 Удалить все элементы из Table Data Source
 */
- (void)deleteAllItems;

@end
