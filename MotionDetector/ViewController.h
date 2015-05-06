//
//  ViewController.h
//  MotionDetector
//
//  Created by Tomas Kamarauskas on 28/04/15.
//  Copyright (c) 2015 EEVOL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "EVLMotionManager.h"

@interface ViewController : UIViewController



@property (weak, nonatomic) IBOutlet UILabel *activityTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentActivityDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *sessionDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityConfidenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sessionActivityStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataSummaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *persistedActivityInfoLabel;

@end

