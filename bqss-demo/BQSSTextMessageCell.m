//
//  MMChatViewTextCell.m
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSTextMessageCell.h"

@implementation BQSSTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setView];
    }
    
    return self;
}

- (void)setView {
    [super setView];
    _textMessageView = [[UITextView alloc] init];
    _textMessageView.backgroundColor = [UIColor clearColor];
    _textMessageView.textContainerInset = UIEdgeInsetsZero;
    _textMessageView.textColor = [UIColor blackColor];
    _textMessageView.font = [UIFont systemFontOfSize:TEXT_MESSAGEFONT_SIZE];
    _textMessageView.editable = false;
    _textMessageView.selectable = false;
    _textMessageView.scrollEnabled = false;
    [self.messageView addSubview:_textMessageView];
}

- (void)set:(BQSSMessage *)messageData {
    [super set:messageData];
    _textMessageView.text = messageData.messageContent;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = [_textMessageView sizeThatFits:CGSizeMake(BUBBLE_MAX_WIDTH - (CONTENT_RIGHT_MARGIN + CONTENT_LEFT_MARGIN), CGFLOAT_MAX)];
    _textMessageView.frame = CGRectMake(CONTENT_LEFT_MARGIN, CONTENT_TOP_MARGIN, size.width, size.height);
}

-(void)prepareForReuse {
    [super prepareForReuse];
}

@end
