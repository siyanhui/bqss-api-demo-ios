//
//  MMMessage.h
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BQSSWebSticker.h"

typedef NS_ENUM(NSUInteger, BQSSMessageType) {
    /*!
     Text message or photo-text message
     */
    BQSSMessageTypeText = 1,
    
    /*!
     big emoji message
     */
    BQSSMessageTypeWebSticker = 2,
    
};

@interface BQSSMessage : NSObject

@property(nonatomic, assign) BQSSMessageType messageType;

/**
 *  text content of message
 */
@property(nonatomic, strong) NSString *messageContent;
/**
 *  the ext of message
 */
@property(nonatomic, strong) NSString *pictureString;

@property(nonatomic) CGSize pictureSize;



- (id)initWithMessageType:(BQSSMessageType)messageType messageContent:(NSString *)messageContent pictureString:(NSString *)pictureString pictureSize:(CGSize)pictureSize;


@end
