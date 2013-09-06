//
//  ViewController.m
//  SenkoHanabi
//
//  Created by lethe on 2013/09/04.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "fadeObject.h"
#import "fire.h"

@interface ViewController ()

@end
@implementation ViewController

UILabel *titleLabel;
UILabel *howLabel;
UIImageView *senkoImage;
UIImageView *hinotamaImage;

NSArray *imageNames;
NSArray *textNames;
fadeObject *showFadeObject;
NSMutableArray *fadeSelects;
int fadeselect = 0;

ALAssetsLibrary* assetsLibrary;
NSMutableArray *assets;
NSMutableDictionary *assetsURL;
int assetsflg = 0;

NSMutableArray* fires;

UIButton *nextButton;
UIButton *addimageButton;

int senkoTime = 50;//線香が落ちるまでの時間
int isTapped = 0;//タップしたか
int initLaunch = 1;//最初の起動かどうか

CMMotionManager *manager;//センサオブジェクト

CGFloat prevAngle = 0.0f;
CGFloat prevprevAngle = 0.0f;

int sceneNumber;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageNames = [NSArray arrayWithObjects:@"fade1.png",@"fade2.png", nil];
    textNames = [NSArray arrayWithObjects:@"気づいたら\nカラオケで\n\n\n\nざこ寝",
                 @"セミの\n\n\n\n\n\n抜け殻",
                 @"プールで\n監視員に\n\n\n\n怒られる",nil];
    assetsURL = [NSMutableDictionary dictionary];
    assets = [NSMutableArray array];
    fadeSelects = [self randomList:[imageNames count] + [textNames count] + [assets count]];
    
    /*fadeImages = [NSMutableArray array];
    for(int i = 0; i < [imageNames count]; i++){
        UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNames[i]]];
        [fadeImages addObject:img];
    }*/
    
    fires = [NSMutableArray array];
    
    sceneNumber = 1;
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(view_Tapped:)];
    
    // ビューにジェスチャーを追加
    [self.view addGestureRecognizer:tapGesture];
    
    //センサー設定
    manager = [[CMMotionManager alloc] init];
    // 現在、加速度センサー無しのデバイスは存在しないが念のための確認
    if (!manager.accelerometerAvailable) {
        manager = nil;
    }
    
    //ループ開始
    [NSTimer scheduledTimerWithTimeInterval:0.03f
                                     target:self
                                   selector:@selector(loop)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)loop{
    if(manager){
        [manager startAccelerometerUpdates];
    }
    
    switch (sceneNumber) {
        case 1://「線香花火」設定
            if(!titleLabel){
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,50,320,100)];
                titleLabel.font = [UIFont fontWithName:@"Hiragino Mincho ProN" size:40];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.text = @"線香花火";
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.alpha = 0.0f;
                [self.view addSubview:titleLabel];
            }else{
                titleLabel.alpha = 0.0f;
            }
            
            sceneNumber = 2;
            break;
            
        case 2://「線香花火」表示アニメ
            titleLabel.alpha += 0.02f;
            if(1.0f < titleLabel.alpha || isTapped){
                sceneNumber = 3;
            }
            break;
        case 3://「線香花火」隠蔽アニメ、線香花火設定、「遊び方」設定
            titleLabel.alpha -= 0.02f;
            if(titleLabel.alpha < 0.0f){
                // 線香花火の画像
                if(!senkoImage){
                    senkoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"senkohanabi.png"]];
                    senkoImage.layer.anchorPoint = CGPointMake(0.5, 0); // (170, -10)が回転の原点
                    // ハードコーディングすると火種の処理で困りそう
                    senkoImage.frame = CGRectMake(140, -10, 61, 337);//122 × 675
                    senkoImage.alpha = 0.0f;
                    [self.view addSubview:senkoImage];
                }else{
                    senkoImage.alpha = 0.0f;
                }
                
                // 火種の画像
                if(!hinotamaImage){
                    hinotamaImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hinotama.png"]];
                    hinotamaImage.layer.anchorPoint = CGPointMake(0.5, -13.6); // 直すべき
                    hinotamaImage.frame = CGRectMake(141, 305, 120/6, 140/6);
                    hinotamaImage.alpha = 0.0f;
                    [self.view addSubview:hinotamaImage];
                }else{
                    hinotamaImage.alpha = 0.0f;
                }

                // 「遊び方」
                if(!howLabel){
                    howLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,50,320,300)];
                    howLabel.font = [UIFont fontWithName:@"Hiragino Mincho ProN" size:40];
                    howLabel.textAlignment = NSTextAlignmentCenter;
                    howLabel.text = @"遊び方\nそんなこんなで\nそんなこんなやで";
                    howLabel.backgroundColor = [UIColor clearColor];
                    howLabel.textColor = [UIColor whiteColor];
                    howLabel.numberOfLines = 3;
                    howLabel.alpha = 0.0f;
                    [self.view addSubview:howLabel];
                }else{
                    howLabel.alpha = 0.0f;
                }
                
                sceneNumber = 4;
            }
            break;
        case 4://線香花火アニメ、「遊び方」表示アニメ
            senkoImage.alpha += 0.02f;
            hinotamaImage.alpha += 0.02f;
            if(initLaunch){
                howLabel.alpha += 0.02f;
            }
            
            if(3.0f < howLabel.alpha){
                senkoImage.alpha = 1.0f;
                hinotamaImage.alpha += 1.0f;
                howLabel.alpha = 1.0f;
                sceneNumber = 5;
            }
            if( isTapped || (!initLaunch && 1.0f < senkoImage.alpha) ){
                senkoImage.alpha = 1.0f;
                hinotamaImage.alpha += 1.0f;
                howLabel.alpha = 0.0f;
                sceneNumber = 6;
            }
            break;
        case 5://「遊び方」隠蔽アニメ
            howLabel.alpha -= 0.02f;
            if(howLabel.alpha < 0.0f || isTapped){
                senkoImage.alpha = 1.0f;
                hinotamaImage.alpha += 1.0f;
                howLabel.alpha = 0.0f;
                fadeselect = 0;
                sceneNumber = 6;
            }
            break;
        case 6:
            //火花作成、Do
        {
            int r = (rand() % 2);
            if( r == 0 ){
                int kind = (rand() % 4) + 2;
                CGFloat angle = ((-manager.accelerometerData.acceleration.x* 90.0f * M_PI / 180.0f) + prevAngle + prevprevAngle) / 3.0f;
                angle = -angle - 0.15f;
                float nx = 160 + 320 * sin(angle);
                float ny = 330 * cos(angle);
                /*fire* f = [[fire alloc] initWithObject:[[UIImageView alloc]
                                                        initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"hibana%d.png", kind]]] view:self.view point:CGPointMake(nx, ny)];
                [fires addObject:f];*/
            }
            
            for(int i = 0; i < [fires count]; i++){
                fire* f = fires[i];
                [f Do];
                if(f.deleteFlg){
                    [fires removeObject:f];
                    i--;
                }
            }
        }
            
            //フェードオブジェクト削除
            if(showFadeObject.deleteFlg){
                showFadeObject = nil;
            }
            //フェードオブジェクト追加
            if(!showFadeObject){
                int i = [fadeSelects[fadeselect] intValue];
                if( i < [imageNames count]){
                    //画像の追加
                    showFadeObject =
                    [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNames[i]]] view:self.view];
                }else if(i - [imageNames count] < [textNames count]){
                    //文字の追加
                    showFadeObject =
                    [[fadeObject alloc] initWithString:textNames[i - [imageNames count]] view:self.view];
                }else{
                    ALAsset *asset = assets[i - [imageNames count] - [textNames count]];
                    UIImage *img = [UIImage imageWithCGImage:[asset thumbnail]];
                    
                    /*ALAssetRepresentation *representation = [asset defaultRepresentation];
                    UIImage *img = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                                       scale:[representation scale]
                                                 orientation:[[asset valueForProperty:@"ALAssetPropertyOrientation"] intValue]];*/
                    showFadeObject =
                    [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:img] view:self.view];
                }
                fadeselect = (fadeselect + 1) % ([imageNames count] + [textNames count] + [assets count]);
            }
            //フェードオブジェクトアニメーション
            [showFadeObject Do];
            
            if(senkoTime-- < 0){
                sceneNumber = 7;
            }
            break;
        case 7:
            //フェードオブジェクト削除
            [showFadeObject DeleteDo];
            if(showFadeObject.deleteFlg){
                showFadeObject = nil;
            }
            //火花オブジェクト消し
            for(int i = 0; i < [fires count]; i++){
                fire* f = fires[i];
                [f Do];
                if(f.deleteFlg){
                    [fires removeObject:f];
                    i--;
                }
            }
            //線香花火消し
            senkoImage.alpha -= 0.01f;
            
            //全部消えたら
            if([fires count] == 0 && !showFadeObject && senkoImage.alpha < 0.0f){
                //もう一度ボタン
                if(!nextButton){
                    UIImage *img = [UIImage imageNamed:@"again2.gif"];
                    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(160-75, 230, 150, 45)];
                    [nextButton setBackgroundImage:img forState:UIControlStateNormal];
                    [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:nextButton];
                }else{
                    [nextButton setHidden:NO];
                }
                //画像追加ボタン
                if(!addimageButton){
                    UIImage *img = [UIImage imageNamed:@"addPicture2.gif"];
                    addimageButton = [[UIButton alloc] initWithFrame:CGRectMake(160-75, 350, 150, 45)];
                    [addimageButton setBackgroundImage:img forState:UIControlStateNormal];
                    [addimageButton addTarget:self action:@selector(addimageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:addimageButton];
                }else{
                    [addimageButton setHidden:NO];
                }
                
                if(assetsflg){
                    assetsflg = 0;
                }
                
            }
            break;
        case 8:
            senkoTime = 400;
            [nextButton setHidden:YES];
            [addimageButton setHidden:YES];
            initLaunch = 0;
            fadeSelects = [self randomList:([imageNames count] + [textNames count] + [assets count])];
            fadeselect = 0;
            sceneNumber = 3;
            break;
    }
    
    //線香花火がある間
    if(4 <= sceneNumber && sceneNumber <= 8){
        if(manager){
            // 角度には平滑化した値を使用
            CGFloat angle = ((-manager.accelerometerData.acceleration.x* 90.0f * M_PI / 180.0f) + prevAngle + prevprevAngle) / 3.0f;
            
            prevprevAngle  = prevAngle;
            prevAngle = (-manager.accelerometerData.acceleration.x* 90.0f * M_PI / 180.0f);
            
            senkoImage.transform = CGAffineTransformMakeRotation(angle);
            hinotamaImage.transform = CGAffineTransformMakeRotation(angle);
            
        }
    }
    
    isTapped = 0;
}

//もう一度ボタン　タップ
- (void)nextButtonTapped:(UIButton *)button{
    sceneNumber = 8;
}

//画像選択ボタン　タップ
- (void)addimageButtonTapped:(UIButton *)button{
    if(!assetsLibrary){
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    NSDate *startDate = [NSDate date];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group){
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSDate* d = [result valueForProperty:ALAssetPropertyDate];
                    NSCalendar *cal = [NSCalendar currentCalendar];
                    NSDateComponents *dcom = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:d];
                    if( 6 <= dcom.month && dcom.month <= 9){
                        NSString *URL = [[result valueForProperty:ALAssetPropertyURLs] objectForKey:[[result defaultRepresentation] UTI]];
                        if(!assetsURL[URL]){
                            [assets addObject:result];
                            assetsURL[URL] = [NSNumber numberWithBool:1];
                        }
                    }
                }else{
                    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
                    NSLog(@"time is %lf (sec)", interval);
                    NSLog(@"終了！");
                    assetsflg = 1;
                }
            };
            
            NSLog(@"%d", [group numberOfAssets]);
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        NSLog(@"Error");
    };
    
    // iphoneに保存された全てのGroupを取得する
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:listGroupBlock failureBlock:failureBlock];
}


//画像選択完了
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//画像選択キャンセル
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//ビュー　タップ
- (void)view_Tapped:(UITapGestureRecognizer *)sender
{
    isTapped = 1;
}
- (NSMutableArray*)randomList:(int)max
{
    NSMutableArray *inList  = [[NSMutableArray alloc] init];
    NSMutableArray *outList = [[NSMutableArray alloc] init];
    int j = 0;
    int randomNumber = 0;
    for (int i=0; i<max; i++)
    {
        NSNumber *nsNum = [NSNumber numberWithInt:i];
        [inList insertObject:nsNum atIndex:i];
    }
    
    // 現在の日時を用いて乱数を初期化する
    srand([[NSDate date] timeIntervalSinceReferenceDate]);
    
    int inListL = [inList count];
    while (inListL){
        randomNumber = rand() % (max-j);
        
        NSNumber *nm_ = [inList objectAtIndex:randomNumber];
        [outList addObject:nm_];
        [inList removeObjectAtIndex:randomNumber];
        j++;
        inListL = [inList count];
        NSLog(@"%d:%d",inListL,[nm_ intValue]);
    }
    return outList;
}


-(void)viewDidAppear:(BOOL)animated{
    // センサーの停止
    if (manager.accelerometerActive) {
        [manager stopAccelerometerUpdates];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
