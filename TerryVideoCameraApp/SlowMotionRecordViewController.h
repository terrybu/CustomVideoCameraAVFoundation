//
//  SlowMotionRecordViewController.h
//  TerryVideoCameraApp
//
//  Created by travis holt on 1/2/15.
//  Copyright (c) 2015 TerryBuOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCaptureManager.h"

@interface SlowMotionRecordViewController : UIViewController <AVCaptureManagerDelegate>

- (IBAction)startRecording:(id)sender;

@end
