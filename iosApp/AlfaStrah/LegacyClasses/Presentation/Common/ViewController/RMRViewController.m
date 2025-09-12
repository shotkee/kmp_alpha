//
//  RMRViewController.m
//  AlfaStrah
//
//  Created by Roman Churkin on 17/04/15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

#import "RMRViewController.h"
#import "UIView+RMRHelper.h"
//#import "AlfaStrah-Swift.h"

@interface RMRViewController ()

@property (nonatomic, copy) void (^customLeftBarButtonAction)(UIViewController *_Nonnull);
@property (nonatomic, strong) UIImage *customLeftBarButtonImage;

@end

@implementation RMRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (self.customLeftBarButtonImage && self.customLeftBarButtonAction) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:self.customLeftBarButtonImage style:UIBarButtonItemStylePlain
            target:self action:@selector(customLeftBarButtonTapped)];
        self.navigationItem.leftBarButtonItem = button;
    }

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)setNeedsCustomLeftBarButtonWith:(UIImage *)image action:(void (^)(UIViewController *_Nonnull))action {
    self.customLeftBarButtonImage = image;
    self.customLeftBarButtonAction = action;
}

- (IBAction)customLeftBarButtonTapped {
    if (self.customLeftBarButtonAction) {
        self.customLeftBarButtonAction(self);
    }
}

@end
