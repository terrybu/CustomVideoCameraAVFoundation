//
//  HomeViewController.h
//  TerryVideoCameraApp
//
//  Created by travis holt on 12/28/14.
//  Copyright (c) 2014 TerryBuOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCaptureManager.h"


@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate;

-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

- (IBAction)recordRegularButton:(id)sender;


@end
