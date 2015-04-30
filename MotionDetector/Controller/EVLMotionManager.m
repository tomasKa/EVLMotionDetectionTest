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
    RLMArray *activitiesArray;
    Session *activitySession;
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
        activityInfoString = @"None";
        NSLog(@"%@", motionActivity);
    }
    NSLog(@" \n UNKNNOWN :%d,STATIONARY: %d WALKING: %d RUNNING: %d AUTOMOTIVE: %d CYCLING: %d", motionActivity.unknown, motionActivity.stationary, motionActivity.walking, motionActivity.running, motionActivity.automotive, motionActivity.cycling);

    NSString * vocalString = [NSString stringWithFormat:@"%@ : %@",activityInfoString,confidenceString];
   
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

}

- (void)startNewSessionWithActivity:(CMMotionActivity*)activity{
    
    Activity * dbActivity = [Activity new];
    
    dbActivity.unknown =activity.unknown;
    dbActivity.stationary = activity.stationary;
    dbActivity.walking = activity.walking;
    dbActivity.running = activity.running;
    dbActivity.automotive = activity.automotive;
    dbActivity.cycling =    activity.cycling;
    dbActivity.startTime = activity.startDate;
    dbActivity.locations = nil;
    
    
    if (!activitySession || activitySession.activities.count< 1) {
        activitySession = [Session new];
        activitySession.startTime = activity.startDate;
        [activitySession.activities addObject:dbActivity];
    }
    
    else{
        [activitySession.activities addObject:dbActivity];
    }
    
    NSLog(@"Writing to realm");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MotionActivityChangedNotification" object:dbActivity];
}

- (void)commitSession:(Session*)session WithActivitiesArray:(RLMArray*)array{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:session];
    [realm commitWriteTransaction];
}

- (void) notifyByVoiceWithString:(NSString*)string{
    
        AVSpeechUtterance *utterance =[AVSpeechUtterance speechUtteranceWithString: string];
        _speechSyntesizer = [[AVSpeechSynthesizer alloc] init] ;
        [_speechSyntesizer speakUtterance:utterance];
}

@end
