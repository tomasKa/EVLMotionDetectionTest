//
//  EVLMotionManager.m
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import "EVLMotionManager.h"
#import <CoreMotion/CoreMotion.h>
#import <Realm/Realm.h>
#import "Activity.h"
#import "Session.h"
#import "Location.h"
#import "EVLConstants.h"

@implementation EVLMotionManager
{
    NSInteger previousConfidence;
    CMMotionActivity *previousActivity;
   
    NSString *currentActivity;
    NSString  *currentSession;
}

- (void)startActivityDetection{
    _activityManager = [CMMotionActivityManager new];
   
    [_activityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity *activity) {
        
            if (!previousActivity) {
                previousActivity = [CMMotionActivity new];
            }
            if (activity.unknown != previousActivity.unknown || activity.stationary != previousActivity.stationary || activity.walking != previousActivity.walking || activity.running != previousActivity.running || activity.automotive != previousActivity.automotive ||activity.cycling != previousActivity.cycling) {
                
                [self updateActivityWithActivity:activity];
            }
            if (activity.confidence != previousActivity.confidence) {
                
                [self confidenceChanged:activity];
            }
            if (activity.confidence == CMMotionActivityConfidenceHigh) {
                
                if (!currentSession){
                    [self startNewSessionWithActivity:activity];
                }
                else{
                    [self persistNewActivity:activity];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MotionActivityChangedNotification" object:[self resolveActivityTypeofActivity:activity]];
    }];
}

- (void)startLocationDetection{
    
    
}

- (void)stopLocationDetection{
    

}
- (NSString *const)resolveActivityTypeofActivity:(CMMotionActivity*)activity{
    
    NSString *returnString = kActivityTypeUnknown;
    
    if(activity.automotive && activity.startDate){
        returnString = kActivityTypeAutomotiveStationary;
    }
    else if (activity.automotive) {
        returnString = kActivityTypeAutomotive;
    }
    else if (activity.stationary) {
        returnString = kActivityTypeStationary;
    }
    else if (activity.cycling) {
        returnString = kActivityTypeCycling;
    }
    else if (activity.walking) {
        returnString = kActivityTypeWalking;
    }
    else if (activity.running) {
        returnString = kActivityTypeRunning;
    }
    return returnString;
}

- (void)updateActivityWithActivity:(CMMotionActivity*)motionActivity{
    
    if (!previousActivity) {
        previousActivity = [CMMotionActivity new];
    }
    previousConfidence = motionActivity.confidence;
    previousActivity = motionActivity;
    NSLog(@" \n UNKNNOWN :%d,STATIONARY: %d WALKING: %d RUNNING: %d AUTOMOTIVE: %d CYCLING: %d", motionActivity.unknown, motionActivity.stationary, motionActivity.walking, motionActivity.running, motionActivity.automotive, motionActivity.cycling);

    }

- (void)confidenceChanged:(CMMotionActivity*)motionActivity{
    NSLog(@"Confidence Changed");
    previousConfidence = motionActivity.confidence;
   
    NSString * activityInfoString = [NSString stringWithFormat:@"%@, confidence:%li",[self resolveActivityTypeofActivity:motionActivity], (long)motionActivity.confidence];
    NSLog(@"%@", activityInfoString);
    [self notifyByVoiceWithString:activityInfoString];
}
- (void)startNewSessionWithActivity:(CMMotionActivity*)activity{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    Activity * dbActivity = [Activity new];
    Session * dbSession = [Session new];
    dbSession.uniqueId = [[NSUUID UUID] UUIDString];
    dbActivity.uniqueId = [[NSUUID UUID] UUIDString];
    
    dbActivity.unknown =activity.unknown;
    dbActivity.stationary = activity.stationary;
    dbActivity.walking = activity.walking;
    dbActivity.running = activity.running;
    dbActivity.automotive = activity.automotive;
    dbActivity.cycling =    activity.cycling;
    dbActivity.startTime = activity.startDate;
    dbActivity.session = dbSession;
    
    dbSession.startTime = activity.startDate;
    currentSession = dbSession.uniqueId;
  //  currentActivity = dbActivity;
    
    [realm beginWriteTransaction];
    [realm addObject:dbSession];
    [realm commitWriteTransaction];
    NSLog(@"Created new Session with activity %@", activity);
}

- (void)persistNewActivity:(CMMotionActivity*)activity{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    Session *session = [Session objectInRealm:realm forPrimaryKey:currentSession];
    
    if (!session) {
        NSLog(@"No session");
        return;
    }
    Activity *dbActivity = [Activity new];
   
    NSLog(@"Will persist new ACTIVITY %@", activity);
    dbActivity.uniqueId = [[NSUUID UUID] UUIDString];
    
    dbActivity.unknown = activity.unknown;
    dbActivity.stationary = activity.stationary;
    dbActivity.walking = activity.walking;
    dbActivity.running = activity.running;
    dbActivity.automotive = activity.automotive;
    dbActivity.cycling =  activity.cycling;
    dbActivity.startTime = activity.startDate;
    dbActivity.session = session;
    
   
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:dbActivity];
    [realm commitWriteTransaction];
    currentActivity = dbActivity.uniqueId;
}

- (void)persistNewLocationForCurrentActivity:(CLLocation*)location{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    Activity * activity = [Activity objectInRealm:realm forPrimaryKey:currentActivity];
    
    Location * dbLocation = [Location new];
    dbLocation.timestamp = location.timestamp;
    dbLocation.longitude = location.coordinate.longitude;
    dbLocation.latitude = location.coordinate.latitude;
    dbLocation.horizontalAccuracy = location.horizontalAccuracy;
    dbLocation.verticalAccuracy = location.verticalAccuracy;
    dbLocation.speed = location.speed;
    dbLocation.course = location.course;
    dbLocation.activity = activity;
   
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:dbLocation];
    [realm commitWriteTransaction];
}

- (void) notifyByVoiceWithString:(NSString*)string{
    
    if ([_speechSyntesizer isSpeaking] ){
        [_speechSyntesizer stopSpeakingAtBoundary:0];
    }
    AVSpeechUtterance *utterance =[AVSpeechUtterance speechUtteranceWithString: string];
    _speechSyntesizer = [[AVSpeechSynthesizer alloc] init] ;
    [_speechSyntesizer speakUtterance:utterance];
}


@end
