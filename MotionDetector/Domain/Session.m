//
//  Session.m
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import "Session.h"

@implementation Session

+ (NSString *)primaryKey {
    return @"uniqueId";
}

- (NSArray *)activities {
    return [self linkingObjectsOfClass:@"Activity" forProperty:@"uniqueId"];
}


// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
