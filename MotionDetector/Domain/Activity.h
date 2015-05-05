//
//  Activity.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Realm/Realm.h>
#import "Location.h"
#import <CoreMotion/CoreMotion.h>

@class Session;

@interface Activity : RLMObject

@property NSDate* startTime;
@property NSString * uniqueId;

//Activity types CMMotion may record more than one activity at once therefore bools for each
@property Session *session;

@property BOOL unknown;
@property BOOL stationary;
@property BOOL walking;
@property BOOL running;
@property BOOL automotive;
@property BOOL cycling;
@property (readonly) NSArray *locations;

@end
RLM_ARRAY_TYPE(Activity)
