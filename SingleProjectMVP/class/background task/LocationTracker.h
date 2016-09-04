//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"
#import <UIKit/UIKit.h>


@protocol LocationTrackerDelegate;

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

//@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (strong,nonatomic) LocationShareModel * shareModel;

//@property (nonatomic) CLLocationCoordinate2D myLocation;

@property (nonatomic, strong) CLLocation *myLastLocation;
@property (nonatomic, strong) CLLocation *myLocation;
@property (nonatomic, strong) CLLocation *prevLocation;

@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (nonatomic) CLLocationAccuracy currTrackAccuracy;

@property (nonatomic, strong) id<LocationTrackerDelegate> delegate;
@property (nonatomic, assign) BOOL isBackgroundMode;


+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;


@end


@protocol LocationTrackerDelegate <NSObject>
@required
- (void)locationTracker:(LocationTracker *)tracker didUpdatedLocations:(CLLocation *)lastLocation;

- (void)locationTracker:(LocationTracker *)tracker didStayedLocation:(CLLocation *)stayedLocation;
@end
