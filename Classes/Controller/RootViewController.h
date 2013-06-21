//
//  RootViewController.h
//  CustomStatusBar
//
//  Created by Kazuya Ueoka on 2013/06/21.
//  Copyright (c) 2013年 fromkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomStatusBar.h"

typedef enum {
    ButtonTypeDisplay = 0,
    ButtonTypeHide,
    ButtonTypeDelay
} ButtonType;

@interface RootViewController : UIViewController <CustomStatusBarDelegae> {
    UIButton *btnDisplay;
    UIButton *btnHide;
    UIButton *btnDelay;
}

@end
