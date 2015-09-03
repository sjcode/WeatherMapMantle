//
//  QMapElement.m
//  checkdevice
//
//  Created by sujian on 15/6/8.
//  Copyright (c) 2015年 FutureDial. All rights reserved.
//

#import "QMapElement.h"

@interface QMapElement()<MKMapViewDelegate>
@property (nonatomic, strong)MKMapView *mapview;
@end

@implementation QMapElement


- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller{
    UITableViewCell *cell = [super getCellForTableView:tableView controller:controller];
    if(!self.mapview){
        
        self.mapview = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160)];
        self.mapview.delegate = self;
        self.mapview.showsUserLocation = YES;
        self.mapview.userInteractionEnabled = NO;

        [cell.contentView addSubview:self.mapview];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [self.mapview setRegion:region animated:YES];
}

@end
