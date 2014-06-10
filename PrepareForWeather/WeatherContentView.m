//
//  WeatherContentView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-10.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "WeatherContentView.h"
#import "WeatherBasicView.h"
#import "WeatherExtraView.h"

@interface WeatherContentView()<UIScrollViewDelegate>
@property (nonatomic) UIScrollView      *scrollView;
@property (nonatomic) WeatherBasicView  *basicView;
@property (nonatomic) WeatherExtraView  *extraView;
@end

@implementation WeatherContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        
        float itemWidth = CGRectGetWidth(_scrollView.bounds);
        float itemHeight = CGRectGetHeight(_scrollView.bounds);
        _basicView = [[WeatherBasicView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
        [_scrollView addSubview:_basicView];
        _extraView = [[WeatherExtraView alloc] initWithFrame:CGRectMake(0, itemHeight, itemWidth, itemHeight)];
        [_scrollView addSubview:_extraView];
        _scrollView.contentSize = CGSizeMake(itemWidth, itemHeight * 2);
        
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)changeSelectedIndex:(NSInteger)selectedIndex{
    float offsetY = CGRectGetHeight(_scrollView.bounds) * selectedIndex;
    [_scrollView setContentOffset:CGPointMake(0, offsetY)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        return;
    }
    [self didChangeSelectedIndexOfScrollView:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self didChangeSelectedIndexOfScrollView:scrollView];
}

- (void)didChangeSelectedIndexOfScrollView:(UIScrollView *)scrollView{
    NSInteger selectedIndex = scrollView.contentOffset.y / CGRectGetHeight(_scrollView.bounds);
    if (_didChangeSelectedIndexHandler) {
        _didChangeSelectedIndexHandler(selectedIndex, self);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
