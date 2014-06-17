//
//  ManageCityComponentViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-12.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "ManageCityComponentViewController.h"
#import "M2SimpleGridView.h"
#import "CityItemCell.h"
#import "SelectCityViewController.h"

@interface ManageCityComponentViewController ()<M2SimpleGridViewDataSource, M2SimpleGridViewDelegate>
@property (nonatomic) NSMutableArray    *datas;
@property (nonatomic) M2SimpleGridView  *cityGridView;
@property (nonatomic) UIButton          *editButton;
@end

@implementation ManageCityComponentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _datas = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            [_datas addObject:[NSString stringWithFormat:@"%d", i]];
        }
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
    _cityGridView = [[M2SimpleGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _cityGridView.backgroundColor = [UIColor grayColor];
    _cityGridView.dataSource = self;
    _cityGridView.delegate = self;
    [self.view addSubview:_cityGridView];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editButton.frame = CGRectMake(60, CGRectGetMaxY(_cityGridView.frame) + 10, 200, 60);
    _editButton.backgroundColor = [UIColor redColor];
    [_editButton setTitle:@"edit" forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(onTapEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editButton];
}

#pragma mark - M2SimpleGridViewDataSource
- (UIEdgeInsets)paddingInsetsForGridView:(M2SimpleGridView *)gridView{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (NSInteger)numberOfCellsInGridView:(M2SimpleGridView *)gridView{
    return [_datas count];
}
- (UIView *)gridView:(M2SimpleGridView *)gridView cellAtIndex:(NSInteger)index{
    CityItemCell *cell = [CityItemCell new];
    [cell reloadData:[_datas objectAtIndex:index]];
    
    return cell;
}
- (CGSize)sizeOfCellForGridView:(M2SimpleGridView *)gridView{
    return CGSizeMake(70, 70);
}
- (NSInteger)cellCountInRowForGridView:(M2SimpleGridView *)gridView{
    return 3;
}
- (NSInteger)rowCountForGridView:(M2SimpleGridView *)gridView{
    return 3;
}
- (UIView *)addCellForGridView:(M2SimpleGridView *)gridView{
    UILabel *label = [UILabel new];
    label.textColor = [UIColor redColor];
    label.text = @"Add";
    return label;
}
- (CGSize)sizeOfDeleteCellForGridView:(M2SimpleGridView *)gridView{
    return CGSizeMake(20, 20);
}
- (UIImage *)imageOfDeleteCellForGridView:(M2SimpleGridView *)gridView{
    return [UIImage imageNamed:@"m2_57"];
}

#pragma mark - M2SimpleGridViewDelegate
- (void)wantsAddNewCellByGridView:(M2SimpleGridView *)gridView{
    SelectCityViewController *subViewController = [SelectCityViewController new];
    __weak typeof(self) weakSelf = self;
    subViewController.tapFinishHandler = ^{
        [weakSelf.datas addObject:[NSString stringWithFormat:@"new%.0f", [[NSDate date] timeIntervalSince1970]]];
        [weakSelf.cityGridView reloadData];
        NSLog(@"_data(%@)  @@%s", weakSelf.datas, __func__);
    };
    [self.navigationController pushViewController:subViewController animated:YES];
}
- (void)gridView:(M2SimpleGridView *)gridView wantsDeleteCellAtIndex:(NSInteger)index{
    [_datas removeObjectAtIndex:index];
    NSLog(@"_data(%@)  @@%s", _datas, __func__);
}
- (void)gridView:(M2SimpleGridView *)gridView wantsMoveCellFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    NSString *curTouchData = [_datas objectAtIndex:fromIndex];
    [_datas removeObject:curTouchData];
    [_datas insertObject:curTouchData atIndex:toIndex];
    NSLog(@"_data(%@)  @@%s", _datas, __func__);
}
- (void)onTapEdit{
    [_cityGridView changeEditing:!_cityGridView.isEditing];
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
