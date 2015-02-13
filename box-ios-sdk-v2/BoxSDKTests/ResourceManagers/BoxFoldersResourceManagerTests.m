//
//  BoxFoldersResourceManagerTests.m
//  BoxSDK
//
//  Created on 3/28/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFoldersResourceManagerTests.h"
#import "BoxSDKTestsHelpers.h"

#import "BoxAPIJSONOperation.h"
#import "BoxFoldersRequestBuilder.h"
#import "BoxFoldersResourceManager.h"
#import "BoxSDKConstants.h"
#import "BoxSerialOAuth2Session.h"
#import "BoxSerialAPIQueueManager.h"
#import "NSURL+BoxURLHelper.h"

#import <OCMock/OCMock.h>

#define BEARER_TOKEN_VALUE (@"bearertoken")
#define FOLDERS_RESOURCE   (@"folders")
#define FOLDERS_ITEMS      (@"items")
#define FOLDERS_COPY       (@"copy")
#define FOLDERS_TRASH      (@"trash")

@implementation BoxFoldersResourceManagerTests

- (void)setUp
{
    APIBaseURL = @"https://api.box.com";
    APIVersion = @"2.0";
    OAuth2Session = [[BoxSerialOAuth2Session alloc] init];
    OAuth2Session.accessToken = BEARER_TOKEN_VALUE;
    queue = nil;
    foldersManager = [[BoxFoldersResourceManager alloc] initWithAPIBaseURL:APIBaseURL OAuth2Session:OAuth2Session queueManager:nil];

    folderID = @"12345";
}

#pragma mark - Folder Info Tests

- (void)testThatFolderInfoReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"folder info should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatFolderInfoReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"folder info URL should match docs");
}

- (void)testThatFolderInfoIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatFolderInfoDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatFolderInfoWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatFolderInfoSuccessBlockIsPassedABoxFolder
{
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        STAssertTrue([folder isMemberOfClass:[BoxFolder class]], @"success block should be passed a BoxFolder");
    };
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatFolderInfoSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatFolderInfoEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatFolderInfoPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager folderInfoWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Create Folder Tests

- (void)testThatCreateFolderReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"create folder should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatCreateFolderReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"create folder URL should match docs");
}

- (void)testThatCreateFolderIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatCreateFolderDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:builder success:nil failure:nil];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];

    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatCreateFolderWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatCreateFolderSuccessBlockIsPassedABoxFolder
{
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        STAssertTrue([folder isMemberOfClass:[BoxFolder class]], @"success block should be passed a BoxFolder");
    };
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatCreateFolderSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatCreateFolderEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatCreateFolderPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Folder Items Tests

- (void)testThatFolderItemsReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"folder items should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatFolderItemsReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID, FOLDERS_ITEMS];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"folder items URL should match docs");
}

- (void)testThatFolderItemsIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatFolderItemsDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatFolderItemsWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxCollectionBlock successBlock = ^(BoxCollection *items)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Collection block should be called when the operation's success block is called");
}

- (void)testThatFolderItemsSuccessBlockIsPassedABoxCollection
{
    BoxCollectionBlock successBlock = ^(BoxCollection *items)
    {
        STAssertTrue([items isMemberOfClass:[BoxCollection class]], @"success block should be passed a BoxCollection");
    };
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatFolderItemsSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatFolderItemsEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatFolderItemsPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager folderItemsWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Edit Folder Tests

- (void)testThatEditFolderReturnsOperationWithHTTPPUTMethod
{
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPUT, operation.APIRequest.HTTPMethod, @"edit folder should be a PUT request");
}

// @see developers.box.com/docs/
- (void)testThatEditFolderReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"edit folder URL should match docs");
}

- (void)testThatEditFolderIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatEditFolderDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:builder success:nil failure:nil];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];

    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatEditFolderWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatEditFolderSuccessBlockIsPassedABoxFolder
{
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        STAssertTrue([folder isMemberOfClass:[BoxFolder class]], @"success block should be passed a BoxFolder");
    };
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatEditFolderSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatEditFolderEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager createFolderWithRequestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatEditFolderPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager editFolderWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Delete Folder Tests

- (void)testThatDeleteFolderReturnsOperationWithHTTPDELETEMethod
{
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodDELETE, operation.APIRequest.HTTPMethod, @"delete folder should be a DELETE request");
}

// @see developers.box.com/docs/
- (void)testThatDeleteFolderReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"delete folder URL should match docs");
}

- (void)testThatDeleteFolderIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatDeleteFolderDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDeleteFolderWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *folderID)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatDeleteFolderSuccessBlockIsPassedANSStringFolderID
{
    NSString *const expectedFolderID = folderID;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *receivedFolderID)
    {
        STAssertEqualObjects(expectedFolderID, receivedFolderID, @"success block should recieve folder id of deleted folder");
    };
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatDeleteFolderSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDeleteFolderEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatDeleteFolderPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Copy Folder Tests

- (void)testThatCopyFolderReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"copy folder should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatCopyFolderReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID, FOLDERS_COPY];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"copy folder URL should match docs");
}

- (void)testThatCopyFolderIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatCopyFolderDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:builder success:nil failure:nil];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];

    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatCopyFolderWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatCopyFolderSuccessBlockIsPassedABoxFolder
{
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        STAssertTrue([folder isMemberOfClass:[BoxFolder class]], @"success block should be passed a BoxFolder");
    };
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatCopyFolderSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatCopyFolderEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatCopyFolderPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager copyFolderWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Folder Info from Trash Tests

- (void)testThatFolderInfoFromTrashReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"folder info from trash should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatFolderInfoFromTrashReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID, FOLDERS_TRASH];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"folder info from trash URL should match docs");
}

- (void)testThatFolderInfoFromTrashIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// GET request should have no body
- (void)testThatFolderInfoFromTrashDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatFolderInfoFromTrashWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatFolderInfoFromTrashSuccessBlockIsPassedABoxFolder
{
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        STAssertTrue([folder isMemberOfClass:[BoxFolder class]], @"success block should be passed a BoxFolder");
    };
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatFolderInfoFromTrashSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatFolderInfoFromTrashEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatFolderInfoFromTrashPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager folderInfoFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Create Folder Tests

- (void)testThatRestoreFolderFromTrashReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"restore folder from trash should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatRestoreFolderFromTrashReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"restore folder from trash URL should match docs");
}

- (void)testThatRestoreFolderFromTrashIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatRestoreFolderFromTrashDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:builder success:nil failure:nil];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];

    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatRestoreFolderFromTrashWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatRestoreFolderFromTrashSuccessBlockIsPassedABoxFolder
{
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        STAssertTrue([folder isMemberOfClass:[BoxFolder class]], @"success block should be passed a BoxFolder");
    };
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatRestoreFolderFromTrashSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatRestoreFolderFromTrashEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatRestoreFolderFromTrashPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Delete Folder from Trash Tests

- (void)testThatDeleteFolderFromTrashReturnsOperationWithHTTPDELETEMethod
{
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodDELETE, operation.APIRequest.HTTPMethod, @"delete folder from trash should be a DELETE request");
}

// @see developers.box.com/docs/
- (void)testThatDeleteFolderFromTrashReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FOLDERS_RESOURCE, folderID, FOLDERS_TRASH];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"delete folder from trash URL should match docs");
}

- (void)testThatDeleteFolderFromTrashIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatDeleteFolderFromTrashDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDeleteFolderFromTrashWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *folderID)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"Folder block should be called when the operation's success block is called");
}

- (void)testThatDeleteFolderFromTrashSuccessBlockIsPassedANSStringFolderID
{
    NSString *const expectedFolderID = folderID;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *receivedFolderID)
    {
        STAssertEqualObjects(expectedFolderID, receivedFolderID, @"success block should recieve folder id of deleted folder");
    };
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatDeleteFolderFromTrashSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDeleteFolderFromTrashEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    foldersManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatDeleteFolderFromTrashPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [foldersManager deleteFolderFromTrashWithID:folderID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

@end
