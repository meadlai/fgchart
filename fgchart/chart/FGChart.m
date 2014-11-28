//
//  FGChart.m
//  FGChart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import "FGChart.h"

@implementation FGChart

+ (UIColor*) ColorRed{
    return [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
}

+ (UIColor*) ColorOrange{
    return [UIColor colorWithRed:1.0f green:0.58f blue:0.21f alpha:1.0f];
}

+ (UIColor*) ColorYellow{
    return [UIColor colorWithRed:1.0f green:0.79f blue:0.28f alpha:1.0f];
}

+ (UIColor*) ColorGreen{
    return [UIColor colorWithRed:0.27f green:0.85f blue:0.46f alpha:1.0f];
}

+ (UIColor*) ColorLightBlue{
    return [UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f];
}

+ (UIColor*) ColorDarkBlue{
    return [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f];
}

+ (UIColor*) ColorPurple{
    return [UIColor colorWithRed:0.35f green:0.35f blue:0.81f alpha:1.0f];
}

+ (UIColor*) ColorPink{
    return [UIColor colorWithRed:1.0f green:0.17f blue:0.34f alpha:1.0f];
}

+ (UIColor*) ColorDarkGray{
    return [UIColor colorWithRed:0.56f green:0.56f blue:0.58f alpha:1.0f];
}

+ (UIColor*) ColorLightGray{
    return [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
}

//调整max & min.
+ (NSDictionary*) roundStep:(int)step max:(CGFloat)max min:(CGFloat)min{
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
    
    return result;
}

@end
