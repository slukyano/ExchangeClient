//
//  ContentViewController.m
//  ExchangeClient
//
//  Created by Администратор on 11.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "ContentViewController.h"
#import "Defines.h"

@interface ContentViewController ()
{
    NSDictionary *mail;
}
@end

@implementation ContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil message:(NSDictionary*)message
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mail = message;
    }
    return self;
}

- (void)viewDidLoad
{
    if ([mail valueForKey:@"BodyType"] == EMailContentTypePlainText) {
        UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
        textView.text = [mail valueForKey:@"Body"];
        [self.view addSubview:textView];
    } else {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:webView];
    }
    UIBarButtonItem *cancel =[[[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self
                               action:@selector(cancelButton)] autorelease];
    self.navigationItem.rightBarButtonItem = cancel;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
