//
//  BoxItem+BoxCocoaAdditions.h
//  BoxSDK
//
//  Created on 7/29/13.
//  Copyright (c) 2013 Box. All rights reserved.
//
//  NOTE: this file is a mirror of BoxSDK/Categories/BoxItem+BoxAdditions.h. Changes made here should be reflected there.
//

#import "BoxItem.h"
#import <Cocoa/Cocoa.h>

/**
 * BoxAdditions exposes the ability to grab icons for the files. These icons are pulled out of the resource bundle
 * that you can include in your project. This category is used by the folder picker to display default icons for each file type.
 */
@interface BoxItem (BoxCocoaAdditions)

/**
 * The icon representing the type of the item
 */
- (NSImage *)icon;

@end
