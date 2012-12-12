//
//  VPYFirstViewController.m
//  ConAir
//
//  Created by Sam Davies on 25/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import "VPYFirstViewController.h"
#import "VPYConairDataSource.h"

@interface VPYFirstViewController () {
    VPYConairDataSource *dataSource;
}

@end

@implementation VPYFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dataSource = [VPYConairDataSource sharedDataSource];
    
    [dataSource addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:NULL];
    self.lblTemperature.text = @"updating...";
}

- (void)updateTemperatureLabel
{
    self.lblTemperature.text = [NSString stringWithFormat:@"%2.1f°C", [[dataSource.data lastObject][@"temperature"] floatValue]];
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    }
    self.lblLastUpdated.text = [dateFormatter stringFromDate:[dataSource.data lastObject][@"ts"]];
}

- (void)dealloc
{
    [dataSource removeObserver:self forKeyPath:@"data"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"data"] && [object isEqual:dataSource]) {
        [self updateTemperatureLabel];
    }
}

@end
