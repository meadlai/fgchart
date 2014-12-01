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
    //绘图部分
    UIView *_main;
    //首次调整弧度
    CGFloat _temp;
    //当前选中区块
    NSInteger _index;
}

//绘制一个扇区
- (CAShapeLayer*)renderPiece:(CGFloat) percent;

//画标签
- (void)renderLabel;

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
                  [FGChart ColorOrange],
                  [FGChart ColorGreen],

                  [FGChart ColorPink],
                  [FGChart ColorLightGray],

                  [FGChart ColorYellow],
                  [FGChart ColorRed],
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
        [_main.layer addSublayer:layer];
        //
        _count ++;
    }
    
    //首次调整
    [self doRotation:_temp];
    
    [self renderLabel];
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
//    [arc closePath];
    layer.path = arc.CGPath;
    layer.fillColor = [[_colorList objectAtIndex:_colorIndex] CGColor];
//    NSLog(@"color=%@",[[_colorList objectAtIndex:_colorIndex] description]);
    //
    _startPosition = endPosition;
    
    //透明动画
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnim.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnim.duration = 2.0;
    [layer addAnimation:fadeAnim forKey:[NSString stringWithFormat:@"opacity%ld",(long)_count]];
    
    //偏移量计算,当前分区/2.
    CGFloat deltaPoint = DEGREES_TO_RADIANS(percent/2 * INT_SCALE) + _startPosition;
    CGPoint delta = [self computeDelta:deltaPoint];

    //记录格式:layer:count:delta.x:delta.y
    //其中delta为动画偏移量
    //用于点击后进行判断,当前是哪个区块.
    layer.name = [NSString stringWithFormat:@"layer:%ld:%f:%f"
                  ,(long)_count
                  ,delta.x,delta.y];
    if(_count == 0){
        //等于1/4-first/2
        //计算首次旋转角度
        _temp  = DEGREES_TO_RADIANS((100/4-percent/2) * INT_SCALE);
        _index = 0;
    }
    NSLog(@"_temp = %f, name = %@",(100/4-percent/2),layer.name);

    //动画坐标,会影响真实坐标.
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    animation.duration = 2; // 持续时间
//    animation.repeatCount = 1; // 重复次数
//    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
//    animation.toValue = [NSNumber numberWithFloat:_temp]; // 终止角度
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
//    //加速度
//    animation.timingFunction =
//    [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
//    [layer addAnimation:animation forKey:@"rotate-layer"];

    
    return layer;
}

- (void) renderLabel{
    int idx = 0;
    CGFloat xx = self.bounds.size.width -50;
    CGFloat yy = 16;
    
    for (id key in _data) {
        NSNumber *val = [_data objectForKey:key];
        if(idx < _colorList.count){
            //饼数目少于颜色数量
            _colorIndex = idx;
        }else{
            //饼数目大于颜色数量
            _colorIndex = idx%_colorList.count;
        }
        UILabel *block = [[UILabel alloc] init];
        block.frame = CGRectMake(xx, yy, 12, 12);
        block.backgroundColor = _colorList[idx];
        [self addSubview:block];
        UILabel *text = [[UILabel alloc] init];
        text.frame = CGRectMake(xx+15, yy, 200, 12);
        text.backgroundColor = [UIColor whiteColor];
        text.textColor = _colorList[idx];
        text.text = key;
        [self addSubview:text];

        yy = yy + 18;
        idx ++;
    }

    
}

#pragma mark
#pragma mark 事件处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_running) {
        //动画正在运行
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CAShapeLayer *hitLayer = [self layerForTouch:touch];
    if (hitLayer) {
        NSArray *string = [hitLayer.name componentsSeparatedByString:@":"];
        if (string.count == 4 && [string[0] isEqualToString:@"layer"]) {
            //获取当前点中index
            NSInteger current = [string[1] integerValue];
            if (current ==_index) {
                //点中相同区块.
                return;
            }
            [self computeRadio:current];
            _running = YES;
            [self doRotation:_temp];
        }
    }
}

//获取点中的CALayer
- (CAShapeLayer *)layerForTouch:(UITouch *)touch {
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

#pragma mark 动画操作
//radio为弧度.
- (void)doRotation:(CGFloat) radio{
    [UIView animateWithDuration:2.1 animations:^{
        _main.transform = CGAffineTransformRotate(_main.transform,radio);
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    } completion:^(BOOL finished) {
        _running = NO;
        //
        [self doMovedown];
    }];
}

- (void)doMovedown{
    //TODO:计算偏移量错误.
    return;
    int idx = 0;
    for (CAShapeLayer *ilayer in _main.layer.sublayers) {
        if (idx == _index) {
            
            CGPoint delta = CGPointZero;
            NSArray *string = [ilayer.name componentsSeparatedByString:@":"];
            if (string.count == 4 && [string[0] isEqualToString:@"layer"]) {
                delta.x = [string[2] floatValue];
                delta.y = [string[3] floatValue];
                NSLog(@"position.x=%f ,position.y=%f",ilayer.position.x,ilayer.position.y);
                NSLog(@"delta.x=%f ,delta.y=%f",delta.x,delta.y);
            }
            //点中区块
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            animation.fromValue = [NSValue valueWithCGPoint:ilayer.position]; // 起始点
            //TODO:偏移量计算,需要三角函数计算
            animation.toValue = [NSValue valueWithCGPoint:delta]; // 终了点
            animation.duration = 1.0;
//            animation.removedOnCompletion = NO;
//            animation.fillMode = kCAFillModeForwards;
            [ilayer addAnimation:animation forKey:@"position_"];
        }
        idx ++;
    }

}

#pragma mark
#pragma mark 计算
//计算移动偏移量
- (CGPoint) computeDelta:(CGFloat)deltaPoint{
    CGPoint  delta = CGPointZero;
    CGFloat isin =  sinf(deltaPoint);
    CGFloat icos =  cosf(deltaPoint);
    NSLog(@"isin = %f, icos = %f",isin,icos);
    CGFloat orginx = icos * _radius;
    CGFloat orginy = isin * _radius;
    NSLog(@"orginx = %f, orginy = %f",orginx,orginy);
    //周长变长20
    delta.x = icos * (_radius + 6);
    delta.y = isin * (_radius + 6);
    
    //象限判断
    if ( 0<= deltaPoint <= M_PI/2 ) {
        //第1象限
        delta.x = _radius + delta.x;
        delta.y = _radius - delta.y;
    }else if ( M_PI/2 < deltaPoint <= M_PI ) {
        //第2象限
        delta.x = _radius - delta.x;
        delta.y = _radius - delta.y;
    }else if ( M_PI <= deltaPoint <= (M_PI/2+M_PI) ) {
        //第3象限
        delta.x = _radius - delta.x;
        delta.y = _radius + delta.y;
    }else if ( (M_PI/2+M_PI) <= deltaPoint <= M_PI*2 ) {
        //第4象限
        delta.x = _radius + delta.x;
        delta.y = _radius + delta.y;
    }
    
    NSLog(@"deltax = %f, deltay = %f",delta.x,delta.y);
    return delta;
}

//计算区间弧度.
- (CGFloat) computeRadio:(NSInteger)current{
    NSInteger idx = 0;
    _temp = 0;
    for (id key in _data) {
        CGFloat percent = [[_data objectForKey:key]floatValue];
        if (current == idx || _index == idx) {
            _temp = percent/2 + _temp;
        }
        if (current > _index && idx>_index && idx<current) {
            _temp = percent + _temp;
        }
        if (current < _index && idx<_index && idx>current) {
            _temp = percent + _temp;
        }
        idx++;
    }
    NSLog(@"current =%ld, index =%ld, _temp = %f ",(long)current,(long)_index,_temp);
    if (current > _index){
        _temp = -DEGREES_TO_RADIANS(_temp * INT_SCALE);
    }else{
        _temp =  DEGREES_TO_RADIANS(_temp * INT_SCALE);
    }
    _index = current;
    return _temp;
}

-(void) animationDidStop:(CAAnimation *) animation finished:(bool) flag {
//    sleep(2);
//    CATransform3D rotate = CATransform3DRotate(_mainLayer.transform, 0.5* M_PI, 0.0f, 0.0f, 1.0f);
//    _mainLayer.transform = rotate;
}

@end
