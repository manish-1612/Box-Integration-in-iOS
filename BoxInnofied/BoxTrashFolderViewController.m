//
//  BoxTrashFolderViewController.m
//  BoxSDKSampleApp
//
//  Created by Ryan Lopopolo on 3/13/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <BoxSDK/BoxSDK.h>

#import "BoxTrashFolderViewController.h"

@interface BoxTrashFolderViewController ()

@property (nonatomic, readwrite, strong) BoxModel *selectedItem;

- (void)restoreFromTrash:(id)sender;
- (void)dismissTrashView:(id)sender;

@end

@implementation BoxTrashFolderViewController

@synthesize selectedItem = _selectedItem;

+ (instancetype)folderViewFromStoryboardWithFolderID:(NSString *)folderID folderName:(NSString *)folderName;
{

    NSString *storyboardName = @"MainStoryboard_iPhone";
    if (IS_IPAD())
    {
        storyboardName = @"MainStoryboard_iPad";
    }

    BoxTrashFolderViewController *folderViewController = (BoxTrashFolderViewController *)[[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:@"TrashFolderTableView"];

    folderViewController.folderID = folderID;
    folderViewController.folderName = folderName;

    return folderViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *restoreFromTrashButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore Item" style:UIBarButtonItemStylePlain target:self action:@selector(restoreFromTrash:)];
    restoreFromTrashButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = restoreFromTrashButton;

    UIBarButtonItem *dismissTrashViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissTrashView:)];
    self.navigationItem.rightBarButtonItem = dismissTrashViewButton;

    [self setToolbarItems:@[]];
    self.navigationController.toolbarHidden = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoxModel *item = (BoxModel *)[self.folderItemsArray objectAtIndex:[indexPath row]];

    self.selectedItem = item;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedItem = nil;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoxModel *modelToDelete = [self.folderItemsArray objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete && [modelToDelete.type isEqualToString:BoxAPIItemTypeFolder])
    {
        NSString *folderIDToDelete = modelToDelete.modelID;

        BoxSuccessfulDeleteBlock success = ^(NSString *deletedFolderID)
        {
            // refresh folder contents
            [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationItem.title];
        };

        [self.refreshControl beginRefreshing];
        [[BoxSDK sharedSDK].foldersManager deleteFolderFromTrashWithID:folderIDToDelete requestBuilder:nil success:success failure:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Permanently Delete";
}

- (void)restoreFromTrash:(id)sender
{
    if (self.selectedItem != nil && [self.selectedItem.type isEqualToString:BoxAPIItemTypeFolder])
    {
        NSString *folderID = self.selectedItem.modelID;

        BoxFolderBlock success = ^(BoxFolder *folder)
        {
            // refresh folder contents
            [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationItem.title];
        };

        [self.refreshControl beginRefreshing];
        [[BoxSDK sharedSDK].foldersManager restoreFolderFromTrashWithID:folderID requestBuilder:nil success:success failure:nil];
    }
}

- (void)dismissTrashView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
