//
//  PlayViewController.m
//  TerryVideoCameraApp
//
//  Created by travis holt on 12/28/14.
//  Copyright (c) 2014 TerryBuOrg. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()

@end

static const NSString *ItemStatusContext;

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  [self syncUI];
  
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.video.uniqueURL options:nil];
  NSString *tracksKey = @"tracks";
  
  [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
   ^{
     
     // Completion handler block.
     dispatch_async(dispatch_get_main_queue(),
                    ^{
                      NSError *error;
                      AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                      
                      if (status == AVKeyValueStatusLoaded) {
                        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                        // ensure that this is done before the playerItem is associated with the player
                        [self.playerItem addObserver:self forKeyPath:@"status"
                                             options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(playerItemDidReachEnd:)
                                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                                   object:self.playerItem];
                        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                        
                        [self.playerView setPlayer:self.player];
                      }
                      else {
                        // You should deal with the error appropriately.
                        NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                      }
                    });

   }];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.playerItem removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)syncUI {
  if ((self.player.currentItem != nil) &&
      ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
    self.playButton.enabled = YES;
  }
  else {
    self.playButton.enabled = NO;
  }
}


- (IBAction)play:sender {
  [self.player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
  
  if (context == &ItemStatusContext) {
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                     [self syncUI];
                   });
    return;
  }
  [super observeValueForKeyPath:keyPath ofObject:object
                         change:change context:context];
  return;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
  [self.player seekToTime:kCMTimeZero];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
