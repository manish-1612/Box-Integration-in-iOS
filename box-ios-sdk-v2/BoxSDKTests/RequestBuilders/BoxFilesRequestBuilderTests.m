//
//  BoxFilesRequestBuilderTests.m
//  BoxSDK
//
//  Created on 3/27/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFilesRequestBuilderTests.h"

#import "BoxSDKConstants.h"

@implementation BoxFilesRequestBuilderTests

- (void)setUp
{
    builder = [[BoxFilesRequestBuilder alloc] init];
}

#pragma mark - Body Dictionary

- (void)testThatBodyDictionaryIsEmptyWhenNoPropertiesAreSet
{
    STAssertEqualObjects(@{}, builder.bodyParameters, @"body parameters should be an empty dictionary if no properties are set");
}

- (void)testThatNameInBodyDictionaryWhenPropertyIsSet
{
    NSString *const name = @"Eli Manning";
    builder.name = name;
    STAssertEqualObjects(@{BoxAPIObjectKeyName : name}, builder.bodyParameters, @"name should be included in body dictionary when set");
}

- (void)testThatDescriptionInBodyDictionaryWhenPropertyIsSet
{
    NSString *const description = @"Elite QB of the NY Giants";
    builder.description = description;
    STAssertEqualObjects(@{BoxAPIObjectKeyDescription : description}, builder.bodyParameters, @"description should be included in body dictionary when set");
}

- (void)testThatSettingContentCreatedAtInBodyDictionaryWhenPropertyIsSet
{
    NSDate *const birthdate = [NSDate dateWithTimeIntervalSince1970:347398722];
    NSString *const birthdateISO8601String = @"1981-01-03T19:38:42Z";
    builder.contentCreatedAt = birthdate;
    STAssertEqualObjects(@{BoxAPIObjectKeyContentCreatedAt : birthdateISO8601String}, builder.bodyParameters, @"content created at should be converted to iso 86012 string and included in body dictionary");
}

- (void)testThatSettingContentModifiedAtInBodyDictionaryWhenPropertyIsSet
{
    NSDate *const birthdate = [NSDate dateWithTimeIntervalSince1970:347398722];
    NSString *const birthdateISO8601String = @"1981-01-03T19:38:42Z";
    builder.contentModifiedAt = birthdate;
    STAssertEqualObjects(@{BoxAPIObjectKeyContentModifiedAt : birthdateISO8601String}, builder.bodyParameters, @"content modified at should be converted to iso 86012 string and included in body dictionary");
}

- (void)testThatContentCreatedAtAndContentModifiedAtInBodyDictionaryWhenBothPropertiesAreSet
{
    NSDate *const birthdate = [NSDate dateWithTimeIntervalSince1970:347398722];
    NSString *const birthdateISO8601String = @"1981-01-03T19:38:42Z";
    NSDate *const superBowlXLVI = [NSDate dateWithTimeIntervalSince1970:1328493600];
    NSString *const superBowlXLVIISO8601String = @"2012-02-06T02:00:00Z";
    builder.contentCreatedAt = birthdate;
    builder.contentModifiedAt = superBowlXLVI;
    NSDictionary *expectedBody = @{BoxAPIObjectKeyContentCreatedAt : birthdateISO8601String,
                                   BoxAPIObjectKeyContentModifiedAt : superBowlXLVIISO8601String};
    STAssertEqualObjects(expectedBody, builder.bodyParameters, @"content created at and content modified at should be converted to iso 86012 string and included in body dictionary");
}

- (void)testThatParentMiniInBodyDictionaryWhenParentIDIsSet
{
    NSString *const parentID = @"10";
    builder.parentID = parentID;
    STAssertEqualObjects(@{ BoxAPIObjectKeyParent : @{BoxAPIObjectKeyID : parentID}}, builder.bodyParameters, @"parent id should be turned into a nested dictionary and included in body dictionary");
}

- (void)testThatMoveAndRenameSetsTheParentAndNamePropertiesInBodyDictionary
{
    NSString *const parentID = @"10";
    builder.parentID = parentID;
    NSString *const name = @"The Greater of the Manning Brothers";
    builder.name = name;
    NSDictionary *expectedBody = @{BoxAPIObjectKeyParent : @{BoxAPIObjectKeyID : parentID}, BoxAPIObjectKeyName : name};
    STAssertEqualObjects(expectedBody, builder.bodyParameters, @"move and rename should set parent id and name");
}

#pragma mark - Query Parameters Dictionary

- (void)testThatDefaultFileBuilderIncludesNoQueryParameters
{
    builder = [[BoxFilesRequestBuilder alloc] init];
    STAssertEqualObjects(@{}, builder.queryStringParameters, @"default builder should provide no query string parameters");
}

- (void)testThatFileBuilderInitializedWithQueryStringParametersIncludesQueryStringParameters
{
    NSDictionary *expectedQueryStringParameters = @{@"foo" : @"bar", @"bam" : @"boom"};
    builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:expectedQueryStringParameters];
    STAssertEqualObjects(expectedQueryStringParameters, builder.queryStringParameters, @"builder with query string parameters should return them");
}

- (void)testThatFileBuilderInitializedWithQueryStringParametersAcceptsAdditionalQueryStringParameters
{
    builder = [[BoxFilesRequestBuilder alloc] initWithQueryStringParameters:@{@"foo" : @"bar"}];
    [builder.queryStringParameters setObject:@"boom" forKey:@"bam"];
    NSDictionary *expectedQueryStringParameters = @{@"foo" : @"bar", @"bam" : @"boom"};
    STAssertEqualObjects(expectedQueryStringParameters, builder.queryStringParameters, @"builder with inital and other query parameters should provide initial and additional query string parameters");
}


@end
