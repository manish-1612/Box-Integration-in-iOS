//
//  BoxUserTests.h
//  BoxSDK
//
//  Created on 8/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class BoxComment;

@interface BoxCommentTests : SenTestCase
{
    NSDictionary *JSONDictionaryFull;
    NSDictionary *JSONDictionaryMini;
    BoxComment *comment;
    BoxComment *miniComment;
}
@end
