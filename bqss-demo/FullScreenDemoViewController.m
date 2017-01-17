//
//  FullScreenDemoViewController.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "FullScreenDemoViewController.h"
#import "Masonry.h"
#import "BQSSBaseMessageCell.h"
#import "BQSSTextMessageCell.h"
#import "BQSSImageMessageCell.h"
#import "BQSSMessage.h"
#import "FullScreenTrendingViewController.h"
#import "UIViewController+HUD.h"
@interface FullScreenDemoViewController ()<UITableViewDelegate, UITableViewDataSource, InputToolBarViewDelegate>{
    NSMutableArray *messagesArray;
}
@end


@implementation FullScreenDemoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"sendMessageNotification" object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    self.title = @"全屏搜索";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)]];
    _inputToolBar = [[BQSSInputToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50) inputType:InputTypeFull];
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
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = false;
//    self.title = @"全屏搜索";
//    self.navigationController.navigationBar.backItem.title = @"首页";
//    self.navigationController.navigationBar.topItem.title = @"首页";

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)layoutViewsWithKeyboardFrame:(CGRect)keyboardFrame {
    [_inputToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardFrame.size.height);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(self.inputToolBar.toolbarHeight));
    }];
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
    [cell set:message];
    return cell;
    
    return nil;
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



- (void)toggleSearchMode {
    FullScreenTrendingViewController *vc = [[FullScreenTrendingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
    [self.view endEditing:true];
}


- (void)sendTextWith:(NSString *)text {
    BQSSMessage *message = [[BQSSMessage alloc] initWithMessageType:BQSSMessageTypeText messageContent:text pictureString:@"" pictureSize:CGSizeZero];
    [self appendAndDisplayMessage:message];
}

#pragma mark -- private
- (void)sendMessage:(NSNotification *) notification {
    NSDictionary *dict = notification.userInfo;
    BQSSMessage *message = [dict valueForKey:@"message"];
    [self appendAndDisplayMessage:message];
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
