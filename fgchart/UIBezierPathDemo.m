//
//  UIBezierPathDemo.m
//  fgchart
//
//  Created by meadlai on Nov/28/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import "UIBezierPathDemo.h"

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
        ((CAShapeLayer *)self.layer).fillColor = nil;
        ((CAShapeLayer *)self.layer).strokeColor = [UIColor blackColor].CGColor;
    }
    return self;
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
    
    [self updatePaths];
}

@end
