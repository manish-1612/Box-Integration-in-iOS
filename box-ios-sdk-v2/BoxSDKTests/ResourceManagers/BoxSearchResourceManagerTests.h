//
//  BoxSearchResourceManagerTests.h
//  BoxSDK
//
//  Created by Ryan Lopopolo on 11/21/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class BoxSearchResourceManager;
@class BoxSerialOAuth2Session;
@class BoxSerialAPIQueueManager;

@interface BoxSearchResourceManagerTests : SenTestCase
{
    BoxSearchResourceManager *searchManager;
    NSString *APIBaseURL;
    NSString *APIVersion;
    BoxSerialOAuth2Session *OAuth2Session;
    BoxSerialAPIQueueManager *queue;
    NSString *query;
}
@end
