//
//  BoxFilesResourceManagerTests.m
//  BoxSDK
//
//  Created on 4/2/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFilesResourceManagerTests.h"
#import "BoxSDKTestsHelpers.h"

#import "BoxFilesResourceManager.h"
#import "BoxFilesRequestBuilder.h"
#import "BoxFile.h"
#import "BoxSerialAPIQueueManager.h"
#import "BoxSerialOAuth2Session.h"

#import "NSURL+BoxURLHelper.h"

#import <OCMock/OCMock.h>

#define BEARER_TOKEN_VALUE (@"accesstoken")
#define FILES_RESOURCE     (@"files")
#define FILES_COPY         (@"copy")
#define FILES_CONTENT      (@"content")
#define FILES_THUMBNAIL    (@"thumbnail.png")

@implementation BoxFilesResourceManagerTests

- (void)setUp
{
    APIBaseURL = @"https://api.box.com";
    APIVersion = @"2.0";
    APIBaseUploadURL = @"https://upload.box.com/api";
    APIUploadVersion = @"2.1";
    OAuth2Session = [[BoxSerialOAuth2Session alloc] init];
    OAuth2Session.accessToken = BEARER_TOKEN_VALUE;
    queue = nil;
    filesManager = [[BoxFilesResourceManager alloc] initWithAPIBaseURL:APIBaseURL OAuth2Session:OAuth2Session queueManager:nil];
    filesManager.uploadBaseURL = APIBaseUploadURL;
    filesManager.uploadAPIVersion = APIUploadVersion;

    fileID = @"12345";
}

#pragma mark - File Info Tests

- (void)testThatFileInfoReturnsOperationWithHTTPGETMethod
{
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"file info should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatFileInfoReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FILES_RESOURCE, fileID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file info URL should match docs");
}

- (void)testThatFileInfoIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatFileInfoDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatFileInfoWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatFileInfoSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatFileInfoSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatFileInfoEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatFileInfoPassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [filesManager fileInfoWithID:fileID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Edit File Tests

- (void)testThatEditFileReturnsOperationWithHTTPPUTMethod
{
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPUT, operation.APIRequest.HTTPMethod, @"file edit should be a PUT request");
}

// @see developers.box.com/docs/
- (void)testThatEditFileReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FILES_RESOURCE, fileID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file edit URL should match docs");
}

- (void)testThatEditFileIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatEditFileDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:builder success:nil failure:nil];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];

    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatEditFileWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatEditFileSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatEditFileSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatEditFileEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatEditFilePassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [filesManager editFileWithID:fileID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Copy File Tests

- (void)testThatCopyFileReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"file copy should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatCopyFileReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FILES_RESOURCE, fileID, FILES_COPY];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file copy URL should match docs");
}

- (void)testThatCopyFileIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatCopyFileDoesIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:builder success:nil failure:nil];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:builder.bodyParameters options:0 error:nil];

    STAssertEqualObjects(expectedData, operation.APIRequest.HTTPBody, @"body parameters from builder should be included with the request");
}

- (void)testThatCopyFileWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatCopyFileSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatCopyFileSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatCopyFileEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatCopyFilePassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [filesManager copyFileWithID:fileID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Delete File Tests

- (void)testThatDeleteFileReturnsOperationWithHTTPDELETEMethod
{
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodDELETE, operation.APIRequest.HTTPMethod, @"file delete should be a DELETE request");
}

// @see developers.box.com/docs/
- (void)testThatDeleteFileReturnsOperationWithDocumentedURL
{
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseURL, APIVersion, FILES_RESOURCE, fileID];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file delete URL should match docs");
}

- (void)testThatDeleteFileIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:builder success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatDeleteFileDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:builder success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDeleteFileWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *deletedFileID)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatDeleteFileSuccessBlockIsPassedAFileID
{
    BoxSuccessfulDeleteBlock successBlock = ^(NSString *deletedFileID)
    {
        STAssertEqualObjects(fileID, deletedFileID, @"expected to delete file ID passed to manager");
    };
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:successBlock failure:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatDeleteFileSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:nil failure:failureBlock];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDeleteFileEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:nil failure:nil];
    [queueManagerMock verify];
}

- (void)testThatDeleteFilePassesOAuth2SessionToOperation
{
    BoxAPIJSONOperation *operation = [filesManager deleteFileWithID:fileID requestBuilder:nil success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Upload file with NSData

- (void)testThatUploadFileWithDataReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"file upload should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatUploadFileWithDataReturnsOperationWithDocumentedURL
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseUploadURL, APIUploadVersion, FILES_RESOURCE, FILES_CONTENT];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file upload URL should match docs");
}

- (void)testThatUploadFileWithDataIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// the HTTP body is encoded as multipart pieces
- (void)testThatUploadFileWithDataDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatUploadFileWithDataWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatUploadFileWithDataSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatUploadFileWithDataSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:failureBlock progress:nil];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatUploadFileWithDataEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];
    [queueManagerMock verify];
}

- (void)testThatUploadFileWithDataPassesOAuth2SessionToOperation
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithData:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Upload file with NSInputStream

- (void)testThatUploadFileWithInputStreamReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"file upload should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatUploadFileWithInputStreamReturnsOperationWithDocumentedURL
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@", APIBaseUploadURL, APIUploadVersion, FILES_RESOURCE, FILES_CONTENT];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file upload URL should match docs");
}

- (void)testThatUploadFileWithInputStreamIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// the HTTP body is encoded as multipart pieces
- (void)testThatUploadFileWithInputStreamDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatUploadFileWithInputStreamWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatUploadFileWithInputStreamSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatUploadFileWithInputStreamSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:failureBlock progress:nil];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatUploadFileWithInputStreamEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    [queueManagerMock verify];
}

- (void)testThatUploadFileWithInputStreamPassesOAuth2SessionToOperation
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager uploadFileWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Overwrite file with NSData

- (void)testThatOverwriteFileWithDataReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"file overwrite should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatOverwriteFileWithDataReturnsOperationWithDocumentedURL
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseUploadURL, APIUploadVersion, FILES_RESOURCE, fileID, FILES_CONTENT];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file overwrite URL should match docs");
}

- (void)testThatOverwriteFileWithDataIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// the HTTP body is encoded as multipart pieces
- (void)testThatOverwriteFileWithDataDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatOverwriteFileWithDataWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatOverwriteFileWithDataSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatOverwriteFileWithDataSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:failureBlock progress:nil];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatOverwriteFileWithDataEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];
    [queueManagerMock verify];
}

- (void)testThatOverwriteFileWithDataPassesOAuth2SessionToOperation
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID data:[NSData data] MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Overwrite file with NSInputStream

- (void)testThatOverwriteFileWithInputStreamReturnsOperationWithHTTPPOSTMethod
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodPOST, operation.APIRequest.HTTPMethod, @"file overwrite should be a POST request");
}

// @see developers.box.com/docs/
- (void)testThatOverwriteFileWithInputStreamReturnsOperationWithDocumentedURL
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseUploadURL, APIUploadVersion, FILES_RESOURCE, fileID, FILES_CONTENT];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file overwrite URL should match docs");
}

- (void)testThatOverwriteFileWithInputStreamIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

// the HTTP body is encoded as multipart pieces
- (void)testThatOverwriteFileWithInputStreamDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatOverwriteFileWithInputStreamWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatOverwriteFileWithInputStreamSuccessBlockIsPassedABoxFile
{
    BoxFileBlock successBlock = ^(BoxFile *file)
    {
        STAssertTrue([file class] == [BoxFile class], @"success block should be passed a BoxFile");
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.success(nil, nil, nil);
}

- (void)testThatOverwriteFileWithInputStreamSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        blockCalled = YES;
    };
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:failureBlock progress:nil];

    operation.failure(nil, nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatOverwriteFileWithInputStreamEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];

    [queueManagerMock verify];
}

- (void)testThatOverwriteFileWithInputStreamPassesOAuth2SessionToOperation
{
    BoxAPIMultipartToJSONOperation *operation = [filesManager overwriteFileWithID:fileID inputStream:[NSInputStream inputStreamWithData:[NSData data]] contentLength:0 MIMEType:nil requestBuilder:nil success:nil failure:nil progress:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Download file with NSOutputStream

- (void)testThatDownloadFileReturnsOperationWithHTTPGETMethod
{
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:nil success:nil failure:nil progress:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"file download should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatDownloadFileReturnsOperationWithDocumentedURL
{
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:nil success:nil failure:nil progress:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FILES_RESOURCE, fileID, FILES_CONTENT];

    STAssertEqualObjects(expectedURLString, operation.APIRequest.URL.absoluteString, @"file download URL should match docs");
}

- (void)testThatDownloadFileIncludesQueryStringParametersFromRequestBuilder
{
    NSDictionary *const queryParametersDictionary = @{@"foo" : @"bar", @"boom" : @"baz"};
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:queryParametersDictionary];
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from builder should be appended to the URL");
}

- (void)testThatDownloadFileDoesNotIncludeBodyDictionaryFromRequestBuilder
{
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"foobar";
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:builder success:nil failure:nil progress:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDownloadFileWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxDownloadSuccessBlock successBlock = ^(NSString *fileID, long long expectedTotalBytes)
    {
        blockCalled = YES;
    };
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:nil success:successBlock failure:nil progress:nil];

    operation.successBlock(nil, 0l);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatDownloadFileSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxDownloadFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        blockCalled = YES;
    };
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:nil success:nil failure:failureBlock progress:nil];

    operation.failureBlock(nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDownloadFileEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

   __unused BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:nil success:nil failure:nil progress:nil];

    [queueManagerMock verify];
}

- (void)testThatDownloadFilePassesOAuth2SessionToOperation
{
    BoxAPIDataOperation *operation = [filesManager downloadFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] requestBuilder:nil success:nil failure:nil progress:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

#pragma mark - Download thumbnail with NSOutputStream

- (void)testThatDownloadFileThumbnailReturnsOperationWithHTTPGETMethod
{
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:nil];

    STAssertEqualObjects(BoxAPIHTTPMethodGET, operation.APIRequest.HTTPMethod, @"file thumbnail should be a GET request");
}

// @see developers.box.com/docs/
- (void)testThatDownloadFileThumbnailReturnsOperationWithDocumentedURL
{
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:nil];

    NSString *expectedURLString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", APIBaseURL, APIVersion, FILES_RESOURCE, fileID, FILES_THUMBNAIL];

    NSString *urlWithoutQueryParameters = [[operation.APIRequest.URL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];

    STAssertEqualObjects(expectedURLString, urlWithoutQueryParameters, @"file download URL should match docs");
}

- (void)testThatDownloadFileThumbnailIncludesQueryStringParametersFromThumbnailSize
{
    NSDictionary *const queryParametersDictionary = @{@"min_width" : @"256", @"min_height" : @"256"};
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:nil];

    STAssertEqualObjects(queryParametersDictionary, operation.APIRequest.URL.box_queryDictionary, @"query parameters from thumbnail size should be appended to the URL");
}

- (void)testThatDownloadFileDoesNotIncludeBodyDictionary
{
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:nil];

    STAssertNil(operation.APIRequest.HTTPBody, @"body parameters from builder should not be included with the request");
}

- (void)testThatDownloadFileThumbnailWrapsSuccessBlockInJSONSuccessBlockAndSetsItOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxDownloadSuccessBlock successBlock = ^(NSString *fileID, long long expectedTotalBytes)
    {
        blockCalled = YES;
    };
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:successBlock failure:nil];

    operation.successBlock(nil, 0l);

    STAssertTrue(blockCalled, @"File block should be called when the operation's success block is called");
}

- (void)testThatDownloadFileThumbnailSetsFailureBlockOnTheOperation
{
    __block BOOL blockCalled = NO;
    BoxDownloadFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        blockCalled = YES;
    };
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:failureBlock];

    operation.failureBlock(nil, nil, nil);

    STAssertTrue(blockCalled, @"Failure block should be called when the operation's failure block is called");
}

- (void)testThatDownloadFileThumbnailEnqueuesOperationInQueueManager
{
    id queueManagerMock = [BoxWeakOCMockProxy mockForClass:[BoxSerialAPIQueueManager class]];
    [[queueManagerMock expect] enqueueOperation:OCMOCK_ANY];
    filesManager.queueManager = queueManagerMock;

    __unused BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:nil];

    [queueManagerMock verify];
}

- (void)testThatDownloadFileThumnbailPassesOAuth2SessionToOperation
{
    BoxAPIDataOperation *operation = [filesManager thumbnailForFileWithID:fileID outputStream:[NSOutputStream outputStreamToMemory] thumbnailSize:BoxThumbnailSize256 success:nil failure:nil];
    STAssertEquals(OAuth2Session, operation.OAuth2Session, @"operation should have the same OAuth2Session as the folders manager");
}

@end
