//
//  ViewController.h
//  SenkoHanabi
//
//  Created by lethe on 2013/09/04.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <GameKit/GameKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAccelerometerDelegate, GKPeerPickerControllerDelegate, GKSessionDelegate>
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
