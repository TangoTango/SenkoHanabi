//
//  fadeObject.m
//  SenkoHanabi
//
//  Created by 丹後 偉也 on 2013/09/05.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "fadeObject.h"
#import <QuartzCore/QuartzCore.h>

static UIImageView *bokashiImage; // ぼかし画像のUIImageView

@implementation fadeObject:NSObject
@synthesize deleteFlg;

// 画像の初期化
-(id)initWithImage:(UIImageView*)img view:(UIView*)view{
    
    self = [super init];
    
    // ぼかし画像の表示
    if( !bokashiImage ){
        bokashiImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradation2.png"]];
        bokashiImage.alpha = 1.0f;
        [view addSubview:bokashiImage];
        
        // ぼかし画像は最前面におく
        [view bringSubviewToFront:bokashiImage];
    }else{
        bokashiImage.alpha = 1.0f;
    }
    
    object = img;
    isImage = 1;
    
    // 画像は初期状態では見えない
    img.alpha = 0.0f;
    deleteFlg = 0;
    
    maxw = 100;
    maxh = 100;
    NSLog(@"img: %@", img);

    // 画像が横長であれば
    if(img.image.size.height < img.image.size.width){
        // 幅が100pxになるようにサイズを調整
        img.frame = CGRectMake(220, 60, maxw, img.image.size.height*(maxw/img.image.size.width));
    }else{
        img.frame = CGRectMake(220, 60, img.image.size.width*(maxh/img.image.size.height), maxh);
    }
    
    // アニメーションパターンは乱数により決定
    animationPattern = arc4random() % 3;
    
    CGRect temp = img.frame;
    
    // アニメーションパターンによる初期位置の設定
    switch (animationPattern) {
            
        case 0:
            temp.origin.x = 220;
            temp.origin.y = 60;
            img.frame = temp;
            break;
            
        case 1:
            temp.origin.x = 50;
            temp.origin.y = 60;
            img.frame = temp;
            break;
            
        case 2:
            temp.origin.x = 100;
            temp.origin.y = 140;
            img.frame = temp;
            break;
            
    }
    
    NSLog(@"img.frame: %@", img);
    
    // メンバ変数に位置とサイズを代入
    CGRect f = img.frame;
    x = f.origin.x;
    y = f.origin.y;
    w = f.size.width;
    h = f.size.height;
    
    [view addSubview:img];
    
    return self;
}

// 文字の初期化
-(id)initWithString:(NSString*)str view:(UIView*)view{
    
    self = [super init];
    
    uilabels = [NSMutableArray array];
    alphaFlags = [NSMutableArray array];
    x = 30, y = 50, w = 270, h = 100;
    int fontsize = 35;
    int ix = 0;
    int iy = 0;
    
    for(int i = 0; i < str.length; i++){
        NSString* c = [str substringWithRange:NSMakeRange(i, 1)];
        if([c rangeOfString:@"\n"].location != NSNotFound){
            iy = 0;
            ix++;
        }else if([c rangeOfString:@"ー"].location != NSNotFound){
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bo2.png"]];
            //img.backgroundColor = [UIColor blueColor];
            img.frame = CGRectMake(w - fontsize * (1+ix), y + fontsize * iy + 4 ,fontsize,fontsize);
            img.alpha = 0.0f;
            
            [view addSubview:img];
            [uilabels addObject:img];
            [alphaFlags addObject:[NSNumber numberWithInt:0]];
            iy++;
        }else if(/*[c rangeOfString:@"。"].location != NSNotFound*/0){
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maru.png"]];
            img.frame = CGRectMake(w - fontsize * (1+ix), y + fontsize * iy ,fontsize,fontsize);
            img.alpha = 0.0f;
            
            [view addSubview:img];
            [uilabels addObject:img];
            [alphaFlags addObject:[NSNumber numberWithInt:0]];
            iy++;
        }else{
            UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(w - fontsize * (1+ix), y + fontsize * iy ,fontsize,fontsize*1.5f)];
            l.font = [UIFont fontWithName:@"AoyagiKouzanFontTOTF" size:fontsize];
            
            if( [self isInt:c] ){
                int number = [c intValue];
                NSString *numberStr = @[ @"〇", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九"][number];
                l.text = numberStr;
            }else if( [c rangeOfString:@"。"].location != NSNotFound){
                CGRect move = l.frame;
                move.origin.x += 20;
                move.origin.y -= 23;
                l.frame = move;
                l.text = c;
            }else if( [self isSmallChar:c]){
                CGRect move = l.frame;
                move.origin.x += 6;
                move.origin.y -= 15;
                l.frame = move;
                l.text = c;
            }else{
                l.text = c;
            }
            l.backgroundColor = [UIColor clearColor];
            l.textColor = [UIColor whiteColor];
            l.alpha = 0.0f;
            [view addSubview:l];
            [uilabels addObject:l];
            [alphaFlags addObject:[NSNumber numberWithInt:0]];
            iy++;
        }
    }
    
    return self;
}

// 画像
-(void)Do{
    // 画像である場合
    if(isImage){
        
        UIImageView *img = object; // 画像のオブジェクト
        
        //NSLog(@"animationPattern: %d", animationPattern);
        
        // アニメーションパターン1つ目
        if (animationPattern == 0) {
            NSLog(@"animationPattern: %d", animationPattern);            
            CGRect f = img.frame;
            
            // 画像の中心が画面全体の中央から右側にあるとき
            if( img.superview.frame.size.width/2 < f.origin.x + f.size.width/2 ){
                
                // 画像を鮮明にする
                img.alpha += 0.02f;
                
                // 画像を左に動かしながら大きくする
                img.frame = CGRectMake(f.origin.x - 1.5f - w * 0.01f, f.origin.y - h * 0.01f,
                                       f.size.width + w * 0.02f, f.size.height + h * 0.02f);
            }
            // 画像の中心が画面全体の中央から左側にあるとき
            else {
                // 画像を透明にする
                img.alpha -= 0.02f;
                
                // 画像を右に動かしながら小さくする
                img.frame = CGRectMake(f.origin.x - 1.5f + w * 0.01f, f.origin.y + h * 0.01f,
                                       f.size.width - w * 0.02f, f.size.height - h * 0.02f);
                
                // 画像が透明になったら
                if(img.alpha < 0) {
                    
                    // 画像を取り除き，ぼかし画像も透明にする
                    [img removeFromSuperview];
                    bokashiImage.alpha = 0.0f;
                    deleteFlg = 1;
                    
                }
            }
            
            // ぼかし画像は常に画像と同じ位置で，かつ最前面
            bokashiImage.frame = img.frame;
            [bokashiImage.superview bringSubviewToFront:bokashiImage];
            
        }
        // アニメーションパターン2つ目
        else {
            NSLog(@"animationPattern: %d", animationPattern);
            CGRect f = img.frame;
            
            // 幅か高さが初期値の2.0倍になるまでは
            if (f.size.width <= 2.0 * w || f.size.height <= 2.0 * h) {
                
                // 画像を鮮明にする
                img.alpha += 0.02f;
                
                // 画像の中央位置を保ちながら幅，高さを増やす
                CGPoint center = img.center; // 画像の中央位置
                f.size.width += w * 0.015f;
                f.size.height += h * 0.015f;
                img.frame = f;
                img.center  = center;
                
            }
            // その後は
            else {
                
                // 画像を透明にする
                img.alpha -= 0.02f;
                bokashiImage.alpha -= 0.01f;
                
                // 画像の中央位置を保ちながら幅，高さを少しだけ増やす
                CGPoint center = img.center;
                f.size.width += w * 0.008f;
                f.size.height += h * 0.008f;
                img.frame = f;
                img.center  = center;
                
                // 画像が透明になったら
                if (img.alpha < 0.0f) {
                    
                    // 画像を取り除き，ぼかし画像も透明にする
                    [img removeFromSuperview];
                    bokashiImage.alpha = 0.0f;
                    deleteFlg = 1;
                }
                
            }
            
            // ぼかし画像は常に画像と同じ位置で，かつ最前面
            bokashiImage.frame = img.frame;
            [bokashiImage.superview bringSubviewToFront:bokashiImage];
            
        }
        
    }else{
        //＋していく先頭の文字の透明度が0.5以上なら次の文字も＋していく。
        int plusi = -1;
        for(int i = 0; i < [uilabels count]; i++){
            NSNumber* n = alphaFlags[i];
            if([n intValue] == 1){
                plusi = i;
            }
        }
        UILabel* l;
        if(plusi == -1){
            if([alphaFlags[0] intValue] == 0){
                alphaFlags[0] = [NSNumber numberWithInt:1];
            }
        }else{
            l = uilabels[plusi];
            if(0.3 < l.alpha && plusi + 1 < [uilabels count]){
                alphaFlags[plusi + 1] = [NSNumber numberWithInt:1];
            }
        }
        
        
        int deletecount = 0;
        for(int i = 0; i < [uilabels count]; i++){
            //透明度が1.5以上なら＋から−へ
            l = uilabels[i];
            if(1.5 < l.alpha){
                alphaFlags[i] = [NSNumber numberWithInt:-1];
            }
            
            //＋ならAlphaを＋　−ならAlphaを−
            if([alphaFlags[i] intValue] == 1){
                l.alpha += 0.05f;
            }else if([alphaFlags[i] intValue] == -1){
                l.alpha -= 0.04f;
                if(l.alpha < 0.0f){
                    deletecount++;
                }
            }
        }
        if(deletecount == [uilabels count]){
            for(int i = 0; i < [uilabels count]; i++){
                l = uilabels[i];
                [l removeFromSuperview];
            }
            deleteFlg = 1;
        }
        
    }
}
-(void)DeleteDo{
    if(isImage){
        UIImageView *img = object;
        CGRect f = img.frame;
        img.alpha -= 0.01f;
        img.frame = CGRectMake(f.origin.x + w * 0.005f, f.origin.y + h * 0.005f,
                               f.size.width - w * 0.01f, f.size.height - h * 0.01f);
        
        if(img.alpha < 0){
            [img removeFromSuperview];
            deleteFlg = 1;
        }
        
        bokashiImage.alpha = img.alpha;
        bokashiImage.frame = img.frame;
        [bokashiImage.superview bringSubviewToFront:bokashiImage];
    }else{
        int deletecount = 0;
        UILabel* l;
        for(int i = 0; i < [uilabels count]; i++){
            l = uilabels[i];
            l.alpha -= 0.04f;
            if(l.alpha < 0.0f){
                deletecount++;
            }
        }
        if(deletecount == [uilabels count]){
            for(int i = 0; i < [uilabels count]; i++){
                l = uilabels[i];
                [l removeFromSuperview];
            }
            deleteFlg = 1;
        }
        
    }
}

-(BOOL)isInt:(NSString *)text{
    NSScanner *aScanner = [NSScanner localizedScannerWithString:text];
    [aScanner setCharactersToBeSkipped:nil];
    
    [aScanner scanInt:NULL];
    return [aScanner isAtEnd];
}
-(BOOL)isSmallChar:(NSString *)c{
    NSString *texts = @"ぁぃぅぇぉゃゅょっゎッャュョヵ";
    if( [texts rangeOfString:c].location != NSNotFound){
        return 1;
    }
    return 0;
}
@end