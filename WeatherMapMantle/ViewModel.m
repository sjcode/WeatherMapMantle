//
//  ViewModel.m
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import "ViewModel.h"
#import "WeatherCondition.h"

@interface ViewModel ()<CLLocationManagerDelegate,QuickDialogDelegate>
@property (nonatomic, strong) CLLocationManager *locmanager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong, readwrite) NSString *longitude;
@property (nonatomic, strong, readwrite) NSString *latitude;
@property (nonatomic, strong, readwrite) NSString *address;

@property (nonatomic, strong, readwrite) NSString *elveation;
@property (nonatomic, strong, readwrite) RACSubject *error;

@property (nonatomic, strong, readwrite) WeatherCondition *weatherModel;

@end
@implementation ViewModel

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc{
    [self.locmanager stopUpdatingLocation];
}

- (void)initialize{
    
    //initialize for locationmanager and geocoder
    self.locmanager = [[CLLocationManager alloc]init];
    self.locmanager.delegate = self;
    self.locmanager.desiredAccuracy = kCLLocationAccuracyBest;
    self.geocoder = [[CLGeocoder alloc] init];
    
    
    @weakify(self)
    //the signal of receive consecutive coordinate data
    RACSignal *locationSignal = [[[[self rac_signalForSelector:@selector(locationManager:didUpdateToLocation:fromLocation:) fromProtocol:@protocol(CLLocationManagerDelegate)]map:^id(RACTuple *tuple) {
        return tuple.second;
    }]publish]autoconnect];
    
    [[self rac_signalForSelector:@selector(locationManager:didFailWithError:) fromProtocol:@protocol(CLLocationManagerDelegate)]subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        
        [self.error sendError:tuple.second];
    }];
    
    //KVO
    //avoid data refresh too quickly.
    RAC(self,longitude) = [[locationSignal map:^id(CLLocation *location) {
        return [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
    }]filter:^BOOL(NSString *value) {
        return ![[value substringToIndex:value.length - 4] isEqualToString:[self.longitude substringToIndex:self.longitude.length - 4]];
    }];
    
    RAC(self,latitude) = [[locationSignal map:^id(CLLocation *location) {
        return [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
    }]filter:^BOOL(NSString *value) {
        return ![[value substringToIndex:value.length - 4] isEqualToString:[self.latitude substringToIndex:self.latitude.length - 4]];
    }];
    
    
    RAC(self,address) =
    [[[[RACSignal combineLatest:@[RACObserve(self, longitude),RACObserve(self, latitude)]] throttle:3] flattenMap:^RACStream *(RACTuple *tuple) {
        @strongify(self)
        double longitude = [tuple.first doubleValue];
        double latitude = [tuple.second doubleValue];
        NSLog(@"fetch address. lon %.8f - lat %0.8f",longitude,latitude);
        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        return [self fetchAddress:currentLocation];
    }]catch:^RACSignal *(NSError *error) {
        return [RACSignal return:@"Temporarily unable to effectively use GPS"];
    }];
    
    //fetch weather
    
    RAC(self, weatherModel) =
    [[[[[[[RACSignal combineLatest:@[RACObserve(self, longitude),RACObserve(self, latitude)]]throttle:3] flattenMap:^RACStream *(RACTuple *tuple) {
        NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&units=imperial",tuple.second,tuple.first];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        return [NSURLConnection rac_sendAsynchronousRequest:request];
    }]catch:^RACSignal *(NSError *error) {
        return [RACSignal return:@"Temporarily unable to effectively use GPS"];
    }]map:^id(RACTuple *tuple) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:tuple.second options:NSJSONReadingMutableContainers error:&error];
        WeatherCondition * model =
        [MTLJSONAdapter modelOfClass:[WeatherCondition class] fromJSONDictionary:json error:&error];
        return model;
    }]publish]autoconnect];
    
    
    
    //for access request authorization
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locmanager startUpdatingLocation];
    }else if(authorizationStatus == kCLAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please on the iPhone \"privacy Settings - Location\" option, allowing Function Test to access your location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }else{
        if ([self.locmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locmanager requestWhenInUseAuthorization];
            [self.locmanager startUpdatingLocation];
        }
    }
}

- (RACSignal*)fetchAddress:(CLLocation*)location{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            @strongify(self);
            if (error == nil && [placemarks count] > 0) {
                self.placemark = [placemarks lastObject];
                NSString *address = ABCreateStringWithAddressDictionary(self.placemark.addressDictionary, YES);
                address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                [subscriber sendNext:address];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

/*
 - (RACCommand*)fetchWeather{
 
 return [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
 return [[[self fetchSignal]map:^id(RACTuple *tuple) {
 NSError *error;
 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:tuple.second options:NSJSONReadingMutableContainers error:&error];
 if (json && !error){
 WeatherCondition * model =
 [MTLJSONAdapter modelOfClass:[WeatherCondition class] fromJSONDictionary:json error:&error];
 return model;
 }else{
 return error;
 }
 }]catch:^RACSignal *(NSError *error) {
 return [RACSignal never];
 }];
 }];
 }
 
 - (RACSignal*)fetchSignal{
 NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/weather?lat=39.915354&lon=116.578584&units=imperial"]];
 return [NSURLConnection rac_sendAsynchronousRequest:request];
 }
 */

@end
