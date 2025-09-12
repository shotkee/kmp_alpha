//
//  RMRTableView.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 27/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "RMRTableView.h"

// Helper
#import "NSString+RMRHelper.h"
#import "UINib+RMRHelper.h"


@implementation RMRTableView

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        [self RMR_loadAndRegisterCellWithIdentifier:identifier];
        cell = [super dequeueReusableCellWithIdentifier:identifier];
    }

    return cell;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    if (!cell) {
        [self RMR_loadAndRegisterCellWithIdentifier:identifier];
        cell = [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    }

    return cell;
}


#pragma mark - Private helper

- (void)RMR_loadAndRegisterCellWithIdentifier:(NSString *)cellIdentifier
{
    UINib *cellNib = [UINib RMR_nibWithNibName:cellIdentifier bundle:nil];
    if (!cellNib) {
        cellNib = [UINib RMR_nibWithNibName:cellIdentifier.pathExtension bundle:nil];
    }

    Class cellClass = NSClassFromString(cellIdentifier);

    if (cellNib) [self registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    else if (cellClass) [self registerClass:cellClass forCellReuseIdentifier:cellIdentifier];
    else {
        NSString *reason =
                [NSString RMR_exceptionReasonConstructor:[self class]
                                                 message:_cmd
                                                    body:@"Не удалось обнаружить ячейку "
                                                            @"с указанным идентификатором."];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:reason
                                     userInfo:nil];
    }
}

@end
