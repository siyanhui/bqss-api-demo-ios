//
//  EmojiCell.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "BQSSHotTagCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

#define BQSSTouchEndNotification    @"BQSSTouchEndNotification"
@implementation BQSSHotTagCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTouchEnd) name:BQSSTouchEndNotification object:nil];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    _emojiImageView = [[UIImageView alloc] init];
    _emojiImageView.contentMode = UIViewContentModeScaleAspectFill;
    _emojiImageView.clipsToBounds = YES;
    [self.contentView addSubview:_emojiImageView];
    
    [_emojiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(12);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-32);
    }];
    
    [_emojiImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadImage)]];
    _emojiImageView.userInteractionEnabled = NO;
    
    _wordLabel = [UILabel new];
    _wordLabel.backgroundColor = [UIColor clearColor];
    _wordLabel.font = [UIFont systemFontOfSize:14];
    _wordLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_wordLabel];
    [_wordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emojiImageView.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.equalTo(@20);
    }];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emojiImageView.mas_centerX);
        make.centerY.equalTo(self.emojiImageView.mas_centerY);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    [_loadingIndicator startAnimating];
}

- (void)setData: (BQSSHotTag *)hotTag {
    _emojiImageView.userInteractionEnabled = NO;
    _picture = hotTag;
    NSURL *url = [[NSURL alloc] initWithString:hotTag.cover];
    if (url != nil) {
        __weak typeof(self) weakSelf = self;
        [self.emojiImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageAvoidAutoSetImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [_loadingIndicator stopAnimating];
            if (image) {
                if (image.images.count > 0) {
                    weakSelf.emojiImageView.animationImages = image.images;
                    weakSelf.emojiImageView.image = image.images[0];
                    weakSelf.emojiImageView.animationDuration = image.duration;
                    [weakSelf.emojiImageView startAnimating];
                }else{
                    weakSelf.emojiImageView.image = image;
                }
            }else{
                weakSelf.emojiImageView.image = [UIImage imageNamed:@"loading_error"];
                _emojiImageView.userInteractionEnabled = YES;
            }
        }];
    }else{
        self.emojiImageView.image = [UIImage imageNamed:@"loading_error"];
        _emojiImageView.userInteractionEnabled = YES;
        NSLog(@"%@ url 无效", hotTag.cover);
    }
    
    _wordLabel.text = hotTag.text;
}

- (void)reloadImage {
    [self setData:_picture];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _wordLabel.text = nil;
    [_emojiImageView sd_cancelCurrentAnimationImagesLoad];
    _emojiImageView.image = nil;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_loadingIndicator];
    [_loadingIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emojiImageView.mas_centerX);
        make.centerY.equalTo(self.emojiImageView.mas_centerY);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    [_loadingIndicator startAnimating];
    
    _emojiImageView.userInteractionEnabled = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleTouchEnd {
    [self.emojiImageView startAnimating];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BQSSTouchEndNotification object:nil];
}
@end
