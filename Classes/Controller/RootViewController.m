//
//  RootViewController.m
//  CustomStatusBar
//
//  Created by Kazuya Ueoka on 2013/06/21.
//  Copyright (c) 2013年 fromkk. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

- (void)tappedButtons:(UIButton *)btn;

@end

@implementation RootViewController

- (void)dealloc
{
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    btnDisplay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnDisplay setTitle:@"表示" forState:UIControlStateNormal];
    [btnDisplay addTarget:self action:@selector(tappedButtons:) forControlEvents:UIControlEventTouchUpInside];
    btnDisplay.tag = ButtonTypeDisplay;
    [self.view addSubview:btnDisplay];
    
    btnHide = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnHide setTitle:@"非表示" forState:UIControlStateNormal];
    [btnHide addTarget:self action:@selector(tappedButtons:) forControlEvents:UIControlEventTouchUpInside];
    btnHide.tag = ButtonTypeHide;
    [self.view addSubview:btnHide];
    btnHide.enabled = NO;
    
    btnDelay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnDelay setTitle:@"遅れて非表示" forState:UIControlStateNormal];
    [btnDelay addTarget:self action:@selector(tappedButtons:) forControlEvents:UIControlEventTouchUpInside];
    btnDelay.tag = ButtonTypeDelay;
    [self.view addSubview:btnDelay];
    btnDelay.enabled = NO;
    
    [CustomStatusBar setDelegate:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width, height;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ( UIInterfaceOrientationIsPortrait(orientation) ) {
        width = self.view.frame.size.width;
        height = self.view.frame.size.height;
    } else {
        width = self.view.frame.size.height;
        height = self.view.frame.size.width;
    }
    
    btnDisplay.frame = CGRectMake(30.0f, 60.0f, width - 60.0f, 44.0f);
    btnHide.frame = CGRectMake(30.0f, CGRectGetMaxY(btnDisplay.frame) + 30.0f, width - 60.0f, 44.0f);
    btnDelay.frame = CGRectMake(30.0f, CGRectGetMaxY(btnHide.frame) + 30.0f, width - 60.0f, 44.0f);
}

- (void)tappedButtons:(UIButton *)btn {
    switch (btn.tag) {
        case ButtonTypeDisplay:
            [CustomStatusBar showWithMessage:@"メッセージ"];
            break;
        case ButtonTypeHide:
            [CustomStatusBar hide];
            break;
        case ButtonTypeDelay:
            [CustomStatusBar hideWithAfterDelay:3.0f];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - CustomStatusBar delegate

- (void)statusBarDidShow {
    btnDisplay.enabled = NO;
    btnHide.enabled = YES;
    btnDelay.enabled = YES;
}

- (void)statusBarDidHide {
    btnDisplay.enabled = YES;
    btnHide.enabled = NO;
    btnDelay.enabled = NO;
    
}

@end
