//
//  MMApiClient.h
//  BQMM
//
//  Created by isan on 16/8/8.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQ_AFNetworking.h"

@interface BQSSApiClient : BQ_AFHTTPSessionManager
@property (nonatomic, strong) NSString *appId;

+ (instancetype)sharedClient;
- (void)setAppId:(NSString *)appId;
@end
