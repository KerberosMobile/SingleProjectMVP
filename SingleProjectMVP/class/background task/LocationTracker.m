//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"
#define IS_OS_8_OR_LATER                ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//          _locationManager.pausesLocationUpdatesAutomatically = NO;
//			_locationManager.allowsBackgroundLocationUpdates = YES;

		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        _isBackgroundMode = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        
	}
	return self;
}

-(void)applicationEnterBackground{
    
    NSLog(@"Application Enter Background Mode");
    _isBackgroundMode = YES;
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    
    //if (usrInfo.trackIsStarted)
        [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    self.shareModel.pauseLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:600
                                                                                target:self
                                                                              selector:@selector(pauseLocationUpdates)
                                                                              userInfo:nil
                                                                               repeats:YES];

    
    self.shareModel.backgroundJobTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(newBackgoundJob) userInfo:nil repeats:YES];
}

- (void)applicationEnterForeground
{
    NSLog(@"Application Comeback Foreground Mode");
    _isBackgroundMode = NO;
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    
    //if (usrInfo.trackIsStarted)
    [locationManager startUpdatingLocation];
    
    [self.shareModel.bgTask endAllBackgroundTasks];
    [self.shareModel.backgroundJobTimer invalidate];
    self.shareModel.backgroundJobTimer = nil;
}

- (void) newBackgoundJob
{
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void)pauseLocationUpdates
{
    NSLog(@"pauseLocationUpdates");
    
    CLLocationManager * locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    [self performSelector:@selector(restartLocationUpdates) withObject:nil afterDelay:3.0f];
    
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
//    
//    if (self.shareModel.timer) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer = nil;
//    }
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");

	if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[servicesDisabledAlert show];
	} else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
              [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
	}
    self.currTrackAccuracy = 100;
    self.shareModel.getCorrectLocationTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getCorrectLocation) userInfo:nil repeats:YES];
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
//    if (self.shareModel.timer) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer = nil;
//    }
    
    if (self.shareModel.backgroundJobTimer) {
        [self.shareModel.backgroundJobTimer invalidate];
        self.shareModel.backgroundJobTimer = nil;
    }
    
    if (self.shareModel.pauseLocationUpdateTimer) {
        [self.shareModel.pauseLocationUpdateTimer invalidate];
        self.shareModel.pauseLocationUpdateTimer = nil;
    }
    
    if (self.shareModel.getCorrectLocationTimer) {
        [self.shareModel.getCorrectLocationTimer invalidate];
        self.shareModel.getCorrectLocationTimer = nil;
    }

    
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations");
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
//        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        
        if (newLocation.coordinate.latitude ==0.0 || newLocation.coordinate.longitude == 0.0) {
            return;
        }
        
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 40.0)
        {
            continue;
        }
        
        
        //Select only valid location and also location with good accuracy
//        if(newLocation!=nil && theAccuracy>0 &&theAccuracy<2000 &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
        if (newLocation != nil && theAccuracy > 0 && theAccuracy < self.currTrackAccuracy)
        {
            [self.shareModel.myLocationArray addObject:newLocation];
            self.myLastLocation = newLocation;
            self.myLastLocationAccuracy= theAccuracy;
        }
            //self.myLastLocation = theLocation;
        
    }
    
  
}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 10 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services on your phone" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


//Send the location to Server
- (void)getCorrectLocation {
    
    NSLog(@"getCorrectLocation");
    
    // Find the best location from the array based on accuracy
//    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    
    CLLocation *myBestLocation;
    
    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
//        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        CLLocation *currentLocation = (CLLocation *)[self.shareModel.myLocationArray objectAtIndex:i];
        
        if(i == 0)
            myBestLocation = currentLocation;
        else
        {
//            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
//                myBestLocation = currentLocation;
//            }
            if (currentLocation.horizontalAccuracy <= myBestLocation.horizontalAccuracy) {
                myBestLocation = currentLocation;
            }
        }
    }
    NSLog(@"My Best location:%@",myBestLocation);
    
    //If the array is 0, get the last location
    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
    if(self.shareModel.myLocationArray.count==0)
    {
        NSLog(@"Unable to get location, use the last known location");

        self.myLocation=self.myLastLocation;
        self.myLocationAccuracy=self.myLastLocationAccuracy;
        
        return;
        
    }else{
//        CLLocationCoordinate2D theBestLocation;
//        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
//        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
//        self.myLocation=theBestLocation;
//        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
        
        self.myLocation = myBestLocation;
    }
    
    if (self.myLocation.speed <= 0) {
        [_delegate locationTracker:self didStayedLocation:self.myLocation];
        return;
    }
    
    NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",self.myLocation.coordinate.latitude, self.myLocation.coordinate.longitude,self.myLocationAccuracy);
    
    double distanceMeters = 1.0f;
    if (self.prevLocation != nil)
    {
        distanceMeters = [self.myLocation distanceFromLocation:self.prevLocation];
        if (distanceMeters > 6.0f)
        {
            //in case moving now
            [_delegate locationTracker:self didUpdatedLocations:self.myLocation];
            self.prevLocation = self.myLocation;
        }
        else
        {
            //in case stop moving
            [_delegate locationTracker:self didStayedLocation:self.myLocation];
        }
    }
    else
    {
        NSLog(@"PrevLocation Nil");
        self.prevLocation = self.myLocation;
        
        //[UserInfo getInstance].currLocation = self.myLocation;
        [_delegate locationTracker:self didUpdatedLocations:self.myLocation];
    }
    
    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
    
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}




@end
