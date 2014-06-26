//
//  TrendsThinkViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-26.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "TrendsThinkViewController.h"
#import "TrendsThinkView.h"
#import "TrendsThinkLayerView.h"
#import "TrendsThinkGroupView.h"

@interface TrendsThinkViewController ()
@property (nonatomic) TrendsThinkView       *trendsView;
@property (nonatomic) TrendsThinkLayerView  *trendsLayerView;
@property (nonatomic) TrendsThinkGroupView  *trendsGroupView;
@end

@implementation TrendsThinkViewController

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
    
    _trendsView = [[TrendsThinkView alloc] initWithFrame:CGRectMake(10, 10, 300, 150)];
    [self.view addSubview:_trendsView];
    
    _trendsLayerView = [[TrendsThinkLayerView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_trendsView.frame) + 10, 300, 150)];
    [self.view addSubview:_trendsLayerView];
    
    _trendsGroupView = [[TrendsThinkGroupView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_trendsLayerView.frame) + 10, 300, 150)];
    [self.view addSubview:_trendsGroupView];    
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
