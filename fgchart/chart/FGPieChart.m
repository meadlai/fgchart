//
//  FGPieChart.m
//  FGChart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import "FGPieChart.h"
#define INT_SCALE 3.6
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@interface FGPieChart (){
    NSMutableDictionary* _data;
    //当前绘图位置
    CGFloat _startPosition;
    //中心点
    CGPoint _center;
    //计数器,计算第几个饼
    NSInteger _count;
    //计数器,颜色指标
    NSInteger _colorIndex;
}

//绘制一个扇形
- (CAShapeLayer*)renderPiece:(CGFloat) percent;

@end

@implementation FGPieChart

#pragma mark lifecycle
+ (Class)layerClass {
    return[CAShapeLayer class];
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
    _ignoreError = NO;
    _radius = 100;
    _startPosition = 0;
    _count = 0;
    //
    _colorList = [NSMutableArray arrayWithObjects:
                  [FGChart ColorLightBlue],
                  [FGChart ColorYellow],
                  [FGChart ColorGreen],
                  [FGChart ColorPink],
                  [FGChart ColorRed],
                  [FGChart ColorOrange],
                  [FGChart ColorLightGray],
                  nil];
}

- (void)setDataMap:(NSDictionary *)data{
    _data = [NSMutableDictionary dictionaryWithDictionary:data];
    if ([self doValid] == NO) {
        return;
    }
    _center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    for (id key in _data) {
        CGFloat percent = [[_data objectForKey:key]floatValue];
        CAShapeLayer *layer = [self renderPiece:percent];
        if (_count != 3) {
            NSLog(@"label = %@, percent = %f",key,percent);
            [self.layer addSublayer:layer];
        }else{
            NSLog(@"##label = %@, percent = %f",key,percent);
            [self.layer addSublayer:layer];
        }
        //
        _count ++;
    }
    
}

- (BOOL)doValid{
    NSInteger sum = 0;
    for (id key in _data) {
        NSNumber *val = [_data objectForKey:key];
        sum = sum + [val integerValue];
    }
    if (sum == 100) {
        return YES;
    }else{
        if (_ignoreError==NO) {
            @throw [NSException exceptionWithName:@"数据错误" reason:@"所有数值,不等于100%,无法组成饼图!" userInfo:nil];
        }
    }
    return NO;
}

#pragma mark
#pragma mark 绘图操作
//绘制一块
- (CAShapeLayer*)renderPiece:(CGFloat) percent{
    //TODO:精度丢失,需要::换成角度,最后转换为弧度.
    CGFloat endPosition = DEGREES_TO_RADIANS(percent * INT_SCALE) + _startPosition;
    NSLog(@"startPosition = %f, endPosition = %f",_startPosition,endPosition);

    if(_count < _colorList.count){
        //饼数目少于颜色数量
        _colorIndex = _count;
    }else{
        //饼数目大于颜色数量
        _colorIndex = _count%_colorList.count;
    }

    NSLog(@"_colorIndex = %ld",(long)_colorIndex);
    NSLog(@"_count = %ld",(long)_count);

    //
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *arc = [UIBezierPath bezierPath];
    //指向中点
    [arc moveToPoint:_center];
    //添加弧形
    [arc addArcWithCenter:_center radius:_radius startAngle:_startPosition endAngle:endPosition clockwise:YES];
    //回到中点
    [arc addLineToPoint:_center];
    layer.path = arc.CGPath;
    layer.fillColor = [[_colorList objectAtIndex:_colorIndex] CGColor];
//    NSLog(@"color=%@",[[_colorList objectAtIndex:_colorIndex] description]);
    //
    _startPosition = endPosition;
    
    //
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnim.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnim.duration = 2.0;
//    fadeAnim.beginTime = _count;
//    fadeAnim.speed = 0.5f;
//    fadeAnim.removedOnCompletion = NO;
//    fadeAnim.fillMode = kCAFillModeForwards;
    [layer addAnimation:fadeAnim forKey:[NSString stringWithFormat:@"opacity%ld",(long)_count]];
    
    //
    CABasicAnimation* theAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    theAnim.fromValue =[NSValue valueWithCGPoint:CGPointMake(_center.x-20, _center.y+20)];
    theAnim.toValue = [NSValue valueWithCGPoint:layer.position];
    theAnim.duration = 1.0;
    //[layer addAnimation:theAnim forKey:@"AnimateFrame"];
    
    //
    CATransition* transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 1.0;
    //[layer addAnimation:transition forKey:@"transition"];
    
    //
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 2; // 持续时间
    animation.repeatCount = 1; // 重复次数
    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    animation.toValue = [NSNumber numberWithFloat:1 * M_PI]; // 终止角度
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    //加速度
    animation.timingFunction =
    [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:animation forKey:@"rotate-layer"];

    return layer;
}

#pragma mark
#pragma mark 事件处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch   = [touches anyObject];
    NSLog(@"##touchesBegan");
    [self doRotation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)doRotation{
    CAShapeLayer *main = (CAShapeLayer*)self.layer;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 2; // 持续时间
    animation.repeatCount = 1; // 重复次数
    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    animation.toValue = [NSNumber numberWithFloat:1 * M_PI]; // 终止角度
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    //加速度
    animation.timingFunction =
    [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    [main addAnimation:animation forKey:@"rotate-layer"];
}

@end
