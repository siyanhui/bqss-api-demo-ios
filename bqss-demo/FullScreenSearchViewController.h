//
//  FullScreenSearchViewController.h
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQSSMessage.h"
#import "BQSSSearchHistoryTagView.h"

@interface FullScreenSearchViewController :UIViewController
@property (nonatomic, strong) BQSSSearchHistoryTagView *tagsView;
@property(strong, nonatomic) UIView *sepeLine1;
@property(strong, nonatomic) UIView *sepeLine2;
@property(strong, nonatomic) UIView *searchContainer;
@property (nonatomic, strong) UISearchBar *searchBar;
@property(strong, nonatomic) UIView *loadingView;
@property(strong, nonatomic) UILabel *emptyLabel;
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(strong, nonatomic) UIView *collectionViewContainer;
@property(strong, nonatomic) UICollectionView *emojiCollectionView;
@property(strong, nonatomic) UIView *collectionViewSepe;
@property(strong, nonatomic) UIButton *reloadButton;
@property(strong, nonatomic) NSString *searchKey;
@end
