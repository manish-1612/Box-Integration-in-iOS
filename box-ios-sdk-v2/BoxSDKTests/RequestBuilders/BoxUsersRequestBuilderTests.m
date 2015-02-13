//
//  BoxUsersRequestBuilderTests.m
//  BoxSDK
//
//  Created on 8/16/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxUsersRequestBuilderTests.h"

#import "BoxSDKConstants.h"

@implementation BoxUsersRequestBuilderTests

- (void)setUp
{
    builder = [[BoxUsersRequestBuilder alloc] init];
}

#pragma mark - Body Dictionary

- (void)testThatBodyDictionaryIsEmptyWhenNoPropertiesAreSet
{
    STAssertEqualObjects(@{}, builder.bodyParameters, @"body parameters should be an empty dictionary if no properties are set");
}

- (void)testThatLoginInBodyDictionaryWhenPropertyIsSet
{
    NSString *const login = @"pheonix@wright.com";
    builder.login = login;
    STAssertEqualObjects(@{BoxAPIObjectKeyLogin : login}, builder.bodyParameters, @"login should be included in body dictionary when set");
}

- (void)testThatNameInBodyDictionaryWhenPropertyIsSet
{
    NSString *const name = @"Phoenix Wright";
    builder.name = name;
    STAssertEqualObjects(@{BoxAPIObjectKeyName : name}, builder.bodyParameters, @"name should be included in body dictionary when set");
}

- (void)testThatRoleInBodyDictionaryWhenPropertyIsSet
{
    NSString *const role = @"admin";
    builder.role = role;
    STAssertEqualObjects(@{BoxAPIObjectKeyRole : role}, builder.bodyParameters, @"role should be included in body dictionary when set");
}

- (void)testThatLanguageInBodyDictionaryWhenPropertyIsSet
{
    NSString *const language = @"en";
    builder.language = language;
    STAssertEqualObjects(@{BoxAPIObjectKeyLanguage : language}, builder.bodyParameters, @"language should be included in body dictionary when set");
}

- (void)testThatIsSyncEnabledInBodyDictionaryWhenPropertyIsSet
{
    NSNumber *const isSyncEnabled = @(NO);
    builder.isSyncEnabled = isSyncEnabled;
    STAssertEqualObjects(@{BoxAPIObjectKeyIsSyncEnabled : isSyncEnabled}, builder.bodyParameters, @"isSyncEnabled should be included in body dictionary when set");
}

- (void)testThatJobTitleInBodyDictionaryWhenPropertyIsSet
{
    NSString *const jobTitle = @"Ace Attorney";
    builder.jobTitle = jobTitle;
    STAssertEqualObjects(@{BoxAPIObjectKeyJobTitle : jobTitle}, builder.bodyParameters, @"jobTitle should be included in body dictionary when set");
}

- (void)testThatPhoneInBodyDictionaryWhenPropertyIsSet
{
    NSString *const phone = @"1234567890";
    builder.phone = phone;
    STAssertEqualObjects(@{BoxAPIObjectKeyPhone : phone}, builder.bodyParameters, @"phone should be included in body dictionary when set");
}

- (void)testThatAddressInBodyDictionaryWhenPropertyIsSet
{
    NSString *const address = @"4440 El Camino Real";
    builder.address = address;
    STAssertEqualObjects(@{BoxAPIObjectKeyAddress : address}, builder.bodyParameters, @"address should be included in body dictionary when set");
}

- (void)testThatSpaceAmountInBodyDictionaryWhenPropertyIsSet
{
    NSNumber *const spaceAmount = [NSNumber numberWithDouble:10737418240];
    builder.spaceAmount = spaceAmount;
    STAssertEqualObjects(@{BoxAPIObjectKeySpaceAmount : spaceAmount}, builder.bodyParameters, @"spaceAmount should be included in body dictionary when set");
}

- (void)testThatTrackingCodesInBodyDictionaryWhenPropertyIsSet
{
    NSDictionary *const trackingCodes = @{
        @"Case" : @"DL-6",
        @"Attorney" : @"Robert Hammond",
    };
    builder.trackingCodes = trackingCodes;
    STAssertEqualObjects(@{BoxAPIObjectKeyTrackingCodes : trackingCodes}, builder.bodyParameters, @"trackingCodes should be included in body dictionary when set");
}

- (void)testThatStatusInBodyDictionaryWhenPropertyIsSet
{
    NSString *const status = @"active";
    builder.status = status;
    STAssertEqualObjects(@{BoxAPIObjectKeyStatus : status}, builder.bodyParameters, @"status should be included in body dictionary when set");
}
@end
