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
    
    EVLMotionManager *motionManager = [EVLMotionManager new];
    [motionManager startActivityDetection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uppdateInterfaceWithActivity:) name:@"MotionActivityChangedNotification" object:nil];
}

- (void)uppdateInterfaceWithActivity:(NSNotification*)notification{
    
          NSLog(@"Updating viewController UI with Activity %@",notification );
        NSDateFormatter * formatterTime = [NSDateFormatter new];
        formatterTime.dateFormat = @"hh : mm : ss";
        _currentActivityDurationLabel.text = [formatterTime stringFromDate:[notification.object valueForKey:@"startTime"]];
    
    
}

- (void)timerLabel{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
