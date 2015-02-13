//
//  BoxSDKTestsHelpers.m
//  BoxSDK
//
//  Created by on 4/23/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSDKTestsHelpers.h"

#import <OCMock/OCMock.h>

@implementation BoxWeakOCMockProxy

@synthesize mockObject = _mockObject;

- (id)initWithMock:(id)mock
{
    self = [super init];
    if (self != nil)
    {
        _mockObject = mock;
    }

    return self;
}

#pragma mark invocation forwarding
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.mockObject;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self.mockObject respondsToSelector:aSelector];
}

#pragma mark OCMockObject Public Methods
+ (id)mockForClass:(Class)aClass
{
    return [[self alloc] initWithMock:[OCMockObject mockForClass:aClass]];
}

+ (id)mockForProtocol:(Protocol *)aProtocol {
    return [[self alloc] initWithMock:[OCMockObject mockForProtocol:aProtocol]];
}

+ (id)niceMockForClass:(Class)aClass {
    return [[self alloc] initWithMock:[OCMockObject niceMockForClass:aClass]];
}

+ (id)niceMockForProtocol:(Protocol *)aProtocol {
    return [[self alloc] initWithMock:[OCMockObject niceMockForProtocol:aProtocol]];
}

+ (id)observerMock {
    return [[self alloc] initWithMock:[OCMockObject observerMock]];
}

+ (id)partialMockForObject:(NSObject *)anObject {
    return [[self alloc] initWithMock:[OCMockObject partialMockForObject:anObject]];
}

- (void)setExpectationOrderMatters:(BOOL)flag
{
    [self.mockObject setExpectationOrderMatters:flag];
}

- (id)stub
{
    return [self.mockObject stub];
}

- (id)expect
{
    return [self.mockObject expect];
}

- (id)reject
{
    return [self.mockObject reject];
}

- (void)verify
{
    [self.mockObject verify];
}

@end
