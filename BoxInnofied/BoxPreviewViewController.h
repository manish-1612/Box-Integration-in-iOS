//
//  BoxPreviewViewController.h
//  BoxSDKSampleApp
//
//  Created by Ryan Lopopolo on 4/10/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoxPreviewViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, readwrite, strong) NSString *fileID;
@property (nonatomic, readwrite, strong) NSString *filename;
@property (nonatomic, readwrite, strong) NSString *parentFolderID;
@property (nonatomic, readwrite, strong) NSData *data;
@property (nonatomic, readwrite, strong) NSString *MIMEType;

- (id)initWithFileID:(NSString *)fileID filename:(NSString *)filename parentFolderID:(NSString *)parentFolderID data:(NSData *)data MIMEType:(NSString *)MIMEType;

@end
