//
//  WeatherView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "WeatherView.h"
#import "WeatherContentView.h"

@interface WeatherView()
@property (nonatomic) UIButton *cityManageButton;
@property (nonatomic) UIButton *mapButton;
@property (nonatomic) UIButton *settingButton;
@property (nonatomic) UIScrollView  *scorllView;
@property (nonatomic) NSMutableArray *items;
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
        
        // temp //TODO:!
        _scorllView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scorllView.pagingEnabled = YES;
        [self addSubview:_scorllView];
        int count = 3;
        WeatherContentView *contentView = nil;
        float itemWidth = CGRectGetWidth(self.bounds);
        float itemHeight = CGRectGetHeight(self.bounds);
        __weak typeof(self) weakSelf = self;
        _items = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            contentView = [[WeatherContentView alloc] initWithFrame:CGRectMake(itemWidth * i, 0, itemWidth, itemHeight)];
            [_scorllView addSubview:contentView];
            [_items addObject:contentView];
            contentView.didChangeSelectedIndexHandler = ^(NSInteger selectedIndex, WeatherContentView *srcItem){
                WeatherContentView *item = nil;
                for (item in weakSelf.items) {
                    if (item != srcItem) {
                        [item changeSelectedIndex:selectedIndex];
                    }
                }
            };
        }
        _scorllView.contentSize = CGSizeMake(itemWidth * count, itemHeight);
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
