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
#import "NewMessageViewController.h"
#import "TableCell.h"
#import "Defines.h"

@interface TableViewController () {
    NSString *currentFolderID;
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

- (BOOL) shouldAutorotate {
    return NO;
}

- (void)viewDidLoad
{
    currentFolderID = [[ExchangeClientDataSingleton instance] messageRootFolderID];
    
    UIBarButtonItem *cancel =[[[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self
                               action:@selector(cancelButton)] autorelease];
    
    self.navigationItem.rightBarButtonItem = cancel;

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setImage:[UIImage imageNamed:@"mailbutton"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(newMessageButton) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setFrame:CGRectMake(0, 0, 100, 35)];
    self.navigationItem.titleView = titleButton;
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) newMessageButton {
    NewMessageViewController *newMessageViewController = [[NewMessageViewController alloc] initWithNibName:@"NewMessageViewController" bundle: nil];
    [self.navigationController pushViewController:newMessageViewController animated:YES];
    [newMessageViewController release];
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
    return [[ExchangeClientDataSingleton instance] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TableCell *cell = (TableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UIViewController *tempVC = [[UIViewController alloc] initWithNibName:@"TableCell" bundle:nil];
        cell=(TableCell *)tempVC.view;
        [tempVC release];
    }
    
    NSInteger currentDataType = [[[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"DataType"] integerValue];
    if (currentDataType == DataTypeFolder) {
        cell.textLabel.text = [[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"DisplayName"];
        if ([[[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"UnreadCount"] integerValue] != 0)
            cell.countLabel.text = [NSString stringWithFormat:@"%d", [[[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"UnreadCount"] integerValue]];
        if ([[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"DisplayName"] == @"/...")
            cell.imageView.image = [UIImage imageNamed:@"back"];
        else
            cell.imageView.image = [UIImage imageNamed:@"folder"];
    } else if (currentDataType == DataTypeEMail) {
        cell.textLabel.text = [[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"Subject"];
        cell.imageView.image = [UIImage imageNamed:@"mail"];
    } else {
        cell.textLabel.text = @"Wrong DataType";
        cell.imageView.image = [UIImage imageNamed:@"mail"];
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
    NSInteger currentDataType = [[[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"DataType"] integerValue];
    if (currentDataType == DataTypeFolder) {
        if ([[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"DisplayName"] == @"/...") {
            currentFolderID = [[ExchangeClientDataSingleton instance] ParentIDForFolderWithID:currentFolderID];
        } else {
            currentFolderID = [[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row] valueForKey:@"FolderID"];
        }
        [[ExchangeClientDataSingleton instance] ItemsInFolderWithID:currentFolderID];
        [self.tableView reloadData];
    } else if (currentDataType == DataTypeEMail) {
        ContentViewController *contentViewController = [[ContentViewController alloc] initWithMessage:[[ExchangeClientDataSingleton instance] objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:contentViewController animated:YES];
        [contentViewController release];
    }
    
}

@end
