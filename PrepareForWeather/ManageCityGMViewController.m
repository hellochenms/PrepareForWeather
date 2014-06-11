//
//  ManageCityGMViewController.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "ManageCityGMViewController.h"
#import "GMGridView.h"
#import "CityGMCell.h"

@interface ManageCityGMViewController ()<GMGridViewDataSource, GMGridViewActionDelegate, GMGridViewSortingDelegate>
@property (nonatomic) NSMutableArray    *datas;
@property (nonatomic) GMGridView        *gridView;
@property (nonatomic) UIButton          *editButton;
@end

@implementation ManageCityGMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _datas = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            [_datas addObject:[NSString stringWithFormat:@"%d", i]];
        }
        [_datas addObject:@"Add"];
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
    
    _gridView = [[GMGridView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    _gridView.backgroundColor = [UIColor grayColor];
    _gridView.minEdgeInsets = UIEdgeInsetsZero;
    _gridView.enableEditOnLongPress = YES;
    _gridView.disableEditOnEmptySpaceTap = YES;
    _gridView.dataSource = self;
    _gridView.actionDelegate = self;
    _gridView.sortingDelegate = self;
    [self.view addSubview:_gridView];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editButton.frame = CGRectMake(60, CGRectGetMaxY(_gridView.frame) + 10, 200, 60);
    _editButton.backgroundColor = [UIColor redColor];
    [_editButton addTarget:self action:@selector(onEditButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editButton];
}

- (void)onEditButton{
    [_gridView setEditing:!_gridView.editing animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView{
    return [_datas count];
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation{
    return CGSizeMake(90, 90);
}
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    static NSString *cellIdentifier = @"cell";
    CityGMCell *cell = (CityGMCell *)[gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [CityGMCell new];
        cell.reuseIdentifier = cellIdentifier;
    }
    [cell reloadData:[_datas objectAtIndex:index]];
    return cell;
}
- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index{
    if (index == [_datas count] - 1) {
        return NO;
    }
    return YES;
}

#pragma mark - GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{}
- (void)GMGridView:(GMGridView *)gridView changedEdit:(BOOL)edit{
//    NSLog(@"  @@%s", __func__);
}
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index{
    NSLog(@"index(%d)  @@%s", index, __func__);
}
#pragma mark - GMGridViewSortingDelegate
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell{
    NSLog(@"  @@%s", __func__);
}
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex{
    NSLog(@"  @@%s", __func__);
}
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2{
    NSLog(@"exchange(%d, %d)  @@%s", index1, index2, __func__);
    [_gridView swapObjectAtIndex:index1 withObjectAtIndex:index2 animated:YES];
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
