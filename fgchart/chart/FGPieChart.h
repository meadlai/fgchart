//
//  FGPieChart.h
//  FGChart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FGChart.h"

//点击提示
typedef NSString *(^FGLabelForTip)(CGFloat value);
typedef UIView *(^FGViewForTip)(CGFloat value);

/**
 * 支持点击旋转,并把点中的区块,旋转到正下方<br>
 * 所有区块绘画完毕,进行一次旋转调整.
 **/
@interface FGPieChart : UIView{
    
}

@property (nonatomic, copy) UIColor* colorBackground;
@property (nonatomic, retain) NSMutableArray* colorList;

//半径r,
@property (nonatomic, readwrite) CGFloat radius;

//map<百分百,详细文本说明>
- (void)setDataMap:(NSDictionary *)date;

@property (nonatomic, readwrite) BOOL debug;
@property (nonatomic, readwrite) BOOL ignoreError;
@property (atomic, readwrite) BOOL running;



@end
