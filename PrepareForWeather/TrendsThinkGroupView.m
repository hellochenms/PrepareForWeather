//
//  TrendsThinkGroupView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-26.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//
//  这种多view的实现方式，可以只用UIKit中的绘图API，而不是纯CG+CoreText代码；

#import "TrendsThinkGroupView.h"

@interface TrendsBackgroudView : UIView
@end
@implementation TrendsBackgroudView
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, self.bounds);
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
}
@end

@interface TrendsContentView : UIView
@end
@implementation TrendsContentView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    
    return self;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    // 线
    CGContextMoveToPoint(ctx, 10, 10);
    CGContextAddLineToPoint(ctx, 150, 100);
    CGContextAddLineToPoint(ctx, 290, 10);
    CGContextSetLineWidth(ctx, 4);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokePath(ctx);
    
    float bigRadius = 8;
    float smallRadius = 4;
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGContextAddEllipseInRect(ctx, CGRectMake(150 - bigRadius, 100 - bigRadius, bigRadius * 2, bigRadius * 2));
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextFillPath(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(150 - smallRadius, 100 - smallRadius, smallRadius * 2, smallRadius * 2));
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
    CGContextFillPath(ctx);
    
    CGContextRestoreGState(ctx);
}
@end


@interface TrendsThinkGroupView()
@property (nonatomic) TrendsBackgroudView   *backgroudView;
@property (nonatomic) TrendsContentView     *contentView;
@end

@implementation TrendsThinkGroupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroudView = [[TrendsBackgroudView alloc] initWithFrame:self.bounds];
        [self addSubview:_backgroudView];
        _contentView = [[TrendsContentView alloc]initWithFrame:self.bounds];
        [self addSubview:_contentView];
    }
    return self;
}

@end
