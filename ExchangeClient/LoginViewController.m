//
//  LoginViewController.m
//  ExchangeClient
//
//  Created by Администратор on 11.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "LoginViewController.h"
#import "TableViewController.h"

@interface LoginViewController () {
    IBOutlet UITextField *addressField;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *passwordField;
}
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    self.title = @"Login";
    ServerWhisperer *serverWhispererInstance = [[ServerWhisperer alloc] initWithServerURL:[NSURL URLWithString:@"https://mail.digdes.com/ews/exchange.asmx"]
                                                                             withUserName:@"sed2"
                                                                             withPassword:@"P@ssw0rd"
                                                                             withDelegate:self];
    [serverWhispererInstance getFolderHierarchy];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)loginButton:(id)sender{
    
    TableViewController *tableViewController = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    [self.navigationController pushViewController:tableViewController animated:YES];
    [tableViewController release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    
    [addressField release];
    [nameField release];
    [passwordField release];
    [super dealloc];
}

- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolderHierarchy:(NSArray *)hierarchy{
    NSLog(@"%@",hierarchy);
}

- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolder:(NSDictionary *)folder {
    
};

- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingItems:(NSArray *)items {
    
}

- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingMessage:(NSDictionary *)folder {
    
}

@end
