//
//  BoxSerialOAuth2SessionTests.m
//  BoxSDK
//
//  Created on 3/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSerialOAuth2SessionTests.h"
#import "BoxSDKTestsHelpers.h"

#import "BoxSerialOAuth2Session.h"
#import "BoxAPIOAuth2ToJSONOperation.h"
#import "BoxSerialAPIQueueManager.h"
#import "BoxSDKConstants.h"
#import "NSString+BoxURLHelper.h"
#import "NSURL+BoxURLHelper.h"

#import <OCMock/OCMock.h>

@implementation BoxSerialOAuth2SessionTests

- (void)setUp
{
    // mock data
    clientID = @"abc123";
    clientSecret = @"nosecret";
    authorizationCode = @"12345";
}

- (void)testThatAuthorizationCodeGrantEnqueuesBoxAPIOauth2ToJSONOperation
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];


    id checkBlock = ^BOOL(id operation)
    {
        return [operation isKindOfClass:[BoxAPIOAuth2ToJSONOperation class]];
    };
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
}

// @see developers.box.com/oauth/
- (void)testThatAuthorizationCodeGrantEnqueuesOperationWithBoxOAuth2TokenURL
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    NSURL *expectedOAuth2URL = [NSURL URLWithString:[BoxAPIBaseURL stringByAppendingString:@"/oauth2/token"]];
    
    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;

        // both base url and actual request URL match url in Box Documentation.
        // This means this request has no query string parameters.
        return [OAuth2Operation.baseRequestURL isEqual:expectedOAuth2URL] && [OAuth2Operation.APIRequest.URL isEqual:expectedOAuth2URL];
    };
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
}

// @see developers.box.com/oauth/
- (void)testThatAuthorizationCodeGrantEnqueuesOperationWithBoxOauth2POSTParameters
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    NSDictionary *expectedMultipartPostParams = @{ @"grant_type" : @"authorization_code",
                                                   @"code" : @"12345",
                                                   @"client_id" : clientID,
                                                   @"client_secret" : clientSecret,
                                                   @"redirect_uri" : redirectURLString, };
    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;

        // Multipart POST params match those required by the Box Documentation.
        return [OAuth2Operation.body isEqualToDictionary:expectedMultipartPostParams];
    };
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
}

// @see developers.box.com/oauth/
- (void)testThatAuthorizationCodeGrantEnqueuesOperationAsPOSTRequest
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;
        return [OAuth2Operation.HTTPMethod isEqualToString:BoxAPIHTTPMethodPOST];
    };
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
}

- (void)testThatAuthorizationCodeOperationHasNonNilSuccessBlock
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;

        // Success block expected to be non nil
        return OAuth2Operation.success != nil;
    };
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
}


- (void)testThatAuthorizationCodeOperationPostsDidBecomeAuthenitcatedNotificationOnSuccess
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    NSDictionary *dummySuccessJSONDictionary = @{BoxOAuth2TokenJSONExpiresInKey : @3600,
                                                 BoxOAuth2TokenJSONAccessTokenKey : @"abc",
                                                 BoxOAuth2TokenJSONRefreshTokenKey : @"xyz"};

    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];

    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;

        // manually trigger success callback. Operations tests assert that this callback is called on success
        OAuth2Operation.success(nil, nil, dummySuccessJSONDictionary);

        return YES;
    };

    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    // observer mock
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:BoxOAuth2SessionDidBecomeAuthenticatedNotification object:nil];
    [[observerMock expect] notificationWithName:BoxOAuth2SessionDidBecomeAuthenticatedNotification object:OAuth2];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
    [observerMock verify];
}

- (void)testThatAuthorizationCodeOperationHasNonNilFailureBlock
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;

        // Failure block expected to be non nil
        return OAuth2Operation.failure != nil;
    };
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
}

- (void)testThatAuthorizationCodeOperationPostsAuthenitcationFailureNotificationOnFailure
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    NSString *receivedRedirectURLString = [redirectURLString stringByAppendingFormat:@"?code=%@", authorizationCode];
    NSURL *dummyReceivedRedirectURL = [NSURL URLWithString:receivedRedirectURLString];

    // @TODO: use a real NSError
    NSError *dummyError = [[NSError alloc] init];

    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];

    id checkBlock = ^BOOL(id operation)
    {
        BoxAPIOAuth2ToJSONOperation *OAuth2Operation = (BoxAPIOAuth2ToJSONOperation *)operation;

        // trigger failure callback. Operations tests assert that this callback is called on failure
        OAuth2Operation.failure(nil, nil, dummyError, nil);

        return YES;
    };

    [[queueManagerMock expect] enqueueOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:queueManagerMock];

    // observer mock
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification object:nil];
    [[observerMock expect] notificationWithName:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification object:OAuth2 userInfo:@{
           BoxOAuth2AuthenticationErrorKey : dummyError,
     }];

    [OAuth2 performAuthorizationCodeGrantWithReceivedURL:dummyReceivedRedirectURL];

    [queueManagerMock verify];
    [observerMock verify];
}

// @see developers.box.com/oauth/
- (void)testThatAuthorizeURLMatchesBoxDocumentation
{
    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:nil];

    NSURL *actualURL = [OAuth2 authorizeURL];
    NSString *expectedURLStringWithoutQueryParams = [NSString stringWithFormat:@"%@/oauth2/authorize", BoxAPIBaseURL];

    NSString *urlStringWithoutQueryParams = (NSString *)[[[actualURL absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
    STAssertEqualObjects(expectedURLStringWithoutQueryParams, urlStringWithoutQueryParams, @"Authorize URL did not match expected");
}

// @see developers.box.com/oauth/
- (void)testThatAuthorizeURLQueryParametersMatchBoxDocumentation
{
    NSString *redirectURLString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:nil];

    NSURL *actualURL = [OAuth2 authorizeURL];
    NSDictionary *expectedQueryDictionary = @{ @"response_type" : @"code",
                                               @"client_id" : clientID,
                                               @"state" : @"ok",
                                               @"redirect_uri" : [NSString box_stringWithString:redirectURLString URLEncoded:YES], };

    STAssertEqualObjects(expectedQueryDictionary, [actualURL box_queryDictionary], @"Expected query params did not match actual authorize query params");
}


// @see developers.box.com/oauth/
- (void)testThatGrantTokensURLMatchesBoxDocumentation
{
    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:nil];

    NSURL *expectedGrantTokensURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/token", BoxAPIBaseURL]];
    NSURL *actualGrantTokensURL = [OAuth2 grantTokensURL];

    STAssertEqualObjects(expectedGrantTokensURL, actualGrantTokensURL, @"Grant tokens URL did not match expected");
}

- (void)testThatSDKRedirectURIStringIsConsistent
{
    // the SDK standard redirect URI is boxsdk-clientID://boxsdkoauth2redirect
    NSString *expectedRedirectURIString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    BoxSerialOAuth2Session *OAuth2 = [[BoxSerialOAuth2Session alloc] initWithClientID:clientID secret:clientSecret APIBaseURL:BoxAPIBaseURL queueManager:nil];

    NSString *actualRedirectURIString = [OAuth2 redirectURIString];

    STAssertEqualObjects(expectedRedirectURIString, actualRedirectURIString, @"SDK redirect URI does not match expected");

    // test with a different client ID
    clientID = @"anotherclientID";
    expectedRedirectURIString = [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", clientID];

    OAuth2.clientID = clientID;

    actualRedirectURIString = [OAuth2 redirectURIString];

    STAssertEqualObjects(expectedRedirectURIString, actualRedirectURIString, @"SDK redirect URI does not match expected");
}

@end
