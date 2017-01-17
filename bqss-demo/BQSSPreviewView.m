//
//  PreviewView.m
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "BQSSPreviewView.h"
#import "Masonry.h"
@implementation BQSSPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    _containerView = [UIView new];
    _containerView.layer.cornerRadius = 4;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_containerView];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(50);
        make.right.equalTo(self.mas_right).with.offset(-50);
        make.height.equalTo(@248);
        make.centerY.equalTo(self.mas_centerY).with.offset(-64);
    }];
    
    _titleLabel = [UILabel new];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"图片预览";
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_containerView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.mas_left).with.offset(18);
        make.top.equalTo(self.containerView.mas_top).with.offset(15);
    }];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    [self.containerView addSubview:_imageView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@123);
        make.height.equalTo(@123);
        make.top.equalTo(self.containerView.mas_top).with.offset(52);
        make.centerX.equalTo(self.containerView.mas_centerX);
    }];
    
    _sepeLine1 = [[UIView alloc] init];
    _sepeLine1.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [_containerView addSubview:_sepeLine1];
    [_sepeLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.containerView.mas_bottom).with.offset(-47);
        make.left.equalTo(self.containerView.mas_left);
        make.right.equalTo(self.containerView.mas_right);
        make.height.equalTo(@1);
    }];

    
    _sepeLine2 = [[UIView alloc] init];
    _sepeLine2.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [_containerView addSubview:_sepeLine2];
    [_sepeLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.containerView.mas_bottom);
        make.height.equalTo(@47);
        make.width.equalTo(@1);
        make.centerX.equalTo(self.containerView.mas_centerX);
    }];
    
    _cancelButton = [UIButton new];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithWhite:151.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelPreview) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_cancelButton];
    
    _sendButton = [UIButton new];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithRed:11.0 / 255.0 green:196.0 / 255.0 blue:205.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendPreview) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_sendButton];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.mas_left);
        make.right.equalTo(self.sendButton.mas_left).with.offset(-1);
        make.bottom.equalTo(self.containerView.mas_bottom);
        make.height.equalTo(@46);
        make.width.equalTo(self.sendButton);
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.mas_right);
        make.left.equalTo(self.sendButton.mas_right).with.offset(1);
        make.bottom.equalTo(self.containerView.mas_bottom);
        make.height.equalTo(@46);
        make.width.equalTo(self.cancelButton);
    }];
}

- (void)setData:(UIImage *)picture animatedImageArray:(NSArray *)animatedImageArray duration:(float)duration {
    _imageView.image = picture;
    
    if (animatedImageArray.count > 0) {
        _imageView.animationImages = animatedImageArray;
        _imageView.image = animatedImageArray[0];
        _imageView.animationDuration = duration;
        [_imageView startAnimating];
    }else{
        _imageView.image = picture;
    }
}

- (void)cancelPreview {
    [self.delegate cancelPreView];
}

- (void)sendPreview {
    [self.delegate sendPreView:_imageView.image animatedImageArray:_imageView.animationImages duration:_imageView.animationDuration];
}

@end
