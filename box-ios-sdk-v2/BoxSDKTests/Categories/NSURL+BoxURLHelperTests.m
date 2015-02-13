//
//  NSURL+BoxURLHelperTests.m
//  BoxSDK
//
//  Created on 3/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "NSURL+BoxURLHelperTests.h"

#import "NSURL+BoxURLHelper.h"

@implementation NSURL_BoxURLHelperTests

- (void)testThatURLWithOnlySchemeAndDomainReturnsEmptyDictionary
{
    NSURL *urlWithNoQueryStringParameters = [NSURL URLWithString:@"https://dick.in.a.box"];
    NSDictionary *actualQueryDictionary = [urlWithNoQueryStringParameters box_queryDictionary];

    STAssertTrue(0 == [actualQueryDictionary count], @"Query dictionary should be empty");
}

- (void)testThatURLWithNoQueryStringReturnsEmptyDictionary
{
    NSURL *urlWithNoQueryStringParameters = [NSURL URLWithString:@"https://dick.in.a.box/index.php"];
    NSDictionary *actualQueryDictionary = [urlWithNoQueryStringParameters box_queryDictionary];

    STAssertTrue(0 == [actualQueryDictionary count], @"Query dictionary should be empty");
}

- (void)testThatURLWithOneQueryStringParameterReturnsCorrectDictionary
{
    NSURL *urlWithOneQueryStringParameter = [NSURL URLWithString:@"https://dick.in.a.box/index.php?danger=zone"];
    NSDictionary *expectedDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"zone", @"danger", nil];
    NSDictionary *actualQueryDictionary = [urlWithOneQueryStringParameter box_queryDictionary];

    STAssertEqualObjects(expectedDictionary, actualQueryDictionary, @"Expected dictionary differs from actual");
}

- (void)testThatURLWithMultipleQueryStringParametersReturnsCorrectDictionary
{
    NSURL *urlWithOneQueryStringParameter = [NSURL URLWithString:@"https://dick.in.a.box/index.php?danger=zone&top=gun&maverick=awesome"];
    NSDictionary *expectedDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"zone", @"danger", @"gun", @"top", @"awesome", @"maverick", nil];
    NSDictionary *actualQueryDictionary = [urlWithOneQueryStringParameter box_queryDictionary];

    STAssertEqualObjects(expectedDictionary, actualQueryDictionary, @"Expected dictionary differs from actual");
}

@end
