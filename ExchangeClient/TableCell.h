//
//  TableCell.h
//  ExchangeClient
//
//  Created by Администратор on 05.12.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@end
