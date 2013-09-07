//
//  fireFlower.m
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/07.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "fireFlower.h"
#import <QuartzCore/QuartzCore.h>

@implementation fireFlower
@synthesize deleteFlg;
-(id)initWithPoint:(CGPoint)p view:(UIView*)view{
    layers = [NSMutableArray array];
    alphaFlags = [NSMutableArray array];
    deleteFlg = 0;
    return self;
    //50〜90度
    int r = 0;
    while (r < 360) {
        r += (rand()%40) + 50;
        CALayer* layer = [CALayer layer];
        layer.contents = (id)[UIImage imageNamed:@"hibana2.png"].CGImage;        
        layer.frame = CGRectMake(p.x, p.y, 100, 100);
        //layer.transform = CATransform3DMakeRotation( r * M_PI / 180.0f, 0, 0, 1);
        [view.layer addSublayer:layer];
        
        [layers addObject:layer];
        [alphaFlags addObject:[NSNumber numberWithInt:1]];
    }
    return self;
}

-(void)Do{
    for(int i = 0; i < [layers count]; i++){
        CALayer* layer = layers[i];
        if([alphaFlags[i] intValue] == 1){
            layer.opacity += 0.5f;
            if(1.0f <= layer.opacity){
                //alphaFlg = -1;
            }
        }else if([alphaFlags[i] intValue] == -1){
            layer.opacity -= 0.3f;
            if(layer.opacity < 0){
                [layer removeFromSuperlayer];
                deleteFlg = 1;
            }
        }
        
    }
        //img.layer.contentsRect = CGRectMake(0, 0, 4-img.alpha*3, 1);
        //img.frame = CGRectMake(x, y, w, h);
        
}

@end
