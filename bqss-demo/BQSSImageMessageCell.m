//
//  MMChatViewImageCell.m
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSImageMessageCell.h"
#import "UIImage+GIF.h"
@implementation BQSSImageMessageCell

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
    _pictureView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _pictureView.layer.masksToBounds = YES;
    [self.messageView addSubview:_pictureView];
    
    self.messageBubbleView.hidden = true;
}

- (void)set:(BQSSMessage *)messageData {
    [super set:messageData];
    self.pictureView.image = [UIImage imageNamed:@"mm_emoji_loading"];
    
    NSString *str = messageData.pictureString;
    NSData *_decodedImageData   = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *_decodedImage      = [UIImage sd_animatedGIFWithData:_decodedImageData];
    
    if (_decodedImage) {
        if (_decodedImage.images.count > 0) {
            self.pictureView.animationImages = _decodedImage.images;
            self.pictureView.image = _decodedImage.images[0];
            self.pictureView.animationDuration = _decodedImage.duration;
            [self.pictureView startAnimating];
        }else{
            self.pictureView.image = _decodedImage;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize messageSize = self.messageView.frame.size;
    CGSize size = CGSizeMake(120 / self.messageModel.pictureSize.height * self.messageModel.pictureSize.width, 120);;
    self.pictureView.frame = CGRectMake(messageSize.width - size.width - CONTENT_RIGHT_MARGIN, (messageSize.height - size.height) / 2, size.width, size.height);
}

-(void)prepareForReuse {
    [super prepareForReuse];
    _pictureView.image = nil;
    _pictureView.animationImages = nil;
}



@end
