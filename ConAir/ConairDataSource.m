//
//  VPYConairDataSource.m
//  ConAir
//
//  Created by Sam Davies on 25/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import "ConairDataSource.h"
#import "NSDate+ISO8601.h"

@interface ConairDataSource () {
    NSTimer *pollingTimer;
}

@property (nonatomic, strong, readwrite) NSMutableArray *data;

@end

@implementation ConairDataSource

+ (ConairDataSource *)sharedDataSource
{
    static ConairDataSource *sharedDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataSource = [[self alloc] init];
    });
    return sharedDataSource;
}

- (id)init
{
    self = [super init];
    if (self) {
        _pollingPeriod = 10;
        pollingTimer = nil;
        // Grab the inital data import
        [self collectDataFromInternet];
    }
    return self;
}

- (void)collectDataFromInternet
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    if(self.data && self.data.count != 0) {
        startDate = [[self.data lastObject] objectForKey:@"ts"];
    }
    NSDate *endDate = [NSDate date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://sl-conair.herokuapp.com/data/?start=%@&stop=%@&step=%@",
                           [startDate dateAsISO8601String], [endDate dateAsISO8601String], @"120000"];
    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_async(queue, ^{
        NSLog(@"requesting");
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // Parse the JSON data
        NSError *error;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(error) {
            NSLog(@"There was an error");
        } else {
            // Convert the JSON structure into a nice array
            NSMutableArray *dataPoints = [[NSMutableArray alloc] init];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setTimeStyle:NSDateFormatterFullStyle];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            NSDate *currentLatestDate = [[self.data lastObject] objectForKey:@"ts"];
            [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDate *ts = [df dateFromString:obj[@"ts"]];
                // Let's check that we have a new data point
                if(!currentLatestDate || !([ts isEqualToDate:currentLatestDate] || ([ts compare:currentLatestDate] == NSOrderedAscending))) {
                    NSDictionary *datapoint = @{@"ts" : ts, @"temperature" : obj[@"temperature"]};
                    [dataPoints addObject:datapoint];
                }
            }];
            
            if (dataPoints.count > 0) {
                // Perform the assignment on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!self.data) {
                        self.data = dataPoints;
                    } else {
                        for (NSDictionary *dp in dataPoints) {
                            [self insertObject:dp inDataAtIndex:self.data.count];
                        }
                    }
                });
            }
        }
    });
}

- (void)startPolling
{
    pollingTimer = [NSTimer scheduledTimerWithTimeInterval:self.pollingPeriod target:self selector:@selector(collectDataFromInternet) userInfo:nil repeats:YES];
}


- (void)stopPolling
{
    [pollingTimer invalidate];
    pollingTimer = nil;
}

- (void)setPollingPeriod:(int)pollingPeriod
{
    if(pollingPeriod != _pollingPeriod) {
        _pollingPeriod = pollingPeriod;
        if(pollingTimer) {
            [self stopPolling];
            [self startPolling];
        }
    }
}

#pragma mark - KVC methods
// We implement these so that we get KVO updates on array insertion
- (NSUInteger)countOfData
{
    return self.data.count;
}

- (id)objectInDataAtIndex:(NSUInteger)index
{
    return self.data[index];
}


- (void)insertObject:(NSDictionary *)object inDataAtIndex:(NSUInteger)index
{
    [self.data insertObject:object atIndex:index];
}

- (void)removeObjectFromDataAtIndex:(NSUInteger)index
{
    [self.data removeObjectAtIndex:index];
}

- (void)replaceObjectInDataAtIndex:(NSUInteger)index withObject:(NSDictionary *)object
{
    [self.data replaceObjectAtIndex:index withObject:object];
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
        dp.xValue = obj[@"ts"];
        dp.yValue = obj[@"temperature"];
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
