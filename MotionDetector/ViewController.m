//
//  ViewController.m
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import "ViewController.h"
#import "EVLMotionManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uppdateInterfaceWithActivity:) name:@"MotionActivityChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uppdateInterfaceWithActivity:) name:@"MotionActivityConfidenceChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uppdateInterfaceWithActivity:) name:@"SessionActivityStatusChangedToNotification" object:nil];
   }

- (void)uppdateInterfaceWithActivity:(NSNotification*)notification{
    
        NSLog(@"Updating viewController UI with Activity %@",notification.object);
    if (!notification.object) {
        NSLog(@"Notification object not found");
        return;
    }
    if ([notification.name isEqual:@"MotionActivityConfidenceChangedNotification"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            _activityConfidenceLabel.text = notification.object;
        });
    }
    if ([notification.name isEqual:@"MotionActivityChangedNotification"]){
    dispatch_async(dispatch_get_main_queue(), ^{
        _activityTypeLabel.text = notification.object;
        _currentActivityDurationLabel.text = [[self timeFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    });
    }
    if ([notification.name isEqual:@"SessionActivityStatusChangedToNotification"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            _sessionActivityStatusLabel.text = notification.object;
            _sessionDurationLabel.text = [[self timeFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        });
    }
}

- (NSDateFormatter*)timeFormatter{
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"hh:mm:ss";
    return formatter;
    
}
- (void)timerLabel{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
