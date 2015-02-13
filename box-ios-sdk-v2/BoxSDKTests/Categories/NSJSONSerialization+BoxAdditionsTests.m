//
//  NSJSONSerialization+BoxAdditionsTests.m
//  BoxSDK
//
//  Created on 8/20/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "NSJSONSerialization+BoxAdditionsTests.h"
#import "BoxSDKTestsHelpers.h"

#import "NSJSONSerialization+BoxAdditions.h"

#define JSON_NULL_KEY            (@"null-valued-key")
#define JSON_NULLABLE_KEY        (@"nullable-key")
#define JSON_NOT_PRESENT_KEY     (@"not-present-key")
#define JSON_BOOLEAN_TRUE_KEY    (@"boolean-true-key")
#define JSON_STRING_VALUED_KEY   (@"string-valued-key")

#define JSON_NULL_VALUE          ([NSNull null])
#define JSON_NULLABLE_VALUE      (@"not-null")
#define JSON_BOOLEAN_VALUE       ([NSNumber numberWithBool:YES])
#define JSON_STRING_VALUE        (@"this is a string")

@implementation NSJSONSerialization_BoxAdditionsTests

- (void)setUp
{
    decodedJSONObject = @{
                          JSON_NULL_KEY : JSON_NULL_VALUE,
                          JSON_NULLABLE_KEY : JSON_NULLABLE_VALUE,
                          JSON_BOOLEAN_TRUE_KEY : JSON_BOOLEAN_VALUE,
                          JSON_STRING_VALUED_KEY : JSON_STRING_VALUE,
                          };
}

- (void)testThatNullValueIsReturnedWhenNullAllowed
{
    id result = [NSJSONSerialization box_ensureObjectForKey:JSON_NULL_KEY inDictionary:decodedJSONObject hasExpectedType:[NSString class] nullAllowed:YES];
    STAssertEqualObjects([NSNull null], result, @"Should return NSNull for null values when nullAllowed = YES");
}

- (void)testThatNullNotReturnedOrThrowsWhenNullNotAllowed
{
    BoxAssertThrowsInDebugOrAssertNilInRelease([NSJSONSerialization box_ensureObjectForKey:JSON_NULL_KEY inDictionary:decodedJSONObject hasExpectedType:[NSString class] nullAllowed:NO], @"Should return nil or throw when nullAllowed = NO");
}

- (void)testThatNullConvertedToNilWhenNullNotAllowedAndNullSuppressed
{
    id result = [NSJSONSerialization box_ensureObjectForKey:JSON_NULL_KEY inDictionary:decodedJSONObject hasExpectedType:[NSString class] nullAllowed:YES suppressNullAsNil:YES];
    STAssertNil(result, @"Should return nil for null values when nullAllowed = YES and suppressNullAsNil = YES");
}

- (void)testThatObjectIsReturnedIfNullAllowedAndNonNullAndExpectedType
{
    id result = [NSJSONSerialization box_ensureObjectForKey:JSON_NULLABLE_KEY inDictionary:decodedJSONObject hasExpectedType:[NSString class] nullAllowed:YES];
    STAssertEqualObjects(JSON_NULLABLE_VALUE, result, @"Should return object for non-null values when nullAllowed = YES");
}

- (void)testThatObjectNotReturnedOrThrowsWhenNullAllowedAndClassMismatch
{
    BoxAssertThrowsInDebugOrAssertNilInRelease([NSJSONSerialization box_ensureObjectForKey:JSON_NULLABLE_KEY inDictionary:decodedJSONObject hasExpectedType:[NSNumber class] nullAllowed:YES], @"Should return nil or throw when nullAllowed = YES and expected type mismatch");
}

- (void)testThatObjectIsReturnedIfNullNotAllowedAndNonNullAndExpectedType
{
    id result = [NSJSONSerialization box_ensureObjectForKey:JSON_NULLABLE_KEY inDictionary:decodedJSONObject hasExpectedType:[NSString class] nullAllowed:NO];
    STAssertEqualObjects(JSON_NULLABLE_VALUE, result, @"Should return object for non-null values when nullAllowed = NO");
}

- (void)testThatObjectNotReturnedOrThrowsWhenNullNotAllowedAndClassMismatch
{
    BoxAssertThrowsInDebugOrAssertNilInRelease([NSJSONSerialization box_ensureObjectForKey:JSON_NULLABLE_KEY inDictionary:decodedJSONObject hasExpectedType:[NSNumber class] nullAllowed:NO], @"Should return nil or throw when nullAllowed = NO and expected type mismatch");
}

- (void)testThatStringIsReturned
{
    id result = [NSJSONSerialization box_ensureObjectForKey:JSON_STRING_VALUED_KEY inDictionary:decodedJSONObject hasExpectedType:[NSString class] nullAllowed:NO];
    STAssertEqualObjects(JSON_STRING_VALUE, result, @"Should return NSString object");
    STAssertTrue([result isKindOfClass:[NSString class]], @"Should return NSString object");
}

- (void)testThatNumberIsReturned
{
    id result = [NSJSONSerialization box_ensureObjectForKey:JSON_BOOLEAN_TRUE_KEY inDictionary:decodedJSONObject hasExpectedType:[NSNumber class] nullAllowed:NO];
    STAssertEqualObjects(JSON_BOOLEAN_VALUE, result, @"Should return NSNumber object");
    STAssertTrue([result isKindOfClass:[NSNumber class]], @"Should return NSNumber object");
}

@end
