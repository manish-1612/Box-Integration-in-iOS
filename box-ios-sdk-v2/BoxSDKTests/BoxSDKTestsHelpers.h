//
//  BoxSDKTestsHelpers.h
//  BoxSDK
//
//  Created by on 4/23/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#ifdef DEBUG
#define BoxAssertThrowsInDebugOrAssertNilInRelease(expr, description, ...) STAssertThrows(expr, description, ##__VA_ARGS__)
#else
#define BoxAssertThrowsInDebugOrAssertNilInRelease(expr, description, ...) STAssertNil(expr, description, ##__VA_ARGS__)
#endif

@interface BoxWeakOCMockProxy : NSObject

// hold a strong reference to the mock (an NSProxy subclass) to work around an issue with
// weak references to NSProxy-derived objects in iOS 5.0 and iOS 5.1
// @see rdar://11117786
@property (nonatomic, readonly, strong) id mockObject;

// define all of the public methods that OCMockObject does
// @see <OCMock/OCMockObject.h>
+ (id)mockForClass:(Class)aClass;
+ (id)mockForProtocol:(Protocol *)aProtocol;
+ (id)partialMockForObject:(NSObject *)anObject;

+ (id)niceMockForClass:(Class)aClass;
+ (id)niceMockForProtocol:(Protocol *)aProtocol;

+ (id)observerMock;

- (void)setExpectationOrderMatters:(BOOL)flag;

- (id)stub;
- (id)expect;
- (id)reject;

- (void)verify;

@end