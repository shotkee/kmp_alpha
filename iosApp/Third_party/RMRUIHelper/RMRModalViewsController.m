//
//  RMRModalViewsController.m
//  RMRUIHelper
//
//  Created by Roman Churkin on 28/01/15.
//  Copyright (c) 2014 Redmadrobot. All rights reserved.
//

#import "RMRModalViewsController.h"

// View Controller
#import "RMRFlexibleStatusBarViewController.h"


@interface RMRModalViewsController ()

#pragma mark - Properties

@property (nonatomic, strong) UIWindow *modalWindow;

@property (nonatomic, strong) UIViewController *modalViewController;

@property (nonatomic, strong) UIView<RMRModalView> *currentView;

@property (nonatomic, strong) NSMutableArray *viewStack;

@end


@implementation RMRModalViewsController

static RMRModalViewsController *sharedModalViewController;

#pragma mark - Initialization

+ (void)initialize
{
    sharedModalViewController = [[RMRModalViewsController alloc] init];
    sharedModalViewController.viewStack = [NSMutableArray array];
}


#pragma mark - Accessors / Mutators

- (UIViewController *)modalViewController
{
    if (_modalViewController) return _modalViewController;
    
    UIViewController *modalViewController = [RMRFlexibleStatusBarViewController new];
    _modalViewController = modalViewController;

    return _modalViewController;
}

- (UIWindow *)modalWindow
{
    if (_modalWindow) return _modalWindow;
    
    CGRect frame = [self mainAppWindow].bounds;
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
    window.rootViewController = self.modalViewController;
    window.windowLevel = UIWindowLevelStatusBar + 2;
    window.hidden = YES;
    
    _modalWindow = window;
    return _modalWindow;
}


#pragma mark - Private helpers

- (UIWindow *)mainAppWindow { return [[[UIApplication sharedApplication] delegate] window]; }

- (void)hideCurrentViewCompletion:(void(^)(void))completion
{
    UIView<RMRModalView> *currentView = self.currentView;
        
    [UIView animateWithDuration:.45
                          delay:0.
         usingSpringWithDamping:.7f
          initialSpringVelocity:.1f
                        options:0
                     animations:^{
                         self.modalWindow.backgroundColor = [UIColor clearColor];
                         [currentView animationHide];
                     }
                     completion:^(BOOL finished) {
                         self.modalWindow.hidden = YES;
                         self.currentView = nil;
                         if (completion) completion();
                     }];
}

- (void)showView:(UIView<RMRModalView> *)view
{
    self.currentView = view;
    
    [self prepareAppearenceForView:view];
    
    self.modalWindow.backgroundColor = [UIColor clearColor];
    self.modalWindow.hidden = NO;
    
    [view prepareForAnimation];

    [UIView animateWithDuration:.25
                          delay:0.
         usingSpringWithDamping:.7f
          initialSpringVelocity:.1f
                        options:0
                     animations:^{
                         self.modalWindow.backgroundColor =
                             [[UIColor blackColor] colorWithAlphaComponent:.3f];
                     }
                     completion:nil];
    
    [UIView animateWithDuration:.25
                          delay:0.05
         usingSpringWithDamping:.8f
          initialSpringVelocity:.1f
                        options:0
                     animations:^{ [view animationAppear]; }
                     completion:nil];
}

- (void)prepareAppearenceForView:(UIView<RMRModalView> *)view
{
    UIView *modalView = self.modalViewController.view;
    
    [modalView addSubview:view];
    
    [view configureLayoutForContainer:modalView];
    
    [modalView layoutIfNeeded];
}

#pragma mark - Public

+ (instancetype)sharedController
{
    return sharedModalViewController;
}

- (void)presentView:(UIView<RMRModalView> *)modalView
{
    modalView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.viewStack addObject:modalView];

    if (self.currentView) [self hideCurrentViewCompletion:^{ [self showView:modalView]; }];
    else [self showView:modalView];
}

- (void)dismissView:(UIView *)modalView completion:(void(^)(void))completion
{
    void (^final)(void) = ^{
        [self.viewStack removeObject:modalView];
        [modalView removeFromSuperview];
        if (completion) completion();
        if ([self.viewStack count] > 0) [self presentView:[self.viewStack lastObject]];
    };
    
    if (self.currentView == modalView) [self hideCurrentViewCompletion:^{ final(); }];
    else final();
}

- (UIView *)viewOnScreen { return self.currentView; }

@end
