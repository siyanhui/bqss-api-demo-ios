//
//  EmojiCell.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQSSHotTag.h"

@interface BQSSHotTagCell : UICollectionViewCell
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(strong, atomic) UIImageView *emojiImageView;
@property(strong, atomic) UILabel *wordLabel;

@property(strong, atomic) BQSSHotTag *picture;

- (void)setData: (BQSSHotTag *)hotTag;
@end
