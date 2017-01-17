//
//  QuaterScreenDemoViewController.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQSSInputToolBar.h"
@interface QuaterScreenDemoViewController : UIViewController
@property(strong, nonatomic) UITableView *messagesTableView;
@property(strong, nonatomic) BQSSInputToolBar *inputToolBar;
@property(strong, nonatomic) UIView *loadingView;
@property(strong, nonatomic) UIButton *reloadButton;
@property(strong, nonatomic) UILabel *emptyLabel;
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

@property(strong, nonatomic) UIView *sepeLine1;
@property(strong, nonatomic) UIView *collectionViewContainer;
@property(strong, nonatomic) UICollectionView *emojiCollectionView;
@property(strong, nonatomic) UIView *collectionViewSepe;
@end
