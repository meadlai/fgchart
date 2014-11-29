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
#define UI_Padding_Top 30
#define UI_Screen_width [UIScreen mainScreen].bounds.size.width

#define UI_Screen_height [UIScreen mainScreen].bounds.size.height

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
//    CAShapeLayer *_mainLayer;
    UIView *_main;
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
    _main = [[UIView alloc] init];
    _main.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:_main];

    _data = [NSMutableDictionary dictionaryWithDictionary:data];
    if ([self doValid] == NO) {
        return;
    }
    _center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    for (id key in _data) {
        CGFloat percent = [[_data objectForKey:key]floatValue];
        CAShapeLayer *layer = [self renderPiece:percent];
        NSLog(@"##label = %@, percent = %f",key,percent);
        [_main.layer addSublayer:layer];
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
    [arc closePath];
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
    [layer addAnimation:fadeAnim forKey:[NSString stringWithFormat:@"opacity%ld",(long)_count]];
    
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
//    [layer addAnimation:animation forKey:@"rotate-layer"];

    layer.name = [NSString stringWithFormat:@"layer%ld",(long)_count];
    
    return layer;
}

#pragma mark
#pragma mark 事件处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //UITouch *touch   = [touches anyObject];
    UITouch *touch = [touches anyObject];
    CALayer *hitLayer = [self layerForTouch:touch];
    if (hitLayer) {
        NSLog(@"##sublayers.count = %lu" ,(unsigned long)_main.layer.sublayers.count);
        [self doRotation];
    }
}

- (CALayer *)layerForTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:_main];
    
        for (CAShapeLayer *ilayer in _main.layer.sublayers) {
            BOOL hit = CGPathContainsPoint([ilayer path], NULL, location, ([ilayer fillRule] == kCAFillRuleEvenOdd));
            if (hit) {
                NSLog(@"location.x=%f ,location.y=%f",location.x,location.y);
                NSLog(@"layer.name = %@",ilayer.name);
                return ilayer;
            }
        }

    
//    监测点击事件
//    location = [self convertPoint:location toView:_main];
//    for (CALayer *ilayer in _main.layer.sublayers) {
//        CALayer *hitPresentationLayer = [ilayer.presentationLayer hitTest:location];
//        if (hitPresentationLayer) {
//            NSLog(@"location.x=%f ,location.y=%f",location.x,location.y);
//            //return hitPresentationLayer.modelLayer;
//        }
//    }
    
    return nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)doRotation{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.delegate = self;
    animation.duration = 2; // 持续时间
    animation.repeatCount = 1; // 重复次数
    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    animation.toValue = [NSNumber numberWithFloat:0.5 * M_PI]; // 终止角度
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    //加速度
    animation.timingFunction =
    [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    //[_main.layer addAnimation:animation forKey:@"rotate-layer"];
    //
    float currentRotation = [(NSNumber*)[animation valueForKeyPath:@"transform.rotation.z"] floatValue];
    NSLog(@"Rotation = %f",currentRotation);
    
    [UIView animateWithDuration:2.1 animations:^{
        _main.transform = CGAffineTransformRotate(_main.transform,0.5 * M_PI);
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    } completion:^(BOOL finished) {
        //
    }];

}

-(void) animationDidStop:(CAAnimation *) animation finished:(bool) flag {
//    sleep(2);
//    CATransform3D rotate = CATransform3DRotate(_mainLayer.transform, 0.5* M_PI, 0.0f, 0.0f, 1.0f);
//    _mainLayer.transform = rotate;
}

@end
