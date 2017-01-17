//
//  homeWordApiManager.h
//  bqss-demo
//
//  Created by isan on 04/01/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "BQSSBaseApiManager.h"
#import "BQSSHotTag.h"
@interface BQSSHotTagApiManager : BQSSBaseApiManager<BQSSAPIManager>

- (NSArray<BQSSHotTag *> *)hotTags;
@end
