//
//  M2NSelect1View.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-7-22.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "M2SimpleNSelect1View.h"

static const NSInteger kM2SNS1V_CellTagOffset = 6000;
static const double kM2SNS1V_UnderlineViewHeight = 1;
static const double kM2SNS1V_UnderlineViewAnimationTimeInterval = 0.15;

@interface M2SimpleNSelect1View()
@property (nonatomic) UIColor           *normalColor;
@property (nonatomic) UIFont            *normalFont;
@property (nonatomic) UIColor           *selectedColor;
@property (nonatomic) UIFont            *selectedFont;
@property (nonatomic) NSMutableArray    *cells;
@property (nonatomic) UIView            *underlineView;
@property (nonatomic) NSInteger         selectedIndex;
@property (nonatomic) BOOL              isTitleAttributedString;
@end

@implementation M2SimpleNSelect1View

- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
        normalColor:(UIColor *)normalColor
         normalFont:(UIFont *)normalFont
      selectedColor:(UIColor *)selectedColor
       selectedFont:(UIFont *)selectedFont{
    return [self initWithFrame:frame
                        titles:titles
       isTitleAttributedString:NO
                   normalColor:normalColor
                    normalFont:normalFont
                 selectedColor:selectedColor
                  selectedFont:selectedFont];
}

- (id)initWithFrame:(CGRect)frame
   attributedTitles:(NSArray *)attributedTitles
        normalColor:(UIColor *)normalColor
      selectedColor:(UIColor *)selectedColor{
    return [self initWithFrame:frame
                        titles:attributedTitles
       isTitleAttributedString:YES
                   normalColor:normalColor
                    normalFont:nil
                 selectedColor:selectedColor
                  selectedFont:nil];
}

- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
isTitleAttributedString:(BOOL)isTitleAttributedString
        normalColor:(UIColor *)normalColor
         normalFont:(UIFont *)normalFont
      selectedColor:(UIColor *)selectedColor
       selectedFont:(UIFont *)selectedFont {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSInteger count = [titles count];
        if (count <= 0) {
            return self;
        }
        _normalColor = normalColor;
        _normalFont = normalFont;
        _selectedColor = selectedColor;
        _selectedFont = selectedFont;
        _isTitleAttributedString = isTitleAttributedString;
        
        _cells = [NSMutableArray array];
        UIButton *cell = nil;
        double cellWidth = ceil(CGRectGetWidth(self.bounds) / count);
        double cellHeight = CGRectGetHeight(self.bounds);
        for (NSInteger i = 0; i < count; i++) {
            cell = [UIButton buttonWithType:UIButtonTypeCustom];
            cell.tag = i + kM2SNS1V_CellTagOffset;
            cell.frame = CGRectMake(cellWidth * i, 0, cellWidth, cellHeight);
            if (_isTitleAttributedString) {
                NSMutableAttributedString *title = [[titles objectAtIndex:i] mutableCopy];
                [title addAttribute:NSForegroundColorAttributeName value:_normalColor range:NSMakeRange(0, [title length])];
                [cell setAttributedTitle:title forState:UIControlStateNormal];
            } else {
                [cell setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
                [cell setTitleColor:_normalColor forState:UIControlStateNormal];
                cell.titleLabel.font = _normalFont;
            }
            
            [cell addTarget:self action:@selector(onTapCell:) forControlEvents:UIControlEventTouchUpInside];
            [_cells addObject:cell];
            [self addSubview:cell];
        }
        
        // 默认选中第一个
        cell = [_cells objectAtIndex:0];
        if (_isTitleAttributedString) {
            NSMutableAttributedString *title = [[cell attributedTitleForState:UIControlStateNormal] mutableCopy];
            [title addAttribute:NSForegroundColorAttributeName value:_selectedColor range:NSMakeRange(0, [title length])];
            [cell setAttributedTitle:title forState:UIControlStateNormal];
        } else {
            [cell setTitleColor:_selectedColor forState:UIControlStateNormal];
            cell.titleLabel.font = _selectedFont;
        }
        _underlineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - kM2SNS1V_UnderlineViewHeight, cellWidth, kM2SNS1V_UnderlineViewHeight)];
        _underlineView.backgroundColor = _selectedColor;
        [self addSubview:_underlineView];
        _selectedIndex = 0;
    }
 
    return self;
}

#pragma mark - event
- (void)onTapCell:(UIButton *)sender{
    self.selectedIndex = sender.tag - kM2SNS1V_CellTagOffset;
    [self selectIndex:self.selectedIndex animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(nSelect1View:didSelectIndex:)]) {
        [self.delegate nSelect1View:self didSelectIndex:self.selectedIndex];
    }
}

#pragma mark - public
- (void)selectIndex:(NSInteger)index{
    [self selectIndex:index animated:NO];
}

#pragma mark - tools
- (void)selectIndex:(NSInteger)index animated:(BOOL)animated{
    if ([self.cells count] <= 0) {
        return;
    }
    
    UIButton *cell = nil;
    UIColor *color = nil;
    UIFont *font = nil;
    for (cell in self.cells) {
        if (cell.tag - kM2SNS1V_CellTagOffset == index) {
            color = self.selectedColor;
            font = self.selectedFont;
        } else {
            color = self.normalColor;
            font = self.normalFont;
        }
        if (self.isTitleAttributedString) {
            NSMutableAttributedString *title = [[cell attributedTitleForState:UIControlStateNormal] mutableCopy];
            [title addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [title length])];
            [cell setAttributedTitle:title forState:UIControlStateNormal];
        } else {
            [cell setTitleColor:color forState:UIControlStateNormal];
            cell.titleLabel.font = font;
        }
    }
    cell = [self.cells objectAtIndex:0];
    double itemWidth = CGRectGetWidth(cell.bounds);
    CGPoint underlineViewCenter = self.underlineView.center;
    underlineViewCenter.x = itemWidth * (0.5 + index);
    if (!self.underlineViewAnimationDisabled && animated) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:kM2SNS1V_UnderlineViewAnimationTimeInterval
                         animations:^{
                             weakSelf.underlineView.center = underlineViewCenter;
                         }];
    } else {
        self.underlineView.center = underlineViewCenter;
    }
}

@end
