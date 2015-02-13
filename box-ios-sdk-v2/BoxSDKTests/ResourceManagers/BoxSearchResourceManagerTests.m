//
//  BoxSearchResourceManagerTests.m
//  BoxSDK
//
//  Created by Ryan Lopopolo on 11/21/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSearchResourceManagerTests.h"

#import "BoxCollection.h"
#import "BoxSearchResourceManager.h"
#import "BoxSerialOAuth2Session.h"
#import "BoxSerialAPIQueueManager.h"
#import "NSURL+BoxURLHelper.h"
#import "BoxSearchRequestBuilder.h"

#import "BoxSDKTestsHelpers.h"
#import <OCMock/OCMock.h>

#define TEST_QUERY         (@"Which seat shall I take?")
#define TEST_QUERY_ENCODED (@"Which%20seat%20shall%20I%20take%3F")
#define BEARER_TOKEN_VALUE (@"accesstoken")
#define SEARCH_RESOURCE    (@"search")


@implementation BoxSearchResourceManagerTests

- (void)setUp
{
    APIBaseURL = @"https://api.box.com";
    APIVersion = @"2.0";
    OAuth2Session = [[BoxSerialOAuth2Session alloc] init];
    OAuth2Session.accessToken = BEARER_TOKEN_VALUE;
    queue = nil;
    searchManager = [[BoxSearchResourceManager alloc] initWithAPIBaseURL:APIBaseURL OAuth2Session:OAuth2Session queueManager:nil];

    query = TEST_QUERY;
}

#pragma mark - search Tests

- (void)testThatSearchReturnsOperationWithHTTPGETMethod
{
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"search should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatSearchReturnsOperationWithDocumentedURL
{
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@?query=%@", APIBaseURL, APIVersion, SEARCH_RESOURCE, TEST_QUERY_ENCODED];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"search URL should match docs");
}

- (void)testThatSearchIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"query" : TEST_QUERY_ENCODED};
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatSearchDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatSearchWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxCollectionBlock successBlock = ^(BoxCollection *results)
    {
        blockCalled = YES;
    };
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:successBlock failureBlock:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"User block should be called when the operation's success block is called");
}

- (void)testThatSearchSuccessBlockIsPassedABoxUser
{
    BoxCollectionBlock successBlock = ^(BoxCollection *results)
    {
        STAssertTrue([results isMemberOfClass:[BoxCollection class]], @"success block should be passed a BoxCollection");
    };
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:successBlock failureBlock:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatSearchSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatSearchEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    searchManager.queueManager = queueManagerMock;

    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    __unused BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:nil];
    [queueManagerMock verify];
}

- (void)testThatSearchPassesOAuth2SessionToOperation
{
    BoxSearchRequestBuilder *builder = [[BoxSearchRequestBuilder alloc] initWithSearch:TEST_QUERY queryStringParameters:nil];
    BoxAPIJSONOperation *operation = [searchManager searchWithBuilder:builder successBlock:nil failureBlock:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the users manager");
}


@end
