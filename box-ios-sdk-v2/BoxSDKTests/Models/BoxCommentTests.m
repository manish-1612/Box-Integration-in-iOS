//
//  BoxCommentTests.m
//  BoxSDK
//
//  Created on 11/21/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxCommentTests.h"
#import "BoxSDKTestsHelpers.h"
#import "BoxSDKConstants.h"

#import "BoxComment.h"
#import "BoxFile.h"
#import "BoxUser.h"

@implementation BoxCommentTests

-(void)setUp
{
    JSONDictionaryFull = @{
        BoxAPIObjectKeyType : BoxAPIItemTypeComment,
        BoxAPIObjectKeyID : @"6000000000",
        BoxAPIObjectKeyCreatedAt : @"2009-03-04T01:02:03Z", // 1236128523
        BoxAPIObjectKeyModifiedAt : @"2009-03-05T01:02:03Z", // 1236214923
        BoxAPIObjectKeyCreatedBy : @{
            BoxAPIObjectKeyType : BoxAPIItemTypeUser,
            BoxAPIObjectKeyID : @"1235"
        },
        BoxAPIObjectKeyIsReplyComment : @(NO),
        BoxAPIObjectKeyItem : @{
            BoxAPIObjectKeyType: BoxAPIItemTypeFile,
            BoxAPIObjectKeyID : @"6789"
        },
        BoxAPIObjectKeyMessage : @"The best way to predict the future is to invent it - Alan Kay",
        BoxAPIObjectKeyTaggedMessage : @"The best way to predict the future is to invent it - @[1234:Alan Kay]",
    };
    JSONDictionaryMini = @{
        BoxAPIObjectKeyType : BoxAPIItemTypeComment,
        BoxAPIObjectKeyID : @"6000000000",
    };

    comment = [[BoxComment alloc] initWithResponseJSON:JSONDictionaryFull mini:NO];
    miniComment = [[BoxComment alloc] initWithResponseJSON:JSONDictionaryMini mini:YES];
}

- (void)testThatMessageIsReturnedFromFullFormat
{
    STAssertEqualObjects(@"The best way to predict the future is to invent it - Alan Kay", comment.message, @"expected message did not match actual");
}

- (void)testThatMessageIsReturnedAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.message, @"expected message should be nil");
}

- (void)testThatTaggedMessageIsReturnedFromFullFormat
{
    STAssertEqualObjects(@"The best way to predict the future is to invent it - @[1234:Alan Kay]", comment.taggedMessage, @"expected tagged_message did not match actual");
}

- (void)testThatTaggedMessageIsReturnedAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.taggedMessage, @"expected tagged_message should be nil");
}

- (void)testThatCreatedAtIsParsedCorrectlyIntoADateFromFullFormat
{
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1236128523];
    STAssertEqualObjects(expectedDate, comment.createdAt, @"expected created_at did not match actual");
}

- (void)testThatCreatedAtIsReturnedAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.createdAt, @"created_at should be nil");
}

- (void)testThatCreatedAtIsReturnedAsNilIfSetToAGarbageValue
{
    BoxComment *garbageComment = [[BoxComment alloc] initWithResponseJSON:@{BoxAPIObjectKeyCreatedAt : @"foobar is not a timestamp"} mini:YES];
    STAssertNil(garbageComment.createdAt, @"created_at should be nil when user is initalized with a garbage value");
}

- (void)testThatModifiedAtIsParsedCorrectlyIntoADateFromFullFormat
{
    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1236214923];
    STAssertEqualObjects(expectedDate, comment.modifiedAt, @"expected modified_at did not match actual");
}

- (void)testThatModifiedAtIsReturnedAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.modifiedAt, @"modified_at should be nil");
}

- (void)testThatModifiedAtIsReturnedAsNilIfSetToAGarbageValue
{
    BoxComment *garbageComment = [[BoxComment alloc] initWithResponseJSON:@{BoxAPIObjectKeyCreatedAt : @"foobar is not a timestamp"} mini:YES];
    STAssertNil(garbageComment.modifiedAt, @"modified at should be nil when user is initalized with a garbage value");
}

- (void)testThatItemIsReturnedFromFullFormat
{
    STAssertTrue([comment.item isKindOfClass:[BoxFile class]], @"expected item to be a BoxFile");
}

- (void)testThatItemIsReturnedAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.item, @"expected item should be nil");
}

- (void)testThatCreatedByIsReturnedFromFullFormat
{
    STAssertTrue([comment.createdBy isKindOfClass:[BoxUser class]], @"expected created by to be a BoxUser");
}

- (void)testThatCreatedByIsReturnedAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.createdBy, @"expected created by should be nil");
}

- (void)testThatIsReplyCommentIsParsedCorrectlyIntoABooleanFromFullFormat
{
    STAssertEquals(@(NO), comment.isReplyComment, @"expected is_reply_comment should be set to False");
}

- (void)testThatIsReplyCommentIsSetAsNilIfUnsetFromMiniFormat
{
    STAssertNil(miniComment.isReplyComment, @"expected is_reply_comment should be nil");
}

@end
