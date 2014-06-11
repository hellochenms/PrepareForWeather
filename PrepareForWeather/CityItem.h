//
//  CityItem.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityItem : UIView
- (void)reloadData:(NSString *)data;
- (void)showDeleteButton:(BOOL)toShow;
@end
