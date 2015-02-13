//
//  BoxOAuth2SessionTests.m
//  BoxSDK
//
//  Created on 3/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxOAuth2SessionTests.h"

#import "BoxOAuth2Session.h"

@implementation BoxOAuth2SessionTests

- (void)testThatOAuth2SessionAddsBearerTokenToRequest
{
    NSString *dummyAccessToken = @"accesstoken";
    NSString *expectedAuthorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", dummyAccessToken];

    BoxOAuth2Session *OAuth2 = [[BoxOAuth2Session alloc] initWithClientID:nil secret:nil APIBaseURL:nil queueManager:nil];
    OAuth2.accessToken = dummyAccessToken;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [OAuth2 addAuthorizationParametersToRequest:request];

    STAssertEqualObjects(expectedAuthorizationHeaderValue, [request valueForHTTPHeaderField:@"Authorization"], @"Authorization header should include Bearer token");
}

- (void)testThatOAuth2SessionOnlyAddsOneHeaderToRequest
{
    NSString *dummyAccessToken = @"accesstoken";

    BoxOAuth2Session *OAuth2 = [[BoxOAuth2Session alloc] initWithClientID:nil secret:nil APIBaseURL:nil queueManager:nil];
    OAuth2.accessToken = dummyAccessToken;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [OAuth2 addAuthorizationParametersToRequest:request];

    NSDictionary *actualHeaders = [request allHTTPHeaderFields];
    STAssertEquals((NSUInteger)1U, actualHeaders.count, @"OAuth2 should add only one header to request");
}

@end
