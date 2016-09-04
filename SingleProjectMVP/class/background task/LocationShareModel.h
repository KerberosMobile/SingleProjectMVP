//
//  LocationShareModel.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationShareModel : NSObject

@property (nonatomic)         NSTimer *timer;

@property (strong, nonatomic) NSTimer *backgroundJobTimer;
@property (strong, nonatomic) NSTimer * pauseLocationUpdateTimer;
@property (strong, nonatomic) NSTimer * restartLocationUpdateTimer;
@property (strong, nonatomic) NSTimer * getCorrectLocationTimer;

@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) BackgroundTaskManager * bgTask;
@property (nonatomic) NSMutableArray *myLocationArray;

+(id)sharedModel;

@end
