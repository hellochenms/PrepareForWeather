//
//  WeatherView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-6.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "WeatherView.h"
#import "WeatherContentView.h"
#import "CityManager.h"

#define WVItemMaxCount 3

@interface WeatherView()<UIScrollViewDelegate>
@property (nonatomic) UIButton *cityManageButton;
@property (nonatomic) UIButton *mapButton;
@property (nonatomic) UIButton *settingButton;
@property (nonatomic) NSMutableArray *items;

// view
@property (nonatomic) UIScrollView      *scrollView;
@property (nonatomic) NSInteger         itemCount;
@property (nonatomic) NSInteger         curItemIndex;
// data
@property (nonatomic) NSMutableArray    *datas;
@property (nonatomic) NSInteger         curDataIndex;
//
@property (nonatomic) BOOL isCodeMakeScroll;
@end

@implementation WeatherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        
        // datas
        _datas = [CityManager defaultCityManager].cities;
        _itemCount = MIN([_datas count], WVItemMaxCount);
        _curDataIndex = [CityManager defaultCityManager].defalutCityIndex;
        
        // temp //TODO:!
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        float itemWidth = CGRectGetWidth(_scrollView.bounds);
        float itemHeight = CGRectGetHeight(_scrollView.bounds);
        _items = [NSMutableArray array];
        WeatherContentView *contentView = nil;
        __weak typeof(self) weakSelf = self;
        for (int i = 0; i < _itemCount; i++) {
            contentView = [[WeatherContentView alloc] initWithFrame:CGRectMake(itemWidth * i, 0, itemWidth, itemHeight)];
            [_scrollView addSubview:contentView];
            [_items addObject:contentView];
            contentView.didChangeSelectedIndexHandler = ^(NSInteger selectedIndex, WeatherContentView *srcItem){
                WeatherContentView *item = nil;
                for (item in weakSelf.items) {
                    if (item != srcItem) {
                        [item changeSelectedIndex:selectedIndex];
                    }
                }
            };
            contentView.tapMapHandler = self.tapMapHandler;
            contentView.tapCityManageHandler = self.tapCityManageHandler;
            contentView.tapSettingHandler = self.tapSettingHandler;
        }
        _scrollView.contentSize = CGSizeMake(itemWidth * _itemCount, itemHeight);
        _curItemIndex = 0;
    }
    return self;
}

- (void)setTapMapHandler:(TapHandler)tapMapHandler{
    WeatherContentView *item = nil;
    for (item in _items) {
        item.tapMapHandler = tapMapHandler;
    }
}
- (void)setTapCityManageHandler:(TapHandler)tapCityManageHandler{
    WeatherContentView *item = nil;
    for (item in _items) {
        item.tapCityManageHandler = tapCityManageHandler;
    }
}
- (void)setTapSettingHandler:(TapHandler)tapSettingHandler{
    WeatherContentView *item = nil;
    for (item in _items) {
        item.tapSettingHandler = tapSettingHandler;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_itemCount < WVItemMaxCount) {//TODO:<=3kCCVItemMaxCount?
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
//                firstItem.text = [_datas objectAtIndex:_curDataIndex + 1];//TODO:!
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
//                lastItem.text = [_datas objectAtIndex:_curDataIndex - 1];
                [_items removeObject:lastItem];
                [_items insertObject:lastItem atIndex:0];
                _isCodeMakeScroll = YES;
                [_scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + itemWidth, 0)];
            }
        }
    }
}

@end
