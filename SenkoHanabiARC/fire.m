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
    
    maxw = 50;
    maxh = 50;
    
    //int r = (arc4random() % 5);
    
    /*NSMutableArray *offsetArray = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(-30.0f, 30.0f)], [NSValue valueWithCGPoint:CGPointMake(-10.0f, 10.0f)], [NSValue valueWithCGPoint:CGPointMake(0.0f, 0.0f)], [NSValue valueWithCGPoint:CGPointMake(10.0f, 10.0f)], [NSValue valueWithCGPoint:CGPointMake(30.0f, 30.0f)], nil];
    CGPoint offset = [[offsetArray objectAtIndex:r] CGPointValue];
    
    NSMutableArray *angleArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:160.0f], [NSNumber numberWithFloat:140.0f], [NSNumber numberWithFloat:120.0f], [NSNumber numberWithFloat:100.0f], [NSNumber numberWithFloat:80.0f], nil];
    */
    //CGPoint position = CGPointMake(p.x + offset.x, p.y + offset.y);
    
    if(img.image.size.height < img.image.size.width){
        img.frame = CGRectMake(p.x+12, p.y-10, maxw, img.image.size.height*(maxw/img.image.size.width));
        //img.frame = CGRectMake(p.x + offset.x, p.y + offset.y, maxw, img.image.size.height*(maxw/img.image.size.width));
    }else{
        img.frame = CGRectMake(p.x+12, p.y-10, img.image.size.width*(maxw/img.image.size.height), maxh);
    }
    
    CGRect f = img.frame;
    x = f.origin.x;
    y = f.origin.y;
    w = f.size.width;
    h = f.size.height;
    
    img.frame = CGRectMake(x, y, w, h);
    img.layer.contentsRect = CGRectMake(0, 0, 4, 1);
    
    img.layer.anchorPoint = CGPointMake(-0.3, 0.5);
    //img.frame = CGRectMake(x,y,w,h);
    
    int r = ((rand() % 240) - 30.0f);
    angle = (r * M_PI / 180.0f);
    //NSLog(@"x: %lf, y: %lf", position.x, position.y);
    //NSLog(@"angleArray:%lf", [[angleArray objectAtIndex:r] floatValue]);
    //angle = ([[angleArray objectAtIndex:r] floatValue] * M_PI / 180.0f);
    
    //img.transform = CGAffineTransformMakeRotation(1.5f);
     img.transform = CGAffineTransformMakeRotation(angle);
    
    [view addSubview:img];
    return self;
}

-(void)Do{
    UIImageView *img = image;
    if(alphaFlg == 1){
        img.alpha += 0.5f;
        img.layer.contentsRect = CGRectMake(0, 0, 4-img.alpha*3, 1);
        //img.frame = CGRectMake(x, y, w, h);
        if(1.0f <= img.alpha){
            alphaFlg = -1;
        }
    }else if(alphaFlg == -1){
        img.alpha -= 0.3f;
        if(img.alpha < 0){
            [img removeFromSuperview];
            deleteFlg = 1;
        }
    }
}

@end
