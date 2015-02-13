//
//  BoxModelTests.m
//  BoxSDK
//
//  Created on 3/18/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxModelTests.h"

#import "BoxSDKConstants.h"

#define MODEL_TYPE    @"model-type"
#define MODEL_ID      @"model-id"
#define MODEL_KEY_FOO @"foo"
#define MODEL_FOO     @"model-foo"

@implementation BoxModelTests

- (void)setUp
{
    model = [[BoxModel alloc] initWithResponseJSON:@{BoxAPIObjectKeyType : MODEL_TYPE,
                                BoxAPIObjectKeyID : MODEL_ID,
                                MODEL_KEY_FOO : MODEL_FOO}
                              mini:YES];
}

- (void)testThatModelReturnsIDFromRawJSONDictionary
{
    STAssertEqualObjects(MODEL_ID, [model.rawResponseJSON objectForKey:BoxAPIObjectKeyID], @"id key not retrieved correctly from JSON dictionary");
}

- (void)testThatModelReturnsIDFromAccessor
{
    STAssertEqualObjects(MODEL_ID, model.modelID, @"id key not retrieved correctly from accessor");
}

- (void)testThatModelReturnsTypeFromRawJSONDictionary
{
    STAssertEqualObjects(MODEL_TYPE, [model.rawResponseJSON objectForKey:BoxAPIObjectKeyType], @"type key not retrieved correctly from JSON dictionary");
}

- (void)testThatModelReturnsTypeFromAccessor
{
    STAssertEqualObjects(MODEL_TYPE, model.type, @"type key not retrieved correctly from accessor");
}

- (void)testThatModelReturnsUnknownKeyFromRawJSONDictionary
{
    STAssertEqualObjects(MODEL_FOO, [model.rawResponseJSON objectForKey:MODEL_KEY_FOO], @"foo key not retrieved correctly from JSON dictionary");
}

- (void)testThatISO8601StringDecodesToCorrectDateObjectForBeginningOfEpochForZuluDateString
{
    NSString *dateString = @"1970-01-01T00:00:00Z";
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *actualDate = [model dateWithISO8601String:dateString];

    STAssertEqualObjects(expectedDate, actualDate, @"date string %@ did not decode correctly", dateString);
}

- (void)testThatISO8601StringDecodesToCorrectDateObjectForBeginningOfEpochForPacificTZDateString
{
    NSString *dateString = @"1969-12-31T16:00:00-08:00";
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *actualDate = [model dateWithISO8601String:dateString];

    STAssertEqualObjects(expectedDate, actualDate, @"date string %@ did not decode correctly", dateString);
}

- (void)testThatISO8601StringDecodesToCorrectDateObjectForY2KForZuluDateString
{
    NSString *dateString = @"2000-01-01T00:00:00Z";
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:946684800];
    NSDate *actualDate = [model dateWithISO8601String:dateString];

    STAssertEqualObjects(expectedDate, actualDate, @"date string %@ did not decode correctly", dateString);
}

- (void)testThatISO8601StringDecodesToCorrectDateObjectForY2KForPacificTZDateString
{
    NSString *dateString = @"1999-12-31T16:00:00-08:00";
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:946684800];
    NSDate *actualDate = [model dateWithISO8601String:dateString];

    STAssertEqualObjects(expectedDate, actualDate, @"date string %@ did not decode correctly", dateString);
}

@end
