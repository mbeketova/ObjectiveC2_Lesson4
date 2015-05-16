//
//  TableMapViewController.h
//  ObjectiveC2_Lesson4
//
//  Created by Admin on 16.05.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>



@interface TableMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>



@end
