//
//  CityItem.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CityItem;

typedef void (^TapDeleteHandler)(CityItem*);

@interface CityItem : UIView
@property (nonatomic, copy) TapDeleteHandler tapDeleteHandler;
- (void)reloadData:(NSString *)data;
- (void)showDeleteButton:(BOOL)toShow;
@end
