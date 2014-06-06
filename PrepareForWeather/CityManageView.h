//
//  CItyManageView.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TapHandler)(void);

@interface CityManageView : UIView
@property (nonatomic, copy) TapHandler tapBackToMainHandler;
@end
