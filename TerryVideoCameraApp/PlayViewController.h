//
//  PlayViewController.h
//  TerryVideoCameraApp
//
//  Created by travis holt on 12/28/14.
//  Copyright (c) 2014 TerryBuOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import "Video.h"

@interface PlayViewController : UIViewController


@property (nonatomic, strong) Video *video;


@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic, weak) IBOutlet PlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
- (IBAction)play:sender;
- (void)syncUI;


@end
