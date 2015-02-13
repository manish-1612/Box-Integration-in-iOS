//
//  NSString+BoxURLHelperTests.m
//  BoxSDK
//
//  Created on 3/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "NSString+BoxURLHelperTests.h"

#import "NSString+BoxURLHelper.h"

@implementation NSString_BoxURLHelperTests

- (void)testThatNonURLEncodedStringsHaveContentsPreserved
{
    NSString *stringWithURLEncodeableCharacters = @"!*'();:@&=+$,/?%#[]";
    NSString *nonEncodedString = [NSString box_stringWithString:stringWithURLEncodeableCharacters URLEncoded:NO];

    STAssertEqualObjects(stringWithURLEncodeableCharacters, nonEncodedString, @"String contents should be preserved when not url encoding");
}

- (void)testThatAllURLEncodeableCharactersAreURLEncoded
{
    NSString *stringWithURLEncodeableCharacters = @"!*'();:@&=+$,/?%#[]";
    NSString *expectedEncodedString = @"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D"; // encoded using PHP's urlencode function
    NSString *actualEncodedString = [NSString box_stringWithString:stringWithURLEncodeableCharacters URLEncoded:YES];

    STAssertEqualObjects(expectedEncodedString, actualEncodedString, @"Actual url encoded string (%@) did not match expected (%@)", actualEncodedString, expectedEncodedString);
}

- (void)testThatURLIsEncodedCorrectly
{
    NSString *urlStringToEncode = @"https://api.box.com/index.php?boom=yeah&danger=zone";
    NSString *expectedEncodedString = @"https%3A%2F%2Fapi.box.com%2Findex.php%3Fboom%3Dyeah%26danger%3Dzone"; // encoded using PHP's urlencode function
    NSString *actualEncodedString = [NSString box_stringWithString:urlStringToEncode URLEncoded:YES];

    STAssertEqualObjects(expectedEncodedString, actualEncodedString, @"Actual url encoded string (%@) did not match expected (%@)", actualEncodedString, expectedEncodedString);

}

@end
