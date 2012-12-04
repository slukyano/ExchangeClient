//
//  TableCell.m
//  ExchangeClient
//
//  Created by Администратор on 05.12.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell
@synthesize textLabel, countLabel, imageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [textLabel release];
    textLabel = nil;
    [countLabel release];
    countLabel = nil;
    [imageView release];
    imageView = nil;
    [super dealloc];
}

@end
