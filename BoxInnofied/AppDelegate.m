//
//  AppDelegate.m
//  BoxInnofied
//
//  Created by Sandip Saha on 30/04/14.
//  Copyright (c) 2014 Sandip Saha. All rights reserved.
//

#import "AppDelegate.h"

#import "KeychainItemWrapper.h"

#define REFRESH_TOKEN_KEY   (@"box_api_refresh_token")


@interface AppDelegate ()

@property (nonatomic, readwrite, strong) KeychainItemWrapper *keychain;
- (void)boxAPITokensDidRefresh:(NSNotification *)notification;

@end


@implementation AppDelegate

@synthesize keychain = _keychain;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
#warning change client id and client secret key. Also change the API key in the info.plist file with api key of your application.
    [BoxSDK sharedSDK].OAuth2Session.clientID = @"YOUR_CLIENT_ID";
    [BoxSDK sharedSDK].OAuth2Session.clientSecret = @"YOUR_CLIENT SECRECT_KEY";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidRefreshTokensNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    
    
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:REFRESH_TOKEN_KEY accessGroup:nil];
    
    id storedRefreshToken = [self.keychain objectForKey:(__bridge id)kSecValueData];
    if (storedRefreshToken)
    {
        [BoxSDK sharedSDK].OAuth2Session.refreshToken = storedRefreshToken;
    }
    
    return YES;
}

- (void)boxAPITokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *) notification.object;
    [self setRefreshTokenInKeychain:OAuth2Session.refreshToken];
}

- (void)setRefreshTokenInKeychain:(NSString *)refreshToken
{
    [self.keychain setObject:@"BoxSDKSampleApp" forKey: (__bridge id)kSecAttrService];
    [self.keychain setObject:refreshToken forKey:(__bridge id)kSecValueData];
}




- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation
{
    [[BoxSDK sharedSDK].OAuth2Session performAuthorizationCodeGrantWithReceivedURL:url];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
