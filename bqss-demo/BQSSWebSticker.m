//
//  MMCPicture.m
//  CoreLib
//
//  Created by Tender on 16/10/14.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BQSSWebSticker.h"

@implementation BQSSWebSticker

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ text=%@, thumb='%@', main='%@', size=%fx%f, is_animated:%@", [super description], self.text, self.thumbImage, self.mainImage, self.size.width, self.size.height, self.isAnimated ? @"YES" : @"NO"];
}

@end
