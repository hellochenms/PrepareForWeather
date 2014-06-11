//
//  CityGMCell.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "CityGMCell.h"

@interface CityGMCell()
@property (nonatomic) UILabel   *label;
@end

@implementation CityGMCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blueColor];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 10 - 60, 10, 60, 20)];
        [self addSubview:_label];
    }
    return self;
}

- (void)reloadData:(NSString *)data{
    _label.text = data;
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
