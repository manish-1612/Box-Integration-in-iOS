//
//  BoxCommentsResourceManagerTests.m
//  BoxSDK
//
//  Created on 11/21/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxCommentsResourceManagerTests.h"

#import "BoxSDKTestsHelpers.h"

#import "BoxAPIJSONOperation.h"
#import "BoxCommentsRequestBuilder.h"
#import "BoxCommentsResourceManager.h"
#import "BoxSDKConstants.h"
#import "BoxSerialOAuth2Session.h"
#import "BoxSerialAPIQueueManager.h"
#import "NSURL+BoxURLHelper.h"

#import <OCMock/OCMock.h>

#define BEARER_TOKEN_VALUE (@"bearertoken")
#define COMMENTS_RESOURCE   (@"comments")

@implementation BoxCommentsResourceManagerTests

- (void)setUp
{
    APIBaseURL = @"https://api.box.com";
    APIVersion = @"2.0";
    OAuth2Session = [[BoxSerialOAuth2Session alloc] init];
    OAuth2Session.accessToken = BEARER_TOKEN_VALUE;
    queue = nil;
    commentsManager = [[BoxCommentsResourceManager alloc] initWithAPIBaseURL:APIBaseURL OAuth2Session:OAuth2Session queueManager:nil];
    
    commentID = @"13570";
}

#pragma mark - Comment Info Tests

- (void)testThatCommentInfoReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"comment info should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatCommentInfoReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, COMMENTS_RESOURCE, commentID];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"comment info URL should match docs");
}

- (void)testThatCommentInfoIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatCommentInfoDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] init];
    builder.message = @"foobar";
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:builder success:nil failure:nil];
    
    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatCommentInfoWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxCommentBlock successBlock = ^(BoxComment *comment)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Comment block should be called when the operation's success block is called");
}

- (void)testThatCommentInfoSuccessBlockIsPassedABoxComment
{
    BoxCommentBlock successBlock = ^(BoxComment *comment)
    {
        STAssertTrue([comment isMemberOfClass:[BoxComment class]], @"success block should be passed a BoxComment");
    };
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatCommentInfoSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatCommentInfoEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    commentsManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatCommentInfoPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [commentsManager commentInfoWithID:commentID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the comments manager");
}

#pragma mark - Create Comment Tests

- (void)testThatCreateCommentReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"create comment should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatCreateCommentReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@", APIBaseURL, APIVersion, COMMENTS_RESOURCE];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"create comment URL should match docs");
}

- (void)testThatCreateCommentIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatCreateCommentDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] init];
    builder.message = @"foobar";
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:builder success:nil failure:nil];
    
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];
    
    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatCreateCommentWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxCommentBlock successBlock = ^(BoxComment *comment)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Comment block should be called when the operation's success block is called");
}

- (void)testThatCreateCommentSuccessBlockIsPassedABoxComment
{
    BoxCommentBlock successBlock = ^(BoxComment *comment)
    {
        STAssertTrue([comment isMemberOfClass:[BoxComment class]], @"success block should be passed a BoxComment");
    };
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatCreateCommentSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatCreateCommentEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    commentsManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatCreateCommentPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the comments manager");
}

#pragma mark - Edit Comment Tests

- (void)testThatEditCommentReturnsOperationWithHTTPPUTMethod
{
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodPUT, operation.APIRequest.HTTPMethod, @"edit comment should be a PUT request");
}

// @see developers.box.com/docs/
- (void)testThatEditCommentReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, COMMENTS_RESOURCE, commentID];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"edit comment URL should match docs");
}

- (void)testThatEditCommentIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatEditCommentDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] init];
    builder.message = @"foobar";
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:builder success:nil failure:nil];
    
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];
    
    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatEditCommentWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxCommentBlock successBlock = ^(BoxComment *comment)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Comment block should be called when the operation's success block is called");
}

- (void)testThatEditCommentSuccessBlockIsPassedABoxComment
{
    BoxCommentBlock successBlock = ^(BoxComment *comment)
    {
        STAssertTrue([comment isMemberOfClass:[BoxComment class]], @"success block should be passed a BoxComment");
    };
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatEditCommentSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatEditCommentEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    commentsManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [commentsManager createCommentWithRequestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatEditCommentPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [commentsManager editCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the comments manager");
}

#pragma mark - Delete Comment Tests

- (void)testThatDeleteCommentReturnsOperationWithHTTPDELETEMethod
{
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    
    STAssertEqualObjects(BoxAPIHTTPMethodDELETE, operation.APIRequest.HTTPMethod, @"delete comment should be a DELETE request");
}

// @see developers.box.com/docs/
- (void)testThatDeleteCommentReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, COMMENTS_RESOURCE, commentID];
    
    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"delete comment URL should match docs");
}

- (void)testThatDeleteCommentIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:builder success:nil failure:nil];
    
    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatDeleteCommentDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxCommentsRequestBuilder *builder = [[BoxCommentsRequestBuilder alloc] init];
    builder.message = @"foobar";
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:builder success:nil failure:nil];
    
    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDeleteCommentWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *commentID)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Comment block should be called when the operation's success block is called");
}

- (void)testThatDeleteCommentSuccessBlockIsPassedANSStringcommentID
{
    NSString *const expectedcommentID = commentID;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *receivedcommentID)
    {
        STAssertEqualObjects(expectedcommentID, receivedcommentID, @"success block should recieve comment id of deleted comment");
    };
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:successBlock failure:nil];
    
    operation.success(nil, nil, nil);
}

- (void)testThatDeleteCommentSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:nil failure:failureBlock];
    
    operation.failure(nil, nil, nil, nil);
    
    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDeleteCommentEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    commentsManager.queueManager = queueManagerMock;
    
    __unused BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatDeleteCommentPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [commentsManager deleteCommentWithID:commentID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the comments manager");
}

@end
