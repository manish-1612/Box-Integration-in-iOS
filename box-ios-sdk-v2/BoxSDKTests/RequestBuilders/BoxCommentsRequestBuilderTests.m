//
//  BoxCommentsRequestBuilderTests.m
//  BoxSDK
//
//  Created on 11/21/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxCommentsRequestBuilderTests.h"
#import "BoxModelBuilder.h"

@implementation BoxCommentsRequestBuilderTests

- (void)setUp
{
    builder = [[BoxCommentsRequestBuilder alloc] init];
}

#pragma mark - Body Dictionary

- (void)testThatItemIsEmptyWhenNoPropertiesAreSet
{
    STAssertEqualObjects(@{}, builder.bodyParameters, @"body parameters should be an empty dictionary if no properties are set");
}

- (void)testThatItemInBodyDictionaryWhenPropertyIsSet
{
    BoxModelBuilder * item = [[BoxModelBuilder alloc] init];
    item.type = BoxAPIItemTypeFile;
    item.modelID = @"12345";
    builder.item = item;
    
    NSDictionary * expectedItem = @{
        BoxAPIObjectKeyType: BoxAPIItemTypeFile,
        BoxAPIObjectKeyID: @"12345",
    };
    
    STAssertEqualObjects(@{BoxAPIObjectKeyItem : expectedItem}, builder.bodyParameters, @"item should be included in body dictionary when set");
}

- (void)testThatMessageInBodyDictionaryWhenPropertyIsSet
{
    NSString *const message = @"Silence is golden, duct tape is silver";
    builder.message = message;
    STAssertEqualObjects(@{BoxAPIObjectKeyMessage : message}, builder.bodyParameters, @"message should be included in body dictionary when set");
}

@end