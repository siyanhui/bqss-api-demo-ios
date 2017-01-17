//
//  MMMessage.m
//  IMDemo
//
//  Created by isan on 16/4/21.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSMessage.h"

@implementation BQSSMessage

- (id)initWithMessageType:(BQSSMessageType)messageType messageContent:(NSString *)messageContent pictureString:(NSString *)pictureString pictureSize:(CGSize)pictureSize {
    
    self = [super init];
    if (self) {
        self.messageType = messageType;
        self.messageContent = messageContent;
        self.pictureString = pictureString;
        self.pictureSize = pictureSize;
    }
    
    return self;
}

@end
