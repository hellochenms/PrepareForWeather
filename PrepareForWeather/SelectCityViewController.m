//
//  CitySelectViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "SelectCityViewController.h"

@interface SelectCityViewController ()
@property (nonatomic) UIButton *finishButton;
@end

@implementation SelectCityViewController

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
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = CGRectMake(60, 10, 200, 50);
    _finishButton.backgroundColor = [UIColor blueColor];
    [_finishButton setTitle:@"完成添加城市" forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(onTapFinish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_finishButton];
}

- (void)onTapFinish{
    if (_tapFinishHandler) {
        _tapFinishHandler();
    }
    [self.navigationController popViewControllerAnimated:YES];
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
