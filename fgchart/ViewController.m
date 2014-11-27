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

#define UI_Padding_Top 16
#define UI_Screen_width [UIScreen mainScreen].bounds.size.width

#define UI_Screen_height [UIScreen mainScreen].bounds.size.height


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testLineChart];
}

- (void)testLineChart{
    CGFloat minBound = MIN(80, 60);

    NSLog(@"Min= %f",minBound);
    
    FGLineChart *chart = [[FGLineChart alloc] init];
    chart.debug = YES;
    //
    chart.frame = CGRectMake(UI_Padding_Top, UI_Padding_Top, UI_Screen_width,200);
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:10];
    
    for(int i=0;i<10;i++) {
        int r = (rand() + rand()) % 1000;
        chartData[i] = [NSNumber numberWithInt:r + 200];
    }
    
    [chart setDataList:chartData];
    [self.view addSubview:chart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
