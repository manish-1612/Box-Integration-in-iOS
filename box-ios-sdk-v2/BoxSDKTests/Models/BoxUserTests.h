//
//  BoxUserTests.h
//  BoxSDK
//
//  Created on 8/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class BoxUser;

@interface BoxUserTests : SenTestCase
{
    NSDictionary *JSONDictionaryFull;
    NSDictionary *JSONDictionaryMini;
    BoxUser *user;
    BoxUser *miniUser;
}
@end
