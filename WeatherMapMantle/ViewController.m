//
//  ViewController.m
//  WeatherMapMantle
//
//  Created by sujian on 15/9/2.
//  Copyright (c) 2015年 sujian. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@import AddressBookUI;
#import "ViewModel.h"
#import "TestModel.h"
#import "QMapElement.h"
#import <ReactiveCocoa.h>
@interface ViewController ()<CLLocationManagerDelegate,QuickDialogDelegate>

@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, strong) CLLocationManager *locmanager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) QLabelElement *longitude;
@property (nonatomic, strong) QLabelElement *latitude;
@property (nonatomic, strong) QTextElement *address;
@property (nonatomic, strong) QElement *customCell;

@property (nonatomic, strong) QLabelElement *date;
@property (nonatomic, strong) QLabelElement *desc;
@property (nonatomic, strong) QLabelElement *temp;
@property (nonatomic, strong) QLabelElement *pressure;
@end

@implementation ViewController

- (void)awakeFromNib{
    
    self.viewModel = [[ViewModel alloc]init];
    QRootElement *root = [[QRootElement alloc] init];
    root.title = @"Weather";
    root.grouped = YES;
    self.root = root;
    
    QSection *sectionmap = [[QSection alloc]init];
    sectionmap.title = @"Map";
    QMapElement *mapElement = [[QMapElement alloc]initWithKey:@"map"];
    mapElement.height = 160;
    [sectionmap addElement:mapElement];
    [self.root addSection:sectionmap];
    
    QSection *section = [[QSection alloc]initWithTitle:@"Location:"];
    QLabelElement *longitude = [[QLabelElement alloc]initWithTitle:@"longitude" Value:@""];
    longitude.key = @"longitude";
    [section addElement:longitude];
    QLabelElement *latitude = [[QLabelElement alloc]initWithTitle:@"latitude" Value:@""];
    latitude.key = @"latitude";
    [section addElement:latitude];
    
    [self.root addSection:section];
    
    QSection *addressSection = [[QSection alloc]initWithTitle:@"address:"];
    QTextElement *address = [[QTextElement alloc]initWithText:@""];
    address.key = @"address";
    [addressSection addElement:address];
    [self.root addSection:addressSection];
    
    QSection *weatherSection = [[QSection alloc]initWithTitle:@"weather:"];
    
    QLabelElement *date = [[QLabelElement alloc]initWithTitle:@"date" Value:@""];
    date.key = @"date";
    [weatherSection addElement:date];
    QLabelElement *desc = [[QLabelElement alloc]initWithTitle:@"description" Value:@""];
    desc.key = @"desc";
    [weatherSection addElement:desc];
    QLabelElement *temp = [[QLabelElement alloc]initWithTitle:@"temperature" Value:@""];
    temp.key = @"temp";
    [weatherSection addElement:temp];
    QLabelElement *pressure = [[QLabelElement alloc]initWithTitle:@"pressure" Value:@""];
    pressure.key = @"pressure";
    [weatherSection addElement:pressure];
    
    [self.root addSection:weatherSection];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.longitude = (QLabelElement*)[self.quickDialogTableView.root elementWithKey:@"longitude"];
    self.latitude = (QLabelElement*)[self.quickDialogTableView.root elementWithKey:@"latitude"];
    self.address = (QTextElement*)[self.quickDialogTableView.root elementWithKey:@"address"];
    self.customCell = (QElement*)[self.quickDialogTableView.root elementWithKey:@"mapview"];
    
    self.date = (QLabelElement*)[self.quickDialogTableView.root elementWithKey:@"date"];
    self.desc = (QLabelElement*)[self.quickDialogTableView.root elementWithKey:@"desc"];
    self.temp = (QLabelElement*)[self.quickDialogTableView.root elementWithKey:@"temp"];
    self.pressure = (QLabelElement*)[self.quickDialogTableView.root elementWithKey:@"pressure"];
    
    RAC(self.address,text) = RACObserve(self.viewModel, address);
    RAC(self.longitude,value) = RACObserve(self.viewModel, longitude);
    RAC(self.latitude,value) = RACObserve(self.viewModel, latitude);
    
    RAC(self.date,value) = [RACObserve(self.viewModel,weatherModel)map:^id(WeatherCondition *weather) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        NSString *timeStamp = [dateFormatter stringFromDate:weather.date];
        //return timeStamp;
        
        return [weather.date descriptionWithLocale:[NSLocale systemLocale]];
    }];
    
    RAC(self.desc,value) = [[RACObserve(self.viewModel,weatherModel)map:^id(WeatherCondition *weather) {
        WeatherModel *model = weather.weather[0];
        return model.desc;
    }]logNext];
    
    RAC(self.temp,value) = [RACObserve(self.viewModel,weatherModel)map:^id(WeatherCondition *weather) {
        return [NSString stringWithFormat:@"%ld F",weather.main.temp_max];
    }];
    RAC(self.pressure,value) = [RACObserve(self.viewModel,weatherModel)map:^id(WeatherCondition *weather) {
        return [NSString stringWithFormat:@"%ld aph",weather.main.pressure];
    }];
    
    [[RACSignal merge:@[RACObserve(self.viewModel, longitude),RACObserve(self.viewModel, latitude),RACObserve(self.viewModel, address)]]
    subscribeNext:^(id _) {
        [self.quickDialogTableView reloadData];
    }];
    
    [[RACObserve(self.viewModel,weatherModel)delay:1]  subscribeNext:^(id x) {
        [self.quickDialogTableView reloadData];
    }];


    @weakify(self)
    [self.viewModel.error subscribeNext:^(NSError *error) {
        @strongify(self)
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tip" message:@"Your phone has lost gps signal." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

@end
