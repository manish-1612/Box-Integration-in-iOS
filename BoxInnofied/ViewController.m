//
//  ViewController.m
//  BoxInnofied
//
//  Created by Sandip Saha on 30/04/14.
//  Copyright (c) 2014 Sandip Saha. All rights reserved.
//

#import "ViewController.h"
#import "BoxAuthorizationNavigationController.h"

@interface ViewController ()
 
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidSucceed:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidFail:)
                                                 name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
   
}

- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 successfully authenticated notification");
    BoxOAuth2Session *session = (BoxOAuth2Session *) [notification object];
    NSLog(@"Access token  (%@) expires at %@", session.accessToken, session.accessTokenExpiration);
    NSLog(@"Refresh token (%@)", session.refreshToken);
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isAuthorized"];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 failed authenticated notification");
    NSString *oauth2Error = [[notification userInfo] valueForKey:BoxOAuth2AuthenticationErrorKey];
    NSLog(@"Authentication error  (%@)", oauth2Error);
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isAuthorized"];

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


- (IBAction)authorizeForBox:(id)sender
{
    
    NSString *redirectURI = [BoxSDK sharedSDK].OAuth2Session.redirectURIString;
    
    BoxAuthorizationViewController *authorizationController = [[BoxAuthorizationViewController alloc]
                                                               initWithAuthorizationURL:[[BoxSDK sharedSDK].OAuth2Session authorizeURL] redirectURI:redirectURI];
    
    BoxAuthorizationNavigationController *loginNavigation = [[BoxAuthorizationNavigationController alloc] initWithRootViewController:authorizationController];
    
    authorizationController.delegate = loginNavigation;
    
    loginNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:loginNavigation animated:YES completion:nil];
}


-(void)makeAPICallsToViewFiles
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
