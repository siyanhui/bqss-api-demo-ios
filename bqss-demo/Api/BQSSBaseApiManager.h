//
//  BaseApiManager.h
//  BQMM
//
//  Created by isan on 16/8/9.
//  Copyright © 2016年 siyanhui. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BQSSBaseApiManager;

@protocol BQSSAPIManager <NSObject>
@required
- (nonnull NSString *)apiMethodName;
@end


@protocol BQSSAPIManagerCallBackDelegate <NSObject>
@required
- (void)managerCallAPIDidSuccess:(nonnull BQSSBaseApiManager *)manager;
- (void)managerCallAPIDidFailed:(nonnull BQSSBaseApiManager *)manager;
@end


@protocol BQSSAPIManagerParamSource <NSObject>
@required
- (nonnull NSMutableDictionary *)paramsForApi:(nonnull BQSSBaseApiManager *)manager;
@end


@interface BQSSBaseApiManager : NSObject
@property (nonatomic, weak, nullable) id<BQSSAPIManager> child;
@property (nonatomic, weak, nullable) id<BQSSAPIManagerCallBackDelegate> delegate;
@property (nonatomic, weak, nullable) id<BQSSAPIManagerParamSource> paramSource;

@property (nonatomic, strong, nullable) id responseObject;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, strong, nullable) NSString *errorMessage;

- (nonnull NSString *)baseParamsWithRequestUrl:(NSString* _Nonnull)url ext:(nullable NSDictionary *)ext;
- (void)loadData;
@end
