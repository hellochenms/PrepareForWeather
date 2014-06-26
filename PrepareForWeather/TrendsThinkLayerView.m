//
//  TrendsThinkView.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-26.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "TrendsThinkLayerView.h"
#import <QuartzCore/QuartzCore.h>

@class LayerDrawProxy;

typedef void (^DrawLayerHandler)(CGContextRef);

@interface LayerDrawProxy : NSObject
@property (nonatomic, copy) DrawLayerHandler drawLayerHandler;
@end

@implementation LayerDrawProxy
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    NSLog(@"context(%p)  %s", ctx, __func__);
    if (_drawLayerHandler) {
        _drawLayerHandler(ctx);
    }
}
@end

@interface TrendsThinkLayerView()
@property (nonatomic) CALayer *backgroundLayer;
@property (nonatomic) LayerDrawProxy *backgroundLayerProxy;
@property (nonatomic) CALayer *contentLayer;
@property (nonatomic) LayerDrawProxy *contentLayerProxy;

@end

@implementation TrendsThinkLayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        __weak typeof(self) weakSelf = self;
        
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.frame = self.bounds;
        _backgroundLayerProxy = [LayerDrawProxy new];
        _backgroundLayerProxy.drawLayerHandler = ^(CGContextRef ctx){
            [weakSelf drawBackgroundLayerInContext:ctx];
        };
        _backgroundLayer.delegate = _backgroundLayerProxy;
        [self.layer addSublayer:_backgroundLayer];
        [_backgroundLayer setNeedsDisplay];
        
        _contentLayer = [CALayer layer];
        _contentLayer.frame = self.bounds;
        _contentLayerProxy = [LayerDrawProxy new];
        _contentLayerProxy.drawLayerHandler = ^(CGContextRef ctx){
            [weakSelf drawContentLayerInContext:ctx];
        };
        _contentLayer.delegate = _contentLayerProxy;
        [self.layer addSublayer:_contentLayer];
        [_contentLayer setNeedsDisplay];
    }
    
    return self;
}

- (void)drawBackgroundLayerInContext:(CGContextRef)ctx{
    NSLog(@"  %s", __func__);
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, _backgroundLayer.bounds);
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
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
