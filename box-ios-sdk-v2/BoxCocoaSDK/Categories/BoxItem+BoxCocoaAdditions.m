//
//  BoxItem+BoxCocoaAdditions.m
//  BoxSDK
//
//  Created on 7/29/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxSDK/Categories/BoxItem+BoxAdditions.m. Changes made here should be reflected there.
//

#import "BoxItem+BoxCocoaAdditions.h"
#import "NSImage+BoxAdditions.h"
#import "BoxFolder.h"

@implementation BoxItem (BoxCocoaAdditions)

- (NSImage *)icon
{
    
    NSImage *icon = nil;
    
    
    if ([self isKindOfClass:[BoxFolder class]])
    {
        icon = [NSImage imageFromBoxSDKResourcesBundleWithName:@"folder"];
        return icon;
    }
    
    NSString *extension = [[self.name pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"docx"])
    {
        extension = @"doc";
    }
    if ([extension isEqualToString:@"pptx"])
    {
        extension = @"ppt";
    }
    if ([extension isEqualToString:@"xlsx"])
    {
        extension = @"xls";
    }
    if ([extension isEqualToString:@"html"])
    {
        extension = @"htm";
    }
    if ([extension isEqualToString:@"jpeg"])
    {
        extension = @"jpg";
    }
    
    icon = [NSImage imageFromBoxSDKResourcesBundleWithName:extension];
    
    if (!icon)
    {
        icon = [NSImage imageFromBoxSDKResourcesBundleWithName:@"generic"];
    }
    
    return icon;
}

@end

