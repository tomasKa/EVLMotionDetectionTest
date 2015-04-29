//
//  Session.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Realm/Realm.h>
#import "Activity.h"


@class Session;

@interface Session : RLMObject

@property RLMArray<Activity> *activities;
@property NSDate * startTime;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<Session>
RLM_ARRAY_TYPE(Session)
