//
//  PlayerView.m
//  TerryVideoCameraApp
//
//  Created by travis holt on 12/28/14.
//  Copyright (c) 2014 TerryBuOrg. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass {
  return [AVPlayerLayer class];
}
- (AVPlayer*)player {
  return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
  [(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
