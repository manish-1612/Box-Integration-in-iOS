//
//  BoxAuthorizationNavigationController.m
//  BoxSDKSampleApp
//
//  Created on 5/15/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxAuthorizationNavigationController.h"

@interface BoxAuthorizationNavigationController ()

@property (nonatomic, readwrite, strong) UIActivityIndicatorView *activityView;

@end

@implementation BoxAuthorizationNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];
    }
    return self;
}


- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView setHidesWhenStopped:YES];
        [_activityView stopAnimating];
    }

    return _activityView;
}

#pragma mark - BoxAuthorizationViewControllerDelegate methods

- (void)authorizationViewControllerDidStartLoading:(BoxAuthorizationViewController *)authorizationViewController
{
    if ([self.activityView isAnimating] == NO)
    {
        CGFloat activityWidth = self.activityView.frame.size.width;
        CGFloat activityHeight = self.activityView.frame.size.height;
        CGFloat x = (self.navigationBar.frame.size.width - activityWidth) * 0.5f;
        CGFloat y = (self.navigationBar.frame.size.height - activityHeight) * 0.5f;
        if (x < 0.0f)
        {
            x = 0.0f;
        }
        if (y < 0.0f)
        {
            y = 0.0f;
        }
        [self.activityView setFrame:CGRectMake(x, y, activityWidth, activityHeight)];

        [self.navigationBar addSubview:self.activityView];
        [self.activityView startAnimating];
    }
}

- (void)authorizationViewControllerDidFinishLoading:(BoxAuthorizationViewController *)authorizationViewController
{
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    self.activityView = nil;
}

- (void)authorizationViewControllerDidCancel:(BoxAuthorizationViewController *)authorizationViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)authorizationViewController:(BoxAuthorizationViewController *)authorizationViewController shouldLoadReceivedOAuth2RedirectRequest:(NSURLRequest *)request
{
    [[BoxSDK sharedSDK].OAuth2Session performAuthorizationCodeGrantWithReceivedURL:request.URL];
    return NO;
}

@end
