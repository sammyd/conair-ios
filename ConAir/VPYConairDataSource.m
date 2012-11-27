//
//  VPYConairDataSource.m
//  ConAir
//
//  Created by Sam Davies on 25/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import "VPYConairDataSource.h"
#import "NSDate+ISO8601.h"

@interface VPYConairDataSource ()

@property (nonatomic, strong, readwrite) NSArray *data;

@end

@implementation VPYConairDataSource

+ (VPYConairDataSource *)sharedDataSource
{
    static VPYConairDataSource *sharedDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataSource = [[self alloc] init];
    });
    return sharedDataSource;
}

- (void)collectDataFromInternet
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    NSString *urlString = [NSString stringWithFormat:@"http://sl-conair.herokuapp.com/data/?start=%@&stop=%@&step=%@",
                           [startDate dateAsISO8601String], [endDate dateAsISO8601String], @"120000"];
    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // Parse the JSON data
        NSError *error;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(error) {
            NSLog(@"There was an error");
        } else {
            // Convert the JSON structure into a nice array
            NSMutableArray *dataPoints = [[NSMutableArray alloc] init];
            [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [dataPoints addObject:[obj objectForKey:@"value"]];
            }];
            
            // Perform the assignment on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                self.data = [NSArray arrayWithArray:dataPoints];
            });
        }
    });
}

- (id)init
{
    self = [super init];
    if(self) {
        [self collectDataFromInternet];
    }
    return self;
}


#pragma mark - SChartDatasource methods
- (int)numberOfSeriesInSChart:(ShinobiChart *)chart
{
    return 1;
}

- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex
{
    return self.data.count;
}

- (NSArray *)sChart:(ShinobiChart *)chart dataPointsForSeriesAtIndex:(int)seriesIndex
{
    NSMutableArray *datapointArray = [[NSMutableArray alloc] init];
    [self.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SChartDataPoint *dp = [[SChartDataPoint alloc] init];
        dp.xValue = [NSNumber numberWithInt:idx];
        dp.yValue = obj;
        [datapointArray addObject:dp];
    }];
    return [NSArray arrayWithArray:datapointArray];
}

- (SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index
{
    SChartLineSeries *series = [[SChartLineSeries alloc] init];
    return series;
}


@end
