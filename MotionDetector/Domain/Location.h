//
//  Location.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Realm/Realm.h>

@class Activity;

@interface Location : RLMObject

@property NSString * uniqueId;
@property Activity *activity;
@property NSString *locationDescription;
@property NSDate *timestamp;

@property double speed;
@property double course;
@property double longitude;
@property double latitude;
@property double distance;
@property double horizontalAccuracy;
@property double verticalAccuracy;

@end

RLM_ARRAY_TYPE(Location)
