//
//  BoxFileTests.m
//  BoxSDK
//
//  Created on 3/22/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFileTests.h"
#import "BoxSDKTestsHelpers.h"

#import "BoxSDKConstants.h"

@implementation BoxFileTests

-(void)setUp
{
    JSONDictionaryFull = @{
        BoxAPIObjectKeyType : BoxAPIItemTypeFile,
        BoxAPIObjectKeyID : @"6000000000", // 6 billion > 2**32
        BoxAPIObjectKeySHA1 : @"deadbeefdeadbeef",
    };
    JSONDictionaryMini = @{
        BoxAPIObjectKeyType : BoxAPIItemTypeFile,
        BoxAPIObjectKeyID : @"6000000000", // 6 billion > 2**32
    };

    file = [[BoxFile alloc] initWithResponseJSON:JSONDictionaryFull mini:NO];
    miniFile = [[BoxFile alloc] initWithResponseJSON:JSONDictionaryMini mini:YES];
}

- (void)testThatSHA1IsReturnedFromFolderWhenSetInFullFormat
{
    STAssertEqualObjects(@"deadbeefdeadbeef", file.SHA1, @"expected sha1 did not match actual");
}

- (void)testThatSHA1IsReturnedAsNilIfNotSetInMiniFormat
{
    STAssertNil(miniFile.SHA1, @"expected sha1 is nil");
}

- (void)testThatSHA1IsReturnedAsNilWhenSetToGarbageValue
{
    BoxFile *garbageFile = [[BoxFile alloc] initWithResponseJSON:@{BoxAPIObjectKeySHA1 : @12345} mini:YES];
    __unused NSString *sha1;
    BoxAssertThrowsInDebugOrAssertNilInRelease(sha1 = garbageFile.SHA1, @"sha1 should be a string");
}

@end
