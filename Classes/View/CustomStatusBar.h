//
//  CustomStatusBar.h
//  CustomStatusBar
//
//  Created by Kazuya Ueoka on 2013/06/21.
//  Copyright (c) 2013年 fromkk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NSObjectDlayBlocks)();

@interface NSObject (delay)

+ (void)performBlocks:(NSObjectDlayBlocks)blocks afterDelay:(NSTimeInterval)delay;

@end

@protocol CustomStatusBarDelegae <NSObject>

- (void)statusBarDidShow;
- (void)statusBarDidHide;

@end

@interface CustomStatusBar : UIWindow {
    BOOL isShowIndicator;
    int displayCount;
}

@property (nonatomic, assign, readonly) UIView *backgroundView;
@property (nonatomic, assign, readonly) UILabel *messageLabel;
@property (nonatomic, assign, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) id <CustomStatusBarDelegae> customDelegate;

+ (void)setMessage:(NSString *)message;
+ (void)showWithMessage:(NSString *)message;
+ (void)hide;
+ (void)hideWithAfterDelay:(CGFloat)delay;
+ (void)showIndicator;
+ (void)hideIndicator;
+ (BOOL)isDisplay;
+ (void)setDelegate:(id)delegate;

@end
