//
//  BoxWebLinkTests.h
//  BoxSDK
//
//  Created on 4/22/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class BoxWebLink;

@interface BoxWebLinkTests : SenTestCase
{
    NSDictionary *JSONDictionaryFull;
    NSDictionary *JSONDictionaryMini;
    BoxWebLink *webLink;
    BoxWebLink *miniWebLink;
}

@end
