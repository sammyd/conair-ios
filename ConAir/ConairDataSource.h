//
//  VPYConairDataSource.h
//  ConAir
//
//  Created by Sam Davies on 25/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>

@interface ConairDataSource : NSObject <SChartDatasource>

@property (nonatomic, strong, readonly) NSMutableArray *data;
@property (nonatomic, assign) int pollingPeriod;

+ (ConairDataSource*)sharedDataSource;

- (void)startPolling;
- (void)stopPolling;

@end
