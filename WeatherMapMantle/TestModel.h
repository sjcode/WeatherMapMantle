//
//  TestModel.h
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface CarModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *make;
@property (nonatomic, copy) NSString *year;
@end

@interface Owner : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic) NSInteger age;
@end

@interface TestModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *cars;
@property (nonatomic, strong) Owner *owner;
@property (nonatomic, copy) NSString *ownername;
@property (nonatomic, copy) NSString *maker;
@end
