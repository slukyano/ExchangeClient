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
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *exitButton;
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
    //[serverWhispererInstance syncFolderHierarchyUsingSyncState:nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"!!!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"logged"]) {
        loginButton.titleLabel.text = @"Data";
        addressField.text = [defaults stringForKey:@"address"];
        nameField.text = [defaults stringForKey:@"name"];
        passwordField.text = [defaults stringForKey:@"password"];
        exitButton.hidden = NO;
    }
    else {
        loginButton.titleLabel.text = @"Login";
        addressField.text = @"";
        nameField.text = @"";
        passwordField.text = @"";
        exitButton.hidden = YES;
        
    }
}

- (IBAction)loginButton:(id)sender{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"logged"];
    [defaults setObject:addressField.text forKey:@"address"];
    [defaults setObject:nameField.text forKey:@"name"];
    [defaults setObject:passwordField.text forKey:@"password"];
    [defaults synchronize];
    
    TableViewController *tableViewController = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    [self.navigationController pushViewController:tableViewController animated:YES];
    [tableViewController release];
}

- (IBAction)exitButton:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"logged"];
    [defaults setObject:@"" forKey:@"address"];
    [defaults setObject:@"" forKey:@"name"];
    [defaults setObject:@"" forKey:@"password"];
    [defaults synchronize];
    [self viewWillAppear:YES];
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

- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingMessage:(NSDictionary *)message{

}

// Передает массив словарей, как в getItemWithID
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFolders:(NSArray *)folders{

}

// Передает массив словарей, как в getFolderWithID
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingItems:(NSArray *)items{

}

// Передает словарь изменений. Ключи - @"Create", @"Update", @"Delete", значения - массивы словарей писем.
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingItemsToSync:(NSDictionary *)itemsToSync{

}

// Передает словарь изменений. Ключи - @"Create", @"Update", @"Delete", значения - массивы словарей папок.
- (void) serverWhisperer:(ServerWhisperer *)whisperer didFinishLoadingFoldersToSync:(NSDictionary *)foldersToSync{

}
@end
