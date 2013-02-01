//
//  VPYSecondViewController.m
//  ConAir
//
//  Created by Sam Davies on 25/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import "SecondViewController.h"
#import <ShinobiCharts/ShinobiChart.h>
#import "ConairDataSource.h"
#import "ShinobiLicense.h"

@interface SecondViewController () {
    ShinobiChart *chart;
    ConairDataSource *dataSource;
}

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dataSource = [ConairDataSource sharedDataSource];
    [dataSource addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:NULL];
    
    chart = [[ShinobiChart alloc] initWithFrame:self.view.bounds withPrimaryXAxisType:SChartAxisTypeDateTime withPrimaryYAxisType:SChartAxisTypeNumber];
    chart.licenseKey = [ShinobiLicense getShinobiLicenseKey];
    chart.datasource = dataSource;
    chart.theme = [SChartDarkTheme new];
    
    chart.xAxis.enableGesturePanning = YES;
    chart.xAxis.enableGestureZooming = YES;
    chart.xAxis.enableMomentumPanning = YES;
    chart.xAxis.enableMomentumZooming = YES;
    chart.yAxis.enableGesturePanning = YES;
    chart.yAxis.enableGestureZooming = YES;
    chart.yAxis.enableMomentumPanning = YES;
    chart.yAxis.enableMomentumZooming = YES;
    chart.yAxis.rangePaddingHigh = @1;
    chart.yAxis.rangePaddingLow = @1;
    
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
