//
//  HalfScreenDemoViewController.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "HalfScreenDemoViewController.h"
#import "BQSSWebStickerCell.h"
#import "BQSSSearchApiManager.h"
#import "BQSSWebSticker.h"
#import "BQSSTrendingApiManager.h"
#import "Masonry.h"
#import "BQSSBaseMessageCell.h"
#import "BQSSTextMessageCell.h"
#import "BQSSImageMessageCell.h"
#import "UIImageView+WebCache.h"
#import "BQSSMessage.h"
#import "SVPullToRefresh.h"
#import "UIViewController+HUD.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface HalfScreenDemoViewController ()<BQSSAPIManagerCallBackDelegate, BQSSAPIManagerParamSource,UITableViewDelegate, UITableViewDataSource, InputToolBarViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>{
    NSMutableArray *messagesArray;
    NSMutableArray *picturesArray;
    BQSSSearchApiManager *searchApiManager;
    BQSSTrendingApiManager *trendingApiManager;
    BOOL showingTrending;
    BOOL loadingMore;
    BOOL loadingFinished;
}
@end


@implementation HalfScreenDemoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        picturesArray = [[NSMutableArray alloc] initWithCapacity:0];
        messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
        loadingFinished = false;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    self.title = @"键盘搜索";
    self.view.backgroundColor = [UIColor whiteColor];

    _inputToolBar = [[BQSSInputToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50) inputType:InputTypeHalf];
    _inputToolBar.delegate = self;
    [self.view addSubview:_inputToolBar];
    
    [_inputToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(self.inputToolBar.toolbarHeight));
    }];
    
    _messagesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _messagesTableView.backgroundColor = [UIColor whiteColor];
    _messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messagesTableView.delegate = self;
    _messagesTableView.dataSource = self;
    _messagesTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    _messagesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [_messagesTableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)]];
    
    [self.view addSubview:_messagesTableView];
    
    [_messagesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(64);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.inputToolBar.mas_top);
    }];
    
    _collectionViewContainer = [[UIView alloc] init];
    _collectionViewContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionViewContainer];
    [_collectionViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.equalTo(@220);
    }];
    _collectionViewContainer.hidden = true;
    
    _loadingView = [UIView new];
    _loadingView.backgroundColor = [UIColor whiteColor];
    [_collectionViewContainer addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionViewContainer.mas_top).with.offset(1);
        make.left.equalTo(self.collectionViewContainer.mas_left);
        make.right.equalTo(self.collectionViewContainer.mas_right);
        make.bottom.equalTo(self.collectionViewContainer.mas_bottom).with.offset(-1);
    }];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingView addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loadingView.mas_centerX);
        make.centerY.equalTo(self.loadingView.mas_centerY);
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
        make.centerY.equalTo(self.loadingView.mas_centerY);
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
        make.centerY.equalTo(self.loadingView.mas_centerY);
    }];
    _reloadButton.hidden = true;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = (screenWidth - 12 * 2 - 12 * 3) / 4;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.minimumLineSpacing = 12;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    
    _emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 104) collectionViewLayout:flowLayout];
    _emojiCollectionView.backgroundColor = [UIColor clearColor];
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
        make.top.equalTo(self.collectionViewContainer.mas_top).with.offset(1);
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
    
    messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    picturesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    searchApiManager = [BQSSSearchApiManager new];
    searchApiManager.delegate = self;
    searchApiManager.paramSource = self;
    
    trendingApiManager = [BQSSTrendingApiManager new];
    trendingApiManager.delegate = self;
    trendingApiManager.paramSource = self;
    
    [self.collectionViewContainer bringSubviewToFront:_loadingView];
    [_loadingIndicator startAnimating];
    
    [_inputToolBar didTouchEmojiDown:_inputToolBar.emojiButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)layoutViewsWithKeyboardFrame:(CGRect)keyboardFrame {
    if (keyboardFrame.size.height == 0) {
        _collectionViewContainer.hidden = false;
        [_inputToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.emojiCollectionView.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@(self.inputToolBar.toolbarHeight));
        }];
    }else{
        _collectionViewContainer.hidden = true;
        [_inputToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardFrame.size.height);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@(self.inputToolBar.toolbarHeight));
        }];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollViewToBottom];
    });
}

- (void)tapToDismissKeyboard {
    [self.view endEditing:true];
}

- (void)scrollViewToBottom {
    NSUInteger finalRow = MAX(0, [self.messagesTableView numberOfRowsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.messagesTableView scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BQSSMessage *message = (BQSSMessage *)messagesArray[indexPath.row];
    return [BQSSBaseMessageCell cellHeightFor:message];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BQSSMessage *message = (BQSSMessage *)messagesArray[indexPath.row];
    NSString *reuseId = @"";
    
    BQSSBaseMessageCell *cell = nil;
    switch (message.messageType) {
        case BQSSMessageTypeText:
        {
            reuseId = @"textMessage";
            cell = (BQSSTextMessageCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
            if(cell == nil) {
                cell = [[BQSSTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            }
            
        }
            break;
            
        case BQSSMessageTypeWebSticker:
        {
            reuseId = @"bigEmojiMessage";
            cell = (BQSSImageMessageCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
            if(cell == nil) {
                cell = [[BQSSImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            }
        }
            break;
    }
    
    //    cell.delegate = self;
    [cell set:message];
    return cell;
    
    return nil;
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
    if (indexPath.row < picturesArray.count) {
        BQSSWebStickerCell *cell = (BQSSWebStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.emojiImageView.userInteractionEnabled) {
            return;
        }
        NSData *_data = nil;
        NSArray *animatedArray = cell.emojiImageView.animationImages;
        UIImage *picture = nil;
        if (animatedArray.count > 0) {
            picture = animatedArray[0];
            _data = [self createImageDataWithImage:animatedArray duration:cell.emojiImageView.animationDuration];
        }else{
            picture = cell.emojiImageView.image;
            _data =  UIImageJPEGRepresentation(picture, 1.0);
        }
        
        NSString *_encodedImageStr = [_data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        BQSSMessage *message = [[BQSSMessage alloc] initWithMessageType:BQSSMessageTypeWebSticker messageContent:@"" pictureString:_encodedImageStr pictureSize:picture.size];
        [self appendAndDisplayMessage:message];
    }
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

#pragma mark <InputToolBarViewDelegate>
- (void)didTouchOtherButtonDown {
    [self showToastText:@"示例按钮,无功能"];
}

- (void)keyboardWillShowWithFrame:(CGRect)keyboardFrame {
    [self layoutViewsWithKeyboardFrame:keyboardFrame];
}

- (void)toolbarHeightDidChangedTo:(CGFloat)height {
    CGRect tableViewFrame = _messagesTableView.frame;
    CGRect toolBarFrame = _inputToolBar.frame;
    
    toolBarFrame.origin.y = CGRectGetMaxY(_inputToolBar.frame) - height;
    toolBarFrame.size.height = height;
    tableViewFrame.size.height = toolBarFrame.origin.y;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _inputToolBar.frame = toolBarFrame;
        _messagesTableView.frame = tableViewFrame;
    } completion:^(BOOL finished) {
        
    }];
    [self scrollViewToBottom];
}

- (void)searchEmojisWith:(NSString *)key {
    loadingFinished = false;
    _emojiCollectionView.infiniteScrollingView.enabled = true;
    [picturesArray removeAllObjects];
    showingTrending = false;
    loadingMore = false;
    [searchApiManager loadDataWith:key];
    
    
    [_collectionViewContainer bringSubviewToFront:_loadingView];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
    
    [self.view endEditing:true];
    
}

- (void)toggleSearchMode {
    _collectionViewContainer.hidden = false;
    _loadingIndicator.hidden = false;
    [_loadingIndicator startAnimating];
    showingTrending = true;
    loadingMore = false;
    [trendingApiManager loadData];
    loadingFinished = false;
    _emojiCollectionView.infiniteScrollingView.enabled = true;
    [self.view endEditing:true];
    [self layoutViewsWithKeyboardFrame:CGRectMake(0, 0, 0, 0)];
    
    [_collectionViewContainer bringSubviewToFront:_loadingView];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
}

- (void)searchBarEndOperation {
    _loadingIndicator.hidden = false;
    [_loadingIndicator startAnimating];
    _collectionViewContainer.hidden = true;
}

- (void)sendTextWith:(NSString *)text {
    BQSSMessage *message = [[BQSSMessage alloc] initWithMessageType:BQSSMessageTypeText messageContent:text pictureString:@"" pictureSize:CGSizeZero];
    [self appendAndDisplayMessage:message];
}

#pragma mark: APIManagerCallBackDelegate, APIManagerParamSource
- (void)managerCallAPIDidFailed:(BQSSBaseApiManager *)manager {
    [_loadingIndicator stopAnimating];
    [_emojiCollectionView.infiniteScrollingView stopAnimating];
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
    }else if([manager isEqual:trendingApiManager]) {
        NSLog(@"获取trending失败");
        if (trendingApiManager.page == 1) {
            _reloadButton.hidden = false;
        }
        trendingApiManager.page -= 1;
        if (trendingApiManager.page < 1) {
            trendingApiManager.page = 1;
        }
    }
}

- (void)reloadFailData {
    [self toggleSearchMode];
    _reloadButton.hidden = true;
}

- (void)managerCallAPIDidSuccess:(BQSSBaseApiManager *)manager {
    [_emojiCollectionView.infiniteScrollingView stopAnimating];
    
    [_loadingIndicator stopAnimating];
    _loadingIndicator.hidden = true;
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
        [_collectionViewContainer bringSubviewToFront:_emojiCollectionView];
    }else if([manager isEqual:trendingApiManager]) {
        if (trendingApiManager.page == 1) {
            [picturesArray removeAllObjects];
        }
        
        NSArray *pics = [trendingApiManager WebStickers];
        
        if (pics.count > 0) {
            [picturesArray addObjectsFromArray:pics];
            [_emojiCollectionView reloadData];
        }else{
            trendingApiManager.page -= 1;
            if (trendingApiManager.page < 1) {
                trendingApiManager.page = 1;
            }
            loadingFinished = true;
        }
        
        if (trendingApiManager.page == 5) {
            loadingFinished = true;
        }
        [_collectionViewContainer bringSubviewToFront:_emojiCollectionView];
    }
    
    loadingMore = false;
}

- (NSDictionary *)paramsForApi:(BQSSBaseApiManager *)manager {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    
    if ([manager isEqual:searchApiManager]) {
        paramDic[@"q"] = searchApiManager.key;
        paramDic[@"p"] = @(searchApiManager.page);
        paramDic[@"size"] = @20;
    }else if([manager isEqual:trendingApiManager]) {
        paramDic[@"p"] = @(trendingApiManager.page);
        paramDic[@"size"] = @20;
    }
    return paramDic;
}

#pragma mark -- private
- (void)loadNextPage {
    if (loadingFinished) {
        [_emojiCollectionView.infiniteScrollingView stopAnimating];
        _emojiCollectionView.infiniteScrollingView.enabled = false;
        return;
    }
    if (showingTrending) {
        [trendingApiManager loadNextPage];
    }else{
        [searchApiManager loadNextPage];
    }
}

- (void)appendAndDisplayMessage:(BQSSMessage *)message {
    if (!message) {
        return;
    }
    [messagesArray addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messagesArray.count - 1 inSection:0];
    if ([self.messagesTableView numberOfRowsInSection:0] != messagesArray.count - 1) {
        NSLog(@"Error, datasource and tableview are inconsistent!!");
        [self.messagesTableView reloadData];
        return;
    }
    [self.messagesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self scrollViewToBottom];
}

@end
