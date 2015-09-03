//
//  WeatherCondition.h
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import "MTLModel.h"

@interface WeatherModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *icon;
@end

@interface WeatherMainModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, assign) NSInteger temp_max;
@property (nonatomic, assign) NSInteger temp_min;
@property (nonatomic, assign) NSInteger pressure;
@end

@interface WeatherCondition : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) NSInteger visibility;
@property (nonatomic, strong) WeatherMainModel *main;
@property (nonatomic, strong) WeatherModel *weather;
@end
