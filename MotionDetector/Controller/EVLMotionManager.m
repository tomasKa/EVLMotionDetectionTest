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
   
    Activity *currentActivity;
    Session *activitySession;
    Location *currentLocation;
}
- (void)startActivityDetection{
    
        _activityManager = [CMMotionActivityManager new];
    
    [_activityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity *activity) {
       
        if (!previousActivity) {
            previousActivity = [CMMotionActivity new];
                
        }
        if (activity.unknown != previousActivity.unknown || activity.stationary != previousActivity.stationary || activity.walking != previousActivity.walking || activity.running != previousActivity.running || activity.automotive != previousActivity.automotive ||activity.cycling != previousActivity.cycling) {
            //New activity
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

    [self notifyByVoiceWithString:vocalString];
    
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
    dbActivity.cycling =  activity.cycling;
    dbActivity.startTime = activity.startDate;
    dbActivity.locations = nil;
    
    currentActivity = dbActivity;
    
    if (!activitySession || activitySession.activities.count< 1) {
       
        activitySession = [Session new];
        activitySession.startTime = activity.startDate;
        [activitySession.activities addObject:dbActivity];
    }
    else{
        [activitySession.activities addObject:dbActivity];
    }

    
    [self startLocatonUpdates];
    [self commitSession:activitySession];
    activitySession = nil;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MotionActivityChangedNotification" object:dbActivity];
}

//----------------------------------------------------------------------------------------
#pragma mark Core Location handling and  Delegate methods
//----------------------------------------------------------------------------------------

- (void)startLocatonUpdates{
   
    if ([CLLocationManager locationServicesEnabled]){
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
        NSLog(@"Starting Location updates...");

    }
    else{
        
        NSLog(@"Location services not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
   
    NSLog(@" OLD LOC: Lat: %f Lon: %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@" NEW LOC: Lat: %f Lon: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    Location *currentLocation = [Location new];
    currentLocation.timestamp = newLocation.timestamp;
    currentLocation.latitude = newLocation.coordinate.latitude;
    currentLocation.longitude = newLocation.coordinate.longitude;
    currentLocation.speed = newLocation.speed;
   
    //Add Location Object to Activity
    NSLog(@"Need to add location to activity array location is %@", currentLocation);
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location manager failed with error: %@", error);
    
}

- (void) stopLocationUpdates{
    
    NSLog(@"Stopping Location updates");
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
    }
}

//----------------------------------------------------------------------------------------
#pragma mark Helper methods
//----------------------------------------------------------------------------------------


- (void)commitSession:(Session*)session{
    NSLog(@"Writing to realm");
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:session];
    [realm commitWriteTransaction];
    
    [activitySession.activities removeAllObjects];
}

- (void) notifyByVoiceWithString:(NSString*)string{
//    
//        AVSpeechUtterance *utterance =[AVSpeechUtterance speechUtteranceWithString: string];
//        _speechSyntesizer = [[AVSpeechSynthesizer alloc] init] ;
//        [_speechSyntesizer speakUtterance:utterance];
}

@end
