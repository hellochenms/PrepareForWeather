//
//  M2SimpleGridViewCell.m
//  PrepareForWeather
//
//  Created by Chen Meisong on 14-6-12.
//  Copyright (c) 2014年 Chen Meisong. All rights reserved.
//

#import "M2SimpleGridViewCell_A.h"

@interface M2SimpleGridViewCell_A()
@property (nonatomic) UIView    *contentView;
@property (nonatomic) UIButton  *deleteButton;
@end

@implementation M2SimpleGridViewCell_A

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _contentView = [UIView new];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor redColor];//TODO:
        [_deleteButton setTitle:@"delete" forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(onTapDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        _deleteButton.hidden = YES;
    }
    return self;
}

#pragma mark - 
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    CGSize deleteButtonSize = [self buildDeleteButtonSize];
    _deleteButton.frame = CGRectMake(0, 0, deleteButtonSize.width, deleteButtonSize.height);
}

#pragma mark - Need Override
- (CGSize)buildDeleteButtonSize{
    return CGSizeMake(20, 20);
}

#pragma mark -
- (void)showDeleteButton:(BOOL)toShow{
    _deleteButton.hidden = !toShow;
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
    shake.duration = 0.13;
    shake.autoreverses = YES;
    shake.repeatCount  = MAXFLOAT;
    shake.removedOnCompletion = NO;//TODO
    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI / 90, 0, 0, 1)];
    shake.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI / 90, 0, 0, 1)];
    if (toShow) {
        [self.layer addAnimation:shake forKey:@"shake"];
    }else{
        [self.layer removeAnimationForKey:@"shake"];
    }
}

- (void)onTapDeleteButton{
    if (_tapDeleteHandler) {
        _tapDeleteHandler(self);
    }
}


@end
