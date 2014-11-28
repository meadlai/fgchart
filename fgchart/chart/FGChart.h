//
//  FGChart.h
//  FGChart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FGChart : NSObject

+ (UIColor*) ColorRed;
+ (UIColor*) ColorOrange;
+ (UIColor*) ColorYellow;
+ (UIColor*) ColorGreen;
+ (UIColor*) ColorLightBlue;
+ (UIColor*) ColorDarkBlue;
+ (UIColor*) ColorPurple;
+ (UIColor*) ColorPink;
+ (UIColor*) ColorDarkGray;
+ (UIColor*) ColorLightGray;

//
+ (NSDictionary*) roundStep:(int)step max:(CGFloat)max min:(CGFloat)min;

@end
