//
//  CollectionViewLabelCell.m
//  SandwichFlow
//
//  Created by Daniel Kwiatkowski on 2015-06-01.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

#import "CollectionViewLabelCell.h"

@implementation CollectionViewLabelCell
{
    UILabel* _title;
}

-(UILabel *)title{
    return _title;
}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        //add a label to the cell
        _title = [[UILabel alloc]initWithFrame:CGRectInset(self.bounds, 3.0, 3.0)];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_title];
        
        //make it a rounded rectangle
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.layer.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    }
    return self;
}


@end
