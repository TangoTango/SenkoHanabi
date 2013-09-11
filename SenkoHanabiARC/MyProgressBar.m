//
//  MyProgressBar.m
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/11.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "MyProgressBar.h"

@implementation MyProgressBar
-(id)initWithView:(UIView*)v{
    view = v;
    parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 360, 500)];
    bars = [NSMutableArray array];
    
    int ix = 0;
    int number = 10;
    int x = 10, y = 100, w = 300, h = 150 / number;
    
    UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress1.png"]];
    imgv.frame = CGRectMake(x + ix * (double)w/number, y, (double)w/number, h);
    imgv.alpha = 0.5f;
    [parentView addSubview:imgv];
    [bars addObject:imgv];
    ix++;
    for(int i = 1; i <= 8; i++,ix++){
        
        UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress3.png"]];
        imgv.frame = CGRectMake(x + ix * (float)w/number, y, (float)w/number, h);
        imgv.alpha = 0.5f;
        [parentView addSubview:imgv];
        [bars addObject:imgv];
    }
    
    imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress2.png"]];
    imgv.frame = CGRectMake(x + ix * (float)w/number, y, (float)w/number, h);
    imgv.alpha = 0.5f;
    [parentView addSubview:imgv];
    [bars addObject:imgv];
    
    parentView.alpha = 1.0f;
    [view addSubview:parentView];
    
    return self;
}
-(void)reInit{
    for(int i = 0; i < [bars count]; i++){
        UIImageView *imgv = bars[i];
        imgv.alpha = 0.5f;
    }
    parentView.alpha = 1.0f;
}
-(void)DoWithRate:(float)rate{
    for(int i = 0; i < [bars count] && ((float)(i+1)/[bars count]) < rate; i++){
        UIImageView *imgv = bars[i];
        imgv.alpha = 1.0f;
    }
}

-(void)hide{
    parentView.alpha = 0.0f;
}
-(int)hideDo{
    parentView.alpha -= 0.03f;
    if(parentView.alpha < 0.0f){
        return 1;
    }
    return 0;
}
@end
