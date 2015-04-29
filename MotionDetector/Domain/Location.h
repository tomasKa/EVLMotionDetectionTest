//
//  Location.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Realm/Realm.h>

@interface Location : RLMObject

@property NSString* locationDescription;
@property NSDate* timestamp;

@property double speed;
@property double direction;
@property double longitude;
@property double latitude;
@property double distance;
@property double acuracy;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Location>
RLM_ARRAY_TYPE(Location)
