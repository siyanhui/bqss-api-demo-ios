//
//  MMChatViewBaseCell.m
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSBaseMessageCell.h"

@implementation BQSSBaseMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setView {
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.backgroundColor = [UIColor grayColor];
    _avatarView.image = [UIImage imageNamed:@"message_icon"];
    _avatarView.layer.cornerRadius = 17.5;
    _avatarView.clipsToBounds = true;
    [self.contentView addSubview:_avatarView];
    
    _messageView = [[UIView alloc] init];
    _messageView.backgroundColor = [UIColor clearColor];
    _messageView.clipsToBounds = true;
    
    
    [self.contentView addSubview:_messageView];
    
    _messageBubbleView = [[UIImageView alloc] init];
    _messageBubbleView.backgroundColor = [UIColor clearColor];
    _messageBubbleView.contentMode = UIViewContentModeScaleToFill;
    [_messageView addSubview:_messageBubbleView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize cellSize = self.contentView.frame.size;
    CGSize size = CGSizeMake(35, 35);
    _avatarView.frame = CGRectMake(cellSize.width - size.width - 15, 0, size.width, size.height);
    
    _messageView.frame = CGRectMake(CGRectGetMinX(_avatarView.frame) - 4 - _bubbleSize.width, 0, _bubbleSize.width, _bubbleSize.height);
    _messageBubbleView.frame = CGRectMake(0, 0, _bubbleSize.width, _bubbleSize.height);
}

- (void)set:(BQSSMessage *)messageData {
    self.messageModel = messageData;
    
    UIImage *bubbleImage = [UIImage imageNamed:@"ic_bubble"];
    self.messageBubbleView.image = [bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 15, 10, 15) resizingMode:UIImageResizingModeStretch];
    
    _bubbleSize = [BQSSBaseMessageCell bubbleSizeFor:messageData];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.bubbleSize = CGSizeMake(0, 0);
}

+ (CGFloat)cellHeightFor:(BQSSMessage *)message {
    CGFloat height = 0;
    CGSize bubbleSize = [BQSSBaseMessageCell bubbleSizeFor:message];
    height += bubbleSize.height + 20;
    return height;
}

+ (CGSize)bubbleSizeFor:(BQSSMessage *)message {
    CGSize size;
    switch (message.messageType) {
        case BQSSMessageTypeText:
            size = [BQSSBaseMessageCell textContentSize:message.messageContent];
            break;
        case BQSSMessageTypeWebSticker:
            size = CGSizeMake(120 / message.pictureSize.height * message.pictureSize.width, 120);
            break;
    }
    size.width = size.width + CONTENT_RIGHT_MARGIN + CONTENT_LEFT_MARGIN;
    size.height = size.height + CONTENT_TOP_MARGIN + CONTENT_BOTTOM_MARGIN;
    return size;
}

+ (CGSize)textContentSize:(NSString *)content {
    
    UITextView *_textMessageView = [[UITextView alloc] init];
    _textMessageView.textContainerInset = UIEdgeInsetsZero;
    _textMessageView.text = content;
    _textMessageView.font = [UIFont systemFontOfSize:TEXT_MESSAGEFONT_SIZE];
    CGFloat maxWidth = BUBBLE_MAX_WIDTH - (CONTENT_RIGHT_MARGIN + CONTENT_LEFT_MARGIN);
    return [_textMessageView sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

@end
