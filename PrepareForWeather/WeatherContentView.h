//
//  WeatherContentView.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeatherContentView;

typedef void (^TapHandler)(void);
typedef void (^DidChangeSelectedIndexHandler)(NSInteger, WeatherContentView*);

@interface WeatherContentView : UIView
@property (nonatomic, copy) TapHandler tapCityManageHandler;
@property (nonatomic, copy) TapHandler tapMapHandler;
@property (nonatomic, copy) TapHandler tapSettingHandler;
@property (nonatomic, copy) DidChangeSelectedIndexHandler didChangeSelectedIndexHandler;
- (void)changeSelectedIndex:(NSInteger)selectedIndex;
@end
