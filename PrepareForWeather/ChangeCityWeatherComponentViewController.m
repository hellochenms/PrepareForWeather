//
//  ChangeCityComponentViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-16.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "ChangeCityWeatherComponentViewController.h"
#import "M2Cell3DataNPagingEnabledView.h"
#import "CCWCWeatherContentView.h"
#import "CityManager.h"

@interface ChangeCityWeatherComponentViewController ()<M2Cell3DataNPagingEnabledViewDataSource>
@property (nonatomic) M2Cell3DataNPagingEnabledView *pagingEnabledView;
@end

@implementation ChangeCityWeatherComponentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    if (isIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _pagingEnabledView = [[M2Cell3DataNPagingEnabledView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    _pagingEnabledView.dataSource = self;
    [self.view addSubview:_pagingEnabledView];
}

#pragma mark - M2Cell3DataNPagingEnabledViewDataSource
- (NSString *)cellClassNameForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view{
    return NSStringFromClass([CCWCWeatherContentView class]);
}
- (NSInteger)numberOfDatasForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view{
    return [[CityManager defaultCityManager].cities count];
}
- (NSInteger)curDataIndexForPagingEnabledView:(M2Cell3DataNPagingEnabledView *)view{
    return [[CityManager defaultCityManager] defalutCityIndex];
}
- (void)pagingEnabledView:(M2Cell3DataNPagingEnabledView *)view wantsReloadDataAtIndex:(NSInteger)index forCell:(UIView *)cell{
    [((CCWCWeatherContentView *)cell) reloadData:[[CityManager defaultCityManager].cities objectAtIndex:index]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
