//
//  TableViewController.m
//  ExchangeClient
//
//  Created by Администратор on 11.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "TableViewController.h"
#import "ContentViewController.h"
#import "ExchangeClientDataSingleton.h"
@interface TableViewController () {
    NSString *currentFolderID;
    NSMutableArray *itemsInCurrentFolder;
}
@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    currentFolderID = @"111";
    itemsInCurrentFolder = [[ExchangeClientDataSingleton instance] ItemsInFolderWithID:currentFolderID];
    UIBarButtonItem *cancel =[[[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self
                               action:@selector(cancelButton)] autorelease];
    self.navigationItem.rightBarButtonItem = cancel;
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) cancelButton {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"logged"];
    [defaults setObject:@"" forKey:@"address"];
    [defaults setObject:@"" forKey:@"name"];
    [defaults setObject:@"" forKey:@"password"];
    [defaults synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [itemsInCurrentFolder count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if ([[itemsInCurrentFolder objectAtIndex:indexPath.row] valueForKey:@"Type"] == @"Folder") {
        cell.textLabel.text = [[itemsInCurrentFolder objectAtIndex:indexPath.row] valueForKey:@"DisplayName"];
    } else {
        cell.textLabel.text = [[itemsInCurrentFolder objectAtIndex:indexPath.row] valueForKey:@"Subject"];
    }
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[itemsInCurrentFolder objectAtIndex:indexPath.row] valueForKey:@"Type"] == @"Folder") {
        
        if ([[itemsInCurrentFolder objectAtIndex:indexPath.row] valueForKey:@"DisplayName"] == @"/...") {
            currentFolderID = [[ExchangeClientDataSingleton instance] ParentIDForFolderWithID:currentFolderID];
        } else {
            currentFolderID = [[itemsInCurrentFolder objectAtIndex:indexPath.row] valueForKey:@"FolderID"];
        }
        itemsInCurrentFolder = [[ExchangeClientDataSingleton instance] ItemsInFolderWithID:currentFolderID];
        [self.tableView reloadData];
    } else {
        ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil message:[itemsInCurrentFolder objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:contentViewController animated:YES];
        [contentViewController release];
    }
    
}

@end
