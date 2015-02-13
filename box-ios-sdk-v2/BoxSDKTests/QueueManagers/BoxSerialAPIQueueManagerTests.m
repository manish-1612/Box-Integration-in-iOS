//
//  BoxSerialAPIQueueManagerTests.m
//  BoxSDK
//
//  Created on 3/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSerialAPIQueueManagerTests.h"

#import "BoxAPIOAuth2ToJSONOperation.h"
#import "BoxSerialAPIQueueManager.h"
#import "BoxAPIJSONOperation.h"
#import "BoxAPIMultipartToJSONOperation.h"
#import "BoxAPIDataOperation.h"

#import <OCMock/OCMock.h>

@implementation BoxSerialAPIQueueManagerTests

// These tests assert that all operations are enqueued on their correct queues
- (void)testThatEnqueueOAuth2OperationEnqueuesInCorrectQueue
{
    id globalQueueMock = [OCMockObject mockForClass:[NSOperationQueue class]];
    id checkBlock = ^BOOL(id operation)
    {
        return [operation isKindOfClass:[BoxAPIOAuth2ToJSONOperation class]];
    };
    [[globalQueueMock expect] addOperation:[OCMArg checkWithBlock:checkBlock]];
    [[globalQueueMock expect] operations];

    BoxSerialAPIQueueManager *queueManager = [[BoxSerialAPIQueueManager alloc] init];
    queueManager.globalQueue = globalQueueMock;

    [queueManager enqueueOperation:[[BoxAPIOAuth2ToJSONOperation alloc] init]];

    [globalQueueMock verify];
}

- (void)testThatEnqueueJSONOperationEnqueuesInCorrectQueue
{
    id globalQueueMock = [OCMockObject mockForClass:[NSOperationQueue class]];
    id checkBlock = ^BOOL(id operation)
    {
        return [operation isKindOfClass:[BoxAPIJSONOperation class]];
    };
    [[globalQueueMock expect] addOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialAPIQueueManager *queueManager = [[BoxSerialAPIQueueManager alloc] init];
    queueManager.globalQueue = globalQueueMock;

    [queueManager enqueueOperation:[[BoxAPIJSONOperation alloc] init]];

    [globalQueueMock verify];
}

- (void)testThatEnqueueMultipartToJSONOperationEnqueuesInCorrectQueue
{
    id globalQueueMock = [OCMockObject mockForClass:[NSOperationQueue class]];
    id checkBlock = ^BOOL(id operation)
    {
        return [operation isKindOfClass:[BoxAPIMultipartToJSONOperation class]];
    };
    [[globalQueueMock expect] addOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialAPIQueueManager *queueManager = [[BoxSerialAPIQueueManager alloc] init];
    queueManager.globalQueue = globalQueueMock;

    [queueManager enqueueOperation:[[BoxAPIMultipartToJSONOperation alloc] init]];

    [globalQueueMock verify];
}

- (void)testThatEnqueueDataOperationEnqueuesInCorrectQueue
{
    id globalQueueMock = [OCMockObject mockForClass:[NSOperationQueue class]];
    id checkBlock = ^BOOL(id operation)
    {
        return [operation isKindOfClass:[BoxAPIDataOperation class]];
    };
    [[globalQueueMock expect] addOperation:[OCMArg checkWithBlock:checkBlock]];

    BoxSerialAPIQueueManager *queueManager = [[BoxSerialAPIQueueManager alloc] init];
    queueManager.globalQueue = globalQueueMock;

    [queueManager enqueueOperation:[[BoxAPIDataOperation alloc] init]];

    [globalQueueMock verify];
}

// test properties of the queue itself
- (void)testThatSerialQueueOnlyAllowsOneConcurrentOperation
{
    BoxSerialAPIQueueManager *queueManager = [[BoxSerialAPIQueueManager alloc] init];
    STAssertEquals((NSInteger)1, queueManager.globalQueue.maxConcurrentOperationCount, @"Queue's maxConcurrentOperationCount should == 1");
}

@end
