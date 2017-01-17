//
//  FullScreenTagViewController.h
//  bqss-demo
//
//  Created by isan on 09/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenTrendingViewController : UIViewController
@property(strong, nonatomic) UIView *sepeLine1;
@property(strong, nonatomic) UIView *sepeLine2;
@property(strong, nonatomic) UIView *searchContainer;
@property (nonatomic, strong) UISearchBar *searchBar;
@property(strong, nonatomic) UIView *loadingView;
@property(strong, nonatomic) UILabel *emptyLabel;
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(strong, nonatomic) UICollectionView *hotWordCollectionView;

@property(strong, nonatomic) UIButton *reloadButton;

@end
