//
//  MapView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "MapView.h"

@interface MapView()
@property (nonatomic) UIButton *backToMainViewButton;
@end

@implementation MapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blueColor];
        
        _backToMainViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backToMainViewButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 10 - 60, 0, 60, 60);
        _backToMainViewButton.backgroundColor = [UIColor redColor];
        [_backToMainViewButton addTarget:self action:@selector(onBackToMainButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backToMainViewButton];
    }
    return self;
}

- (void)onBackToMainButton{
    if (_tapBackToMainHandler) {
        _tapBackToMainHandler();
    }
}

@end
