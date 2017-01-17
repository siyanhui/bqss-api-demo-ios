//
//  MMCPicture.h
//  CoreLib
//
//  Created by Tender on 16/10/14.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  网络表情
 */
@interface BQSSWebSticker : NSObject

/**
 *  图片名称
 */
@property (nonatomic, strong) NSString *text;

/**
 *  图片缩略图地址
 */
@property (nonatomic, strong) NSString *thumbImage;

/**
 *  图片地址
 *  可能是GIF、PNG、JPG格式
 */
@property (nonatomic, strong) NSString *mainImage;

/**
 *  图片尺寸（pix）
 */
@property (nonatomic, assign) CGSize size;

/**
 *  是否动画表情（GIF）
 */
@property (nonatomic, assign) BOOL isAnimated;

@end
