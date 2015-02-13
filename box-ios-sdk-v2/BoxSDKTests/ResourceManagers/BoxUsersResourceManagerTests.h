//
//  BoxUsersResourceManagerTests.h
//  BoxSDK
//
//  Created on 8/16/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class BoxUsersResourceManager;
@class BoxSerialOAuth2Session;
@class BoxSerialAPIQueueManager;

@interface BoxUsersResourceManagerTests : SenTestCase
{
    BoxUsersResourceManager *usersManager;
    NSString *APIBaseURL;
    NSString *APIVersion;
    BoxSerialOAuth2Session *OAuth2Session;
    BoxSerialAPIQueueManager *queue;
    NSString *userID;
}
@end
