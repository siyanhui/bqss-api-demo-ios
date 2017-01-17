//
//  TagsView.h
//  BQMM
//
//  Created by isan on 16/8/30.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagsViewDelegate <NSObject>
- (void)didClickedTagButton:(UIButton *)button;
- (void)clearHistoryButtonClicked;
@required

@end

@interface BQSSSearchHistoryTagView : UIView
@property(strong, nonatomic) UIView *sepeLine1;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UIButton *clearButton;

@property (nonatomic, weak) id<TagsViewDelegate> delegate;

+ (CGFloat)heightForTags:(NSArray *)tags;
- (void)setViewWithTags:(NSArray *)tags;

@end
