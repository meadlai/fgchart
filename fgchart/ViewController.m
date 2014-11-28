//
//  ViewController.m
//  fgchart
//
//  Created by meadlai on Nov/27/2014.
//  Copyright (c) 2014 fgchart. All rights reserved.
//

#import "ViewController.h"
#import "FGChart.h"
#import "FGLineChart.h"
#import "UIBezierPathDemo.h"

#define UI_Padding_Top 30
#define UI_Screen_width [UIScreen mainScreen].bounds.size.width

#define UI_Screen_height [UIScreen mainScreen].bounds.size.height


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testLineChart];
    [self testBezierLine];
}

- (void)testLineChart{
    CGFloat minBound = MIN(80, 60);

    NSLog(@"Min= %f",minBound);
    
    FGLineChart *chart = [[FGLineChart alloc] init];
    chart.debug = YES;
    //
    chart.frame = CGRectMake(UI_Padding_Top, UI_Padding_Top, UI_Screen_width-UI_Padding_Top*2,200);
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:10];

    for(int i=0;i<10;i++) {
        int r = (rand() + rand()) % 1000;
        r = abs(r);
        chartData[i] = [NSNumber numberWithInt:r + 100];
    }
    
    [chart setDataList:chartData];
    [self.view addSubview:chart];
}

- (void)testBezierLine{
    UIBezierPathDemo *line = [[UIBezierPathDemo alloc] init];
    line.frame = CGRectMake(UI_Padding_Top, UI_Padding_Top*3+200, UI_Screen_width-UI_Padding_Top*2, 200);
    [self.view addSubview:line];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
