//
//  HomeViewController.m
//  TerryVideoCameraApp
//
//  Created by travis holt on 12/28/14.
//  Copyright (c) 2014 TerryBuOrg. All rights reserved.
//

#import "HomeViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoThumbCell.h"
#import "Video.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface HomeViewController () {
  
  ALAssetsLibrary *library;
}

@property (nonatomic, strong) NSMutableArray* videos;
@property (nonatomic, strong) NSMutableSet *uniqueURLs;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.videos = [[NSMutableArray alloc]init];
  self.uniqueURLs = [[NSMutableSet alloc]init];
  
  library = [[ALAssetsLibrary alloc] init];
  
  [self findVideosMakeThumbsAddThemToDataArray];
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:NO];
  [self findVideosMakeThumbsAddThemToDataArray];
}

- (void) findVideosMakeThumbsAddThemToDataArray {
  // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
  [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    
    if (group) {
      // Within the group enumeration block, filter to enumerate just videos.
      [group setAssetsFilter:[ALAssetsFilter allVideos]];
      
      // For this example, we're only interested in the first item.
      [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *stop) {
        
        // The end of the enumeration is signaled by asset == nil.
        if (alAsset) {
          ALAssetRepresentation *representation = [alAsset defaultRepresentation];
          NSURL *url = [representation url];
          AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
          //check if we already dealt with this avAsset before, checking inclusion with url
          if ([self thisAssetIsSomethingWeHaveNotYetProcessed:url]) {
            AVAssetImageGenerator *imageGenerator =
            [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
            imageGenerator.appliesPreferredTrackTransform = YES;
            imageGenerator.maximumSize = CGSizeMake(320, 180);
            CMTime thumbTime = CMTimeMakeWithSeconds(0, 30);
            CMTime actualTime;
            NSError *error = nil;
            CGImageRef image = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
            UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
            
            Video *video = [[Video alloc]init];
            video.uniqueURL = url;
            video.thumbnailImage = thumb;
            [self.videos addObject:video];
            [self.uniqueURLs addObject:url];
            NSLog(@"done with imageGenerator converting thumb");
            dispatch_async(dispatch_get_main_queue(), ^{
              NSLog(@"reloading collectionview");
              [self.collectionView reloadData];
            });
          }
          else {
            NSLog(@"don't process - we did this one already");
          }
        }
      }];
    }
  }
 failureBlock: ^(NSError *error) {
   NSLog(@"error enumerating AssetLibrary groups %@\n", error);
 }];

}

- (BOOL) thisAssetIsSomethingWeHaveNotYetProcessed: (NSURL *) url {
  if ([self.uniqueURLs containsObject:url])
    return FALSE;
  return TRUE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.videos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  VideoThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  
  Video* video = [self.videos objectAtIndex:indexPath.row];
  cell.videoThumbImageview.image = video.thumbnailImage;
  
  return cell;
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id) delegate {
  // 1 - Validations
  if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
      || (delegate == nil)
      || (controller == nil)) {
    return NO;
  }
  // 2 - Get image picker
  UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
  cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
  // Displays a control that allows the user to choose movie capture
  cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
  // Hides the controls for moving & scaling pictures, or for
  // trimming movies. To instead show the controls, use YES.
  cameraUI.allowsEditing = NO;
  cameraUI.delegate = delegate;
  // 3 - Display image picker
  [controller presentViewController:cameraUI animated:YES completion:nil];
  return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
  [self dismissViewControllerAnimated:NO completion:nil];
  // Handle a movie capture
  if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
    NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
      UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self,
                                          @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
  }
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
  if (error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }
}

- (IBAction)recordRegularButton:(id)sender {
  [self startCameraControllerFromViewController:self usingDelegate:self];
  
}

- (IBAction)recordSlowMoButton:(id)sender {
  
}




@end
