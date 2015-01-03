//
//  SlowMotionRecordViewController.m
//  TerryVideoCameraApp
//
//  Created by travis holt on 1/2/15.
//  Copyright (c) 2015 TerryBuOrg. All rights reserved.
//

#import "SlowMotionRecordViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SlowMotionRecordViewController () {
  NSTimeInterval startTime;
  BOOL isNeededToSave;
}

@property (nonatomic, strong) AVCaptureManager *captureManager;

@end

@implementation SlowMotionRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.captureManager = [[AVCaptureManager alloc] initWithPreviewView:self.view];
  self.captureManager.delegate = self;
  [self.captureManager switchFormatWithDesiredFPS:120.0];

  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// =============================================================================
#pragma mark - AVCaptureManagerDeleagte

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
  
  if (error) {
    NSLog(@"error:%@", error);
    return;
  }
  
  if (!isNeededToSave) {
    return;
  }
  
  [self saveRecordedFile:outputFileURL];
}

- (void)saveRecordedFile:(NSURL *)recordedFile {
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary writeVideoAtPathToSavedPhotosAlbum:recordedFile
                                     completionBlock:
     ^(NSURL *assetURL, NSError *error) {
       
       dispatch_async(dispatch_get_main_queue(), ^{
         
         NSString *title;
         NSString *message;
         
         if (error != nil) {
           
           title = @"Failed to save video";
           message = [error localizedDescription];
         }
         else {
           title = @"Saved!";
           message = nil;
         }
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
       });
     }];
  });
}

- (IBAction)startRecording:(id)sender {
  // REC START
  if (!self.captureManager.isRecording) {
    
    [self.captureManager startRecording];
  }
  // REC STOP
  else {
    
    isNeededToSave = YES;
    [self.captureManager stopRecording];
  
  }

}
@end
