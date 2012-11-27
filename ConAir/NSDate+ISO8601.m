//
//  NSDate+ISO8601.m
//  ConAir
//
//  Created by Sam Davies on 27/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

// Based on http://www.radupoenaru.com/processing-nsdate-into-an-iso8601-string/

#import "NSDate+ISO8601.h"

@implementation NSDate (ISO8601)

- (NSString *)dateAsISO8601String
{
    static NSDateFormatter* iso8601Formatter = nil;
    
    if (!iso8601Formatter) {
        iso8601Formatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        int offset = [timeZone secondsFromGMT];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyyMMdd'T'HH:mm:ss"];
        offset /= 60; // We want the offset in minutes instead
        if (offset == 0)
            [strFormat appendString:@"Z"];
        else
            [strFormat appendFormat:@"%+02d%02d", offset / 60, offset % 60];
        
        [iso8601Formatter setTimeStyle:NSDateFormatterFullStyle];
        [iso8601Formatter setDateFormat:strFormat];
    }
    return[iso8601Formatter stringFromDate:self];
}

+ (NSDate *)dateFromISO8601String:(NSString *)dateString
{
    static NSDateFormatter* iso8601Formatter = nil;
    
    if (!iso8601Formatter) {
        iso8601Formatter = [[NSDateFormatter alloc] init];
        [iso8601Formatter setTimeStyle:NSDateFormatterFullStyle];
        [iso8601Formatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
    }
    if ([dateString hasSuffix:@"Z"]) {
        dateString = [dateString substringToIndex:(dateString.length-1)];
    }
    
    return [iso8601Formatter dateFromString:dateString];
}

@end
