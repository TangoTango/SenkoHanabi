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
#import "CustomButton.h"
#import "MyProgressBar.h"

@interface ViewController ()

@end
@implementation ViewController

fadeView *title;//タイトル
fadeView *how;//遊び方
fadeView *add;//画像追加結果
fadeView *yakedo;//火傷しちゃう警告
fadeView *friendWait;//友達待ち
fadeView *katori;//蚊取り線香
UIImageView *senkoImage; // 線香花火の画像
UIImageView *hinotamaImage;//火の玉の画像
CALayer* hinotamaBlackLayer; // 消えた火の玉の画像のレイヤ
UIButton *connectButton;//通信ボタン
MyProgressBar *addBar;//画像追加プログレスバー
NSMutableArray* fireFlowers;//火花の画像
bool hiFlg = NO; // 火種が落ちたかどうか

NSArray *imageNames; // 現れて消えるアニメーション画像の配列
NSArray *textNames; // 現れて消えるテキストの配列
fadeObject *showFadeObject; //表示中のフェードオブジェクト
NSMutableArray *fadeSelects;//
int fadeselect;

ALAssetsLibrary* assetsLibrary;
NSMutableArray *assets;
NSMutableDictionary *assetsURL;
int assetsflg = 0;
int addAssetsCount;//追加時Assetカウント
int addedAssetsCount;//追加時追加済Assetカウント
int initAssetsCount;//起動時Assetカウント

GKSession *currentSession;//友達とのセッション
NSMutableArray *friendImages;//友達の写真
NSNumber *myGyanken;//自分のじゃんけんの値
NSNumber *enemyGyanken;//相手のじゃんけんの値
NSMutableArray *enemyRandom90s;//相手のランダムな配列
NSMutableArray *random90s;//受け取ったランダムな配列
int startNumber;//二人とも始めたら進行するようにカウント
int endNumber;//二人とも終わったら進行するようにカウント
int scene7Flg;//シーン7の終了一回目
int sharedFlg;//友達と写真を共有したら1にして文表示
int winner;//じゃんけんに勝ったかどうか

UIButton *nextButton;
CustomButton *addimageButton;

int senkoTime = 5000;//線香が落ちるまでの時間
int hinotamaBlackTime = 0;
int isTapped = 0;//タップしたか
int initLaunch = 1;//最初の起動かどうか

CMMotionManager *manager;//センサオブジェクト
NSMutableArray* prevAccelerations;//センサデータ記録

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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    //友達の写真の初期化
    friendImages = [NSMutableArray array];
    
    // ひぐらしの鳴き声読み込み
    [[OALSimpleAudio sharedInstance] preloadBg:@"higurashi.mp3"];
    
    // ひぐらしの鳴き声再生
    [[OALSimpleAudio sharedInstance] playBg:@"higurashi.mp3" volume:0.2 pan:0.0 loop:YES];
    
    // 火花の炸裂音読み込み
    [[OALSimpleAudio sharedInstance] preloadEffect:@"spark.mp3"];
    
    //フェードオブジェクトを選択して、タイマー開始
    [self selectFadeObjectWithCompleteFunc:^{
        [NSTimer scheduledTimerWithTimeInterval:0.03f
                                         target:self
                                       selector:@selector(loop)
                                       userInfo:nil
                                        repeats:YES];
    }];
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
    }else{
        [prevAccelerations addObject:[NSDictionary dictionaryWithObjectsAndKeys:@0,@"x",@0,@"y",@0,@"z", nil]];
        if(5 < [prevAccelerations count]){
            [prevAccelerations removeObjectsInRange:NSMakeRange(0, 1)];
        }
    }
    
    switch (sceneNumber) {
        case 1://「線香花火」設定
            if(!title){
                title = [[fadeView alloc] initWithLableText:@"おもひではなび" point:CGPointMake(155,50) fontsize:50 upAlpha:0.02f downAlpha:0.02f topAlpha:2.0f superview:self.view];
            }else{
                [title reInit];
            }
            
            sceneNumber = 3;
            break;
        case 3://「線香花火」隠蔽アニメ、線香花火設定、「遊び方」設定
            //全体の最初
            if(isTapped){
                [title hide];//タッチしたら消えるように
                title.alphaFlag = -1;
            }
            if([title Do]){//タイトルアニメーション　アニメーションが終了すれば1が返ってくる
                // 線香花火の画像
                if(!senkoImage){
                    senkoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"senkohanabi5.png"]];
                    senkoImage.layer.anchorPoint = CGPointMake(0.5, 0); // (170, -10)が回転の原点
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
                    
                    // 消えた後の火の玉の画像をレイヤとして取得
                    hinotamaBlackLayer = [CALayer layer];
                    hinotamaBlackLayer.contents = (id) [UIImage imageNamed:@"hinotama_black2.png"].CGImage;
                    hinotamaBlackLayer.opacity = 0.0f;
                    [hinotamaImage.layer addSublayer:hinotamaBlackLayer];
                    hinotamaBlackTime = 0;
                    
                    [self.view addSubview:hinotamaImage];
                }else{
                    hinotamaImage.alpha = 0.0f;
                    hinotamaBlackLayer.opacity = 0.0f;
                    hinotamaBlackTime = 0;
                }
                
                // 「遊び方」
                if(!how){
                    how = [[fadeView alloc] initWithLableText:@"遊び方\n\n端末の上部を持って\n\n\n\n\n線香花火を眺めながら\n夏の思い出に浸りましょう。\n" point:CGPointMake(150,40) fontsize:30 upAlpha:0.02f downAlpha:0.02f topAlpha:3.0f superview:self.view];
                }else{
                    [how reInit];
                }
                
                //オブジェクトシーンの順番初期化
                [self fadeSelectUpdate];
                
                sceneNumber = 4;
            }
            break;
        case 4://線香花火アニメ、「遊び方」表示アニメ
            senkoImage.alpha += 0.02f;
            hinotamaImage.alpha += 0.02f;
            
            //起動から1回目のプレイかどうか
            if(initLaunch){
                if([how Do] || isTapped){//遊び方アニメーション　アニメーションが終了すれば1が返ってくる
                    senkoImage.alpha = 1.0f;
                    hinotamaImage.alpha = 1.0f;
                    [how hide];
                    if( !yakedo ){
                        yakedo = [[fadeView alloc] initWithLableText:@"火傷します！" point:CGPointMake(270,30) fontsize:50 upAlpha:0.03f downAlpha:0.03f topAlpha:1.0f superview:self.view];
                        yakedo.alphaFlag = 2;
                        [yakedo reverse];
                    }else{
                        [yakedo reInit];
                    }
                    senkoCount = 0;
                    fireScene = 1;
                    sceneNumber = 6;
                }
            }else{
                if(1.0f < senkoImage.alpha && 1.0f < hinotamaImage.alpha){
                    senkoCount = 0;
                    fireScene = 1;
                    sceneNumber = 6;
                }
            }
            break;
            
        case 6:
            ///////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////点火開始〜終了まで////////////////////////////////
            ///////////////////////////////////////////////////////////////////////////////
        {
            //画像保存しまくるやつ
            //hiFlg = 1;
            //[self saveImageToPhotosAlbum:[UIImage imageNamed:@"senkohanabi5.png"]];
            
        }
        {
            //持ち方がおかしければ警告
            if( 0 < [prevAccelerations count] ){
                NSDictionary* now = prevAccelerations[[prevAccelerations count]-1];
                if( 0.4 < [now[@"y"] floatValue] ){
                    [yakedo Do];
                }else{
                    [yakedo hideDo];
                }
            }
        }
            
            
            //fireScene設定
            senkoCount++;
            if(33*80 < senkoCount) {
                fireScene = 7; // 火が消える
            }else if(33*70 < senkoCount){
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
            
            //火花の花作成、Do
        {
            int rate = [@[ @50, @30, @10, @1, @10, @50, @9999][fireScene-1] intValue];
            int r = (arc4random() % rate);
            if( r == 0 ){
                fireFlower* ff = [[fireFlower alloc] initWithPoint:hidanePoint view:self.view scene:fireScene];
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
                    int t = i;
                    //画像の追加
                    showFadeObject =
                    [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNames[t]]] view:self.view];
                }else if(i - [imageNames count] < [textNames count]){
                    int t = i - [imageNames count];
                    //文字の追加
                    showFadeObject =
                    [[fadeObject alloc] initWithString:textNames[t] view:self.view];
                }else if(!currentSession || winner){
                    if(i - [imageNames count] - [textNames count] < [assets count]){
                        int t = i - [imageNames count] - [textNames count];
                        ALAsset *asset = assets[t];
                        UIImage *img = [UIImage imageWithCGImage:[asset thumbnail]];
                        showFadeObject =
                        [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:img] view:self.view];
                    }else if(i - [imageNames count] - [textNames count] - [assets count] < [friendImages count]){
                        int t = i - [imageNames count] - [textNames count] - [assets count];
                        showFadeObject = [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:friendImages[t]] view:self.view];
                    }
                }else{
                    if(i - [imageNames count] - [textNames count] < [friendImages count]){
                        int t = i - [imageNames count] - [textNames count];
                        showFadeObject = [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:friendImages[t]] view:self.view];
                    }else if(i - [imageNames count] - [textNames count] - [friendImages count] < [assets count]){
                        int t = i - [imageNames count] - [textNames count] - [friendImages count];
                        ALAsset *asset = assets[t];
                        UIImage *img = [UIImage imageWithCGImage:[asset thumbnail]];
                        showFadeObject =
                        [[fadeObject alloc] initWithImage:[[UIImageView alloc] initWithImage:img] view:self.view];
                    }
                }
                fadeselect = (fadeselect + 1) % ([imageNames count] + [textNames count] + [assets count] + [friendImages count]);
            }
            
            //フェードオブジェクトアニメーション
            [showFadeObject Do];
            
            
        {
            
            // 効果音
            float rate = [@[ @3.0f, @3.0f, @2.0f, @2.0f, @1.0f, @1.0f, @1.0f][fireScene-1] floatValue];
            // 加速度が大きくなりすぎたら火種を落とす　終了しているときは落とさない
            if( 2 < [prevAccelerations count] && fireScene != 7 ){
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
            //端にぶつかると落ちる。　終了しているときは落とさない
            if( (hinotamaImage.frame.origin.x < 0
                 || self.view.frame.size.width < hinotamaImage.frame.origin.x + hinotamaImage.frame.size.width)
               && fireScene != 7 ) {
                hiFlg = YES;
                NSDictionary* now = prevAccelerations[[prevAccelerations count]-1];
                hidaneAX =  0;
                hidaneAY = -2.0*([now[@"y"] floatValue]);
                hidaneVX = hidaneAX;
                hidaneVY = hidaneAY;
            }
            //火種が落下
            if(hiFlg) {
                hinotamaImage.transform = CGAffineTransformMakeRotation(0);
                CGRect move = hinotamaImage.frame;
                hidaneVX += 0.3*hidaneAX;
                hidaneVY += 0.3*hidaneAY;
                move.origin.x += hidaneVX;
                move.origin.y += hidaneVY;
                hinotamaImage.frame = move;
                hinotamaImage.transform = CGAffineTransformMakeRotation(senkoAngle);
                //hinotamaImage.alpha -= 0.06f;
                hinotamaBlackLayer.opacity += 0.03f;
                
                // 火種が画面下に来るか火種が消えると終了
                if( hinotamaImage.frame.origin.x < -hinotamaImage.frame.size.width
                   || self.view.frame.size.width < hinotamaImage.frame.origin.x
                   || hinotamaImage.frame.origin.y < -hinotamaImage.frame.size.height
                   || self.view.frame.size.height < hinotamaImage.frame.origin.y
                   || 1.0f < hinotamaBlackLayer.opacity ) {
                    
                    hinotamaImage.alpha = 0.0f;
                    scene7Flg = 1;//sceneNumber = 7;とセットでお願いします(泣)
                    sceneNumber = 7;
                    break;
                }
            }
            
            if( fireScene == 7) {
                if( hinotamaBlackLayer.opacity < 0.8f){
                    hinotamaBlackLayer.opacity += 0.05f;
                }
                
                //火の玉が黒ずんで、3秒経てば終了
                if ( 0.8f < hinotamaBlackLayer.opacity && 33 * 3 < ++hinotamaBlackTime) {
                    scene7Flg = 1;//sceneNumber = 7;とセットでお願いします(泣)
                    sceneNumber = 7;
                    break;
                }
                
            }
            
        }
            break;
        case 7:
            //フェードオブジェクト削除
            [showFadeObject DeleteDo];
            if(showFadeObject.deleteFlg){
                showFadeObject = nil;
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
            
            // 火種を消す
            hinotamaBlackLayer.opacity += 0.01f;
            
            //全部消えたら
            if([yakedo hideDo] && !showFadeObject && senkoImage.alpha < 0.0f){
                if(scene7Flg){
                    //初回だけこの中が呼び出される。
                    startNumber = 0;
                    [addimageButton setEnabled:YES];
                    [nextButton setEnabled:YES];
                    [connectButton setEnabled:YES];
                    if(currentSession){
                        myGyanken = nil;
                        [self sendEndAndCountEnd];
                        if(!friendWait){
                            friendWait = [[fadeView alloc] initWithLableText:@"友達が終わるのを\n待っています。" point:CGPointMake(160,50)  fontsize:40 upAlpha:0.1f downAlpha:0.0f topAlpha:1.0f superview:self.view];
                        }else{
                            [friendWait changeTextWithString:@"友達が終わるのを\n待っています。"];
                        }
                    }
                    scene7Flg = 0;
                }
                //二人でやっている場合は、二人共消えるまでボタン表示しない
                if(currentSession && endNumber != 2){
                    [friendWait Do];
                    break;
                }
                if(friendWait){
                    [friendWait hide];
                }
                //画像共有中
                
                if(katori){
                    if(sharedFlg != 1){
                        [katori hide];
                    }
                }
                
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
                // 「画像を追加」ボタン
                if(!addimageButton){
                    UIImage *img = [UIImage imageNamed:@"addPicture2.gif"];
                    addimageButton = [[CustomButton  alloc] initWithFrame:CGRectMake(160-75, 300, 150, 45)];
                    [addimageButton setBackgroundImage:img forState:UIControlStateNormal];
                    [addimageButton addTarget:self action:@selector(addimageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:addimageButton];
                    
                }else{
                    [addimageButton setHidden:NO];
                }
                //「写真を共有」ボタン
                if(!connectButton){
                    UIImage *img = [UIImage imageNamed:@"sharePicture.gif"];
                    connectButton = [[CustomButton alloc] initWithFrame:CGRectMake(85, 370, 150, 45)];
                    [connectButton setBackgroundImage:img forState:UIControlStateNormal];
                    [connectButton addTarget:self action:@selector(connectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:connectButton];
                }else{
                    [connectButton setHidden:NO];
                }
                
                
                //画像選択完了or写真共有完了
                if(assetsflg == 1 || sharedFlg == 2){
                    
                    NSString *text;
                    if( sharedFlg == 2){
                        sharedFlg = 0;
                        text = [NSString stringWithFormat:@"友達の写真を\n%d枚\n共有しました。",[friendImages count]];
                    }else if(0 < addAssetsCount){
                        text = [NSString stringWithFormat:@"夏の思い出写真を\n%d枚\n追加しました。",addAssetsCount];
                    }else if(0 < addedAssetsCount){
                        text = @"あなたの\n夏の思い出写真は\nもうありません。";
                    }else{
                        text = @"あなたの\n夏の思い出写真は\nありません。";
                    }
                    if(!add){
                        add = [[fadeView alloc] initWithLableText:text point:CGPointMake(160,40) fontsize:20 upAlpha:0.04f downAlpha:0.04f topAlpha:1.6f superview:self.view];
                    }else{
                        [add changeTextWithString:text];
                        [add hide];
                    }
                    sceneNumber = 9;
                    assetsflg = 0;
                }
            }
            break;
        case 8://全体の末尾の初期化
        {
            senkoTime = 400;
            [nextButton setHidden:YES];
            [addimageButton setHidden:YES];
            [connectButton setHidden:YES];
            [add hide];
            initLaunch = 0;
            hiFlg = NO;
            sceneNumber = 10;
            [self selectFadeObjectWithCompleteFunc:^{
                if(currentSession){
                    endNumber = 0;
                    startNumber++;
                    if(!friendWait){
                        friendWait = [[fadeView alloc] initWithLableText:@"友達が始めるのを\n待っています。" point:CGPointMake(160,50)  fontsize:40 upAlpha:0.1f downAlpha:0.0f topAlpha:1.0f superview:self.view];
                    }else{
                        [friendWait changeTextWithString:@"友達が始めるのを\n待っています。"];
                    }
                }
                
                sceneNumber = 11;
            }];
            break;
        }
        case 9:
            
            if([add Do]){
                [addimageButton setEnabled:YES];
                [nextButton setEnabled:YES];
                [connectButton setEnabled:YES];
                sceneNumber = 7;
            }
            break;
        case 10:
            break;
        case 11://全体の末尾
            if( !currentSession ){
                if(friendWait){
                    [friendWait hide];
                }
                sceneNumber = 3;
            }else if(startNumber == 2){
                if( [myGyanken intValue] < [enemyGyanken intValue]){
                    winner = 1;
                    random90s = enemyRandom90s;
                }else{
                    winner = 0;
                }
                //[self fadeSelectUpdate];
                if(friendWait){
                    [friendWait hide];
                }
                sceneNumber = 3;
            }else if(currentSession && startNumber != 2){
                [friendWait Do];
            }
            break;
        case 12:
            //共有が終わればプログレスバーが消えていく
            if(assetsflg && [addBar hideDo]){
                sceneNumber = 7;
            }
            break;
    }
    
    //線香花火がある間
    if(senkoImage){
        // 角度には平滑化した値を使用
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
            
            // 消えた火の玉の大きさ
            CGRect hinotamaRect = hinotamaImage.frame;
            hinotamaRect.origin.x = 0.0f;
            hinotamaRect.origin.y = 0.0f;
            hinotamaBlackLayer.frame = hinotamaRect;
            
            hinotamaImage.transform = CGAffineTransformMakeRotation(senkoAngle);
        }
    }
    
    isTapped = 0;
}

//imageNames, textNames, assets, friendImagesを設定する
-(void)selectFadeObjectWithCompleteFunc:(void (^)())func{
    textNames = [NSArray arrayWithObjects:@"気づいたら\nカラオケで\n\n\n\nざこ寝",
                 @"セミの\n\n\n\n\n\n抜け殻",
                 @"プールで\n監視員に\n\n\n\n怒られる",
                 @"好きな子と\n友達が\n\n\n\n付き合ってた",
                 @"お祭り\n\n\n\n\n騒ぎ",
                 @"山\n\n\n\n\nガール",
                 @"キャンプで\n\n\n\n\n\nバーベキュー",
                 @"セミの鳴き声で\n\n\n\n\n\n目を覚ます",
                 @"昼間は\n\n\n\n\n図書館で\n勉強",
                 @"縁日で\n\n\n\n\n\nくじ引き",
                 @"アイス食べて\n\n\n\n\n\nお腹を壊す",
                 @"開発で\n\n\n\n\n\n一日が終わる",
                 nil];
    if(!currentSession){
        //一人でプレイ
        imageNames = [NSArray arrayWithObjects:@"fade1.png", @"fade2.png", @"fade3.png", @"fade4.png", @"fade5.png", @"fade6.png", nil];
        friendImages = [NSArray array];
        //id selfo = self;
        [self setAssets:^{
            //[selfo fadeSelectUpdate];
            func();
        }];
    }else{
        //二人でプレイ
        imageNames = [NSArray array];
        //[self fadeSelectUpdate];
        //friendImagesとassetsは通信で受取済
        func();
    }
}
-(void)setAssets:(void (^)())func{
    static int ASSETS_MAX = 30;
    assetsLibrary = [self.class defaultAssetsLibrary];
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    assetsURL = [ud objectForKey:@"assetsURL"];
    assets = [NSMutableArray array];
    initAssetsCount = 0;
    if( !assetsURL || [assetsURL count] == 0 ){
        assetsURL = [NSMutableDictionary dictionary];
        //[self fadeSelectUpdate];
        func();
        return;
    }
    assetsURL = [assetsURL mutableCopy];
    NSArray *URLstrs = [assetsURL allKeys];
    NSArray *randomSelects = [self randomList:[URLstrs count]];
    int min = [URLstrs count] < ASSETS_MAX ? [URLstrs count] : ASSETS_MAX;
    for(int i = 0; i < min; i++){
        NSString *URLstr = URLstrs[[randomSelects[i] intValue]];
        NSURL* URL = [NSURL URLWithString:URLstr];
        [assetsLibrary assetForURL:URL
                       resultBlock:^(ALAsset *asset) {
                           initAssetsCount++;
                           if(asset){
                               [assets addObject:asset];
                           }else{
                               [assetsURL removeObjectForKey:URLstr];
                               initAssetsCount--;
                           }
                           if(initAssetsCount == min || i == min-1){
                               //消えてる写真がある場合もあるので、assetsURLは保存し直す
                               NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
                               [ud setObject:assetsURL forKey:@"assetsURL"];
                               [ud synchronize];
                               //[self fadeSelectUpdate];
                               func();
                           }
                       }
                      failureBlock:^(NSError *error) {
                          initAssetsCount++;
                          if(initAssetsCount == min){
                              //消えてる写真がある場合もあるので、assetsURLは保存し直す
                              NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
                              [ud setObject:assetsURL forKey:@"assetsURL"];
                              [ud synchronize];
                              //[self fadeSelectUpdate];
                              func();
                          }
                      }];
    }
}

-(void)fadeSelectUpdate{
    fadeselect = 0;
    if( !currentSession ){
        fadeSelects = [self randomList:[imageNames count] + [textNames count] + [assets count] + [friendImages count]];
    }else{
        int t = [imageNames count] + [textNames count] + [assets count] + [friendImages count];
        for(int i = 0; i < [random90s count]; i++){
            if(t <= [random90s[i] intValue]){
                [random90s removeObject:random90s[i]];
                i--;
            }
        }
        fadeSelects = random90s;
    }
}

//もう一度ボタン　タップ
- (void)nextButtonTapped:(UIButton *)button{
    if(!currentSession){
        //一人ならそのまま開始
        sceneNumber = 8;
    }else{
        //二人ならランダム順番情報送信してから開始
        [addimageButton setEnabled:NO];
        [nextButton setEnabled:NO];
        [connectButton setEnabled:NO];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        random90s = [self randomList:90];
        dic[@"random90s"] = random90s;
        myGyanken = [NSNumber numberWithInt:arc4random()];
        dic[@"gyanken"] = myGyanken;
        
        // 生成したオブジェクトをNSData型に変換
        NSData *d = [NSKeyedArchiver archivedDataWithRootObject:dic];
        NSError *error = nil;
        [currentSession sendDataToAllPeers:d
                              withDataMode:GKSendDataReliable
                                     error:&error];
        
        if (error){
            NSLog(@"%@", [error localizedDescription]);
            currentSession = nil;
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:@"通信エラーが\n発生しました。"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            [addimageButton setEnabled:YES];
            [nextButton setEnabled:YES];
            [connectButton setEnabled:YES];
        }else{
            sceneNumber = 8;
        }
    }
}

// 「写真を追加」ボタンをタップした時
- (void)addimageButtonTapped:(UIButton *)button{
    // 写真追加の説明文をアラートで表示
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"写真を追加" message:@"カメラロールから\n写真をアプリに取り込み、\nスライドショー表示します。" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [alert show];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

// 「写真を共有」ボタンをタップした時
- (void)connectButtonTapped:(UIButton *)button{
    // 写真共有の説明文をアラートで表示
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"写真を共有" message:@"Bluetooth通信を行い、\n近くにいる友だちと\nアプリに追加した\n写真を交換します。" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [alert show];
    
    
}
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    [addimageButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [connectButton setEnabled:YES];
}
- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session{
    // セッションを保管
    currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    endNumber = 2;
    
    UIView *selfview = self.view;
    //id randomCall = self;
    [self setAssets:^{
        sharedFlg = 1;
        if(!katori){
            katori = [[fadeView alloc] initWithImageName:@"katori.png" frame:CGRectMake(100, 50, 120, 120) upAlpha:0.1f downAlpha:0.0f topAlpha:1.0f superview:selfview];
        }else{
            [katori show];
        }
        
        // 接続中のすべてのピアにデータを送信
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        int count = 0;
        for(ALAsset *asset in assets){
            UIImage *img = [UIImage imageWithCGImage:[asset thumbnail]];
            dic[[NSString stringWithFormat:@"%d",count]] = img;
            count++;
            if([assets count] <= count || 30 <= count)break;
        }
        dic[@"shareImg"] = @(YES);
        
        // 生成したオブジェクトをNSData型に変換
        NSData *d = [NSKeyedArchiver archivedDataWithRootObject:dic];
        NSError *error = nil;
        [currentSession sendDataToAllPeers:d
                              withDataMode:GKSendDataReliable
                                     error:&error];
        
        if (error){
            NSLog(@"%@", [error localizedDescription]);
            currentSession = nil;
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:@"通信エラーが\n発生しました。"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            [addimageButton setEnabled:YES];
            [nextButton setEnabled:YES];
            [connectButton setEnabled:YES];
        }else{
        }
    }];
    
    // ピアピッカーを閉じる
    picker.delegate = nil;
    [picker dismiss];
}
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    
    // NSData型オブジェクトをNSDictionary型に変換
    NSDictionary *reverse = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(reverse[@"shareImg"]){
        friendImages = [NSMutableArray array];
        for(int i = 0; i < 30; i++){
            if(reverse[[NSString stringWithFormat:@"%d",i]]){
                [friendImages addObject:reverse[[NSString stringWithFormat:@"%d",i]] ];
            }
        }
        sharedFlg = 2;
    }else if(reverse[@"gyanken"]){
        enemyRandom90s = reverse[@"random90s"];
        enemyGyanken = reverse[@"gyanken"];
        startNumber++;
    }else if(reverse[@"end"]){
        endNumber++;
    }
    
}
- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            currentSession = nil;
            break;
        default:
            break;
    }
}
-(void)sendEndAndCountEnd{
    endNumber++;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"end"] = @(YES);
    // 生成したオブジェクトをNSData型に変換
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSError *error = nil;
    [currentSession sendDataToAllPeers:d
                          withDataMode:GKSendDataReliable
                                 error:&error];
    
    if (error){
        NSLog(@"%@", [error localizedDescription]);
        currentSession = nil;
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:@"通信エラーが\n発生しました。"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


-(CGPoint)getHidanePointWithAngle:(CGFloat)angle{
    if(0 <= angle){
        return CGPointMake(senkoImage.frame.origin.x+
                           + senkoRelativeX * sin(angle) + 11 * cos(angle),
                           
                           senkoImage.frame.origin.y+senkoImage.frame.size.height
                           - 50 * sin(angle) - senkoRelativeX * cos(angle));
        
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//画像選択キャンセル
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//ビュー　タップ
- (void)view_Tapped:(UITapGestureRecognizer *)sender{
    isTapped = 1;
}
- (NSMutableArray*)randomList:(int)max{
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


// 写真へのアクセスが許可されている場合はYESを返す。まだ許可するか選択されていない場合はYESを返す。
- (BOOL)isPhotoAccessEnableWithIsShowAlert:(BOOL)_isShowAlert {
    // このアプリの写真への認証状態を取得する
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    BOOL isAuthorization = NO;
    
    switch (status) {
        case ALAuthorizationStatusAuthorized: // 写真へのアクセスが許可されている
            isAuthorization = YES;
            break;
        case ALAuthorizationStatusNotDetermined: // 写真へのアクセスを許可するか選択されていない
            isAuthorization = YES; // 許可されるかわからないがYESにしておく
            break;
        case ALAuthorizationStatusRestricted: // 設定 > 一般 > 機能制限で利用が制限されている
        {
            isAuthorization = NO;
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
            break;
            
        case ALAuthorizationStatusDenied: // 設定 > プライバシー > 写真で利用が制限されている
        {
            isAuthorization = NO;
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"写真へのアクセスが許可されていません。\n設定 > プライバシー > 写真で許可してください。"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
            break;
            
        default:
            break;
    }
    return isAuthorization;
}

- (void)saveImageToPhotosAlbum:(UIImage*)_image {
    
    BOOL isPhotoAccessEnable = [self isPhotoAccessEnableWithIsShowAlert:YES];
    
    /////// フォトアルバムに保存 ///////
    if (isPhotoAccessEnable) {
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:_image.CGImage
                                  orientation:(ALAssetOrientation)_image.imageOrientation
                              completionBlock:
         ^(NSURL *assetURL, NSError *error){
             NSLog(@"URL:%@", assetURL);
             NSLog(@"error:%@", error);
             
             ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
             
             if (status == ALAuthorizationStatusDenied) {
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"エラー"
                                           message:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                 [alertView show];
             } else {
                 /*UIAlertView *alertView = [[UIAlertView alloc]
                  initWithTitle:@""
                  message:@"フォトアルバムへ保存しました。"
                  delegate:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil];
                  [alertView show];*/
             }
         }];
    }
}

// アラートのボタンが押されたとき
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"alertView.titie: %@", alertView.title);
    
    if ([alertView.title isEqualToString:@"写真を追加"]) {
        switch (buttonIndex) {
            case 0:
                // "キャンセル"が押されたとき
                NSLog(@"cancel!");
                break;
            case 1:
                // "OK"が押されたとき
                NSLog(@"OK!");
                
                
                if(!addBar){
                    addBar = [[MyProgressBar alloc] initWithView:self.view];
                }else{
                    [addBar reInit];
                }
                [nextButton setEnabled:NO];
                [addimageButton setEnabled:NO];
                [connectButton setEnabled:NO];
                
                sceneNumber = 12;
                addAssetsCount = 0;
                addedAssetsCount = 0;
                assetsLibrary = [self.class defaultAssetsLibrary];
                NSDate *startDate = [NSDate date];
                ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop){
                    if (group){
                        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if (result) {
                                
                                //progressView.progress += (double)(1.0 / [group numberOfAssets]);
                                [addBar DoWithRate:((double)(addAssetsCount + addedAssetsCount) / [group numberOfAssets])];
                                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeInterval:0.001 sinceDate:[NSDate date]]];
                                
                                NSDate* d = [result valueForProperty:ALAssetPropertyDate];
                                int m = [[[NSString stringWithFormat:@"%@",d] componentsSeparatedByString:@"-"][1] intValue];
                                if( 6 <= m && m <= 9){
                                    NSURL *URL = [[result valueForProperty:ALAssetPropertyURLs] objectForKey:[[result defaultRepresentation] UTI]];
                                    NSString* URLstr = [URL absoluteString];
                                    if(!assetsURL[URLstr]){
                                        addAssetsCount++;
                                        //[assets addObject:result];
                                        assetsURL[URLstr] = [NSNumber numberWithBool:1];
                                    }else{
                                        addedAssetsCount++;
                                    }
                                }
                            }else{
                                NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
                                [ud setObject:assetsURL forKey:@"assetsURL"];
                                [ud synchronize];
                                [addBar DoWithRate:1.1];
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
                
                
                break;
        }
        
    }
    
    
    if ([alertView.title isEqualToString:@"写真を共有"]) {
        switch (buttonIndex) {
            case 0:
                // "キャンセル"が押されたとき
                NSLog(@"cancel!");
                break;
            case 1:
                // "OK"が押されたとき
                NSLog(@"OK!");
                
                [nextButton setEnabled:NO];
                [addimageButton setEnabled:NO];
                [connectButton setEnabled:NO];
                
                // ピアピッカーを作成
                GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
                picker.delegate = self;
                picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
                [picker show];
                
                break;
        }
        
    }
    
}

@end
