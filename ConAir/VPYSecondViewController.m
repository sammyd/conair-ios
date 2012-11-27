//
//  VPYSecondViewController.m
//  ConAir
//
//  Created by Sam Davies on 25/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import "VPYSecondViewController.h"
#import <ShinobiCharts/ShinobiChart.h>
#import "VPYConairDataSource.h"
#import "VPYShinobiLicense.h"

@interface VPYSecondViewController () {
    ShinobiChart *chart;
    VPYConairDataSource *dataSource;
}

@end

@implementation VPYSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dataSource = [VPYConairDataSource sharedDataSource];
    [dataSource addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:NULL];
    
    chart = [[ShinobiChart alloc] initWithFrame:self.view.bounds];
    chart.licenseKey = [VPYShinobiLicense getShinobiLicenseKey];
    chart.datasource = dataSource;
    chart.theme = [SChartMidnightTheme new];
    
    SChartNumberAxis *xAxis = [[SChartNumberAxis alloc] init];
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.enableMomentumPanning = YES;
    xAxis.enableMomentumZooming = YES;
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    yAxis.enableGesturePanning = YES;
    yAxis.enableGestureZooming = YES;
    yAxis.enableMomentumPanning = YES;
    yAxis.enableMomentumZooming = YES;
    chart.xAxis = xAxis;
    chart.yAxis = yAxis;
    
    chart.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:chart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)redrawChart
{
    [chart reloadData];
    [chart redrawChartAndGL:YES];
}

- (void)dealloc
{
    [dataSource removeObserver:self forKeyPath:@"data"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"data"] && [object isEqual:dataSource]) {
        [self redrawChart];
    }
}

@end
