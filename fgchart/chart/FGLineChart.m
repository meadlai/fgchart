//
//  FGLineChart.m
//  FGChart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import "FGLineChart.h"

@interface FGLineChart (){
    NSMutableArray* _dataX;
    NSMutableArray* _dataY;
    NSMutableDictionary* _data;
    CGFloat _minY;
    CGFloat _maxY;
    CGFloat _minX;
    CGFloat _maxX;
    //
    CGFloat width;
    CGFloat height;
    CGFloat scale;
}
//初始化默认参数
- (void)loadParameters;
//画网格
- (void)renderGrid;
//画图
- (void)renderChart;
//画贝塞尔曲线
- (UIBezierPath*)renderBezierLine:(float)scale withSmoothing:(BOOL)smoothed close:(BOOL)closed;

@end

@implementation FGLineChart

#pragma mark lifecycle
- (void) dealloc{
    #if __has_feature(objc_arc)
        //
    #else
        [super dealloc];
    #endif
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        if (_colorBackground) {
            self.backgroundColor = _colorBackground;
        }else{
            self.backgroundColor = [UIColor whiteColor];
        }
        [self loadParameters];
    }
    return self;
}


- (void)loadParameters{
    
    _margin = 5.0f;
    //
    _colorLine = [FGChart ColorLightBlue];
    _colorFill = [[FGChart ColorLightBlue] colorWithAlphaComponent:.25];
    //
    _animation = YES;
    _animationDuration = 1.3f;
    _bezierSmoothing = NO;
    _bezierSmoothingTension = 2.0f;
    //
    _touchInteraction = NO;
    //
    _stepHorizontal = 3;
    _stepVertical = 3;
    _axisLineWidth = 1;
    _axisColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _axisWidth = self.frame.size.width - 2 * _margin;
    _axisHeight = self.frame.size.height - 2 * _margin;
    //
    _gridInside = YES;
    _gridInsideColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _gridInsideWidth = 0.5;

}

#pragma mark 调用方法
- (void)setDataList:(NSArray *)data{
    width = self.frame.size.width;
    height = self.frame.size.height;
    _axisWidth = width - 2 * _margin;
    _axisHeight = height - 2 * _margin;
    
    _dataX = [NSMutableArray arrayWithArray:data];
    _dataY = [NSMutableArray array];
    //
    [self computeSteps];
    //
    [self renderChart];
    
}

- (void)setDataMap:(NSDictionary *)data{
    width = self.frame.size.width;
    height = self.frame.size.height;
    _data = [NSMutableDictionary dictionaryWithDictionary:data];
    _dataX = [NSMutableArray array];
    _dataY = [NSMutableArray array];
    
    //
    [self computeSteps];
    //
    [self renderChart];
}

- (void)reload:(CGFloat)animationDuration{
    
}

#pragma mark
#pragma mark 画图
- (void)renderChart{
    
}

- (void)drawRect:(CGRect)rect{
    [self renderGrid];
}

- (void)renderGrid{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, _axisLineWidth);
    CGContextSetStrokeColorWithColor(ctx, [_axisColor CGColor]);
    
    // y轴
    CGContextMoveToPoint(ctx, _margin, _margin);
    CGContextAddLineToPoint(ctx, _margin, _axisHeight + _margin);
    CGContextStrokePath(ctx);
    // x轴
    CGContextMoveToPoint(ctx, _margin, _axisHeight + _margin);
    CGContextAddLineToPoint(ctx, _axisWidth + _margin , _axisHeight + _margin);
    CGContextStrokePath(ctx);
    NSLog(@"x轴.x = %f,  x轴.y = %f",_axisWidth + _margin ,_axisHeight + _margin);

    
    if (_gridInside) {
        CGFloat avg = _axisWidth / _stepHorizontal;
        if (_debug) {
            NSLog(@"_axisWidth = %f",_axisWidth);
            NSLog(@"_stepHorizontal = %d",_stepHorizontal);
            NSLog(@"avg = %f",avg);
        }

        //画y轴平行的innner线
        for (int i = 0; i < _stepHorizontal; i++) {
            CGContextSetStrokeColorWithColor(ctx, [_gridInsideColor CGColor]);
            CGContextSetLineWidth(ctx, _gridInsideWidth);
            //
            CGPoint point = CGPointMake( avg * (i+1) + _margin, _margin);
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, _axisHeight + _margin);
            CGContextStrokePath(ctx);
        }
        
        //画x轴平行的innner线
        avg = _axisHeight / _stepVertical;
        for (int i = 0; i < _stepVertical; i++) {
            CGContextSetStrokeColorWithColor(ctx, [_gridInsideColor CGColor]);
            CGContextSetLineWidth(ctx, _gridInsideWidth);
            //
            CGPoint point = CGPointMake(  _margin, avg * (i) + _margin);
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, _axisWidth + _margin, point.y);
            CGContextStrokePath(ctx);
        }

    }

}



- (UIBezierPath*)renderBezierLine:(float)scale withSmoothing:(BOOL)smoothed close:(BOOL)closed{
    return nil;
}

#pragma mark
#pragma mark 计算方法
//计算边距
- (void) computeSteps{
    _minY = MAXFLOAT;
    _maxY = -MAXFLOAT;
    
    _minX = MAXFLOAT;
    _maxX = -MAXFLOAT;
    
    //取字典值
    if (_data && _data.count>0) {
        for (id key in _data) {
            NSNumber *val = [_data objectForKey:key];
            [_dataX addObject:key];
            [_dataY addObject:val];
            if ([val floatValue] < _minY) {
                _minY = [val floatValue];
            }
            if ([val floatValue] > _maxY) {
                _maxY = [val floatValue];
            }
            if ([key floatValue] < _minX) {
                _minX = [key floatValue];
            }
            if ([key floatValue] > _maxX) {
                _maxX = [key floatValue];
            }
        }
    }else if(_dataX){
        for (id key in _dataX) {
            if ([key floatValue] < _minY) {
                _minY = [key floatValue];
            }
            if ([key floatValue] > _maxY) {
                _maxY = [key floatValue];
            }
        }

    }else{
        @throw [NSException
                exceptionWithName:@"无法初始化"
                reason:@"没有数据"
                userInfo:nil];
    }
    
    if (_debug) {
        NSLog(@"_minY = %f,_maxY = %f",_minY,_maxY);
        //NSLog(@"_minX = %f,_minX = %f",_minX,_maxX);
    }
    
    NSDictionary *vertResult = [self roundStep:_stepVertical max:_maxY min:_minY];
    _maxY = [[vertResult objectForKey:@"max"] floatValue];
    _minY = [[vertResult objectForKey:@"min"] floatValue];

    NSDictionary *horiResult = [self roundStep:_stepHorizontal max:_maxX min:_minX];
    _maxX = [[horiResult objectForKey:@"max"] floatValue];
    _minX = [[horiResult objectForKey:@"min"] floatValue];

}

//调整max & min.
- (NSDictionary*) roundStep:(int)step max:(CGFloat)max min:(CGFloat)min{
    NSMutableDictionary *result = [NSMutableDictionary
                                   dictionaryWithObjects:
  @[[NSNumber numberWithFloat:0.0f]
    ,[NSNumber numberWithFloat:0.0f]]
                                   forKeys:
  @[@"max"
    ,@"mix"]
                                   ];
   
    CGFloat delta = max - min;
    if (delta < 1) {
        [result setValue:[NSNumber numberWithFloat:1.0f] forKey:@"max"];
        [result setValue:[NSNumber numberWithFloat:0.0f] forKey:@"min"];
    }
    
    CGFloat logValue = log10f(delta);
    CGFloat iscale = powf(10, floorf(logValue));
    CGFloat temp = max / iscale;
    max = ceilf(temp) * iscale;
    //TODO:没有考虑max为负数的情况.
    //TODO:小数点0.212,需要考虑.
    [result setValue:[NSNumber numberWithFloat:max] forKey:@"max"];
    
    if (min < 0 ) {
        //负数情况
        temp = fabs(min / iscale);
        min = ceilf(temp) * iscale;
        [result setValue:[NSNumber numberWithFloat:min] forKey:@"min"];
    }else{
        min = 0.0f;
        [result setValue:[NSNumber numberWithFloat:0.0f] forKey:@"min"];
    }

    scale = max/_stepVertical;
    if (_debug) {
        NSLog(@"logValue = %f", logValue);
        NSLog(@"iscale = %f", iscale);
        NSLog(@"max = %f", max);
        NSLog(@"min = %f", min);
        NSLog(@"scale = %f", scale);
    }
    
    
    return result;
}


@end
