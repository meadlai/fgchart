//
//  UIBezierPathDemo.m
//  fgchart
//
//  Created by meadlai on Nov/28/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import "UIBezierPathDemo.h"
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@implementation UIBezierPathDemo


// OTDrawView.m
+ (Class)layerClass {
    return[CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Initialization code
        points = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        ((CAShapeLayer *)self.layer).fillColor=[UIColor blackColor].CGColor;
        
//        ((CAShapeLayer *)self.layer).fillColor = nil;
//        ((CAShapeLayer *)self.layer).strokeColor = [UIColor blackColor].CGColor;
        [self circleTest:20];
    }
    return self;
}

- (void)circleTest:(CGFloat)percent{
    CGFloat radius = 100;
    
    CGFloat starttime = M_PI/6; //1 pm = 1/6 rad
    CGFloat endtime = M_PI;  //6 pm = 1 rad
    
    //draw arc
    CGPoint center = CGPointMake(radius,radius);
    UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
    [arc moveToPoint:center];
    CGPoint next;
    next.x = center.x + radius * cos(starttime);
    next.y = center.y + radius * sin(starttime);
    [arc addLineToPoint:next]; //go one end of arc
    [arc addArcWithCenter:center radius:radius startAngle:starttime endAngle:endtime clockwise:YES]; //add the arc
    [arc addLineToPoint:center]; //back to center
    
    ((CAShapeLayer *)self.layer).path = arc.CGPath;
    ((CAShapeLayer *)self.layer).fillColor = [[UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f] CGColor];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [((CAShapeLayer *)self.layer) addAnimation:pathAnimation forKey:@"path"];
    
    
//    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
//                                                         radius:radius
//                                                     startAngle:0
//                                                       endAngle:DEGREES_TO_RADIANS(90)
//                                                      clockwise:YES];
//    [aPath addLineToPoint:center]; //back to center
//
//    [aPath fill];
    
//    ((CAShapeLayer *)self.layer).path = aPath.CGPath;
//    ((CAShapeLayer *)self.layer).fillColor = [[UIColor colorWithRed:1.0f green:0.58f blue:0.21f alpha:1.0f] CGColor];



}

- (void)updatePaths
{
    if ([points count] >= 2) {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:[[points firstObject] CGPointValue]];
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [points count] - 1)];
        [points enumerateObjectsAtIndexes:indexSet
                                  options:0
                               usingBlock:^(NSValue *pointValue, NSUInteger idx, BOOL *stop) {
                                   [path addLineToPoint:[pointValue CGPointValue]];
                               }];
        ((CAShapeLayer *)self.layer).path = path.CGPath;
    }
    else
    {
        ((CAShapeLayer *)self.layer).path = nil;
    }
    //
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch =[touches anyObject];
    CGPoint point = [touch locationInView:self];
    [points addObject:[NSValue valueWithCGPoint:point]];
    
    //[self updatePaths];
}

@end
