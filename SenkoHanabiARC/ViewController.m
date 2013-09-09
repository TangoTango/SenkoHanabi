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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "fadeObject.h"
#import "fire.h"
#import "fireFlower.h"
#import "fadeView.h"
#import "Bgm.h"

@interface ViewController ()

@end
@implementation ViewController

fadeView *title;
UILabel *titleLabel; // タイトルのラベル
UILabel *howLabel; // 「遊び方」のラベル
UIImageView *senkoImage; // 線香花火の画像
UIImageView *hinotamaImage;
UILabel* addLabel; // 「画像を追加」ボタンを押したときのメッセージのラベル
//CALayer* hi; // 火種のレイヤ
bool hiFlg = NO; // 火種が落ちたかどうか

NSArray *imageNames; // 現れて消えるアニメーション画像の配列
NSArray *textNames; // 現れて消えるテキストの配列
fadeObject *showFadeObject; //
NSMutableArray *fadeSelects;
int fadeselect = 0;

ALAssetsLibrary* assetsLibrary;
NSMutableArray *assets;
NSMutableDictionary *assetsURL;
int assetsflg = 0;
int addAssetsCount;//追加時Assetカウント
int addedAssetsCount;//追加時追加済Assetカウント
int initAssetsCount;//起動時Assetカウント

NSMutableArray* fires;
NSMutableArray* fireFlowers;

UIButton *nextButton;
UIButton *addimageButton;

int senkoTime = 5000;//線香が落ちるまでの時間
int isTapped = 0;//タップしたか
int initLaunch = 1;//最初の起動かどうか

CMMotionManager *manager;//センサオブジェクト
NSMutableArray* prevAccelerations;//センサデータ記録

//CGFloat prevAngle = 0.0f;
//CGFloat prevprevAngle = 0.0f;

CGFloat senkoRelativeX = 11.0f;//線香花火の火種の相対座標(画像と表示サイズに依存)
CGFloat senkoRelativeY = 326.0f;
CGFloat senkoOriginalW = 61.0f;//線香花火のサイズ(回転したら取得できなくなるので)
CGFloat senkoOriginalH = 337.0f;
CGFloat senkoAngle;
int senkoCount;
int fireScene;
CGPoint hidanePoint;
CGFloat hidaneAX, hidaneAY, hidaneVX, hidaneVY;

int sceneNumber;

Bgm* sparkBgm;
bool soundFlg = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //火花
    fires = [NSMutableArray array];
    //火花の花
    fireFlowers = [NSMutableArray array];
    
    //シーン1
    sceneNumber = 1;
    
    // ビューにジェスチャーを追加
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(view_Tapped:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //センサー設定
    manager = [[CMMotionManager alloc] init];
    // 現在、加速度センサー無しのデバイスは存在しないが念のための確認
    if (!manager.accelerometerAvailable) {
        manager = nil;
    }
    prevAccelerations = [NSMutableArray array];
    
    //フェードオブジェクト(テキスト、画像の名前、Asset)読み込み
    imageNames = [NSArray arrayWithObjects:@"fade1.png",@"fade2.png", nil];
    textNames = [NSArray arrayWithObjects:@"気づいたら\nカラオケで\n\n\n\nざこ寝",
                 @"セミの\n\n\n\n\n\n抜け殻",
                 @"プールで\n監視員に\n\n\n\n怒られる",
                 @"好きな子と\n友達が\n\n\n\n付き合ってた",
                 @"お祭り\n\n\n\n\n騒ぎ",
                 @"山\n\n\n\n\nガール",nil];
    
    //既に写真を追加したか確認して読み込み
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    assetsURL = [ud objectForKey:@"assetsURL"];
    assets = [NSMutableArray array];
    if(assetsURL){
        initAssetsCount = 0;
        for (NSString* URLstr in assetsURL) {
            NSURL* URL = [NSURL URLWithString:URLstr];
            assetsLibrary = [self.class defaultAssetsLibrary];
            [assetsLibrary assetForURL:URL
                           resultBlock:^(ALAsset *asset) {
                               initAssetsCount++;
                               if(asset){
                                   [assets addObject:asset];
                               }
                               if(initAssetsCount == [assetsURL count]){
                                   fadeSelects = [self randomList:[imageNames count] + [textNames count] + [assets count]];
                                   //ループ開始
                                   [NSTimer scheduledTimerWithTimeInterval:0.03f
                                                                    target:self
                                                                  selector:@selector(loop)
                                                                  userInfo:nil
                                                                   repeats:YES];
                               }
                           }
                          failureBlock:^(NSError *error) {
                              initAssetsCount++;
                              if(initAssetsCount == [assetsURL count]){
                                  fadeSelects = [self randomList:[imageNames count] + [textNames count] + [assets count]];
                                  //ループ開始
                                  [NSTimer scheduledTimerWithTimeInterval:0.03f
                                                                   target:self
                                                                 selector:@selector(loop)
                                                                 userInfo:nil
                                                                  repeats:YES];
                              }
                          }];
        }
    }else{
        assetsURL = [NSMutableDictionary dictionary];
        fadeSelects = [self randomList:[imageNames count] + [textNames count] + [assets count]];
        
        //ループ開始
        [NSTimer scheduledTimerWithTimeInterval:0.03f
                                         target:self
                                       selector:@selector(loop)
                                       userInfo:nil
                                        repeats:YES];
    }
}
-(void)loop{
    if(manager){
        [manager startAccelerometerUpdates];
        NSNumber* nowx = [NSNumber numberWithFloat:manager.accelerometerData.acceleration.x];
        NSNumber* nowy = [NSNumber numberWithFloat:manager.accelerometerData.acceleration.y];
        NSNumber* nowz = [NSNumber numberWithFloat:manager.accelerometerData.acceleration.z];
        [prevAccelerations addObject:[NSDictionary dictionaryWithObjectsAndKeys:nowx,@"x",nowy,@"y",nowz,@"z", nil]];
        if(5 < [prevAccelerations count]){
            [prevAccelerations removeObjectsInRange:NSMakeRange(0, 1)];
        }
    }
    
    switch (sceneNumber) {
        case 1://「線香花火」設定
            if(!title){
                title = [[fadeView alloc] initWithLableText:@"線香花火" point:CGPointMake(160,100) line:1 fontsize:50 upAlpha:0.02f downAlpha:0.02f topAlpha:1.0f superview:self.view];
            }else{
                [title reInit];
            }
            sceneNumber = 3;
            /*if(!titleLabel){
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
            
            sceneNumber = 2;*/
            break;
        case 2://「線香花火」表示アニメ
            /*titleLabel.alpha += 0.02f;
            if(1.0f < titleLabel.alpha || isTapped){
                sceneNumber = 3;
            }*/
            break;
        case 3://「線香花火」隠蔽アニメ、線香花火設定、「遊び方」設定
            //titleLabel.alpha -= 0.02f;
            if([title Do]/*titleLabel.alpha < 0.0f*/){
                // 線香花火の画像
                if(!senkoImage){
                    senkoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"senkohanabi5.png"]];
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
                    UIImage* img = [UIImage imageNamed:@"hinotama.png"];
                    hinotamaImage = [[UIImageView alloc] initWithImage:img];
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
                senkoCount = 0;
                fireScene = 1;
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
                senkoCount = 0;
                fireScene = 1;
                sceneNumber = 6;
            }
            break;
            
            
        case 6:
            
            //fireScene設定
            senkoCount++;
            if(33*70 < senkoCount){
                fireScene = 6;//ほぼ何もない
            }else if(33*60 < senkoCount){
                fireScene = 5;//盛り下がり
            }else if(33*40 < senkoCount){
                fireScene = 4;//絶頂期
            }else if(33*20 < senkoCount){
                fireScene = 3;//盛り上がり
            }else if(33*10 < senkoCount){
                fireScene = 2;//ちょい出始める
            }
            //火花作成、Do
        {
            int r = (rand() % 2);
            if( r == 0 ){
                /*int kind = (rand() % 4) + 2;
                CGFloat angle = ((-manager.accelerometerData.acceleration.x* 90.0f * M_PI / 180.0f) + prevAngle + prevprevAngle) / 3.0f;
                angle = -angle - 0.15f;
                float nx = 160 + 320 * sin(angle)+13;
                float ny = 330 * cos(angle)-10;
                fire* f = [[fire alloc] initWithObject:[[UIImageView alloc]
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
            //火花の花作成、Do
        {
            int rate;
            switch (fireScene) {
                case 1:
                default:
                    rate = 100;
                    break;
                case 2:
                    rate = 50;
                    break;
                case 3:
                    rate = 10;
                    break;
                case 4:
                    rate = 1;
                    break;
                case 5:
                    rate = 10;
                    break;
                case 6:
                    rate = 50;
                    break;
            }
            int r = (rand() % rate);
            if( r == 0 ){
                fireFlower* ff = [[fireFlower alloc] initWithPoint:hidanePoint view:self.view];
                [fireFlowers addObject:ff];
            }
            
            for(int i = 0; i < [fireFlowers count]; i++){
                fireFlower* ff = fireFlowers[i];
                [ff DoWithScene:fireScene];
                if(ff.deleteFlg){
                    [fireFlowers removeObject:ff];
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
                    showFadeObject =
                    [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:img] view:self.view];
                }
                fadeselect = (fadeselect + 1) % ([imageNames count] + [textNames count] + [assets count]);
            }
            
            //フェードオブジェクトアニメーション
            [showFadeObject Do];
            
            // 加速度が大きくなりすぎたら火種を落とす
            float rate;
            switch (fireScene) {
                case 1:
                default:
                    rate = 5;
                    break;
                case 2:
                    rate = 4;
                    break;
                case 3:
                    rate = 3;
                    break;
                case 4:
                    rate = 2;
                    break;
                case 5:
                    rate = 1;
                    break;
            }
        {
            if( 2 < [prevAccelerations count] ){
                NSDictionary* now = prevAccelerations[[prevAccelerations count]-1];
                NSDictionary* prev = prevAccelerations[[prevAccelerations count]-2];
                if(0.05 * rate< fabs([now[@"x"] floatValue] - [prev[@"x"] floatValue])
                   || 0.1 * rate < fabs([now[@"y"] floatValue] - [prev[@"y"] floatValue])
                   || 0.05 * rate < fabs([now[@"z"] floatValue] - [prev[@"z"] floatValue])) {
                    hiFlg = YES;
                    hidaneAX =  1.0*([now[@"x"] floatValue]);
                    hidaneAY = -1.0*([now[@"y"] floatValue]);
                    hidaneVX = hidaneAX;
                    hidaneVY = hidaneAY;
                }
            }
            
            if(hiFlg) {
                hinotamaImage.transform = CGAffineTransformMakeRotation(0);
                CGRect move = hinotamaImage.frame;
                hidaneVX += hidaneAX;
                hidaneVY += hidaneAY;
                move.origin.x += hidaneVX;
                move.origin.y += hidaneVY;
                hinotamaImage.frame = move;
                hinotamaImage.transform = CGAffineTransformMakeRotation(senkoAngle);
                hinotamaImage.alpha -= 0.06f;
            }
            
            if(!soundFlg) {
                soundFlg = YES;
                
                sparkBgm = [[Bgm alloc] initWithPath:@"spark.wav"];
                
                [sparkBgm setVolume:0.5];
                [sparkBgm setNumberOfLoops:-1];
                [sparkBgm play];
                
//                // ファイルのパスを作成します。
//                NSString *path = [[NSBundle mainBundle] pathForResource:@"spark" ofType:@"wav"];
//                
//                // ファイルのパスを NSURL へ変換します。
//                NSURL* url = [NSURL fileURLWithPath:path];
//                NSLog(@"path:%@", url);
//                // ファイルを読み込んで、プレイヤーを作成します。
//                player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//                
//                [player setNumberOfLoops:-1];
//                // 再生
//                [player play];
            }
            

            // 火種が画面下に来ると終了
            if( hinotamaImage.frame.origin.x < -hinotamaImage.frame.size.width
               || self.view.frame.size.width < hinotamaImage.frame.origin.x
               || hinotamaImage.frame.origin.y < -hinotamaImage.frame.size.height
               || self.view.frame.size.height < hinotamaImage.frame.origin.y
               || hinotamaImage.alpha < 0.0f
               ) {
                [sparkBgm stop];
                sceneNumber = 7;
            }
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
            //火花の花オブジェクト消し
            for(int i = 0; i < [fireFlowers count]; i++){
                fireFlower* ff = fireFlowers[i];
                [ff DoWithScene:fireScene];
                if(ff.deleteFlg){
                    [fireFlowers removeObject:ff];
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
                
                if(assetsflg == 1){
                    if(!addLabel){
                        addLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 100)];
                        addLabel.font = [UIFont fontWithName:@"Hiragino Mincho ProN" size:20];
                        addLabel.textAlignment = NSTextAlignmentCenter;
                        addLabel.backgroundColor = [UIColor clearColor];
                        addLabel.textColor = [UIColor whiteColor];
                        addLabel.numberOfLines = 3;
                        addLabel.alpha = 0.0f;
                        [self.view addSubview:addLabel];
                    }else{
                        addLabel.alpha = 0.0f;
                    }
                    if(0 < addAssetsCount){
                        addLabel.text = [NSString stringWithFormat:@"夏の思い出写真を\n%d枚追加しました。",addAssetsCount];
                    }else if(0 < addedAssetsCount){
                        addLabel.text = [NSString stringWithFormat:@"あなたの\n夏の思い出写真は\nもうありません。"];
                    }else{
                        addLabel.text = [NSString stringWithFormat:@"あなたの\n夏の思い出は\nありません。"];
                    }
                    sceneNumber = 9;
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
            hiFlg = NO;
            sceneNumber = 3;
            break;
        case 9:
            addLabel.alpha += 0.04f;
            if(1.6f < addLabel.alpha){
                sceneNumber = 10;
            }
            
            break;
        case 10:
            addLabel.alpha -= 0.04f;
            if(addLabel.alpha < 0.0f){
                [addimageButton setEnabled:YES];
                [nextButton setEnabled:YES];
                sceneNumber = 7;
            }
            break;
    }
    
    //線香花火がある間
    if(senkoImage){
        if(manager){
            // 角度には平滑化した値を使用
            /*senkoAngle = ((-manager.accelerometerData.acceleration.x* 90.0f * M_PI / 180.0f) + prevAngle + prevprevAngle) / 3.0f;
            prevprevAngle  = prevAngle;
            prevAngle = (-manager.accelerometerData.acceleration.x* 90.0f * M_PI / 180.0f);*/
            
            senkoAngle = -[[self getSmoothingaccelerationWithNumber:@3][@"x"] floatValue];
            senkoImage.transform = CGAffineTransformMakeRotation(senkoAngle);
            hidanePoint = [self getHidanePointWithAngle:senkoAngle];
            
            if( !hiFlg ){
                UIImage* img = [UIImage imageNamed:@"hinotama.png"];
                float rate = 7.5;
                float layw = img.size.width/rate;
                float layh = img.size.height/rate;
                hinotamaImage.transform = CGAffineTransformMakeRotation(0);
                hinotamaImage.frame = CGRectMake(hidanePoint.x - layw/2, hidanePoint.y - layh/2, layw, layh);
                hinotamaImage.transform = CGAffineTransformMakeRotation(senkoAngle);
            }
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
    [addimageButton setEnabled:NO];
    [nextButton setEnabled:NO];
    
    addAssetsCount = 0;
    addedAssetsCount = 0;
    assetsLibrary = [self.class defaultAssetsLibrary];
    NSDate *startDate = [NSDate date];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group){
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSDate* d = [result valueForProperty:ALAssetPropertyDate];
                    NSCalendar *cal = [NSCalendar currentCalendar];
                    NSDateComponents *dcom = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:d];
                    if( 6 <= dcom.month && dcom.month <= 9){
                        NSURL *URL = [[result valueForProperty:ALAssetPropertyURLs] objectForKey:[[result defaultRepresentation] UTI]];
                        NSString* URLstr = [URL absoluteString];
                        if(!assetsURL[URLstr]){
                            addAssetsCount++;
                            [assets addObject:result];
                            assetsURL[URLstr] = [NSNumber numberWithBool:1];
                        }else{
                            addedAssetsCount++;
                        }
                    }
                    //addLabel.layer.transform = CATransform3DMakeRotation(10, 0, 0, 1);
                }else{
                    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:assetsURL forKey:@"assetsURL"];
                    [ud synchronize];
                    assetsflg = 1;
                    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
                    NSLog(@"time is %lf (sec)", interval);
                }
            };
            
            NSLog(@"%d", [group numberOfAssets]);
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        NSLog(@"Error");
    };
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:listGroupBlock failureBlock:failureBlock];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

-(CGPoint)getHidanePointWithAngle:(CGFloat)angle{
    if(0 <= angle){
        return CGPointMake(senkoImage.frame.origin.x+
                           + 11 * sin(angle) + 11 * cos(angle),
                           
                           senkoImage.frame.origin.y+senkoImage.frame.size.height
                           - 50 * sin(angle) - 11 * cos(angle));
        
    }else{
        angle = - angle;
        return CGPointMake(senkoImage.frame.origin.x+
                           + senkoRelativeX * cos(angle) + senkoRelativeY * sin(angle),
                           
                           senkoImage.frame.origin.y+senkoImage.frame.size.height
                           - senkoRelativeX * sin(angle)
                           - (senkoOriginalH - senkoRelativeY) * cos(angle));
    }
    
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

-(NSDictionary*)getSmoothingaccelerationWithNumber:(NSNumber*)n{
    float sx = 0, sy = 0, sz = 0;
    for(int i = [prevAccelerations count]-1, count = [n intValue] - 1; 0 <= i && 0 <= count; i--,count--){
        sx += [prevAccelerations[i][@"x"] floatValue];
        sy += [prevAccelerations[i][@"y"] floatValue];
        sz += [prevAccelerations[i][@"z"] floatValue];
    }
    sx /= [n floatValue];
    sy /= [n floatValue];
    sz /= [n floatValue];
    
    NSNumber* ssx = [NSNumber numberWithFloat:sx];
    NSNumber* ssy = [NSNumber numberWithFloat:sy];
    NSNumber* ssz = [NSNumber numberWithFloat:sz];
    return [NSDictionary dictionaryWithObjectsAndKeys:ssx,@"x",ssy,@"y",ssz,@"z", nil];
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
