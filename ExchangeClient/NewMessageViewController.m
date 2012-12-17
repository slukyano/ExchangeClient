//
//  NewMessageViewController.m
//  ExchangeClient
//
//  Created by Администратор on 03.12.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "NewMessageViewController.h"
#import "DataBaseManager.h"
#import "Defines.h"
#import "ExchangeClientDataSingleton.h"
#import <QuartzCore/QuartzCore.h>

@interface NewMessageViewController () {
    IBOutlet UITextField *fromTextField;
    IBOutlet UITextField *toTextField;
    IBOutlet UITextField *subjectTextField;
    IBOutlet UITextView *messageTextView;
    
}
@end

@implementation NewMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    messageTextView.layer.borderWidth = 2.0f;
    messageTextView.layer.cornerRadius = 5;
    messageTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    UIBarButtonItem *done =[[[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                               target:self
                               action:@selector(doneButton)] autorelease];
    
    self.navigationItem.rightBarButtonItem = done;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) doneButton {
    if ((fromTextField.text != @"") &
        (toTextField.text != @"") &
        (subjectTextField.text != @"") &
        (messageTextView.text != @""))
    {
        DataBaseManager *dataBaseManager = [[DataBaseManager alloc] initWithDatabaseForUser:@"sed2"];
        NSDictionary *recipientsDict = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"TEST",@"Name",toTextField.text,@"EmailAddress",nil]];
        
        NSDictionary *mailDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  subjectTextField.text, @"Subject",
                                  messageTextView.text, @"Body",
                                  recipientsDict, @"Recipients",
                                  [NSNumber numberWithInteger:EMailContentTypePlainText],@"BodyType",nil];
        BOOL success = [dataBaseManager sendMessageUsingDictionary:mailDict];
        
        if (success)
            NSLog(@"success!");
        else
            NSLog(@"something's wrong");
        
        [dataBaseManager release];
        
        if (success)
            [[ExchangeClientDataSingleton instance] databaseUpdated];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
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
    [messageTextView release];
    [super dealloc];
}
@end
