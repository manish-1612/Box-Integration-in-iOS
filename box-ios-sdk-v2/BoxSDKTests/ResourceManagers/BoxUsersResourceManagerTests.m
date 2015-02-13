//
//  BoxUsersResourceManagerTests.m
//  BoxSDK
//
//  Created on 8/16/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxUsersResourceManagerTests.h"

#import "BoxSDKTestsHelpers.h"

#import "BoxAPIJSONOperation.h"
#import "BoxUsersRequestBuilder.h"
#import "BoxUsersResourceManager.h"
#import "BoxSDKConstants.h"
#import "BoxSerialOAuth2Session.h"
#import "BoxSerialAPIQueueManager.h"
#import "NSURL+BoxURLHelper.h"

#import <OCMock/OCMock.h>

#define BEARER_TOKEN_VALUE (@"bearertoken")
#define USERS_RESOURCE   (@"users")

@implementation BoxUsersResourceManagerTests

- (void)setUp
{
    APIBaseURL = @"https://api.box.com";
    APIVersion = @"2.0";
    OAuth2Session = [[BoxSerialOAuth2Session alloc] init];
    OAuth2Session.accessToken = BEARER_TOKEN_VALUE;
    queue = nil;
    usersManager = [[BoxUsersResourceManager alloc] initWithAPIBaseURL:APIBaseURL OAuth2Session:OAuth2Session queueManager:nil];
    
    userID = @"13570";
}

#pragma mark - User Info Tests

- (void)testThatUserInfoReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"user info should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatUserInfoReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, USERS_RESOURCE, userID];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"user info URL should match docs");
}

- (void)testThatUserInfoIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatUserInfoDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:builder success:nil failure:nil];
    
    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatUserInfoWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxUserBlock successBlock = ^(BoxUser *user)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"User block should be called when the operation's success block is called");
}

- (void)testThatUserInfoSuccessBlockIsPassedABoxUser
{
    BoxUserBlock successBlock = ^(BoxUser *user)
    {
        STAssertTrue([user isMemberOfClass:[BoxUser class]], @"success block should be passed a BoxUser");
    };
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatUserInfoSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatUserInfoEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    usersManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatUserInfoPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [usersManager userInfoWithID:userID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the users manager");
}

#pragma mark - User Infos Tests

- (void)testThatUserInfosReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"user info should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatUserInfosReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@", APIBaseURL, APIVersion, USERS_RESOURCE];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"user info URL should match docs");
}

- (void)testThatUserInfosIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [usersManager userInfos:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatUserInfosDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [usersManager userInfos:builder success:nil failure:nil];
    
    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatUserInfosWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxCollectionBlock successBlock = ^(BoxCollection *collection)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"User block should be called when the operation's success block is called");
}

- (void)testThatUserInfosSuccessBlockIsPassedABoxCollection
{
    BoxCollectionBlock successBlock = ^(BoxCollection *collection)
    {
        STAssertTrue([collection isMemberOfClass:[BoxCollection class]], @"success block should be passed a BoxCollection");
    };
    BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatUserInfosSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatUserInfosEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    usersManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatUserInfosPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [usersManager userInfos:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the users manager");
}


#pragma mark - Create User Tests

- (void)testThatCreateUserReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"create user should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatCreateUserReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@", APIBaseURL, APIVersion, USERS_RESOURCE];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"create user URL should match docs");
}

- (void)testThatCreateUserIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatCreateUserDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:builder success:nil failure:nil];
    
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];
    
    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatCreateUserWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxUserBlock successBlock = ^(BoxUser *user)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"User block should be called when the operation's success block is called");
}

- (void)testThatCreateUserSuccessBlockIsPassedABoxUser
{
    BoxUserBlock successBlock = ^(BoxUser *user)
    {
        STAssertTrue([user isMemberOfClass:[BoxUser class]], @"success block should be passed a BoxUser");
    };
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatCreateUserSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatCreateUserEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    usersManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatCreateUserPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the users manager");
}

#pragma mark - Edit User Tests

- (void)testThatEditUserReturnsOperationWithHTTPPUTMethod
{
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodPUT, operation.APIRequest.HTTPMethod, @"edit user should be a PUT request");
}

// @see developers.box.com/docs/
- (void)testThatEditUserReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, USERS_RESOURCE, userID];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"edit user URL should match docs");
}

- (void)testThatEditUserIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatEditUserDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:builder success:nil failure:nil];
    
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];
    
    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatEditUserWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxUserBlock successBlock = ^(BoxUser *user)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"User block should be called when the operation's success block is called");
}

- (void)testThatEditUserSuccessBlockIsPassedABoxUser
{
    BoxUserBlock successBlock = ^(BoxUser *user)
    {
        STAssertTrue([user isMemberOfClass:[BoxUser class]], @"success block should be passed a BoxUser");
    };
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatEditUserSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatEditUserEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    usersManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [usersManager createUserWithRequestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatEditUserPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [usersManager editUserWithID:userID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the users manager");
}

#pragma mark - Delete User Tests

- (void)testThatDeleteUserReturnsOperationWithHTTPDELETEMethod
{
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodDELETE, operation.APIRequest.HTTPMethod, @"delete user should be a DELETE request");
}

// @see developers.box.com/docs/
- (void)testThatDeleteUserReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, USERS_RESOURCE, userID];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"delete user URL should match docs");
}

- (void)testThatDeleteUserIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatDeleteUserDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxUsersRequestBuilder *builder = [[BoxUsersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:builder success:nil failure:nil];
    
    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDeleteUserWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *userID)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"User block should be called when the operation's success block is called");
}

- (void)testThatDeleteUserSuccessBlockIsPassedANSStringuserID
{
    NSString *const expecteduserID = userID;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *receiveduserID)
    {
        STAssertEqualObjects(expecteduserID, receiveduserID, @"success block should recieve user id of deleted user");
    };
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatDeleteUserSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDeleteUserEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    usersManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatDeleteUserPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [usersManager deleteUserWithID:userID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the users manager");
}

@end
