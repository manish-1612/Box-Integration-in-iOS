//
//  BoxWebLinkTests.m
//  BoxSDK
//
//  Created on 4/22/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxWebLinkTests.h"
#import "BoxSDKTestsHelpers.h"

#import "BoxWebLink.h"
#import "BoxSDKConstants.h"

@implementation BoxWebLinkTests

-(void)setUp
{
    JSONDictionaryFull = @{
                           BoxAPIObjectKeyType : BoxAPIItemTypeWebLink,
                           BoxAPIObjectKeyID : @"6000000000", // 6 billion > 2**32
                           BoxAPIObjectKeyURL : @"https://www.box.com",
                           };
    JSONDictionaryMini = @{
                           BoxAPIObjectKeyType : BoxAPIItemTypeWebLink,
                           BoxAPIObjectKeyID : @"6000000000", // 6 billion > 2**32
                           };

    webLink = [[BoxWebLink alloc] initWithResponseJSON:JSONDictionaryFull mini:NO];
    miniWebLink = [[BoxWebLink alloc] initWithResponseJSON:JSONDictionaryMini mini:YES];
}

- (void)testThatURLIsReturnedFromFolderWhenSetInFullFormat
{
    NSURL *expectedURL = [NSURL URLWithString:@"https://www.box.com"];
    STAssertEqualObjects(expectedURL, webLink.URL, @"expected URL did not match actual");
}

- (void)testThatURLIsReturnedAsNilIfNotSetInMiniFormat
{
    STAssertNil(miniWebLink.URL, @"expected URL is nil");
}

- (void)testThatURLIsReturnedAsNilWhenSetToGarbageValue
{
    BoxWebLink *garbageWebLink = [[BoxWebLink alloc] initWithResponseJSON:@{BoxAPIObjectKeyURL : @12345} mini:YES];
    __unused NSURL *URL;
    BoxAssertThrowsInDebugOrAssertNilInRelease(URL = garbageWebLink.URL, @"URL should be a string");
}

@end
