//
//  FullScreenTagViewController.m
//  bqss-demo
//
//  Created by isan on 09/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "FullScreenTrendingViewController.h"
#import "SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "BQSSSearchApiManager.h"
#import "BQSSWebSticker.h"
#import "BQSSHotTag.h"
#import "BQSSHotTagApiManager.h"
#import "BQSSHotTagCell.h"
#import "BQSSWebStickerCell.h"
#import "BQSSMessage.h"
#import "BQSSPreviewView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FullScreenSearchViewController.h"
#import "UIViewController+HUD.h"
@interface FullScreenTrendingViewController ()<BQSSAPIManagerCallBackDelegate, BQSSAPIManagerParamSource, UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate>{
    NSMutableArray *hotWordArray;
    BQSSHotTagApiManager *homeWordApiManager;
    BOOL loadingMore;
}

@end

@implementation FullScreenTrendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"热门";
    
    _searchContainer = [UIView new];
    _searchContainer.backgroundColor = [UIColor colorWithWhite:242.0 / 255 alpha:1.0];
    [self.view addSubview:_searchContainer];
    [_searchContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).with.offset(64);
        make.height.equalTo(@52);
    }];
    
    _sepeLine1 = [[UIView alloc] init];
    _sepeLine1.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [_searchContainer addSubview:_sepeLine1];
    [_sepeLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_top);
        make.left.equalTo(self.searchContainer.mas_left);
        make.right.equalTo(self.searchContainer.mas_right);
        make.height.equalTo(@1);
    }];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.searchBarStyle = UISearchBarStyleProminent;
    _searchBar.backgroundImage = [UIImage imageNamed:@"bg_242"];
    _searchBar.placeholder = @"搜索感兴趣的图片";
    _searchBar.tintColor = [UIColor blueColor];
    _searchBar.barTintColor = self.searchContainer.backgroundColor;
    
    UITextField *searchField = [_searchBar valueForKey:@"searchField"];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 4.0;
    }
    
    _searchBar.delegate = self;
    [self.searchContainer addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchContainer.mas_left).with.offset(5);
        make.right.equalTo(self.searchContainer.mas_right).with.offset(-5);
        make.height.equalTo(@50);
        make.centerY.equalTo(self.searchContainer.mas_centerY);
    }];
    
    _sepeLine2 = [[UIView alloc] init];
    _sepeLine2.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self.searchContainer addSubview:_sepeLine2];
    [_sepeLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.searchContainer.mas_bottom).with.offset(-1);
        make.left.equalTo(self.searchContainer.mas_left);
        make.right.equalTo(self.searchContainer.mas_right);
        make.height.equalTo(@1);
    }];
    
    _loadingView = [UIView new];
    _loadingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    _reloadButton = [UIButton new];
    [_reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [_reloadButton setTitleColor:[UIColor colorWithWhite:100.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    _reloadButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    [_reloadButton addTarget:self action:@selector(reloadFailData) forControlEvents:UIControlEventTouchUpInside];
    _reloadButton.layer.cornerRadius = 2;
    _reloadButton.layer.borderWidth = 1;
    _reloadButton.layer.borderColor = [UIColor colorWithWhite:225.0 / 255 alpha:1.0].CGColor;
    [_loadingView addSubview:_reloadButton];
    [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY).with.offset(-64);
    }];
    _reloadButton.hidden = true;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingView addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY).with.offset(-64);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    _emptyLabel = [UILabel new];
    _emptyLabel.text = @"没有表情";
    _emptyLabel.backgroundColor = [UIColor clearColor];
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.font = [UIFont systemFontOfSize:17];
    [_loadingView addSubview:_emptyLabel];
    [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY).with.offset(-64);
    }];
    _emptyLabel.hidden = true;
    
    UICollectionViewFlowLayout *hotWordFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = (screenWidth - 20 * 2 - 20 * 2) / 3;
    hotWordFlowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 12 + 20 + 12);
    hotWordFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    hotWordFlowLayout.minimumInteritemSpacing = 2;
    hotWordFlowLayout.minimumLineSpacing = 12;
    hotWordFlowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    _hotWordCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 104) collectionViewLayout:hotWordFlowLayout];
    _hotWordCollectionView.backgroundColor = [UIColor whiteColor];
    [_hotWordCollectionView registerClass:[BQSSHotTagCell class] forCellWithReuseIdentifier:@"hotWordCell"];
    _hotWordCollectionView.delegate = self;
    _hotWordCollectionView.dataSource = self;
    
    [self.view addSubview:_hotWordCollectionView];
    [_hotWordCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.searchContainer.mas_bottom);
    }];

    hotWordArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    homeWordApiManager = [BQSSHotTagApiManager new];
    homeWordApiManager.delegate = self;
    homeWordApiManager.paramSource = self;
    
    [self.view bringSubviewToFront:_loadingView];
    self.hotWordCollectionView.hidden = true;
    [_loadingIndicator startAnimating];
    [homeWordApiManager loadData];
}


#pragma mark: UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    FullScreenSearchViewController *vc = [FullScreenSearchViewController new];
    [self.navigationController pushViewController:vc animated:true];
    return false;
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _hotWordCollectionView) {
        return hotWordArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BQSSHotTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hotWordCell" forIndexPath:indexPath];
    
    if (indexPath.row < hotWordArray.count) {
        BQSSHotTag *picture = hotWordArray[indexPath.row];
        [cell setData:picture];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:true];
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    if (indexPath.row < hotWordArray.count) {
        BQSSHotTag *word = hotWordArray[indexPath.row];
        FullScreenSearchViewController *vc = [FullScreenSearchViewController new];
        vc.searchKey = word.text;
        [self.navigationController pushViewController:vc animated:true];
    }
    
}


#pragma mark: APIManagerCallBackDelegate, APIManagerParamSource
- (void)managerCallAPIDidFailed:(BQSSBaseApiManager *)manager {
    [_loadingIndicator stopAnimating];
    _reloadButton.hidden = false;
    [self showToastText:manager.errorMessage];
}

- (void)reloadFailData {
    [self.view bringSubviewToFront:_loadingView];
    _reloadButton.hidden = true;
    self.hotWordCollectionView.hidden = true;
    [_loadingIndicator startAnimating];
    [homeWordApiManager loadData];
}

- (void)managerCallAPIDidSuccess:(BQSSBaseApiManager *)manager {
    
    if ([manager isEqual:homeWordApiManager]) {
        self.loadingView.hidden = true;
        self.hotWordCollectionView.hidden = false;
        [self.view bringSubviewToFront:_hotWordCollectionView];
        [_loadingIndicator stopAnimating];
        
        [hotWordArray removeAllObjects];
        [hotWordArray addObjectsFromArray:[homeWordApiManager hotTags]];
        [_hotWordCollectionView reloadData];
    }
}

- (NSDictionary *)paramsForApi:(BQSSBaseApiManager *)manager {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    return paramDic;
}

@end

