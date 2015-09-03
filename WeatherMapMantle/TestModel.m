//
//  TestModel.m
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import "TestModel.h"
@implementation CarModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"make":@"make",@"year":@"year"};
}

@end

@implementation Owner

+ (NSDictionary*)JSONKeyPathsByPropertyKey{
    return @{@"name":@"name",
             @"gender":@"gender",@"age":@"age",
             };
}

@end
@implementation TestModel

//指向一个array的映射
+ (NSValueTransformer *)carsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:CarModel.class];
}

//指向一个dict的映射
+ (NSValueTransformer*)ownerJSONTransformer{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Owner.class];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"name":@"name",
             @"cars":@"cars",
             @"owner":@"owner",
             @"ownername":@"owner.name",
             @"maker":@"cars",
             };
}
//找出cars下第一个item的make
+ (NSValueTransformer *)makerJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *cars, BOOL *success, NSError **error) {
        return [cars.firstObject valueForKey:@"make"];
    }];
}



@end
