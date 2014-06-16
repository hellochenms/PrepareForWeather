//
//  CityManager.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "CityManager.h"

NSString * const kCMCitiesDidUpdate = @"kCMCitiesDidUpdate";

@interface CityManager()
@property (nonatomic) NSMutableArray *cities;
@end

@implementation CityManager

static CityManager *s_cityManager = nil;
+ (CityManager *)defaultCityManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cityManager = [CityManager new];
    });
    
    return s_cityManager;
}

- (id)init{
    self = [super init];
    if (self) {
        _cities = [NSMutableArray array];
        int count = 6;
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            [array addObject:[NSString stringWithFormat:@"%d", i]];
        }
        [_cities addObjectsFromArray:array];
        _defalutCityIndex = arc4random() % count;
        NSLog(@"_cities(%@) _defalutCityIndex(%d) @@%s", _cities, _defalutCityIndex, __func__);
    }
    
    return self;
}

- (void)didUpdateCities{
    // 也许可以dispatch_asyc到主线程
    [[NSNotificationCenter defaultCenter] postNotificationName:kCMCitiesDidUpdate object:nil];
}

@end
