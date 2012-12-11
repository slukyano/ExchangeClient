//
//  ContentViewController.m
//  ExchangeClient
//
//  Created by Администратор on 11.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ContentViewController.h"
#import "Defines.h"
#import "NewMessageViewController.h"

@interface ContentViewController ()
{
    NSDictionary *mail;
    IBOutlet UITextField *fromTextField;
    IBOutlet UITextField *toTextField;
    IBOutlet UITextField *subjectTextField;
    IBOutlet UIButton *replyButton;
    IBOutlet UIButton *forwardButton;
    IBOutlet UITextView *bodyTextView;
    IBOutlet UIWebView *bodyWebView;
    
}
@end

@implementation ContentViewController

- (id)initWithMessage:(NSDictionary*)message
{
    if ([message valueForKey:@"BodyType"] ==  [NSNumber numberWithUnsignedInteger:EMailContentTypePlainText]) self = [super initWithNibName:@"ContentViewText" bundle:nil];
    else self = [super initWithNibName:@"ContentViewHTML" bundle:nil];
    
    if (self) {
        mail = message;
        NSLog(@"%@", mail);
    }
    return self;
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (void)viewDidLoad
{
    UIBarButtonItem *cancel =[[[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self
                               action:@selector(cancelButton)] autorelease];
    self.navigationItem.rightBarButtonItem = cancel;
    
    subjectTextField.text = [mail valueForKey:@"Subject"];
    fromTextField.text = [[mail valueForKey:@"From"] valueForKey:@"EmailAddress"];
    if ([[mail valueForKey:@"Recipients"] count] != 0)
        toTextField.text = [[[mail valueForKey:@"Recipients"] objectAtIndex:0] valueForKey:@"EmailAddress"];
    if ([mail valueForKey:@"BodyType"] ==  [NSNumber numberWithUnsignedInteger:EMailContentTypePlainText])
        bodyTextView.text = [mail valueForKey:@"Body"];
    else {
        //загрузка body wev view
    }
        
    
    [super viewDidLoad];
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

- (IBAction)replyButton:(id)sender{
    NewMessageViewController *newMessageViewController = [[NewMessageViewController alloc] initWithNibName:@"NewMessageViewController" bundle: nil];
    [self.navigationController pushViewController:newMessageViewController animated:YES];
    [newMessageViewController release];
}

- (IBAction)forwardButton:(id)sender{
    NewMessageViewController *newMessageViewController = [[NewMessageViewController alloc] initWithNibName:@"NewMessageViewController" bundle: nil];
    [self.navigationController pushViewController:newMessageViewController animated:YES];
    [newMessageViewController release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [fromTextField release];
    [toTextField release];
    [subjectTextField release];
    [replyButton release];
    [forwardButton release];
    [super dealloc];
}
@end
