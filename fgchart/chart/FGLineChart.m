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
//私有函数
//初始化默认参数
- (void)loadParameters;
//画网格
- (void)renderGrid;
//画图
- (void)renderChart;
//画贝塞尔曲线
- (UIBezierPath*)renderBezierLine:(BOOL)smoothed close:(BOOL)closed;
//画标签
- (void)renderTag;
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
    _colorFill = nil;
    //
    _animation = YES;
    _animationDuration = 1.3f;
    _bezierSmoothing = NO;
    _bezierSmoothingTension = 0.8f;
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
    
    _dataY = [NSMutableArray arrayWithArray:data];
    _dataX = [NSMutableArray array];
    //计算边距
    [self computeSteps];
    //画-线条
    [self renderChart];
    //画-标签tag
    [self renderTag];
    //重绘
    [self setNeedsDisplay];
    
}

- (void)setDataMap:(NSDictionary *)data{
    width = self.frame.size.width;
    height = self.frame.size.height;
    _data = [NSMutableDictionary dictionaryWithDictionary:data];
    _dataX = [NSMutableArray array];
    _dataY = [NSMutableArray array];
    
    //计算边距
    [self computeSteps];
    //画-线条
    [self renderChart];
    //画-标签tag
    [self renderTag];
    //重绘
    [self setNeedsDisplay];
}

- (void)reload:(CGFloat)animationDuration{
    
}

#pragma mark
#pragma mark 画图
- (void)renderChart{
    UIBezierPath *path = [UIBezierPath bezierPath];
//    UIBezierPath* fill = [UIBezierPath bezierPath];
    path = [self renderBezierLine:_bezierSmoothing close:NO];
//    fill = [self renderBezierLine:_bezierSmoothing close:YES];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    //绘线
    if(_colorFill) {
        
        
    }else{
        layer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        layer.path = path.CGPath;
        layer.fillColor = nil;
        layer.strokeColor = _colorLine.CGColor;
        [self.layer addSublayer:layer];
    }
    
    //动画效果
    if(_colorFill) {
        
    } else {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = _animationDuration;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [layer addAnimation:pathAnimation forKey:@"path"];
    }

    
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

    
    if (_gridInside) {
        CGFloat avg = _axisWidth / _stepHorizontal;
        if (_debug) {
//            NSLog(@"_axisWidth = %f",_axisWidth);
//            NSLog(@"_stepHorizontal = %d",_stepHorizontal);
//            NSLog(@"avg = %f",avg);
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

- (UIBezierPath*)renderBezierLine:(BOOL)smoothed close:(BOOL)closed{
    UIBezierPath* path = [[UIBezierPath alloc] init];
    if (smoothed) {
        //曲线图
        //光滑度控制
        CGPoint controlPoint[2];
        // 下一节点,上一节点,中间节点,当前节点
        CGPoint nextPoint, previousPoint, middlePoint, point;
        
        
        for(int i=0;i<_dataY.count - 1;i++) {
            
            point = [self getPointForIndex:i];
            if(i == 0){
                //起点
                [path moveToPoint:point];
            }
            
            //计算第一个控制点
            nextPoint = [self getPointForIndex:i + 1];
            previousPoint = [self getPointForIndex:i - 1];
            middlePoint = CGPointZero;
            if(i > 0) {
                middlePoint.x = (nextPoint.x - previousPoint.x) / 2;
                middlePoint.y = (nextPoint.y - previousPoint.y) / 2;
            }else{
                middlePoint.x = (nextPoint.x - point.x) / 2;
                middlePoint.y = (nextPoint.y - point.y) / 2;
            }
            controlPoint[0].x = point.x + middlePoint.x * _bezierSmoothingTension;
            controlPoint[0].y = point.y + middlePoint.y * _bezierSmoothingTension;
            
            //计算第二个控制点
            point = [self getPointForIndex:i+1];
            nextPoint = [self getPointForIndex:i + 2];
            previousPoint = [self getPointForIndex:i];
            middlePoint = CGPointZero;
            if(i < _dataY.count - 2) {
                middlePoint.x = (nextPoint.x - previousPoint.x) / 2;
                middlePoint.y = (nextPoint.y - previousPoint.y) / 2;
            } else {
                middlePoint.x = (point.x - previousPoint.x) / 2;
                middlePoint.y = (point.y - previousPoint.y) / 2;
            }
            controlPoint[1].x = point.x - middlePoint.x * _bezierSmoothingTension;
            controlPoint[1].y = point.y - middlePoint.y * _bezierSmoothingTension;

            //画线
            [path addCurveToPoint:point controlPoint1:controlPoint[0] controlPoint2:controlPoint[1]];
        }
    }else{//_END_OF_曲线图
        //折线图
        for(int i=0;i<_dataY.count;i++) {
            if(i == 0){
                //起点
                [path moveToPoint:[self getPointForIndex:i]];
            }else{
                //画线
                [path addLineToPoint:[self getPointForIndex:i]];
            }
        }
    }//_END_OF_smoothed
    
    if(closed) {
        // 闭合曲线
        CGPoint final = [self getPointForIndex:_data.count - 1];
        CGPoint start = [self getPointForIndex:0];

        [path addLineToPoint:final];
        [path addLineToPoint:start];
    }

    return path;
}

- (void)renderTag{
    
}

#pragma mark
#pragma mark 计算方法
//获取取点,换算
- (CGPoint)getPointForIndex:(NSInteger)idx{
    
    if(idx < 0 || idx >= _dataX.count){
        //取控制点,可能会返回-1
        return CGPointMake(_margin, _margin);
    }
    //_maxX / _axisWidth = valX / point.x
    CGFloat scaleX = _maxX / _axisWidth;
    //_maxY / _axisHeight = valY / point.y
    CGFloat scaleY = _maxY / _axisHeight;
    
    //
    if(_dataY && _dataY.count>0){
        CGFloat numberX = [_dataX[idx] floatValue];
        CGFloat numberY = [_dataY[idx] floatValue];
        CGPoint point = CGPointMake(numberX/scaleX + _margin, numberY/scaleY + _margin);
        if (_debug) {
            NSLog(@"获取相对点,point.x = %f, point.y = %f",point.x,point.y);
        }
        return point;
    }
//    CGFloat avgX = _axisWidth / _stepHorizontal;
//    CGFloat avgY = _axisHeight / _stepVertical;
//    CGPoint point = CGPointMake(avgX*idx + _margin, avgY*idx + _margin);
    return CGPointMake(_margin, _margin);;
}

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
    }else if(_dataY && _dataY.count>0){
        int x = 0;
        CGFloat avg = _axisWidth / _stepHorizontal;
        for (id key in _dataY) {
            if ([key floatValue] < _minY) {
                _minY = [key floatValue];
            }
            if ([key floatValue] > _maxY) {
                _maxY = [key floatValue];
            }
            //
            [_dataX addObject:[NSNumber numberWithFloat:x*avg]];
            x ++;
        }
        //没有x值,则按照等均分布
        _minX = _margin;
        _maxX = _margin + x*avg;
    }else{
        @throw [NSException
                exceptionWithName:@"无法初始化"
                reason:@"没有数据"
                userInfo:nil];
    }
    
    if (_debug) {
        NSLog(@"_minY = %f,_maxY = %f",_minY,_maxY);
        NSLog(@"_minX = %f,_minX = %f",_minX,_maxX);
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
    
    //获取iScale度量区间,10,100,1000?
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
