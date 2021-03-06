//
//  FGLineChart.h
//  FGChart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FGChart.h"

//点击提示
typedef NSString *(^FGLabelForTip)(CGFloat value);
typedef UIView *(^FGViewForTip)(CGFloat value);

//axis轴
typedef NSString *(^FGLabelForHorizontal)(CGFloat index);
typedef NSString *(^FGLabelForVertical)(CGFloat value);


@interface FGLineChart : UIView{
    
}


//axis步进-切分
@property (nonatomic, readwrite) int stepVertical;
@property (nonatomic, readwrite) int stepHorizontal;

#pragma mark 颜色定义
@property (nonatomic, readwrite) CGFloat margin;
//线条颜色
@property (nonatomic, copy) UIColor* colorLine;
//填充颜色(默认填充,除非设为nil)
@property (nonatomic, copy) UIColor* colorFill;
@property (nonatomic, copy) UIColor* colorBackground;
//轴颜色 & 宽度
@property (nonatomic, copy) UIColor* axisColor;
@property (nonatomic, readwrite) CGFloat axisLineWidth;
@property (nonatomic, readonly) CGFloat axisWidth;
@property (nonatomic, readonly) CGFloat axisHeight;
//网格线
@property (nonatomic, readwrite) BOOL gridInside;
@property (nonatomic, copy) UIColor* gridInsideColor;
@property (nonatomic, readwrite) CGFloat gridInsideWidth;


#pragma mark 动画定义
@property (nonatomic, readwrite) BOOL animation;
@property (nonatomic, readwrite) CGFloat animationDuration;
//是否开启:贝塞尔曲线
@property (nonatomic, readwrite) BOOL bezierSmoothing;
//曲线设置
@property (nonatomic, readwrite) CGFloat bezierSmoothingTension;

#pragma mark 交互定义
@property (nonatomic, readwrite) BOOL touchInteraction;
//点击提示
@property (copy) FGLabelForTip labelTip;
@property (copy) FGViewForTip viewTip;
@property (copy) FGLabelForHorizontal labelHorizontal;
@property (copy) FGLabelForVertical labelVertical;
@property (nonatomic, readwrite) BOOL labelRight;
@property (nonatomic, strong) UIFont* labelFont;
@property (nonatomic, copy) UIColor* labelFontColor;




- (void)setDataList:(NSArray *)date;
//map<x,y>
- (void)setDataMap:(NSDictionary *)date;
- (void)reload:(CGFloat)animationDuration;

@property (nonatomic, readwrite) BOOL debug;

@end
