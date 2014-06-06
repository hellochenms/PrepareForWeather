//
//  MainView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "MainView.h"
#import "WeatherView.h"
#import "SettingView.h"
#import "CityManageView.h"

#define MV_OffsetX 100

@interface MainView()
@property (nonatomic) WeatherView       *weatherView;
@property (nonatomic) CityManageView    *cityManageView;
@property (nonatomic) SettingView       *settingView;
@property (nonatomic) UIControl         *coverView;
@end

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _weatherView = [[WeatherView alloc] initWithFrame:self.bounds];
        __weak typeof(self) weakSelf = self;
        _weatherView.tapCityManageHandler = ^{
            [weakSelf showCityManageView];
        };
        _weatherView.tapMapHandler = ^{
            [weakSelf showMapView];
        };
        _weatherView.tapSettingHandler = ^{
            [weakSelf showSettingView];
        };
        [self addSubview:_weatherView];
        
        CGRect cityManageFrame = self.bounds;
        cityManageFrame.origin.y = -CGRectGetHeight(self.bounds);
        _cityManageView = [[CityManageView alloc] initWithFrame:cityManageFrame];
        _cityManageView.tapBackToMainHandler = ^{
            [weakSelf hideCityManageView];
        };
        [self addSubview:_cityManageView];
        
        _settingView = [[SettingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, 100, CGRectGetHeight(self.bounds))];
        [self addSubview:_settingView];
        
        _coverView = [[UIControl alloc] initWithFrame:_weatherView.bounds];
        [_coverView addTarget:self action:@selector(hiddSettingView) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)showCityManageView{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.userInteractionEnabled = NO;
                         CGRect cityManageFrame = _cityManageView.frame;
                         cityManageFrame.origin.y = 0;
                         _cityManageView.frame = cityManageFrame;
                     }
                     completion:^(BOOL finished) {
                         self.userInteractionEnabled = YES;
                     }];
}
- (void)hideCityManageView{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.userInteractionEnabled = NO;
                         CGRect cityManageFrame = _cityManageView.frame;
                         cityManageFrame.origin.y = - CGRectGetHeight(self.bounds);
                         _cityManageView.frame = cityManageFrame;
                     }
                     completion:^(BOOL finished) {
                         self.userInteractionEnabled = YES;
                     }];
}

- (void)showSettingView{
    [_weatherView addSubview:_coverView];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.userInteractionEnabled = NO;
                         CGPoint weatherCenter = _weatherView.center;
                         weatherCenter.x = CGRectGetWidth(self.bounds) / 2 - MV_OffsetX;
                         _weatherView.center = weatherCenter;
                         CGRect settingFrame = _settingView.frame;
                         settingFrame.origin.x = CGRectGetWidth(self.bounds) - MV_OffsetX;
                         _settingView.frame = settingFrame;
                     }
                     completion:^(BOOL finished) {
                         self.userInteractionEnabled = YES;
                     }];
}
- (void)hiddSettingView{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.userInteractionEnabled = NO;
                         CGPoint weatherCenter = _weatherView.center;
                         weatherCenter.x = CGRectGetWidth(self.bounds) / 2;
                         _weatherView.center = weatherCenter;
                         CGRect settingFrame = _settingView.frame;
                         settingFrame.origin.x = CGRectGetWidth(self.bounds);
                         _settingView.frame = settingFrame;
                     }
                     completion:^(BOOL finished) {
                         self.userInteractionEnabled = YES;
                         [_coverView removeFromSuperview];
                     }];
}

- (void)showMapView{
    if (_toMapBlock) {
        _toMapBlock();
    }
}

@end
