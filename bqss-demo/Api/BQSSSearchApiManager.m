//
//  SearchApiManager.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "BQSSSearchApiManager.h"

@implementation BQSSSearchApiManager
#pragma mark: BQSSAPIManager
- (NSString *)apiMethodName {
    NSString *url = @"emojis/net/search";
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@", url, [self baseParamsWithRequestUrl:url ext:[self.paramSource paramsForApi:self]]];
    return finalUrl;
}

- (void)loadDataWith:(NSString *)key {
    self.page = 1;
    self.key = key;
    [super loadData];
}

- (void) loadNextPage {
    self.page += 1;
    [super loadData];
}

- (NSArray<BQSSWebSticker *> *)WebStickers {
    NSArray *picsArray = self.responseObject[@"emojis"];
    
    if (picsArray && [picsArray isKindOfClass:[NSArray class]] && picsArray.count > 0) {
        NSMutableArray *ret = [NSMutableArray arrayWithCapacity:picsArray.count];
        for (NSDictionary* picDic in picsArray) {
            BQSSWebSticker *picture = [[BQSSWebSticker alloc] init];
            picture.text = picDic[@"text"];
            picture.thumbImage = picDic[@"thumb"];
            picture.mainImage = picDic[@"main"];
            NSInteger width = [picDic[@"width"] integerValue];
            NSInteger height = [picDic[@"height"] integerValue];
            picture.size = CGSizeMake(width, height);
            picture.isAnimated = [picDic[@"is_animated"] boolValue];
            [ret addObject:picture];
        }
        return ret;
    }
    return nil;
}
@end
