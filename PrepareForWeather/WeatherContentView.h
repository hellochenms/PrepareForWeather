//
//  WeatherContentView.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeatherContentView;

typedef void (^DidChangeSelectedIndexHandler)(NSInteger, WeatherContentView*);

@interface WeatherContentView : UIView
@property (nonatomic, copy) DidChangeSelectedIndexHandler didChangeSelectedIndexHandler;
- (void)changeSelectedIndex:(NSInteger)selectedIndex;
@end
