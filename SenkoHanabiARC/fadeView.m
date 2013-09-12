//
//  fadeView.m
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/08.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "fadeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation fadeView

@synthesize alphaFlag;

-(id)initWithImageName:(NSString*)name frame:(CGRect)frame upAlpha:(float)up downAlpha:(float)down topAlpha:(float)top superview:(UIView*)view{
    obj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    obj.frame = frame;
    [view addSubview:obj];
    rotation = 0;
    
    superview = view;
    upAlpha = up;
    downAlpha = down;
    topAlpha = top;
    alphaFlag = 1;
    
    /* 回転 */
    
    // y軸に対して回転．（z軸を指定するとUIViewのアニメーションのように回転）
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // アニメーションのオプションを設定
    animation.duration = 2.5; // アニメーション速度
    animation.repeatCount = 9999; // 繰り返し回数
    
    // 回転角度を設定
    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 開始時の角度
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI]; // 終了時の角度
    
    // アニメーションを追加
    [obj.layer addAnimation:animation forKey:@"rotate-layer"];
    
    return self;
}
-(id)initWithLableText:(NSString*)text point:(CGPoint)p fontsize:(NSInteger)fontsize upAlpha:(float)up downAlpha:(float)down topAlpha:(float)top superview:(UIView*)view{
    
    Text = text;
    P = p;
    int line = [[text componentsSeparatedByString:@"\n"] count];
    fontSize = fontsize;
    View = view;
    
    obj = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    int w = fontsize * line;
    int boxsize = fontsize * 1.6;
    p.x = p.x - w / 2;
    int ix = 0;
    int iy = 0;
    for(int i = 0; i < text.length; i++){
        NSString* c = [text substringWithRange:NSMakeRange(i, 1)];
        if([c rangeOfString:@"\n"].location != NSNotFound){
            iy = 0;
            ix++;
        }else if([c rangeOfString:@"ー"].location != NSNotFound){
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bo2.png"]];
            img.frame = CGRectMake(p.x + fontsize * (line-1-ix), p.y + fontsize * iy, fontSize, fontSize);
            [obj addSubview:img];
            iy++;
        }else if(/*[c rangeOfString:@"。"].location != NSNotFound*/0){
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maru.png"]];
            img.frame = CGRectMake(p.x + fontsize * (line-1-ix), p.y + fontsize * iy, fontSize, fontSize);
            [obj addSubview:img];
            iy++;
        }else{
            UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(p.x + fontsize * (line-1-ix), p.y + fontsize * iy ,
                                                                   fontsize,boxsize)];
            l.font = [UIFont fontWithName:@"AoyagiKouzanFontTOTF" size:fontsize+5];
            l.backgroundColor = [UIColor clearColor];
            
            if( [self isInt:c] ){
                int number = [c intValue];
                NSString *numberStr = @[ @"〇", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九"][number];
                l.text = numberStr;
            }else if( [c rangeOfString:@"。"].location != NSNotFound){
                CGRect move = l.frame;
                move.origin.x += fontsize*(23.0/40.0);
                move.origin.y -= fontsize*(28.0/40.0);
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
            l.textColor = [UIColor whiteColor];
            [obj addSubview:l];
            iy++;
        }
    }
    obj.alpha = 0.0f;
    [view addSubview:obj];
    
    superview = view;
    upAlpha = up;
    downAlpha = down;
    topAlpha = top;
    alphaFlag = 1;
    return self;
}
-(void)reverse{
    obj.transform = CGAffineTransformMakeRotation(M_PI);
}
-(void)rotationDo{
    obj.alpha += upAlpha;
    //rotation += 0.05;
    //obj.transform = CGAffineTransformMakeRotation(rotation);
}

-(void)changeTextWithString:(NSString *)newText{
    [obj removeFromSuperview];
    
    id t = [self initWithLableText:newText point:P fontsize:fontSize upAlpha:upAlpha downAlpha:downAlpha topAlpha:topAlpha superview:View];
    t=t;
}

//二回目初期化用
-(void)reInit{
    obj.alpha = 0.0f;
    alphaFlag = 1;
}
-(BOOL)isDisp{
    if(0 < obj.alpha){
        return 1;
    }
    return 0;
}
-(void)show{
    obj.alpha = 1.0f;
}
-(void)hide{
    obj.alpha = 0.0f;
}
-(int)hideDo{
    if(obj.alpha <= 0.0f){
        return 1;
    }else{
        obj.alpha -= downAlpha;
        return 0;
    }
}

-(int)Do{
    if(alphaFlag == 1){
        obj.alpha += upAlpha;
        if(topAlpha < obj.alpha){
            alphaFlag = -1;
        }
    }else if(alphaFlag == 2){
        if( obj.alpha < topAlpha ){
            obj.alpha += upAlpha;
        }
    
    }else{
        obj.alpha -= downAlpha;
        if(obj.alpha <= 0.0f){
            return 1;
        }
    }
    return 0;
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
