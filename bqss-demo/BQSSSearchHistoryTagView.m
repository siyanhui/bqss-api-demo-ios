//
//  TagsView.m
//  BQMM
//
//  Created by isan on 16/8/30.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSSearchHistoryTagView.h"
#import "Masonry.h"
@implementation BQSSSearchHistoryTagView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setViewWithTags:(NSArray *)tags {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    if (tags.count <= 0) {
        return;
    }
    
    _infoLabel = [UILabel new];
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.text = @"搜索历史";
    _infoLabel.font = [UIFont systemFontOfSize:14];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    _infoLabel.textColor = [UIColor colorWithWhite:74.0 / 255 alpha:1.0];
    [self addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(20);
        make.top.equalTo(self.mas_top).with.offset(25);
    }];
    
    _clearButton = [UIButton new];
    _clearButton.backgroundColor = [UIColor clearColor];
    [_clearButton setTitle:@"清除" forState:UIControlStateNormal];
    _clearButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_clearButton setTitleColor:[UIColor colorWithWhite:74.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    [_clearButton addTarget:self action:@selector(clearHistoryButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_clearButton];
    [_clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-20);
        make.centerY.equalTo(self.infoLabel.mas_centerY);
        make.height.equalTo(@44);
    }];
    
    _sepeLine1 = [[UIView alloc] init];
    _sepeLine1.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self addSubview:_sepeLine1];
    [_sepeLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@1);
    }];
    
    
    CGFloat margin = 20;
    CGFloat Y = 20 + 40;
    CGFloat X = margin;
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat currentRight = margin - 14;  //为了第一个
    for (NSString *tag in tags) {
        if (tag.length > 0) {
            UIButton *button = [self createButtonWithTag:tag];
            [self addSubview:button];
            CGSize buSize = [BQSSSearchHistoryTagView sizeForTagButton:tag];
            
            if (currentRight + 14 + buSize.width > maxWidth - margin) {
                currentRight = margin + buSize.width;
                X = margin;
                Y = Y + 14 + 41;
            }else{
                X = currentRight + 14;
                currentRight = currentRight + 14 + buSize.width;
            }
            button.frame = CGRectMake(X, Y, buSize.width, 41);
        }
    }
}

- (UIButton *)createButtonWithTag:(NSString *)tag {
    UIButton *button = [UIButton new];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 3;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithWhite:151.0 / 255 alpha:1.0].CGColor;
    [button setTitle:tag forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:74.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    
    CGFloat offset = 15;
    
    button.contentEdgeInsets = UIEdgeInsetsMake(0, offset, 0, offset);
    
    [button addTarget:self action:@selector(tagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark: action 
- (void)tagButtonClicked:(UIButton *)sender {
    [self.delegate didClickedTagButton:sender];
}

- (void)clearHistoryButtonClicked {
    [self.delegate clearHistoryButtonClicked];
}

+ (CGFloat)heightForTags:(NSArray *)tags {
    CGFloat height = 22 + 41 + 40;
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat margin = 20;
    
    CGFloat currentRight = margin - 14;
    for (NSString *tag in tags) {
        if (tag.length > 0) {
            CGSize buSize = [BQSSSearchHistoryTagView sizeForTagButton:tag];
            if (currentRight + 14 + buSize.width > maxWidth - margin) {
                height = height + 14 + 41;
                currentRight = margin + buSize.width;
            }else{
                currentRight = currentRight + 14 + buSize.width;
            }
        }
    }
    height = height + 22;
    return height;
}

+ (CGSize)sizeForTagButton:(NSString *)tag {
    
    UIButton *button = [UIButton new];
    [button setTitle:tag forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    CGFloat offset = 15;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, offset, 0, offset);
    CGSize buttonSize = [button sizeThatFits:CGSizeMake(2000, 41)];
    return buttonSize;
}


@end
