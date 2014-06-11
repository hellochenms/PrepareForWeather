//
//  WeatherRootViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "WeatherRootViewController.h"
#import "MainView.h"
#import "MapView.h"

@interface WeatherRootViewController ()
@property (nonatomic) MainView  *mainView;
@property (nonatomic) MapView   *mapView;
@end

@implementation WeatherRootViewController

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
//    self.navigationController.navigationBarHidden = YES;
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _mainView = [[MainView alloc] initWithFrame:frame];
    __weak typeof(self) weakSelf = self;
    _mainView.toMapBlock = ^{
        [weakSelf flipMainAndMap:YES];
    };
    [self.view addSubview:_mainView];
    
    _mapView = [[MapView alloc] initWithFrame:frame];
    _mapView.tapBackToMainHandler = ^{
        [weakSelf flipMainAndMap:NO];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)flipMainAndMap:(BOOL)isToMap{
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionNone;
    UIView *fromView = nil;
    UIView *toView = nil;
    if (isToMap) {
        fromView = _mainView;
        toView = _mapView;
        options = UIViewAnimationOptionTransitionFlipFromLeft;
    }else{
        fromView = _mapView;
        toView = _mainView;
        options = UIViewAnimationOptionTransitionFlipFromRight;
    }
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:options
                    completion:nil];
}

@end
