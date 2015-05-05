//
//  EVLMotionManager.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

@class CMMotionActivityManager;
@class CLLocationManager;
@class AVSpeechSynthesizer;

@interface EVLMotionManager : NSObject <AVSpeechSynthesizerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong)CMMotionActivityManager *activityManager;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)AVSpeechSynthesizer *speechSyntesizer;


-(void) startActivityDetection;

@end
