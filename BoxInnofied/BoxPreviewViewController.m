//
//  BoxPreviewViewController.m
//  BoxSDKSampleApp
//
//  Created by Ryan Lopopolo on 4/10/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <BoxSDK/BoxSDK.h>

#import "BoxPreviewViewController.h"

@interface BoxPreviewViewController ()

- (void)copyFileButtonPressed:(id)sender;

@end

@implementation BoxPreviewViewController

@synthesize fileID = _fileID;
@synthesize filename = _filename;
@synthesize parentFolderID = _parentFolderID;
@synthesize data = _data;
@synthesize MIMEType = _MIMEType;

- (id)initWithFileID:(NSString *)fileID filename:(NSString *)filename parentFolderID:(NSString *)parentFolderID data:(NSData *)data MIMEType:(NSString *)MIMEType
{
    self = [super init];
    if (self != nil)
    {
        _fileID = fileID;
        _filename = filename;
        _parentFolderID = parentFolderID;
        _data = data;
        _MIMEType = MIMEType;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIWebView *webView = (UIWebView *)self.view;
    webView.scalesPageToFit = YES;
    [webView loadData:self.data MIMEType:self.MIMEType textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"https://box.com" ]];


    UIBarButtonItem *copyFileButton = [[UIBarButtonItem alloc] initWithTitle:@"Copy file" style:UIBarButtonItemStyleBordered target:self action:@selector(copyFileButtonPressed:)];

    self.navigationItem.rightBarButtonItem = copyFileButton;
    self.navigationItem.title = self.filename;
}

- (void)loadView
{
    self.view = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

- (void)copyFileButtonPressed:(id)sender
{
    UIAlertView *copyFileAlert = [[UIAlertView alloc] initWithTitle:@"Copy File" message:@"Name of copy:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Copy", nil];

    copyFileAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

    [copyFileAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex)
    {
        UITextField *nameField = [alertView textFieldAtIndex:0];
        BoxFileBlock success = ^(BoxFile *file)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"File successfully copied" message:[NSString stringWithFormat:@"file id:%@", file.modelID] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

                [successAlert show];
            });
        };

        BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
        {
            NSLog(@"file create failed with error code: %i", response.statusCode);
            if (response.statusCode == 409)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIAlertView *conflictAlert = [[UIAlertView alloc] initWithTitle:@"Name conflict" message:[NSString stringWithFormat:@"A file already exists with the name %@.\n\nNew name:", nameField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

                    conflictAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

                    [conflictAlert show];
                });
            }
        };

        BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
        builder.name = nameField.text;
        builder.parentID = self.parentFolderID;

        [[BoxSDK sharedSDK].filesManager copyFileWithID:self.fileID requestBuilder:builder success:success failure:failure];
    }
}


@end
