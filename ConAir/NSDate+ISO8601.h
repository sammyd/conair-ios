//
//  NSDate+ISO8601.h
//  ConAir
//
//  Created by Sam Davies on 27/11/2012.
//  Copyright (c) 2012 Sam Davies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601)

- (NSString*)dateAsISO8601String;
+ (NSDate*)dateFromISO8601String:(NSString*)dateString;

@end
