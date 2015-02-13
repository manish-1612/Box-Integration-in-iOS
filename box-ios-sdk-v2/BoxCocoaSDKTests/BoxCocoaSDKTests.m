//
//  BoxCocoaSDKTests.m
//  BoxCocoaSDKTests
//
//  Created on 7/29/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxSDKTests/BoxSDKTests.m. Changes made here should be reflected there.
//

#import "BoxCocoaSDKTests.h"

#import "BoxCocoaSDK.h"

@implementation BoxCocoaSDKTests

- (void)setUp
{
    SDK = [[BoxCocoaSDK alloc] init];
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
    STAssertEquals([BoxCocoaSDK sharedSDK].APIBaseURL, [BoxCocoaSDK sharedSDK].OAuth2Session.APIBaseURLString, @"BoxCocoaSDK and OAuth2Session were not constructed with the same API base URL");
}

- (void)testThatSingletonSDKIsOnlyInstantiatedOnce
{
    BoxCocoaSDK *firstSingletonSDK = [BoxCocoaSDK sharedSDK];
    BoxCocoaSDK *secondSingletonSDK = [BoxCocoaSDK sharedSDK];
    
    STAssertTrue(firstSingletonSDK == secondSingletonSDK, @"multiple invocations of [BoxCocoaSDK sharedSDK] should refer to the same object");
}

@end
