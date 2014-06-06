//
//  CityManager.h
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const kCMCitiesDidUpdate;

@interface CityManager : NSObject
@property (nonatomic, readonly) NSMutableArray *cities;
@property (nonatomic) int defalutCityIndex;
+ (CityManager *)defaultCityManager;
- (void)didUpdateCities;
@end
