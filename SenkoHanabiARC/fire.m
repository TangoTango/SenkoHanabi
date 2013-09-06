//
//  fire.m
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/06.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "fire.h"
#import <QuartzCore/QuartzCore.h>

@implementation fire
@synthesize deleteFlg;

-(id)initWithObject:(UIImageView*)img view:(UIView*)view point:(CGPoint)p{
    image = img;
    img.alpha = 0.0f;
    deleteFlg = 0;
    alphaFlg = 1;
    
    maxw = 100;
    maxh = 100;
    if(img.image.size.height < img.image.size.width){
        img.frame = CGRectMake(p.x, p.y, maxw, img.image.size.height*(maxw/img.image.size.width));
    }else{
        img.frame = CGRectMake(p.x, p.y, img.image.size.width*(maxw/img.image.size.height), maxh);
    }
    
    CGRect f = img.frame;
    x = f.origin.x;
    y = f.origin.y;
    w = f.size.width;
    h = f.size.height;
    
    img.layer.anchorPoint = CGPointMake(0, 0.5);
    
    int r = ((rand() % 240) - 30.0f);
    CGFloat angle = (r * M_PI / 180.0f);
    
    img.transform = CGAffineTransformMakeRotation(angle);
    
    [view addSubview:img];
    return self;
}

-(void)Do{
    UIImageView *img = image;
    if(alphaFlg == 1){
        img.alpha += 0.5f;
        if(1.0f < img.alpha){
            alphaFlg = -1;
        }
    }else if(alphaFlg == -1){
        img.alpha -= 0.3f;
        if(img.alpha < 0){
            deleteFlg = 1;
        }
    }
}

@end
