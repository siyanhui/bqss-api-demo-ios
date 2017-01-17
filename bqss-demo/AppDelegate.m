//
//  AppDelegate.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BQ_AFNetworkReachabilityManager.h"
#import "BQSSApiClient.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化
    [[BQSSApiClient sharedClient] setAppId:@"15e0710942ec49a29d2224a6af4460ee"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    
    nav.navigationBar.barTintColor = [UIColor colorWithRed:27.0 / 255 green:130.0 / 255 blue:210.0 / 255 alpha:1.0];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    nav.navigationBar.titleTextAttributes = attributes;
    
    [[BQ_AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[BQ_AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(BQ_AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:@"无网络连接，请检查网络"
                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil
                                      ];
                
                [alert show];
            }
                break;
                
            default:
                break;
        }
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"占用内存太大");
}

@end
