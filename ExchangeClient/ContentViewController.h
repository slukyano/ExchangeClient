//
//  ContentViewController.h
//  ExchangeClient
//
//  Created by Администратор on 11.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController
- (id)initWithMessage:(NSDictionary*)message;
- (IBAction)replyButton:(id)sender;
- (IBAction)forwardButton:(id)sender;
@end
