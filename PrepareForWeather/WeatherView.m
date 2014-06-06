//
//  WeatherView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "WeatherView.h"

@interface WeatherView()
@property (nonatomic) UIButton *cityManageButton;
@property (nonatomic) UIButton *mapButton;
@property (nonatomic) UIButton *settingButton;
@end

@implementation WeatherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        
        _cityManageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cityManageButton.frame = CGRectMake(0, 100, 60, 60);
        _cityManageButton.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, _cityManageButton.center.y);
        _cityManageButton.backgroundColor = [UIColor redColor];
        [_cityManageButton addTarget:self action:@selector(onTapCityManageButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cityManageButton];
        
        _mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mapButton.frame = CGRectMake(10, 200, 60, 60);
        _mapButton.backgroundColor = [UIColor redColor];
        [_mapButton addTarget:self action:@selector(onTapMapButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_mapButton];
        
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 60 - 10, 200, 60, 60);
        _settingButton.backgroundColor = [UIColor redColor];
        [_settingButton addTarget:self action:@selector(onTapSettingButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_settingButton];

    }
    return self;
}
- (void)onTapCityManageButton{
    if (_tapCityManageHandler) {
        _tapCityManageHandler();
    }
}

- (void)onTapMapButton{
    if (_tapMapHandler) {
        _tapMapHandler();
    }
}

- (void)onTapSettingButton{
    if (_tapSettingHandler) {
        _tapSettingHandler();
    }
}

@end
