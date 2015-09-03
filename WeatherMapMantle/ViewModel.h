//
//  ViewModel.h
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "WeatherCondition.h"
@import AddressBookUI;
@import CoreLocation;

@interface ViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *longitude;
@property (nonatomic, strong, readonly) NSString *latitude;
@property (nonatomic, strong, readonly) NSString *address;

@property (nonatomic, strong, readonly) NSString *elveation;
@property (nonatomic, strong, readonly) RACSubject *error;

@property (nonatomic, strong, readonly) WeatherCondition *weatherModel;

@end
