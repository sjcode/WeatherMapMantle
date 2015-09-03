//
//  WeatherCondition.m
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import "WeatherCondition.h"
@implementation WeatherModel

+ (NSDictionary*)JSONKeyPathsByPropertyKey{
    return @{
             @"icon":@"icon",
             @"desc":@"description"
             };
}

@end

@implementation WeatherMainModel

+ (NSDictionary*)JSONKeyPathsByPropertyKey{
    return @{
             @"temp_max":@"temp_max",
             @"temp_min":@"temp_min",
             @"pressure":@"pressure",
             };
}


@end

@implementation WeatherCondition

+ (NSDictionary*)JSONKeyPathsByPropertyKey{
    return @{
             @"date":@"dt",
             @"visibility":@"visibility",
             @"weather":@"weather",
             @"main":@"main"
             };
}

+ (NSValueTransformer*)mainJSONTransformer{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:WeatherMainModel.class];
}

+ (NSValueTransformer*)weatherJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:WeatherModel.class];
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:
            ^id(NSNumber *number)
            {
                NSTimeInterval secs = [number doubleValue];
                return [NSDate dateWithTimeIntervalSince1970:secs];
            } reverseBlock:^id(NSDate *d) {
                return @([d timeIntervalSince1970]);
            }];
    
}


@end
