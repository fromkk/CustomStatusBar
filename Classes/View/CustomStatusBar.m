//
//  CustomStatusBar.m
//  CustomStatusBar
//
//  Created by Kazuya Ueoka on 2013/06/21.
//  Copyright (c) 2013年 fromkk. All rights reserved.
//

#import "CustomStatusBar.h"

#define StatusBarFontSize 12.0f
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define StatusBarHeight 20.0f
#define StatsuBarPadding 4.0f

#define ORIENTATION [[UIApplication sharedApplication] statusBarOrientation]
#define LANDSCAPE UIInterfaceOrientationIsLandscape(ORIENTATION)
#define PORTRAIT !LANDSCAPE

@interface CustomStatusBar ()

+ (CustomStatusBar *)sharedInstance;

- (void)show;
- (void)hide;
- (void)showWithMessage:(NSString *)message;
- (void)showIndicator;
- (void)hideIndicator;

- (void)didChangeStatusBarFrame:(NSNotification *)notif;
- (void)rotateToStatusBarFrameWithAnimate:(BOOL)withAnimate;

@end

@implementation NSObject (delay)

+ (void)performBlocks:(NSObjectDlayBlocks)blocks afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(_executeSelector:) withObject:Block_copy(blocks) afterDelay:delay];
}

+ (void)_executeSelector:(NSObjectDlayBlocks)blocks {
    if ( nil != blocks ) {
        blocks();
        Block_release(blocks);
    }
}

@end

@implementation CustomStatusBar

static CustomStatusBar *sharedInstance = nil;

- (void)dealloc
{
    _customDelegate = nil;
    
    [_backgroundView removeFromSuperview];
    [_backgroundView release];
    
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    [_indicator release];
    
    [_messageLabel removeFromSuperview];
    [_messageLabel release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        
        //初期設定
        self.backgroundColor = [UIColor blackColor];
        self.windowLevel = UIWindowLevelStatusBar + 1.0f; //ここが肝
        self.frame = statusBarFrame;
        self.alpha = 0.0f;
        self.hidden = YES;
        
        //透明の背景ビュー
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
        
        //インディケーター
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_backgroundView addSubview:_indicator];
        [_indicator stopAnimating];
        isShowIndicator = NO;
        
        //メッセージラベル
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont boldSystemFontOfSize:StatusBarFontSize];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = UITextAlignmentCenter;
        _messageLabel.backgroundColor = [UIColor clearColor];
        [_backgroundView addSubview:_messageLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        [self rotateToStatusBarFrameWithAnimate:NO];
        
        _customDelegate = nil;
    }
    return self;
}

#pragma mark - 表示位置調整

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _indicator.frame = CGRectMake(StatsuBarPadding, StatsuBarPadding, _backgroundView.frame.size.height - StatsuBarPadding * 2, _backgroundView.frame.size.height - StatsuBarPadding * 2);
    
    CGFloat messageLabelX = StatsuBarPadding;
    
    if ( isShowIndicator ) {
        messageLabelX = CGRectGetMaxX(_indicator.frame) + StatsuBarPadding;
    }
    
    CGFloat messageLabelWidth = 0.0f;
    messageLabelWidth = _backgroundView.frame.size.width - messageLabelX - StatsuBarPadding * 2;
    
    _messageLabel.frame = CGRectMake(messageLabelX, StatsuBarPadding, messageLabelWidth, _backgroundView.frame.size.height - StatsuBarPadding * 2);
}

#pragma mark - 画面の向きに合わせる

- (void)rotateToStatusBarFrameWithAnimate:(BOOL)withAnimate {
    
    __block CustomStatusBar *wself = self;
    void (^transform)() = ^{
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat pi = (CGFloat)M_PI;
        if (orientation == UIDeviceOrientationPortrait) {
            wself.transform = CGAffineTransformIdentity;
            wself.frame = CGRectMake(0.f,0.f,ScreenWidth, StatusBarHeight);
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            wself.transform = CGAffineTransformMakeRotation(pi * (90.f) / 180.0f);
            wself.frame = CGRectMake(ScreenWidth - StatusBarHeight,0, StatusBarHeight, ScreenHeight);
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            wself.transform = CGAffineTransformMakeRotation(pi * (-90.f) / 180.0f);
            wself.frame = CGRectMake(0.f,0.f, StatusBarHeight, ScreenHeight);
        } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            wself.transform = CGAffineTransformMakeRotation(pi);
            wself.frame = CGRectMake(0.f,ScreenHeight - StatusBarHeight, ScreenWidth, StatusBarHeight);
        }
        
        _backgroundView.frame = PORTRAIT ? CGRectMake(0.0f, 0.0f, ScreenWidth, StatusBarHeight) : CGRectMake(0.0f, 0.0f, ScreenHeight, StatusBarHeight);
    };
    
    if ( withAnimate ) {
        [UIView animateWithDuration:0.4f animations:^{
            transform();
        }];
    } else {
        transform();
    }
}

#pragma mark - ステータスバーのサイズが変更された時に呼ばれる

- (void)didChangeStatusBarFrame:(NSNotification *)notif {
    [self rotateToStatusBarFrameWithAnimate:YES];
    [self setNeedsLayout];
}

#pragma mark - メッセージを表示する

- (void)showWithMessage:(NSString *)message {
    _messageLabel.text = message;
    
    [self show];
}

#pragma mark - ステータスバーを表示する

- (void)show {
    [self setNeedsLayout];
    
    self.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if ( nil != _customDelegate && [_customDelegate respondsToSelector:@selector(statusBarDidShow)] ) {
            [_customDelegate performSelector:@selector(statusBarDidShow)];
        }
    }];
    
    displayCount++;
}

#pragma mark - ステータスバーを非表示にする

- (void)hide {
    if ( 0 < displayCount ) {
        displayCount--;
    }
    
    if ( 0 == displayCount ) {
        self.messageLabel.text = nil;
        
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            
            if ( nil != _customDelegate && [_customDelegate respondsToSelector:@selector(statusBarDidHide)] ) {
                [_customDelegate performSelector:@selector(statusBarDidHide)];
            }
        }];
    }
}

#pragma mark - インディケーターを表示する

- (void)showIndicator {
    isShowIndicator = YES;
    
    [_indicator startAnimating];
}

#pragma mark - インディケーターを非表示にする

- (void)hideIndicator {
    isShowIndicator = NO;
    
    [_indicator stopAnimating];
}

#pragma mark - クラスメソッド

+ (CustomStatusBar *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CustomStatusBar alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - メッセージを表示する

+ (void)showWithMessage:(NSString *)message {
    CustomStatusBar *instance = [self sharedInstance];
    [instance showWithMessage:message];
}

#pragma mark - メッセージを設定し直す

+ (void)setMessage:(NSString *)message {
    CustomStatusBar *instance = [self sharedInstance];
    [instance.messageLabel setText:message];
}

#pragma mark - インディケーターを表示する

+ (void)showIndicator {
    CustomStatusBar *instance = [self sharedInstance];
    [instance showIndicator];
}

#pragma mark - インディケーターを非表示にする

+ (void)hideIndicator {
    CustomStatusBar *instance = [self sharedInstance];
    [instance hideIndicator];
}

#pragma mark - 非表示にする

+ (void)hide {
    CustomStatusBar *instance = [self sharedInstance];
    [instance hide];
}

#pragma mark - 時間差で非表示にする

+ (void)hideWithAfterDelay:(CGFloat)delay {
    [NSObject performBlocks:^{
        CustomStatusBar *instance = [self sharedInstance];
        [instance hide];
    } afterDelay:delay];
}

#pragma mark - 表示されてるか確認

+ (BOOL)isDisplay {
    CustomStatusBar *instance = [self sharedInstance];
    
    return ! instance.hidden;
}

#pragma mark - デリゲートを設定

+ (void)setDelegate:(id)delegate {
    CustomStatusBar *instance = [self sharedInstance];
    instance.customDelegate = nil;
    instance.customDelegate = delegate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
