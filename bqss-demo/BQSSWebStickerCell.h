//
//  EmojiCell.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQSSWebSticker.h"

@interface BQSSWebStickerCell : UICollectionViewCell
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(strong, atomic) UIImageView *emojiImageView;
@property(strong, atomic) BQSSWebSticker *picture;

- (void)setData: (BQSSWebSticker *)webSticker;
@end
