//
//  fadeObject.m
//  SenkoHanabi
//
//  Created by 丹後 偉也 on 2013/09/05.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "fadeObject.h"

static UIImageView *bokashiImage;

@implementation fadeObject:NSObject
@synthesize deleteFlg;

-(id)initWithImage:(UIImageView*)img view:(UIView*)view{
    if( !bokashiImage ){
        bokashiImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradation2.png"]];
        bokashiImage.alpha = 1.0f;
        [view addSubview:bokashiImage];
        [view bringSubviewToFront:bokashiImage];
    }else{
        bokashiImage.alpha = 1.0f;
    }
    object = img;
    isImage = 1;
    img.alpha = 0.0f;
    deleteFlg = 0;
    
    maxw = 100;
    maxh = 100;
    if(img.image.size.height < img.image.size.width){
        img.frame = CGRectMake(320-100, 60, maxw, img.image.size.height*(maxw/img.image.size.width));
    }else{
        img.frame = CGRectMake(320-100, 60, img.image.size.width*(maxw/img.image.size.height), maxh);
    }
    
    CGRect f = img.frame;
    x = f.origin.x;
    y = f.origin.y;
    w = f.size.width;
    h = f.size.height;
    
    [view addSubview:img];
    return self;
}

-(id)initWithString:(NSString*)str view:(UIView*)view{
    x = 30, y = 30, w = 120, h = 300;
    int fontsize = 30;
    int ix = 0;
    int iy = 0;
    isImage = 0;
    deleteFlg = 0;
    uilabels = [NSMutableArray array];
    alphaFlags = [NSMutableArray array];
    for(int i = 0; i < str.length; i++){
        NSString* c = [str substringWithRange:NSMakeRange(i, 1)];
        if([c rangeOfString:@"\n"].location == NSNotFound){
            UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(w - fontsize * (1+ix), y + fontsize * iy ,320,100)];
            l.font = [UIFont fontWithName:@"Hiragino Mincho ProN" size:fontsize];
            l.textAlignment = NSTextAlignmentCenter;
            l.text = c;
            l.backgroundColor = [UIColor clearColor];
            l.textColor = [UIColor whiteColor];
            l.alpha = 0.0f;
            [view addSubview:l];
            [uilabels addObject:l];
            [alphaFlags addObject:[NSNumber numberWithInt:0]];
            iy++;
        }else{
            iy = 0;
            ix++;
        }
    }
    
    return self;
}

-(void)Do{
    if(isImage){
        UIImageView *img = object;
        CGRect f = img.frame;
        if( img.superview.frame.size.width/2 < f.origin.x + f.size.width/2 ){
            img.alpha += 0.02f;
            img.frame = CGRectMake(f.origin.x - 1.5f - w * 0.01f, f.origin.y - h * 0.01f,
                                   f.size.width + w * 0.02f, f.size.height + h * 0.02f);
        }else{
            img.alpha -= 0.02f;
            img.frame = CGRectMake(f.origin.x - 1.5f + w * 0.01f, f.origin.y + h * 0.01f,
                                   f.size.width - w * 0.02f, f.size.height - h * 0.02f);
            if(img.alpha < 0){
                [img removeFromSuperview];
                bokashiImage.alpha = 0.0f;
                deleteFlg = 1;
            }
        }
        
        bokashiImage.frame = img.frame;
        [bokashiImage.superview bringSubviewToFront:bokashiImage];
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
    }
}
@end