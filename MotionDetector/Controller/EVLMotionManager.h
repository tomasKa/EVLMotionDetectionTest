//
//  EVLMotionManager.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Realm/Realm.h>
#import "EVLLocationManager.h"
#import "Activity.h"
#import "Session.h"
#import "Location.h"



@interface EVLMotionManager : NSObject <AVSpeechSynthesizerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong)CMMotionActivityManager *activityManager;
@property (nonatomic, strong)AVSpeechSynthesizer *speechSyntesizer;
@property (nonatomic, strong)CLLocationManager *locationManager;

@property BOOL walking;

-(void) startActivityDetection;

@end
