//
//  EVLMotionManager.m
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import "EVLMotionManager.h"

@implementation EVLMotionManager
{
    NSInteger previousConfidence;
    CMMotionActivity *previousActivity;
}

- (void)startActivityDetection{
    
    _activityManager = [CMMotionActivityManager new];
    
    [_activityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity *activity) {
        
        if (!previousActivity) {
            previousActivity = [CMMotionActivity new];
        }
        
        if (activity.unknown != previousActivity.unknown || activity.stationary != previousActivity.stationary || activity.walking != previousActivity.walking || activity.running != previousActivity.running || activity.automotive != previousActivity.automotive ||activity.cycling != previousActivity.cycling) {
            [self performSelector:@selector(updateActivityWithActivity:) withObject:activity];
        }
        if (activity.confidence != previousActivity.confidence) {
            [self performSelector:@selector(onlyConfidenceChanged:) withObject:activity];
        }
        
        if (activity.confidence == CMMotionActivityConfidenceHigh) {
            [self startNewSessionWithActivity:activity];
        }

        
       // [self performSelector:@selector(updateActivityWithActivity:) withObject:activity];
    }];
}

- (void)updateActivityWithActivity:(CMMotionActivity*)motionActivity{
    
    
    NSString * activityInfoString = [NSString new];
    NSString * confidenceString = [NSString new];
    if (!previousActivity) {
        previousActivity = [CMMotionActivity new];
    }
    previousConfidence = motionActivity.confidence;

    previousActivity = motionActivity;

    if (motionActivity.confidence== CMMotionActivityConfidenceHigh) {
        confidenceString = @"DEFINETELY ";
           }
    if (motionActivity.confidence== CMMotionActivityConfidenceMedium){
        confidenceString = @"PROBABLY ";
        
    }
    if (motionActivity.confidence==CMMotionActivityConfidenceLow) {
        confidenceString = @"UNLIKELY...";
    }
    
    if (motionActivity.stationary) {
        activityInfoString = [NSString stringWithFormat:@"stationary"];;
    
    }
    if (motionActivity.walking) {
       activityInfoString = [NSString stringWithFormat:@"walking"];

    }
    if (motionActivity.running) {
        activityInfoString = [NSString stringWithFormat:@"running"];
        
    }
    if (motionActivity.automotive) {
        activityInfoString = [NSString stringWithFormat:@"automotive"];
        
    }
    if (motionActivity.cycling) {
       activityInfoString = [NSString stringWithFormat:@"cycling"];
        
    }
    if (motionActivity.unknown) {
       activityInfoString = [NSString stringWithFormat:@"unknown"];
    }
    
    if (!motionActivity.unknown && !motionActivity.cycling && !motionActivity.running && !motionActivity.walking && !motionActivity.stationary){
        activityInfoString = @"NOTHING";
        NSLog(@"%@", motionActivity);
    }
    NSLog(@" \n UNKNNOWN :%d,STATIONARY: %d WALKING: %d RUNNING: %d AUTOMOTIVE: %d CYCLING: %d", motionActivity.unknown, motionActivity.stationary, motionActivity.walking, motionActivity.running, motionActivity.automotive, motionActivity.cycling);

    NSString * vocalString = [NSString stringWithFormat:@" New activity: %@ | %@", confidenceString, activityInfoString];
   
    NSLog(@"%@", vocalString);

       AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:vocalString];
    if ([_speechSyntesizer isSpeaking] ){
        [_speechSyntesizer stopSpeakingAtBoundary:0];
    }
    _speechSyntesizer = [[AVSpeechSynthesizer alloc] init] ;
    [_speechSyntesizer speakUtterance:utterance];
    
}

- (void)onlyConfidenceChanged:(CMMotionActivity*)motionActivity{
    
    
    NSLog(@"Only conficenceChanged to %li", (long)motionActivity.confidence);
    previousConfidence = motionActivity.confidence;
   
    NSString * activityInfoString = [NSString new];
    NSString * confidenceString = [NSString new];

    if (motionActivity.confidence== CMMotionActivityConfidenceHigh) {
        confidenceString = @"DEFINETELY ";
    }
    if (motionActivity.confidence== CMMotionActivityConfidenceMedium){
        confidenceString = @"PROBABLY ";
        
    }
    if (motionActivity.confidence==CMMotionActivityConfidenceLow) {
        confidenceString = @"UNLIKELY...";
    }
    NSLog(@"%@", confidenceString);

    if (motionActivity.stationary) {
        activityInfoString = [NSString stringWithFormat:@"stationary"];;
        
    }
    if (motionActivity.walking) {
        activityInfoString = [NSString stringWithFormat:@"walking"];
        
    }
    if (motionActivity.running) {
        activityInfoString = [NSString stringWithFormat:@"running"];
        
    }
    if (motionActivity.automotive) {
        activityInfoString = [NSString stringWithFormat:@"automotive"];
        
    }
    if (motionActivity.cycling) {
        activityInfoString = [NSString stringWithFormat:@"cycling"];
        
    }
    if (motionActivity.unknown) {
        activityInfoString = [NSString stringWithFormat:@"unknown"];
    }
    
    if (!motionActivity.unknown && !motionActivity.cycling && !motionActivity.running && !motionActivity.walking && !motionActivity.stationary){
        activityInfoString = @"NOTHING";
    }
    
    NSLog(@"%@", activityInfoString);

//    
//    AVSpeechUtterance *utterance =[AVSpeechUtterance speechUtteranceWithString: @"confidence changed"];
//    _speechSyntesizer = [[AVSpeechSynthesizer alloc] init] ;
//    [_speechSyntesizer speakUtterance:utterance];

}

- (void)startNewSessionWithActivity:(CMMotionActivity*)activity{
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    
    
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    Activity * dbActivity = [Activity new];
    dbActivity.unknown =activity.unknown;
    dbActivity.stationary = activity.stationary;
    dbActivity.walking = activity.walking;
    dbActivity.running = activity.running;
    dbActivity.automotive = activity.automotive;
    dbActivity.cycling =    activity.cycling;
    dbActivity.startTime = activity.startDate;
    dbActivity.locations = nil;
    
    Session * dbSession = [Session new];
    [dbSession.activities addObject:dbActivity];
    dbSession.startTime = activity.startDate;
  
        [realm beginWriteTransaction];
    [realm addObject:dbSession];
    [realm commitWriteTransaction];
    NSLog(@"Writing to realm");
    [notificationCenter postNotificationName:@"MotionActivityChangedNotification" object:dbActivity];
}

@end
