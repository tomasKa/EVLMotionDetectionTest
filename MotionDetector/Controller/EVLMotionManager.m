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
@import CoreLocation;

@implementation EVLMotionManager
{
    NSInteger previousConfidence;
    CMMotionActivity *previousActivity;
   
    NSString *currentActivity;
    NSString  *currentSession;
}

- (id)init {
    if (self = [super init]) {
        
        //Location manager
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        //Motion manager
        self.activityManager = [[CMMotionActivityManager alloc] init];
        
        
    }
    return self;
}

- (void)startActivityDetection{
  
   
    [_activityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity *activity) {
        
            if (!previousActivity) {
                previousActivity = [CMMotionActivity new];
            }
            if (activity.unknown != previousActivity.unknown || activity.stationary != previousActivity.stationary || activity.walking != previousActivity.walking || activity.running != previousActivity.running || activity.automotive != previousActivity.automotive ||activity.cycling != previousActivity.cycling) {
                
                [self updateActivityWithNewActivity:activity];
            }
            if (activity.confidence != previousActivity.confidence) {
                
                [self confidenceChanged:activity];
            }
        
            if (activity.confidence == CMMotionActivityConfidenceHigh) {
                
                if (!currentSession){
                    [self startNewSessionWithActivity:activity];
                    [self startLocationDetection];
                }
                else{
                    
                    [self persistNewActivity:activity];
                }
            }
            else if(activity.confidence == CMMotionActivityConfidenceHigh && !activity.stationary){
                
                NSLog(@"Activity is not stationary");
                currentSession = nil;
                
            }
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MotionActivityChangedNotification" object:[self resolveActivityTypeofActivity:activity]];
    }];
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

//---------------------------------------------------------------------------
#pragma mark - Core Motion handling and delegate methods
//---------------------------------------------------------------------------


- (void)updateActivityWithNewActivity:(CMMotionActivity*)motionActivity{
    
    if (!previousActivity) {
        previousActivity = [CMMotionActivity new];
    }
    previousConfidence = motionActivity.confidence;
    previousActivity = motionActivity;
}

- (void)confidenceChanged:(CMMotionActivity*)motionActivity{
    NSLog(@"Confidence Changed");
    previousConfidence = motionActivity.confidence;
   
    NSString * activityInfoString = [NSString stringWithFormat:@"%@, confidence:%li",[self resolveActivityTypeofActivity:motionActivity], (long)motionActivity.confidence];
    NSLog(@"%@", activityInfoString);
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
    currentActivity = dbActivity.uniqueId;
    
    [realm beginWriteTransaction];
    [realm addObject:dbSession];
    [realm commitWriteTransaction];
    NSLog(@"Created new Session with activity %@", activity);
}

- (void)stopCurrentSession{
    
    
}


//---------------------------------------------------------------------------
#pragma mark - Location handling and delegate methods
//---------------------------------------------------------------------------

- (void)startLocationDetection{
    
        if ([CLLocationManager locationServicesEnabled]){
            
            NSLog(@"Start updating locations  ");
            [self.locationManager  startUpdatingLocation];
        }
        else {
        //Location services are not enabled.prompt the user to enable the location services
        NSLog(@"Location services are not enabled, show notification to the user");
        }
}

- (void)stopLocationDetection{
    if (self.locationManager){
        
        [self.locationManager stopUpdatingLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    [self persistNewLocationForCurrentActivity:location];
    
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"Location manager failed error:%@", error);
}
    


//---------------------------------------------------------------------------
#pragma mark - Persisting methods
//---------------------------------------------------------------------------

- (void)persistNewActivity:(CMMotionActivity*)activity{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    Session *session = [Session objectInRealm:realm forPrimaryKey:currentSession];
    if (!session) {
        NSLog(@"Error: No Session");
        return;
    }
    Activity *dbActivity = [Activity new];
   
    dbActivity.uniqueId = [[NSUUID UUID] UUIDString];
    currentActivity = dbActivity.uniqueId;
   
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
    NSLog(@"Location persisted to activity %@", [self resolveActivityTypeofActivity:activity]);
    
}

- (void)persistNewLocationForCurrentActivity:(CLLocation *)location{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSLog(@"Persisting new location...");
    
    if (currentActivity) {
        Activity * activity = [Activity objectInRealm:realm forPrimaryKey:currentActivity];
        if (!activity) {
            NSLog(@"Error: No Current Activity");
            return;
        }
        Location * dbLocation = [Location new];
        
        dbLocation.uniqueId = [[NSUUID UUID] UUIDString];
        dbLocation.timestamp = location.timestamp;
        dbLocation.longitude = location.coordinate.longitude;
        dbLocation.latitude = location.coordinate.latitude;
        dbLocation.horizontalAccuracy = location.horizontalAccuracy;
        dbLocation.verticalAccuracy = location.verticalAccuracy;
        dbLocation.speed = location.speed;
        dbLocation.course = location.course;
        dbLocation.activity = activity;
        dbLocation.locationDescription = location.description;
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:dbLocation];
        [realm commitWriteTransaction];
        NSLog(@"Location Persisted!");
    }
    else if (!currentActivity){
        
        NSLog(@" No Current Activity, cannot persist");
        
    }
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
