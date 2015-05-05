//
//  Session.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Realm/Realm.h>
#import "Activity.h"



@interface Session : RLMObject

@property NSString * uniqueId;
@property NSDate * startTime;

@property (readonly) NSArray *activities;
@end
RLM_ARRAY_TYPE(Session)
