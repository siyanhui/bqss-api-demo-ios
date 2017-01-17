//
//  homeWordApiManager.m
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "BQSSHotTagApiManager.h"

@implementation BQSSHotTagApiManager
- (NSString *)apiMethodName {
    NSString *url = @"netword/hot";
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@", url, [self baseParamsWithRequestUrl:url ext:[self.paramSource paramsForApi:self]]];
    return finalUrl;
}

- (NSArray<BQSSHotTag *> *)hotTags; {
    NSArray *picsArray = self.responseObject[@"data_list"];
    if (picsArray && [picsArray isKindOfClass:[NSArray class]] && picsArray.count > 0) {
        NSMutableArray *ret = [NSMutableArray arrayWithCapacity:picsArray.count];
        for (NSDictionary* picDic in picsArray) {
            BQSSHotTag *picture = [[BQSSHotTag alloc] init];
            picture.text = picDic[@"text"];
            picture.cover = picDic[@"cover"];
            [ret addObject:picture];
        }
        return ret;
    }
    return nil;
}
@end

