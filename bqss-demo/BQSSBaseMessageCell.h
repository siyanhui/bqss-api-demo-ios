//
//  MMChatViewBaseCell.h
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQSSMessage.h"

#define BUBBLE_MAX_WIDTH ([[UIScreen mainScreen] bounds].size.width * 0.65)
#define TEXT_MESSAGEFONT_SIZE 17
#define CONTENT_TOP_MARGIN 8
#define CONTENT_BOTTOM_MARGIN 9
#define CONTENT_LEFT_MARGIN 6
#define CONTENT_RIGHT_MARGIN 14

@interface BQSSBaseMessageCell : UITableViewCell

@property(strong, nonatomic) UIImageView *avatarView;
@property(strong, nonatomic) UIView *messageView;
@property(strong, nonatomic) UIImageView *messageBubbleView;

@property(strong, nonatomic) BQSSMessage *messageModel;
@property(nonatomic) CGSize bubbleSize;

- (void)setView;
- (void)set:(BQSSMessage *)messageData;
+ (CGFloat)cellHeightFor:(BQSSMessage *)message;

@end
