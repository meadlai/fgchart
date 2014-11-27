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
            self.backgroundColor = [UIColor redColor];
        }
        [self loadParameters];
    }
    return self;
}


- (void)loadParameters{
    
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
}

#pragma mark 调用方法
- (void)setDataList:(NSArray *)data{
    width = self.frame.size.width;
    height = self.frame.size.height;
    _dataX = [NSMutableArray arrayWithArray:data];
    _dataY = [NSMutableArray array];
    [self computeSteps];
    
}

- (void)setDataMap:(NSDictionary *)data{
    width = self.frame.size.width;
    height = self.frame.size.height;
    _data = [NSMutableDictionary dictionaryWithDictionary:data];
    _dataX = [NSMutableArray array];
    _dataY = [NSMutableArray array];
    [self computeSteps];

}

- (void)reload:(CGFloat)animationDuration{
    
}

#pragma mark
#pragma mark 画图
- (void)drawRect:(CGRect)rect{
    [self renderGrid];
}

- (void)renderGrid{
    
}

- (void)renderChart{
    
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
    
    _maxY = [self roundStep:_maxY length:height step:_stepHorizontal];
    
    
}

- (CGFloat)roundStep:(CGFloat)val length:(CGFloat)length step:(int)step{
    if (val<0) {
        return 0;
    }
    CGFloat avg= length / step;
    CGFloat scale = val/ length;
    
    if (_debug) {
        NSLog(@"avg = %f",avg);
        NSLog(@"scale = %f",scale);

    }
    return 0;
}

@end
