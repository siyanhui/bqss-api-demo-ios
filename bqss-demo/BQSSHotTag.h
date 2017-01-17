//
//  BQSSHotTag.h
//  bqss-demo
//
//  Created by isan on 11/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  热门tag
 */
@interface BQSSHotTag : NSObject

/**
 *  tag名称
 */
@property (nonatomic, strong) NSString *text;

/**
 *  tag封面图片
 */
@property (nonatomic, strong) NSString *cover;

@end

