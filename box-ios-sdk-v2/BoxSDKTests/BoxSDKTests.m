//
//  BoxSDKTests.m
//  BoxSDKTests
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxCocoaSDKTests/BoxCocoaSDKTests.m. Changes made here should be reflected there.
//

#import "BoxSDKTests.h"

#import "BoxSDK.h"

@implementation BoxSDKTests

- (void)setUp
{
    SDK = [[BoxSDK alloc] init];
    SDK.OAuth2Session = [[BoxSerialOAuth2Session alloc] init];
    SDK.APIBaseURL = BoxAPIBaseURL;
}

- (void)testThatSDKURLAndOAuth2URLAreKeptInSyncBySetter
{
    NSString *APIBaseURL = @"https://dick.in.a.box.com/api";

    // precondition
    STAssertFalse([SDK.OAuth2Session.APIBaseURLString isEqualToString:APIBaseURL], @"OAuth2 base URL is not different from test target URL");

    SDK.APIBaseURL = APIBaseURL;

    STAssertEqualObjects(SDK.APIBaseURL, SDK.OAuth2Session.APIBaseURLString, @"Shared SDK and OAuth2 base URLs are not in sync");

}

- (void)testThatSDKAndOAuth2SessionAreConstructedWithSameAPIUrl
{
    STAssertEquals([BoxSDK sharedSDK].APIBaseURL, [BoxSDK sharedSDK].OAuth2Session.APIBaseURLString, @"BoxSDK and OAuth2Session were not constructed with the same API base URL");
}

- (void)testThatSingletonSDKIsOnlyInstantiatedOnce
{
    BoxSDK *firstSingletonSDK = [BoxSDK sharedSDK];
    BoxSDK *secondSingletonSDK = [BoxSDK sharedSDK];

    STAssertTrue(firstSingletonSDK == secondSingletonSDK, @"multiple invocations of [BoxSDK sharedSDK] should refer to the same object");
}

@end
