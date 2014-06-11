//
//  CityItem.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "CityItem.h"
@interface CityItem()
@property (nonatomic) UILabel   *label;
@property (nonatomic) UIButton  *deleteButton;
@end

@implementation CityItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 20)];
        [self addSubview:_label];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(10, 40, 60, 20);
        _deleteButton.backgroundColor = [UIColor redColor];
        [_deleteButton setTitle:@"delete" forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        _deleteButton.hidden = YES;
        
    }
    return self;
}

- (void)reloadData:(NSString *)data{
    _label.text = data;
}

- (void)showDeleteButton:(BOOL)toShow{
    _deleteButton.hidden = !toShow;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
