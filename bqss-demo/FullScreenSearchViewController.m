//
//  FullScreenSearchViewController.m
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "FullScreenSearchViewController.h"
#import "SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "BQSSSearchApiManager.h"
#import "BQSSWebSticker.h"
#import "BQSSWebStickerCell.h"
#import "BQSSMessage.h"
#import "BQSSPreviewView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+HUD.h"
@interface FullScreenSearchViewController ()<BQSSAPIManagerCallBackDelegate, BQSSAPIManagerParamSource, UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate, PreviewViewDelegate, TagsViewDelegate>{
    NSMutableArray *picturesArray;
    BQSSSearchApiManager *searchApiManager;
    BOOL loadingMore;
    BOOL loadingFinished;
    BQSSPreviewView *emojiPreview;
}

@end

@implementation FullScreenSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    self.title = @"搜索";
    self.view.backgroundColor = [UIColor whiteColor];

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
    
    //    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)]];
    
    UICollectionViewFlowLayout *hotWordFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = (screenWidth - 20 * 2 - 20 * 2) / 3;
    hotWordFlowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 12 + 20 + 12);
    hotWordFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    hotWordFlowLayout.minimumInteritemSpacing = 2;
    hotWordFlowLayout.minimumLineSpacing = 12;
    hotWordFlowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    _collectionViewContainer = [[UIView alloc] init];
    _collectionViewContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionViewContainer];
    [_collectionViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    itemWidth = (screenWidth - 20 * 2 - 20 * 2) / 3;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.minimumLineSpacing = 12;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    _emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 104) collectionViewLayout:flowLayout];
    _emojiCollectionView.backgroundColor = [UIColor whiteColor];
    [_emojiCollectionView registerClass:[BQSSWebStickerCell class] forCellWithReuseIdentifier:@"emojiCell"];
    _emojiCollectionView.delegate = self;
    _emojiCollectionView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    [_emojiCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadNextPage];
    }];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [customView addSubview:indicator];
    indicator.center = customView.center;
    [indicator startAnimating];
    customView.backgroundColor = [UIColor clearColor];
    [_emojiCollectionView.infiniteScrollingView setCustomView:customView forState:SVInfiniteScrollingStateLoading];
    
    [self.collectionViewContainer addSubview:_emojiCollectionView];
    [_emojiCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.bottom.equalTo(self.collectionViewContainer.mas_bottom);
        make.top.equalTo(self.collectionViewContainer.mas_top);
    }];
    
    _collectionViewSepe = [[UIView alloc] init];
    _collectionViewSepe.backgroundColor = [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self.collectionViewContainer addSubview:_collectionViewSepe];
    [_collectionViewSepe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.top.equalTo(self.collectionViewContainer.mas_top);
        make.height.equalTo(@1);
    }];
    
    picturesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    searchApiManager = [BQSSSearchApiManager new];
    searchApiManager.delegate = self;
    searchApiManager.paramSource = self;

    if (_searchKey != nil && _searchKey.length > 0) {
        self.searchBar.text = _searchKey;
        [self searchEmojisWith:_searchKey];
    }else{
        [self.searchBar becomeFirstResponder];
        [self searchBarTextDidBeginEditing:self.searchBar];
    }
}


#pragma mark: UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    [self settagsView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
}

- (void)search {
    NSString *text = [self.searchBar.text stringByTrimmingCharactersInSet:NSMutableCharacterSet.whitespaceCharacterSet];
    if (text != nil && text.length > 0) {
        [self searchEmojisWith:text];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return picturesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BQSSWebStickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
    
    if (indexPath.row < picturesArray.count) {
        BQSSWebSticker *picture = picturesArray[indexPath.row];
        [cell setData:picture];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:true];
    if (indexPath.row < picturesArray.count) {
        BQSSWebStickerCell *cell = (BQSSWebStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.emojiImageView.userInteractionEnabled) {
            return;
        }
        [[self emojiPreview] setData:cell.emojiImageView.image animatedImageArray:cell.emojiImageView.animationImages duration:cell.emojiImageView.animationDuration];
    }
    
}

#pragma mark: PreViewDelegate
- (void)cancelPreView {
    [emojiPreview removeFromSuperview];
    emojiPreview = nil;
}

- (void)sendPreView:(UIImage *)image animatedImageArray:(NSArray *)animatedImageArray duration:(float)duration {
    NSData *_data = nil;
    NSArray *animatedArray = animatedImageArray;
    UIImage *picture = nil;
    if (animatedArray.count > 0) {
        picture = animatedArray[0];
        _data = [self createImageDataWithImage:animatedArray duration:duration];
    }else{
        picture = image;
        _data =  UIImageJPEGRepresentation(picture, 1.0);
    }
    
    NSString *_encodedImageStr = [_data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    BQSSMessage *message = [[BQSSMessage alloc] initWithMessageType:BQSSMessageTypeWebSticker messageContent:@"" pictureString:_encodedImageStr pictureSize:picture.size];
    NSDictionary *userInfo = @{@"message": message};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageNotification" object:nil userInfo:userInfo];
    
    NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [vcs removeLastObject];
    [vcs removeLastObject];
    [self.navigationController setViewControllers:vcs animated:true];
}

- (NSData *)createImageDataWithImage:(NSArray *)images duration:(float) duration {
    int numFrame = (int)(images.count);
    NSMutableData *data = [[NSMutableData alloc] init];
    CGImageDestinationRef animatedGif = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, kUTTypeGIF, numFrame, NULL);
    
    int loopCount = 0;
    NSDictionary *gifProperties = @{ (NSString *)kCGImagePropertyGIFDictionary: @{ (NSString *)kCGImagePropertyGIFLoopCount : @(loopCount) } };
    CGImageDestinationSetProperties(animatedGif, (__bridge CFDictionaryRef) gifProperties);
    float singleDu = duration / numFrame;
    for (int index = 0; index < numFrame; index++) {
        
        CGImageRef cgImage = ((UIImage *)images[index]).CGImage;
        float duration = singleDu;
        NSDictionary *frameProperties = @{ (NSString *)kCGImagePropertyGIFDictionary: @{ (NSString *)kCGImagePropertyGIFDelayTime : @(duration) } };
        CGImageDestinationAddImage(animatedGif, cgImage, (__bridge CFDictionaryRef)frameProperties);
        
    }
    
    BOOL result = CGImageDestinationFinalize(animatedGif);
    CFRelease(animatedGif);
    if (result) {
        return data;
    } else {
        return nil;
    }
}

#pragma mark: TagsViewDelegate
- (void)didClickedTagButton:(UIButton *)button {
    NSString *tagName = button.titleLabel.text;
    self.searchBar.text = tagName;
    [self searchEmojisWith:tagName];
}

- (void)clearHistoryButtonClicked {
    [self clearHistoryData];
    [_tagsView setViewWithTags:@[]];
}

#pragma mark: APIManagerCallBackDelegate, APIManagerParamSource
- (void)managerCallAPIDidFailed:(BQSSBaseApiManager *)manager {
    [_emojiCollectionView.infiniteScrollingView stopAnimating];
    [_loadingIndicator stopAnimating];
    
    [self showToastText:manager.errorMessage];
    
    if ([manager isEqual:searchApiManager]) {
        NSLog(@"查询失败");
        if (searchApiManager.page == 1) {
            _reloadButton.hidden = false;
        }
        searchApiManager.page -= 1;
        if (searchApiManager.page < 1) {
            searchApiManager.page = 1;
        }
    }
}

- (void)reloadFailData {
    [self.view bringSubviewToFront:_loadingView];
    _reloadButton.hidden = true;
    [_loadingIndicator startAnimating];
    [self search];
}

- (void)managerCallAPIDidSuccess:(BQSSBaseApiManager *)manager {
    
    if ([manager isEqual:searchApiManager]) {
        NSArray *pics = [searchApiManager WebStickers];
        if (searchApiManager.page == 1) {
            [picturesArray removeAllObjects];
            [_emojiCollectionView setContentOffset:CGPointMake(0, 0)];
            if (pics.count <= 0) {
                self.loadingIndicator.hidden = true;
                self.emptyLabel.hidden = false;
                return;
            }
        }
        
        if (pics.count > 0) {
            [picturesArray addObjectsFromArray:pics];
            [_emojiCollectionView reloadData];
        }else{
            searchApiManager.page -= 1;
            if (searchApiManager.page < 1) {
                searchApiManager.page = 1;
            }
            
            loadingFinished = true;
        }
        
        if (searchApiManager.page == 5) {
            loadingFinished = true;
        }
    }
    
    self.loadingView.hidden = true;
    self.collectionViewContainer.hidden = false;
    [self.view bringSubviewToFront:_collectionViewContainer];
    [_loadingIndicator stopAnimating];
    [_emojiCollectionView.infiniteScrollingView stopAnimating];
    
    loadingMore = false;
}

- (NSDictionary *)paramsForApi:(BQSSBaseApiManager *)manager {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    
    if ([manager isEqual:searchApiManager]) {
        paramDic[@"q"] = searchApiManager.key;
        paramDic[@"p"] = @(searchApiManager.page);
        paramDic[@"size"] = @20;
    }
    return paramDic;
}

#pragma mark -- private
- (BQSSPreviewView *)emojiPreview {
    if (emojiPreview == nil) {
        emojiPreview = [BQSSPreviewView new];
        emojiPreview.delegate = self;
        [self.view addSubview:emojiPreview];
        [emojiPreview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
            make.top.equalTo(self.view.mas_top).with.offset(64);
        }];
    }
    return emojiPreview;
}

- (void)settagsView {
    
    NSArray *tags = [self getSearchHistoryData];
    if (_tagsView == nil) {
        _tagsView = [BQSSSearchHistoryTagView new];
        _tagsView.delegate = self;
        [self.view addSubview:_tagsView];
    }
    
//        CGFloat tagsViewHeight = [TagsView heightForTags:tags];
    [_tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchContainer.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
//            make.height.equalTo(@(tagsViewHeight));
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [_tagsView setViewWithTags:tags];
    
    [self.view bringSubviewToFront:_tagsView];
}

- (void)searchEmojisWith:(NSString *)key {
    [_tagsView removeFromSuperview];
    _tagsView = nil;
    [self.view endEditing:true];
    self.loadingView.hidden = false;
    self.loadingIndicator.hidden = false;
    self.emptyLabel.hidden = true;
    self.collectionViewContainer.hidden = true;
    [self.view bringSubviewToFront:_loadingView];
    [_loadingIndicator startAnimating];
    [picturesArray removeAllObjects];
    loadingMore = false;
    loadingFinished = false;
    _emojiCollectionView.infiniteScrollingView.enabled = true;
    [searchApiManager loadDataWith:key];
    
    [self updateSearchHistoryDataWith:key];
}

- (void)loadNextPage {
    if (loadingFinished) {
        [_emojiCollectionView.infiniteScrollingView stopAnimating];
        _emojiCollectionView.infiniteScrollingView.enabled = false;
        return;
    }
    [searchApiManager loadNextPage];
}

- (void)updateSearchHistoryDataWith:(NSString *)searchWord { //保存最新的没有过期的10条
    NSString *searchHistoryPath = [[self rootPathForSearchData] stringByAppendingPathComponent:@"searchHistory.plist"];
    
    if (searchHistoryPath.length == 0) {
        return;
    }
    NSMutableArray *searchWords = [NSMutableArray new];
    [searchWords addObjectsFromArray:[NSMutableArray arrayWithContentsOfFile:searchHistoryPath]];
    for (NSString *word in searchWords) {
        if([searchWord isEqualToString:word]) {
            return;
        }
    }
    while (searchWords.count >= 10) {
        [searchWords removeLastObject];
    }
    [searchWords insertObject:searchWord atIndex:0];
    [searchWords writeToFile:searchHistoryPath atomically:YES];
}

- (NSArray *)getSearchHistoryData {
    NSString *searchHistoryPath = [[self rootPathForSearchData] stringByAppendingPathComponent:@"searchHistory.plist"];
    NSArray *searchArrays = [NSArray arrayWithContentsOfFile:searchHistoryPath];
    return searchArrays;
}

- (void)clearHistoryData {
    NSString *searchHistoryPath = [[self rootPathForSearchData] stringByAppendingPathComponent:@"searchHistory.plist"];
    [@[] writeToFile:searchHistoryPath atomically:YES];
}

- (NSString *)rootPathForSearchData {
    NSString *rootPath = [[self diskBaseStoreDirectory] stringByAppendingPathComponent:@"SearchHistoryData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return rootPath;
}

- (NSString *)diskBaseStoreDirectory {
    NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    return appSupportPaths[0];
}
@end
