//
//  TrendsThinkView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-26.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "TrendsThinkView.h"

@implementation TrendsThinkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawBackgroundLayerInContext:ctx];
    [self drawContentLayerInContext:ctx];
}

- (void)drawBackgroundLayerInContext:(CGContextRef)ctx{
    NSLog(@"  %s", __func__);
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, self.bounds);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
}

- (void)drawContentLayerInContext:(CGContextRef)ctx{
    NSLog(@"  %s", __func__);
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
