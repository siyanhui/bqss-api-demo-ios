//
//  MMApiClient.m
//  BQMM
//
//  Created by isan on 16/8/8.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSApiClient.h"
@implementation BQSSApiClient
+ (instancetype)sharedClient {
    
    static BQSSApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *baseUrl = @"https://open-api.dongtu.com:1443/open-api";
        _sharedClient = [[BQSSApiClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        _sharedClient.securityPolicy = [BQ_AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress * _Nonnull))downloadProgress
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
    
    return [super GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull progress) {
        
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failure(task, error);
            }];
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    return [super POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull progress) {
        
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failure(task, error);
            }];
}

@end
