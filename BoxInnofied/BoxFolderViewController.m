//
//  BoxRootViewController.m
//  BoxSDKSampleApp
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <BoxSDK/BoxSDK.h>

#import "BoxFolderViewController.h"

#import "AppDelegate.h"
//#import "BoxNavigationController.h"
#import "BoxPreviewViewController.h"
#import "BoxTrashFolderViewController.h"

#define TABLE_CELL_REUSE_IDENTIFIER  @"Cell"

@interface BoxFolderViewController ()

- (void)drillDownToFolderID:(NSString *)folderID name:(NSString *)name;
- (void)displayPreviewWebviewWithFileID:(NSString *)fileID filename:(NSString *)filename;
- (void)displayTrashFolder:(id)sender;
- (void)performSampleUpload:(id)sender;
- (void)addFolderButtonClicked:(id)sender;
- (void)logoutButtonClicked:(id)sender;

- (void)boxTokensDidRefresh:(NSNotification *)notification;
- (void)boxDidGetLoggedOut:(NSNotification *)notification;

@end

@implementation BoxFolderViewController

@synthesize accessTokenLabel = _accessTokenLabel;
@synthesize refreshTokenLabel = _refreshTokenLabel;
@synthesize logoutButton = _logoutButton;
@synthesize folderItemsArray = _folderItemsArray;
@synthesize totalCount = _totalCount;
@synthesize folderID = _folderID;
@synthesize folderName = _folderName;

+ (instancetype)folderViewFromStoryboardWithFolderID:(NSString *)folderID folderName:(NSString *)folderName;
{

    /*
    NSString *storyboardName = @"MainStoryboard_iPhone";
    if (IS_IPAD())
    {
        storyboardName = @"MainStoryboard_iPad";
    }
     */
    BoxFolderViewController *folderViewController = (BoxFolderViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FolderTableView"];

    folderViewController.folderID = folderID;
    folderViewController.folderName = folderName;

    return folderViewController;
}

- (void)viewDidLoad
{
    
    self.view.frame=CGRectMake(0, 22, 320, self.view.frame.size.height-22);
    self.accessTokenLabel.text = [BoxSDK sharedSDK].OAuth2Session.accessToken;
    self.refreshTokenLabel.text = [BoxSDK sharedSDK].OAuth2Session.refreshToken;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewDidPullToRefresh) forControlEvents:UIControlEventValueChanged];

    /*
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithTitle:@"Trash" style:UIBarButtonItemStylePlain target:self action:@selector(displayTrashFolder:)];
    self.navigationItem.rightBarButtonItem = trashButton;

    self.logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonClicked:)];
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"Sample Upload" style:UIBarButtonItemStyleBordered target:self action:@selector(performSampleUpload:)];
    UIBarButtonItem *addFolderButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Folder" style:UIBarButtonItemStyleBordered target:self action:@selector(addFolderButtonClicked:)];

    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:@[self.logoutButton, uploadButton, addFolderButton] animated:YES];*/
    
    

    // Handle logged in
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxTokensDidRefresh:)
                                                name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                            object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxTokensDidRefresh:)
                                                name:BoxOAuth2SessionDidRefreshTokensNotification
                                            object:[BoxSDK sharedSDK].OAuth2Session];
    // Handle logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxDidGetLoggedOut:)
                                                name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                            object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxDidGetLoggedOut:)
                                                name:BoxOAuth2SessionDidReceiveRefreshErrorNotification
                                                object:[BoxSDK sharedSDK].OAuth2Session];

    if (self.folderID == nil)
    {
        self.folderID = BoxAPIFolderIDRoot;
        self.folderName = @"All Files";
    }

    self.navigationItem.title = self.folderName;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)boxTokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *)notification.object;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.accessTokenLabel.text = OAuth2Session.accessToken;
        self.refreshTokenLabel.text = OAuth2Session.refreshToken;
        self.logoutButton.title = @"Logout";
    });
}

- (void)boxDidGetLoggedOut:(NSNotification *)notification
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        // clear old folder items
        self.folderItemsArray = [NSMutableArray array];
        [self.tableView reloadData];
        self.accessTokenLabel.text = @"";
        self.refreshTokenLabel.text = @"";
        self.logoutButton.title = @"Login";
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchFolderItemsWithFolderID:self.folderID name:self.folderName];
}

#pragma mark - UITableViewController refresh control
- (void)tableViewDidPullToRefresh
{
    [self fetchFolderItemsWithFolderID:self.folderID name:self.folderName];
}

#pragma mark - UITabableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOXAssert([indexPath row] < self.folderItemsArray.count, @"Table cell requested for row greater than number of items in folder");

    BoxItem *item = (BoxItem *)[self.folderItemsArray objectAtIndex:[indexPath row]];

    UITableViewCell *cell = (UITableViewCell  *)[self.tableView dequeueReusableCellWithIdentifier:TABLE_CELL_REUSE_IDENTIFIER];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLE_CELL_REUSE_IDENTIFIER];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"%@",item.name]];
    
    
    if ([item.type isEqualToString:BoxAPIItemTypeFolder])
    {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoxItem *item = (BoxItem *)[self.folderItemsArray objectAtIndex:[indexPath row]];
    
    NSLog(@"item type : %@ : %@ : %@ ", item.type, item.name, item.sharedLink);
    
    
    if ([item.type isEqualToString:BoxAPIItemTypeFolder])
    {
        [self drillDownToFolderID:item.modelID name:item.name];
    }
    else if ([item.type isEqualToString:BoxAPIItemTypeFile])
    {
        //[self displayPreviewWebviewWithFileID:item.modelID filename:item.name];
        
       // NSLog(@"dict : %@", [item.sharedLink objectForKey:@"url"]);

        [self displayFileInWebviewfromDictionary:item.sharedLink];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![BoxSDK sharedSDK].OAuth2Session.isAuthorized)
    {
        return 0;
    }
    else
    {
        return self.folderItemsArray.count;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *IDToDelete = ((BoxModel *)[self.folderItemsArray objectAtIndex:indexPath.row]).modelID;
        NSString *typeToDelete = ((BoxModel *)[self.folderItemsArray objectAtIndex:indexPath.row]).type;

        BoxSuccessfulDeleteBlock success = ^(NSString *deletedID)
        {
            // refresh folder contents
            [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationItem.title];
        };

        if ([typeToDelete isEqualToString:BoxAPIItemTypeFolder])
        {
            [self.refreshControl beginRefreshing];

            BoxFoldersRequestBuilder * builder = [[BoxFoldersRequestBuilder alloc] initWithRecursiveKey:YES];
            [[BoxSDK sharedSDK].foldersManager deleteFolderWithID:IDToDelete requestBuilder:builder success:success failure:nil];
        }
        else if ([typeToDelete isEqualToString:BoxAPIItemTypeFile])
        {
            [self.refreshControl beginRefreshing];
            [[BoxSDK sharedSDK].filesManager deleteFileWithID:IDToDelete requestBuilder:nil success:success failure:nil];
        }

    }
}

- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name
{
    BoxCollectionBlock success = ^(BoxCollection *collection)
    {
        self.folderItemsArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < collection.numberOfEntries; i++)
        {
            [self.folderItemsArray addObject:[collection modelAtIndex:i]];
        }
        self.totalCount = [collection.totalCount integerValue];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    };
    
    BoxFileBlock successfulShare = ^(BoxFile *file)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Share Successful" message:[NSString stringWithFormat:@"Shared link: %@", [file.sharedLink objectForKey:@"url"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
    };
    
    
    
    BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        NSLog(@"folder items error: %@", error);
    };

    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:folderID requestBuilder:nil success:success failure:failure];
}

- (void)drillDownToFolderID:(NSString *)folderID name:(NSString *)name
{
    BoxFolderViewController *drillDownViewController = [BoxFolderViewController folderViewFromStoryboardWithFolderID:folderID folderName:name];

    [self.navigationController pushViewController:drillDownViewController animated:YES];
}


-(void)displayFileInWebviewfromDictionary:(NSDictionary *)dictionary
{
    NSLog(@"dict : %@", dictionary);
    
}

- (void)displayPreviewWebviewWithFileID:(NSString *)fileID filename:(NSString *)filename
{
    /*
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *path = [documentRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", fileID, filename]];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];

    BoxDownloadSuccessBlock successBlock = ^(NSString *downloadedFileID, long long expectedContentLength)
    {
        NSLog(@"downloaded file - %@", fileID);
        NSString *blockPath = path;
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:blockPath options:0 error:&error];

        NSString *MIMETypeString;

        // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
        // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[blockPath pathExtension], NULL);
        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        if (!mimeType) {
            MIMETypeString =  @"application/octet-stream";
        }
        else
        {
            MIMETypeString = (__bridge NSString *)mimeType ;
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            BoxPreviewViewController *controller = [[BoxPreviewViewController alloc] initWithFileID:fileID filename:filename parentFolderID:self.folderID data:data MIMEType:MIMETypeString];
            [self.navigationController pushViewController:controller animated:YES];
        });
    };

    BoxDownloadFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        NSLog(@"download error with response code: %i", response.statusCode);
    };

    [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:successBlock failure:failureBlock progress:nil];*/
    
    
    
}

//Override to support conditional editing of the table view.
//This only needs to be implemented if you are going to be returning NO
//for some items. By default, all items are editable.

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemType = ((BoxItem *)[self.folderItemsArray objectAtIndex:indexPath.row]).type;
    return [itemType isEqualToString:BoxAPIItemTypeFolder] || [itemType isEqualToString:BoxAPIItemTypeFile];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemType = ((BoxModel *)[self.folderItemsArray objectAtIndex:indexPath.row]).type;
    if ([itemType isEqualToString:BoxAPIItemTypeFolder] || [itemType isEqualToString:BoxAPIItemTypeFile])
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Move To Trash";
}

#pragma mark - Navigation Bar Button
- (void)displayTrashFolder:(id)sender
{
    BoxTrashFolderViewController *drillDownViewController = [BoxTrashFolderViewController folderViewFromStoryboardWithFolderID:BoxAPIFolderIDTrash folderName:@"Trash"];

    UINavigationController *modalViewController = [[UINavigationController alloc] initWithRootViewController:drillDownViewController];
    [self presentViewController:modalViewController animated:YES completion:nil];
}
- (void)performSampleUpload1:(id)sender
{
    BoxFileBlock successfulShare = ^(BoxFile *file)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Share Successful" message:[NSString stringWithFormat:@"Shared link: %@", [file.sharedLink objectForKey:@"url"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
    };
    BoxAPIJSONFailureBlock failedShare = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        BOXLog(@"status code: %i", response.statusCode);
        BOXLog(@"share response JSON: %@", JSONDictionary);
    };
    BoxFileBlock fileBlock = ^(BoxFile *file)
    {
        [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationController.title];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Upload Successful" message:[NSString stringWithFormat:@"File has id: %@", file.modelID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
        BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
        BoxSharedObjectBuilder *sharedBuilder = [[BoxSharedObjectBuilder alloc] init];
        sharedBuilder.access = BoxAPISharedObjectAccessOpen;
        builder.sharedLink = sharedBuilder;
        [[BoxSDK sharedSDK].filesManager editFileWithID:file.modelID requestBuilder:builder success:successfulShare failure:failedShare];
    };
    
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        BOXLog(@"status code: %i", response.statusCode);
        BOXLog(@"upload response JSON: %@", JSONDictionary);
    };
    
    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"Logo_Box_Blue_Whitebg_480x480.jpg";
    builder.parentID = self.folderID;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Logo_Box_Blue_Whitebg_480x480.jpg" ofType:nil];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    long long contentLength = [[fileAttributes objectForKey:NSFileSize] longLongValue];
    
    [[BoxSDK sharedSDK].filesManager uploadFileWithInputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:nil];
}

#pragma mark - Upload
- (void)performSampleUpload:(id)sender
{
    BoxFileBlock fileBlock = ^(BoxFile *file)
    {
        [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationController.title];

        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Upload Successful" message:[NSString stringWithFormat:@"File has id: %@", file.modelID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
    };

    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        BOXLog(@"status code: %i", response.statusCode);
        BOXLog(@"upload response JSON: %@", JSONDictionary);
    };

    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = @"Logo_Box_Blue_Whitebg_480x480.jpg";
    builder.parentID = self.folderID;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Logo_Box_Blue_Whitebg_480x480.jpg" ofType:nil];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    long long contentLength = [[fileAttributes objectForKey:NSFileSize] longLongValue];

    [[BoxSDK sharedSDK].filesManager uploadFileWithInputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:nil];
}

#pragma mark - Folder creation
- (void)addFolderButtonClicked:(id)sender
{
    UIAlertView *folderNamePrompt = [[UIAlertView alloc] initWithTitle:@"Add Folder" message:@"Name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

    folderNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;

    [folderNamePrompt show];
}

#pragma mark - Logout
- (void)logoutButtonClicked:(id)sender
{
    // clear Tokens from memory
    [BoxSDK sharedSDK].OAuth2Session.accessToken = @"INVALID_ACCESS_TOKEN";
    [BoxSDK sharedSDK].OAuth2Session.refreshToken = @"INVALID_REFRESH_TOKEN";

    // clear tokens from keychain
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
   // [appDelegate setRefreshTokenInKeychain:@"INVALID_REFRESH_TOKEN"];

    //[(BoxNavigationController *)self.navigationController boxAPIHeartbeat];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex)
    {
        UITextField *nameField = [alertView textFieldAtIndex:0];
        BoxFolderBlock success = ^(BoxFolder *folder)
        {
            [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationItem.title];
        };

        BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
        {
            NSLog(@"folder create failed with error code: %i", response.statusCode);
            if (response.statusCode == 409)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIAlertView *conflictAlert = [[UIAlertView alloc] initWithTitle:@"Name conflict" message:[NSString stringWithFormat:@"A folder already exists with the name %@.\n\nNew name:", nameField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

                    conflictAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

                    [conflictAlert show];
                });
            }
        };

        BoxFoldersRequestBuilder *builder = [[BoxFoldersRequestBuilder alloc] init];
        builder.name = nameField.text;
        builder.parentID = self.folderID;

        [[BoxSDK sharedSDK].foldersManager createFolderWithRequestBuilder:builder success:success failure:failure];
    }
}

@end
