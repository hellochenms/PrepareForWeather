//
//  CCWPWeatherContentView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-16.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "CCWCWeatherContentView.h"

@interface CCWCWeatherContentView()
@property (nonatomic) UILabel *label;
@end

@implementation CCWCWeatherContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = randomColor;
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
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
