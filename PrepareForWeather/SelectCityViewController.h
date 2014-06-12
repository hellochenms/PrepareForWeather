//
//  CitySelectViewController.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapHandler) (void);

@interface SelectCityViewController : UIViewController
@property (nonatomic, copy) TapHandler tapFinishHandler;
@end
