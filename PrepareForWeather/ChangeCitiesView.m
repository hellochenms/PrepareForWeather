//
//  ChangeCitiesView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "ChangeCitiesView.h"
#import "CityManager.h"

NSInteger const kCCVItemMaxCount = 3;

@interface ChangeCitiesView()<UIScrollViewDelegate>
// view
@property (nonatomic) UIScrollView      *scrollView;
@property (nonatomic) NSMutableArray    *items;
@property (nonatomic) NSInteger         itemCount;
@property (nonatomic) NSInteger         curItemIndex;
// data
@property (nonatomic) NSMutableArray    *datas;
@property (nonatomic) NSInteger         curDataIndex;
// 
@property (nonatomic) BOOL isCodeMakeScroll;
// temp
@property (nonatomic) NSArray *colors;
@property (nonatomic) UILabel *tipsLabel;
@end

@implementation ChangeCitiesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        
        // datas
        _datas = [CityManager defaultCityManager].cities;
        _itemCount = MIN([_datas count], kCCVItemMaxCount);
        _curDataIndex = [CityManager defaultCityManager].defalutCityIndex;
        
        // temp
        _colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]];
        
        // views
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.bounds) - 20 * 2, 100)];
        _scrollView.backgroundColor = [UIColor grayColor];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        UILabel *item = nil;
        float width = CGRectGetWidth(_scrollView.bounds);
        float height = CGRectGetHeight(_scrollView.bounds);
        _items = [NSMutableArray array];
        for (int i = 0; i < _itemCount; i++) {
            item = [[UILabel alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
            item.text = [_datas objectAtIndex:i];
            item.backgroundColor = [_colors objectAtIndex:i];
            [_scrollView addSubview:item];
            [_items addObject:item];
        }
        _scrollView.contentSize = CGSizeMake(width * _itemCount, height);
        _curItemIndex = 0;
        
        UIButton *changeCitiesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        changeCitiesButton.frame = CGRectMake(20, CGRectGetMaxY(_scrollView.frame) + 20, CGRectGetWidth(self.bounds) - 20 * 2, 60);
        changeCitiesButton.backgroundColor = [UIColor blueColor];
        [changeCitiesButton setTitle:@"改变城市列表及默认城市" forState:UIControlStateNormal];
        [changeCitiesButton addTarget:self action:@selector(onTapChangeCities:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changeCitiesButton];
        
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(changeCitiesButton.frame) + 20, CGRectGetWidth(self.bounds) - 20 * 2, 100)];
        _tipsLabel.backgroundColor = [UIColor blueColor];
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:_tipsLabel];
        
        // notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidUpdateCities:) name:kCMCitiesDidUpdate object:nil];
    }
    
    return self;
}

- (void)onTapChangeCities:(id *)sender{
    int count = arc4random() % 7;
    int defaultDataIndex = (count == 0 ? 0 : arc4random() % count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [[CityManager defaultCityManager].cities removeAllObjects];
    [[CityManager defaultCityManager].cities addObjectsFromArray:array];
    [CityManager defaultCityManager].defalutCityIndex = defaultDataIndex;
    NSLog(@"数据刷新为（%d）个，defaultDataIndex（%d） @@%s", count, defaultDataIndex, __func__);
    [[CityManager defaultCityManager] didUpdateCities];
}

- (void)onDidUpdateCities:(NSNotification *)notification{
    NSLog(@"cities_count(%d) defaultIndex(%d)  @@%s", [[CityManager defaultCityManager].cities count], [CityManager defaultCityManager].defalutCityIndex, __func__);
    _tipsLabel.text = [NSString stringWithFormat:@"城市数量（%d）\n默认城市index（%d）", [[CityManager defaultCityManager].cities count], [CityManager defaultCityManager].defalutCityIndex];
    _datas = [CityManager defaultCityManager].cities;
    [self refreshUIWithDatas:_datas defaultDataIndex:[CityManager defaultCityManager].defalutCityIndex];
}

- (void)refreshUIWithDatas:(NSMutableArray *)datas defaultDataIndex:(int)defaultDataIndex{
    int curItemCount = MIN([_datas count], 3);
    int delta = curItemCount - _itemCount;
    float width = CGRectGetWidth(_scrollView.bounds);
    float height = CGRectGetHeight(_scrollView.bounds);
    if (delta == 0) {
        // nop;
    }else if (delta > 0){
        // 需要增加item
        UILabel *view = nil;
        for (int i = _itemCount; i < curItemCount; i++) {
            view = [[UILabel alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
            view.text = [_datas objectAtIndex:i];
            view.backgroundColor = [_colors objectAtIndex:i];
            [_scrollView addSubview:view];
            [_items addObject:view];
        }
    }else if (delta < 0){
        // 需要删除item
        UILabel *view = nil;
        for (int i = _itemCount - 1; i >= curItemCount; i--) {
            view = [_items objectAtIndex:i];
            [view removeFromSuperview];
            [_items removeObject:view];
        }
    }
    _itemCount = curItemCount;
    // 刷新数据
    _curDataIndex = defaultDataIndex;
    
    __weak typeof(self) weakSelf = self;
    if (_curDataIndex == 0) {
        [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UILabel *)obj).text = [weakSelf.datas objectAtIndex:idx];
        }];
        _curItemIndex = 0;
        _isCodeMakeScroll = YES;
        [_scrollView setContentOffset:CGPointZero];
    }else if (_curDataIndex == [_datas count] - 1){
        int delta = [_datas count] - _itemCount;
        [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UILabel *)obj).text = [weakSelf.datas objectAtIndex:idx + delta];
        }];
        _curItemIndex = _itemCount - 1;
        _isCodeMakeScroll = YES;
        [_scrollView setContentOffset:CGPointMake(width * _curItemIndex, 0)];
    }else {
        [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UILabel *)obj).text = [weakSelf.datas objectAtIndex:_curDataIndex - 1 + idx];
        }];
        _curItemIndex = 1;
        _isCodeMakeScroll = YES;
        [_scrollView setContentOffset:CGPointMake(width, 0)];
    }
    _scrollView.contentSize = CGSizeMake(width * _itemCount, CGRectGetHeight(_scrollView.bounds));
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_itemCount <= 2) {
        return;
    }
    if (_isCodeMakeScroll) {
        _isCodeMakeScroll = NO;
        return;
    }
    float itemWidth = CGRectGetWidth(scrollView.bounds);
    int nextItemIndex = (scrollView.contentOffset.x + itemWidth / 2) / itemWidth;
    if (nextItemIndex != _curItemIndex) {
        NSLog(@"itemIndex change(%d->%d)  @@%s", _curItemIndex, nextItemIndex, __func__);
        if (nextItemIndex > _curItemIndex) {
            _curDataIndex++;
        }else if (nextItemIndex < _curItemIndex){
            _curDataIndex--;
        }
        
        NSLog(@"scrollView.contentOffset.x(%f)  @@%s", scrollView.contentOffset.x, __func__);
        // 在中间
        if (nextItemIndex == 1) {
//        if (scrollView.contentOffset.x >= itemWidth / 2 && scrollView.contentOffset.x <= itemWidth * 3 / 2) {
            NSLog(@"在中间，不需要调整  @@%s", __func__);
            _curItemIndex = nextItemIndex;
        }
        // 在右边
        else if (nextItemIndex == 2){
//        else if (scrollView.contentOffset.x > itemWidth * 3 / 2){
            if (_curDataIndex + 1 > [_datas count] - 1) {
                NSLog(@"到达数据右边界， 不需要调整  @@%s", __func__);
                _curItemIndex = nextItemIndex;
            }else{
                CGRect lastItemFrame = ((UIView *)[_items lastObject]).frame;
                int count = [_items count];
                for (int i = count - 1; i > 0; i--) {
                    ((UIView *)[_items objectAtIndex:i]).frame = ((UIView *)[_items objectAtIndex:i - 1]).frame;
                }
                UILabel *firstItem = [_items firstObject];
                firstItem.frame = lastItemFrame;
                firstItem.text = [_datas objectAtIndex:_curDataIndex + 1];
                [_items removeObject:firstItem];
                [_items addObject:firstItem];
                _isCodeMakeScroll = YES;
                [_scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - itemWidth, 0)];
            }
        }
        // 在左边
        else if (nextItemIndex == 0){
//        else if (scrollView.contentOffset.x < itemWidth / 2){
            if (_curDataIndex - 1 < 0) {
                NSLog(@"到达数据左边界， 不需要调整  @@%s", __func__);
                _curItemIndex = nextItemIndex;
            }else{
                CGRect firstItemFrame = ((UIView *)[_items firstObject]).frame;
                int count = [_items count];
                for (int i = 0; i < count - 1; i++) {
                    ((UIView *)[_items objectAtIndex:i]).frame = ((UIView *)[_items objectAtIndex:i + 1]).frame;
                }
                UILabel *lastItem = [_items lastObject];
                lastItem.frame = firstItemFrame;
                lastItem.text = [_datas objectAtIndex:_curDataIndex - 1];
                [_items removeObject:lastItem];
                [_items insertObject:lastItem atIndex:0];
                _isCodeMakeScroll = YES;
                [_scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + itemWidth, 0)];
            }
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
