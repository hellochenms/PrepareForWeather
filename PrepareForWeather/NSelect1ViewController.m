//
//  NSelect1ViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-7-22.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "NSelect1ViewController.h"
#import "M2SimpleNSelect1View.h"

@interface NSelect1ViewController ()<M2SimpleNSelect1ViewDelegate>
@property (nonatomic) UIButton *button;
@property (nonatomic) M2SimpleNSelect1View *nSelect1View;
@property (nonatomic) M2SimpleNSelect1View *attributedNSelect1View;
@property (nonatomic) M2SimpleNSelect1View *vertivalNSelect1View;
@end

@implementation NSelect1ViewController

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
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(10, 10, 300, 30);
    _button.backgroundColor = [UIColor blueColor];
    [_button setTitle:@"测试" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onTapButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    // 常规字符串
    _nSelect1View = [[M2SimpleNSelect1View alloc] initWithFrame:CGRectMake(10, 50, 300, 60)
                                                         titles:@[@"℃", @"℉"]
                                                    normalColor:[UIColor whiteColor]
                                                     normalFont:[UIFont systemFontOfSize:10]
                                                  selectedColor:[UIColor blueColor]
                                                   selectedFont:[UIFont systemFontOfSize:20]];
    _nSelect1View.backgroundColor = [UIColor grayColor];
    _nSelect1View.delegate = self;
    [self.view addSubview:_nSelect1View];
    
    // AttibutedString
    NSMutableAttributedString *title0 = [[NSMutableAttributedString alloc] initWithString:@"24h"];
    [title0 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, [title0 length])];
    [title0 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(2, 1)];
    NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc] initWithString:@"12h"];
    [title1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, [title0 length])];
    [title1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(2, 1)];
    _attributedNSelect1View = [[M2SimpleNSelect1View alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_nSelect1View.frame) + 10, 300, 60)attributedTitles:@[title0, title1]
                                                              normalColor:[UIColor whiteColor]
                                                            selectedColor:[UIColor blueColor]];
    _attributedNSelect1View.backgroundColor = [UIColor grayColor];
    _attributedNSelect1View.underlineViewAnimationDisabled = YES;
    _attributedNSelect1View.delegate = self;
    [self.view addSubview:_attributedNSelect1View];
    
    // vertival layout
    _vertivalNSelect1View = [[M2SimpleNSelect1View alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_attributedNSelect1View.frame) + 10, 320 - 50 * 2, 200)
                                                                 titles:@[@"蓝", @"红", @"橘", @"绿", @"粉"]
                                                            normalColor:[UIColor whiteColor]
                                                             normalFont:[UIFont systemFontOfSize:15]
                                                          selectedColor:[UIColor blueColor]
                                                           selectedFont:[UIFont systemFontOfSize:25]];
    _vertivalNSelect1View.isVerticalLayout = YES;
    _vertivalNSelect1View.backgroundColor = [UIColor grayColor];
    _vertivalNSelect1View.delegate = self;
    [self.view addSubview:_vertivalNSelect1View];
}

#pragma mark - event
- (void)onTapButton{
    [_nSelect1View selectIndex:1];
    [_attributedNSelect1View selectIndex:1];
    [_vertivalNSelect1View selectIndex:1];
}

#pragma mark - M2SimpleNSelect1ViewDelegate
- (void)nSelect1View:(UITableView *)M2SimpleNSelect1View didSelectIndex:(NSInteger)index{
    NSLog(@"selectedIndex(%d)  %s", index, __func__);
}


@end
