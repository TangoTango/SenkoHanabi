//
//  fadeView.m
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/08.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "fadeView.h"

@implementation fadeView

@synthesize alphaFlag;
float upAlpha, downAlpha, topAlpha;
UIView *superview;
id obj;

-(id)initWithImageName:(NSString*)name superview:(UIView*)view  upAlpha:(float)up downAlpha:(float)down topAlpha:(float)top{
    obj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    //詳しい初期化を。。。後回し
    [obj setAlpha:0.0f];
    
    /*UIImage *img = [UIImage imageNamed:@"again2.gif"];
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(160-75, 230, 150, 45)];
    [nextButton setBackgroundImage:img forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];*/
    
    [view addSubview:obj];
    superview = view;
    upAlpha = up;
    downAlpha = down;
    topAlpha = top;
    alphaFlag = 1;
    return self;
}
-(id)initWithLableText:(NSString*)text point:(CGPoint)p line:(NSInteger)line fontsize:(NSInteger)fontsize upAlpha:(float)up downAlpha:(float)down topAlpha:(float)top superview:(UIView*)view{
    
    obj = [NSMutableArray array];
    int w = fontsize * line;
    int boxsize = fontsize * 1.5;
    p.x = p.x - w / 2;
    int ix = 0;
    int iy = 0;
    for(int i = 0; i < text.length; i++){
        NSString* c = [text substringWithRange:NSMakeRange(i, 1)];
        if([c rangeOfString:@"\n"].location == NSNotFound){
            float f = p.x + fontsize * (line-1-ix);
            UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(p.x + boxsize * (line-1-ix), p.y + boxsize * iy ,
                                                                   320,100)];
            l.font = [UIFont fontWithName:@"Hiragino Mincho ProN" size:fontsize];
            l.textAlignment = NSTextAlignmentCenter;
            l.text = c;
            l.backgroundColor = [UIColor clearColor];
            l.textColor = [UIColor whiteColor];
            l.alpha = 0.0f;
            [view addSubview:l];
            [obj addObject:l];
            iy++;
        }else{
            iy = 0;
            ix++;
        }
    }
    
    superview = view;
    upAlpha = up;
    downAlpha = down;
    topAlpha = top;
    alphaFlag = 1;
    return self;
}

//二回目用
-(void)reInit{
    if( [obj isKindOfClass:[UIView class]] ){
        UIView *ui = obj;
        ui.alpha = 0.0f;
    }else{
        for(int i = 0; i < [obj count]; i++){
            UIView *ui = obj[i];
            ui.alpha = 0.0f;
        }
    }
    alphaFlag = 1;
}

-(int)Do{
    if( [obj isKindOfClass:[UIView class]] ){
        //UIView一つの場合
        return [self DoWithView:obj];
    }else{
        //UIViewの配列の場合
        int flg = 1;
        NSArray *arr = obj;
        for(id obj in arr){
            if([self DoWithView:obj] == 0){
                flg = 0;
            }
        }
        return flg;
    }
}
-(int)DoWithView:(UIView*)obj{
    UIView* ui = obj;
    if(alphaFlag == 1){
        ui.alpha += upAlpha;
        if(topAlpha < ui.alpha){
            alphaFlag = -1;
        }
    }else{
        ui.alpha -= downAlpha;
        if(ui.alpha < 0.0f){
            return 1;
        }
    }
    return 0;
}
@end
