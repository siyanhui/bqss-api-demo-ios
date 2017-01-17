//
//  UIViewController+HUD.m
//  bqss-demo
//
//  Created by isan on 09/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "UIViewController+HUD.h"

@implementation UIViewController (HUD)

- (void)showToastText:(NSString *)text {
    MBProgressHUD *hudProgress = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    hudProgress.mode = MBProgressHUDModeText;
    hudProgress.label.text = text;
    hudProgress.minSize = CGSizeMake(135, 60);
    hudProgress.square = false;
    [hudProgress hideAnimated:true afterDelay:1.0];
}

- (void)showToastForever {
    MBProgressHUD *hudProgress = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    hudProgress.minSize = CGSizeMake(135, 135);
    hudProgress.square = true;
//    hudProgress.activityIndicatorColor = [UIColor grayColor];
}

- (void) hideToast {
    [MBProgressHUD hideHUDForView:self.view animated:true];
}

@end
