//
//  RMRTableViewDataSource.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 30/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "RMRTableViewDataSource.h"

// View
#import "RMRCell.h"
#import "RMRTableView.h"


@interface RMRTableViewDataSource ()

#pragma mark — Properties

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) NSIndexPath *loadRequestIndexPath;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL animateCells;
@property (nonatomic, strong) NSMutableDictionary *cellHeights;
@property (nonatomic, strong) RMRTableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *bottomActivityIndictor;

@end


@implementation RMRTableViewDataSource

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.bottomActivityIndictor.tintColor =
        self.refreshControl.tintColor = tintColor;
}

#pragma mark — Private helpers

- (void)showActivityIndicator:(void(^)(void))completion
{
    if ([self.delegate respondsToSelector:@selector(tableDataSource:showActivityIndicator:)]) {
        [self.delegate tableDataSource:self showActivityIndicator:^(BOOL finished) {
            if (completion) completion();
        }];
    } else if (completion) completion();
}

- (void)hideActivityIndicator:(void(^)(void))completion
{
    if ([self.delegate respondsToSelector:@selector(tableDataSource:hideActivityIndicator:)]) {
        [self.delegate tableDataSource:self hideActivityIndicator:^(BOOL finished) {
            if (completion) completion();
        }];
    } else if (completion) completion();
}

- (void)showBottomActivityIndicator:(void(^)(void))completion
{
    if (!self.bottomActivityIndictor) {
        self.bottomActivityIndictor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.bottomActivityIndictor.color = self.tintColor;
        self.bottomActivityIndictor.hidesWhenStopped = YES;
    }

    self.tableView.tableFooterView = self.bottomActivityIndictor;

    [self.bottomActivityIndictor startAnimating];

    if (completion) completion();
}

- (void)hideBottomActivityIndicator:(void(^)(void))completion
{
    [self.bottomActivityIndictor stopAnimating];
    if (completion) completion();
    return;
}

- (void)hideAllActivityIndicators:(void(^)(void))completion
{
    typeof(self) __weak weakSelf = self;
    [self.refreshControl endRefreshing];
    [self hideActivityIndicator:^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideBottomActivityIndicator:completion];
    }];
}

- (void)updateWithItems:(NSArray *)newItems
{
    BOOL animateCells = [self.items count] == 0;

    BOOL presentZeroScreen = !([self.items count] || [newItems count]);

    if (presentZeroScreen && [self.delegate respondsToSelector:@selector(showZeroScreenForTableDataSource:)]) {
        [self.delegate showZeroScreenForTableDataSource:self];
        return;
    }


    // Удаляем дубликаты, если они вдруг пришли
    NSMutableArray *mutableNewItems = [newItems mutableCopy];
    for (id item in self.items) [mutableNewItems removeObject:item];


    NSUInteger difference = [newItems count] - [mutableNewItems count];

    newItems = [NSArray arrayWithArray:mutableNewItems];

    if ([newItems count] == 0) {
        self.loadRequestIndexPath = nil;
        return;
    }


    if (self.items) self.items = [self.items arrayByAddingObjectsFromArray:newItems];
    else self.items = newItems;

    if ([self.delegate respondsToSelector:@selector(tableDataSourceItemsUpdate:)]) {
        [self.delegate tableDataSourceItemsUpdate:self];
    }

    NSInteger itemsToLoad = [self.tableViewModel itemsRequestLimit];

    if ([newItems count] + difference >= itemsToLoad) {
        NSInteger requestRowIndex = [self.items count] - 3;
        if (requestRowIndex > 0) {
            self.loadRequestIndexPath =
            [NSIndexPath indexPathForRow:requestRowIndex
                               inSection:0];
        }
    } else self.loadRequestIndexPath = nil;

    self.animateCells = animateCells;

    [self.tableView reloadData];
}

- (BOOL)needShowSectionHeaderForSection:(NSInteger)section
{
    if (!self.sectionHeaderView) return NO;
    else if (section == 0) {
        if ([self.items count]) return YES;
        else if (self.hideHeaderOnZeroItemsCount) return NO;
        else return YES;
    } else return NO;
}

- (void)clearAndReload:(id)sender
{
    typeof(self) __weak weakSelf = self;
    [self clearDatasourceCompletion:^{ [weakSelf requestItemsWithOffset:0]; }];
}

- (void)configurePullToRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = self.tintColor;
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self
                       action:@selector(clearAndReload:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSAssert(indexPaths.count, @"Не выбрано ни одного элемента!");

    NSArray *items = [self.items copy];

    NSArray *rowsToDelete = [indexPaths valueForKey:NSStringFromSelector(@selector(row))];

    NSMutableArray *itemsToDelete = [NSMutableArray arrayWithCapacity:rowsToDelete.count];
    for (NSNumber *rowIndex in rowsToDelete) {
        [itemsToDelete addObject:items[[rowIndex integerValue]]];
    }

    NSMutableArray *newItems = [items mutableCopy];
    NSMutableArray *indexPathsToDelete = [NSMutableArray arrayWithCapacity:rowsToDelete.count];
    for (NSNumber *rowIndex in rowsToDelete) {
        NSInteger index = [rowIndex integerValue];
        [newItems removeObject:items[index]];
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:index inSection:0]];

    }

    self.items = newItems;
    if ([self.delegate respondsToSelector:@selector(tableDataSourceItemsUpdate:)]) {
        [self.delegate tableDataSourceItemsUpdate:self];
    }

    UITableView *tableView = self.tableView;
    [tableView deleteRowsAtIndexPaths:indexPathsToDelete
                     withRowAnimation:UITableViewRowAnimationFade];

    typeof(self) __weak weakSelf = self;
    RMRTableViewModelFailure failure = ^(NSError *error) {
        [weakSelf hideAllActivityIndicators:^{
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.delegate tableDataSource:strongSelf processErorr:error];
        }];
    };

    [self.tableViewModel removeItems:itemsToDelete
                          completion:nil
                             failure:failure];

    if (self.items.count == 0 && [self.delegate respondsToSelector:@selector(showZeroScreenForTableDataSource:)]) {
        [self.delegate showZeroScreenForTableDataSource:self];
    }
}


#pragma mark — Public

+ (instancetype)tableViewDataSourceForTable:(RMRTableView *)tableView
                                  withModel:(id<RMRTableViewModel>)viewModel
                       pullToRefreshEnabled:(BOOL)pull2refresh
{
    RMRTableViewDataSource *tableDatasource = [RMRTableViewDataSource new];
    tableDatasource.hideHeaderOnZeroItemsCount = NO;
    tableDatasource.tableView = tableView;
    tableDatasource.tableViewModel = viewModel;
    tableDatasource.cellHeights = [NSMutableDictionary dictionary];
    tableDatasource.tintColor = tableView.tintColor;

    tableView.allowsMultipleSelectionDuringEditing = YES;

    if (pull2refresh) [tableDatasource configurePullToRefreshControl];

    return tableDatasource;
}

- (void)requestItemsWithOffset:(NSInteger)offset
{
    self.tableView.scrollEnabled = !self.refreshControl.refreshing;

    if (!self.refreshControl.refreshing) {
        if ([self.items count] == 0) [self showActivityIndicator:nil];
        else [self showBottomActivityIndicator:nil];
    }

    typeof(self) __weak weakSelf = self;

    RMRTableViewModelGetItemsSucces completion = ^(NSArray *items) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideAllActivityIndicators:^{
            [strongSelf updateWithItems:items];
            strongSelf.tableView.scrollEnabled = YES;
        }];
    };

    RMRTableViewModelFailure failure = ^(NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideAllActivityIndicators:^{
            strongSelf.tableView.scrollEnabled = YES;
            [strongSelf.delegate tableDataSource:strongSelf processErorr:error];
        }];
    };

    [self.tableViewModel getItemsOffset:offset completion:completion failure:failure];
}

- (void)requestMoreItems
{
    NSInteger offset = [self.items count];
    [self requestItemsWithOffset:offset];
}

- (void)clearDatasourceCompletion:(void(^)(void))completion;
{
    UITableView *tableView = self.tableView;

    if ([self.items count] == 0) {
        self.cellHeights = [NSMutableDictionary dictionary];
        [tableView reloadData];
        if (completion) completion();
        return;
    }

    void(^animationFinish)(BOOL finished) = ^(BOOL finished) {
        self.items = [NSArray array];
        self.cellHeights = [NSMutableDictionary dictionary];
        if ([self.delegate respondsToSelector:@selector(tableDataSourceItemsUpdate:)]) {
            [self.delegate tableDataSourceItemsUpdate:self];
        }
        [self.tableView reloadData];
        if (completion) completion();
    };

    NSArray *visibleCells = [tableView visibleCells];
    NSUInteger count = [visibleCells count];

    SEL deleteAnimationSelector = @selector(tableDataSource:animateCellDelete:atIndex:completion:);

    if ([self.delegate respondsToSelector:deleteAnimationSelector]) {
        for (NSInteger i = 0; i < count; i++) {
            UITableViewCell *cell = visibleCells[i];
            NSInteger index = [tableView indexPathForCell:cell].row;
            [self.delegate tableDataSource:self
                         animateCellDelete:cell
                                   atIndex:index
                                completion:count - 1 == i ? animationFinish : nil];
        }
    } else animationFinish(YES);
}

- (void)deleteAllItems
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.items.count];
    for (NSInteger i = 0; i < self.items.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self deleteItemsAtIndexPaths:indexPaths];
}

- (void)deleteSelectedItems
{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    [self deleteItemsAtIndexPaths:selectedIndexPaths];
}


#pragma mark — UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(RMRTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.getCellIdentifierBlock, @"Не задан блок, который возвращает cell identifier (getCellIdentifierBlock)");
    NSAssert(self.configureCellBlock, @"Не задан блок, который конфигурирует ячейку (configureCellBlock)");

    NSInteger index = indexPath.row;
    id item = self.items[index];

    RMRCell *cell =
        [tableView dequeueReusableCellWithIdentifier:
            self.getCellIdentifierBlock(self, tableView, item) forIndexPath:indexPath];
    self.configureCellBlock(self, cell, item);

    id heightKey = @(index);
    if (!self.cellHeights[heightKey]) {
        self.cellHeights[heightKey] =
            @([cell requiredHeightForWidth:CGRectGetHeight(tableView.bounds)]);
    }

    return cell;
}


#pragma mark — UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self needShowSectionHeaderForSection:section]) return self.sectionHeaderView;
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self needShowSectionHeaderForSection:section]) {
        return [self.sectionHeaderView requiredHeightForWidth:CGRectGetWidth(tableView.bounds)];
    } else return CGFLOAT_MIN;
}

- (CGFloat)tableView:(RMRTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.getCellIdentifierBlock, @"Не задан блок, который возвращает cell identifier (getCellIdentifierBlock)");
    NSAssert(self.configureCellBlock, @"Не задан блок, который конфигурирует ячейку (configureCellBlock)");

    NSInteger index = indexPath.row;
    id heightKey = @(index);

    NSNumber *height = self.cellHeights[heightKey];

    if (height) return [height floatValue];
    else {
        id item = self.items[index];

        RMRCell *cell =
            [tableView dequeueReusableCellWithIdentifier:
                self.getCellIdentifierBlock(self, tableView, item)];
        self.configureCellBlock(self, cell, item);

        CGFloat heightValue = [cell requiredHeightForWidth:CGRectGetWidth(tableView.bounds)];

        self.cellHeights[heightKey] = @(heightValue);

        return heightValue;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableDataSourceSelectionUpdate:)]) {
        [self.delegate tableDataSourceSelectionUpdate:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableDataSourceSelectionUpdate:)]) {
        [self.delegate tableDataSourceSelectionUpdate:self];
    }

    if (!tableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        id item = self.items[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(tableDataSource:actionForItem:)]) {
            [self.delegate tableDataSource:self actionForItem:item];
        }
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL insertAnimationSelector = @selector(tableDataSource:animateCellInsert:atIndex:completion:);

    BOOL animateInsert =
        self.animateCells
        && [self.delegate respondsToSelector:insertAnimationSelector];

    if (animateInsert) {
        [self.delegate tableDataSource:self
                     animateCellInsert:cell
                               atIndex:indexPath.row
                            completion:nil];
    }

    if (!self.loadRequestIndexPath) return;

    if ([indexPath isEqual:self.loadRequestIndexPath]) {
        self.loadRequestIndexPath = nil;
        [self requestMoreItems];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView { self.animateCells = NO; }

@end
