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

@interface Activity : RLMObject

@property NSDate* startTime;

//Activity types CMMotion may record 2 activities at once therefore bools for each
@property BOOL unknown;
@property BOOL stationary;
@property BOOL walking;
@property BOOL running;
@property BOOL automotive;
@property BOOL cycling;

@property RLMArray<Location>* locations;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Activity>
RLM_ARRAY_TYPE(Activity)
