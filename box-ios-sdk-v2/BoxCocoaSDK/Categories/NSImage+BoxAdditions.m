//
//  NSImage+BoxAdditions.m
//  BoxSDK
//
//  Created on 7/29/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxSDK/Categories/UIImage+BoxAdditions.m. Changes made here should be reflected there.
//

#import "NSImage+BoxAdditions.h"
#import "BoxCocoaSDK.h"

@implementation NSImage (BoxAdditions)

+ (NSImage *)imageFromBoxSDKResourcesBundleWithName:(NSString *)string
{
    NSBundle *bundle = [BoxCocoaSDK resourcesBundle];
    NSString *str = [[bundle resourcePath] stringByAppendingPathComponent:[bundle pathForResource:string ofType:nil]];
    return [[NSImage alloc] initWithContentsOfFile:[str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", string]]];
}

@end
