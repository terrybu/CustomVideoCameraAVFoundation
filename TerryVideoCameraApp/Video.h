//
//  Video.h
//  TerryVideoCameraApp
//
//  Created by travis holt on 12/28/14.
//  Copyright (c) 2014 TerryBuOrg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Video : NSObject

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSURL *uniqueURL;

@end
