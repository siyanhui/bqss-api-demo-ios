//
//  BaseApiManager.m
//  BQMM
//
//  Created by isan on 16/8/9.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import "BQSSBaseApiManager.h"
#import "BQSSApiClient.h"
#import <CommonCrypto/CommonCrypto.h>
@interface BQSSBaseApiManager()

@end

@implementation BQSSBaseApiManager

- (instancetype)init
{
    self = [super init];
    if ([self conformsToProtocol:@protocol(BQSSAPIManager)]) {
        self.child = (id<BQSSAPIManager>)self;
    } else {
        NSAssert(NO, @"子类必须要实现APIManager这个protocol。");
    }
    
    return self;
}

- (void)loadData {
    NSMutableDictionary *params = [self.paramSource paramsForApi:self];
    [self loadDataWithParams:params];
}

- (void)loadDataWithParams:(NSDictionary *)params {
    __weak typeof(self) weakSelf = self;

    [[BQSSApiClient sharedClient] GET:[self.child apiMethodName] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.responseObject = responseObject;
        [[strongSelf delegate] managerCallAPIDidSuccess:strongSelf];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf parseError:error task:task];
        [[strongSelf delegate] managerCallAPIDidFailed:strongSelf];
    }];
}




#pragma mark: base work
- (NSString *)signatureForurl:(NSString*)url params:(NSDictionary *)params {
    NSArray *keys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",key,params[key]]];
    }
    NSString *pairsStr = [pairs componentsJoinedByString:@"&"];
    NSString *finalString = [NSString stringWithFormat:@"%@%@%@",
                   [BQSSApiClient sharedClient].baseURL,
                   url,
                   pairsStr];
    
    NSString *signature = [[self md5:finalString] uppercaseString];
    
    return signature;
}


- (NSDictionary *)generateFinalParamsWithUrl:(NSString*)url ext:(NSDictionary*)ext {
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:ext];
    
    NSString *timeStampe = [NSString stringWithFormat:@"%lld", (long long)([[NSDate  date] timeIntervalSince1970] * 1000)];
    mDic[@"timestamp"] = timeStampe;
    mDic[@"os"] = [NSString stringWithFormat:@"ios%@", [[UIDevice currentDevice] systemVersion]];
    mDic[@"app_id"] = [BQSSApiClient sharedClient].appId;
    mDic[@"ssl_res"] = @YES;
    mDic[@"fs"] = @"medium";
    mDic[@"signature"] = [self signatureForurl:url params:mDic];
    
    return mDic;
}

- (NSString *)baseParamsWithRequestUrl:(NSString*)url ext:(NSDictionary*)ext {
    NSDictionary *params = [self generateFinalParamsWithUrl:url ext:ext];
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:[params.allKeys count]];
    for (NSString *key in params.allKeys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",key,params[key]]];
    }
    NSString *pairsStr = [pairs componentsJoinedByString:@"&"];
    NSCharacterSet *set = [NSCharacterSet URLFragmentAllowedCharacterSet];
    return [[NSString stringWithFormat:@"?%@", pairsStr] stringByAddingPercentEncodingWithAllowedCharacters:set];
}

#pragma mark: private
- (NSString *)md5:(NSString *)str {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    const char *strUTF8 = [str UTF8String];
    CC_MD5(strUTF8, (CC_LONG)strlen(strUTF8), digest);
    NSData *data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    NSMutableString *str1 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    const unsigned char * buffer = [data bytes];
    for (NSUInteger i = 0; i < [data length]; i++) {
        [str1 appendString:[NSString stringWithFormat:@"%02x",buffer[i]]];
    }
    return [NSString stringWithString:str1];
}

- (void)parseError:(NSError *)error task:(NSURLSessionDataTask *)task {
    self.error = error;
    self.errorMessage = @"网络出错";
    if ([error.localizedDescription containsString:@"offline"]) {
        self.errorMessage = @"无网络连接，请检查网络";
        return;
    }
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    if (response) {
        NSInteger statusCode = response.statusCode;
        if (statusCode == 500) {
            self.errorMessage = @"服务器内部出错";
        }else if(statusCode == 408 || statusCode == 504) {
            self.errorMessage = @"请求超时";
        }
    }
}
@end
