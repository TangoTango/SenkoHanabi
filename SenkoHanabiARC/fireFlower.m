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
    lifeCounts = [NSMutableArray array];
    deleteFlg = 0;
    //50〜90度
    int r = 0;
    while (r < 360) {
        r += (rand()%40) + 50;
        CALayer* layer = [CALayer layer];
        int kind = (rand() % 4) + 2;
        UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"hibana%d.png",kind]];
        layer.contents = (id)(img.CGImage);
        
        int maxw = 70;
        int maxh = 70;
        
        if(img.size.height < img.size.width){
            layer.frame = CGRectMake(p.x, p.y, maxw, img.size.height*(maxw/img.size.width));
        }else{
            layer.frame = CGRectMake(p.x, p.y, img.size.width*(maxw/img.size.height), maxh);
        }
        
        layer.anchorPoint = CGPointMake(0, 0.7);
        layer.transform = CATransform3DMakeRotation( r * M_PI / 180.0f, 0, 0, 1);
        [view.layer addSublayer:layer];
        
        maxLifeCount = 3;
        
        [layers addObject:layer];
        [alphaFlags addObject:[NSNumber numberWithInt:1]];
        [lifeCounts addObject:[NSNumber numberWithInt:maxLifeCount]];
    }
    return self;
}

-(void)Do{
    float deleteCount = 0;
    for(int i = 0; i < [layers count]; i++){
        CALayer* layer = layers[i];
        if(i==0){
            NSLog(@"%f", 1 + 3*([lifeCounts[i] floatValue]/maxLifeCount));
        }
        lifeCounts[i] = [NSNumber numberWithInt:[lifeCounts[i] intValue] - 1];
        layer.contentsRect = CGRectMake(0, 0, 1 + 1*([lifeCounts[i] floatValue]/maxLifeCount), 1);
        //layer.contentsRect = CGRectMake(0, 0, 1, 1);
        if([lifeCounts[i] intValue] < 0){
            deleteCount++;
        }
        
    }
    if(deleteCount == [layers count]){
        for(int i = 0; i < [layers count]; i++){
            [layers[i] removeFromSuperlayer];
        }
        layers = nil;
        alphaFlags = nil;
        lifeCounts = nil;
        deleteFlg = 1;
    }
        
}

@end
