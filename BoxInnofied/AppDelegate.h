//
//  AppDelegate.h
//  BoxInnofied
//
//  Created by Sandip Saha on 30/04/14.
//  Copyright (c) 2014 Sandip Saha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxSDK/BoxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setRefreshTokenInKeychain:(NSString *)refreshToken;


@end
