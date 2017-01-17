//
//  SearchApiManager.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "BQSSBaseApiManager.h"
#import "BQSSWebSticker.h"
@interface BQSSSearchApiManager : BQSSBaseApiManager<BQSSAPIManager>
@property (nonatomic) int page;
@property (nonatomic, strong) NSString *key;

- (void)loadDataWith:(NSString *)key;
- (void) loadNextPage;

- (NSArray<BQSSWebSticker *> *)WebStickers;

@end
