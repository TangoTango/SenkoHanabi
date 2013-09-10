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

static Bgm* sparkBgm = nil; // 効果音

@synthesize deleteFlg;

-(id)initWithPoint:(CGPoint)p view:(UIView*)v{
    
    self = [super init];
    
    view = v;
    layers = [NSMutableArray array];
    lifeCounts = [NSMutableArray array];
    deleteFlg = 0;
    //火種から出ている時フラグ(花が開くときは0)
    rootFlg = 1;
    
    //-120度から120度
    float r = rand() % 240 - 120;
    r = (r * M_PI) / 180.0f;
    rootDirection = r;
    
    CALayer* layer = [CALayer layer];
    //int kind = (rand() % 2) + 6;
    int kind = 8;
    UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"hibana%d.png",kind]];
    layer.contents = (id)(img.CGImage);
    
    //30から80の大きさ
    int maxw = random()%50 + 30;
    int maxh = maxw;
    float dist = 15.0;//火種からの距離
    float imgw;
    float imgh;
    
    if(img.size.height < img.size.width){
        imgw = maxw;
        imgh = img.size.height*(maxw/img.size.width);
    }else{
        imgw = img.size.width*(maxw/img.size.height);
        imgh = maxh;
    }
    layer.frame = CGRectMake(p.x, p.y - imgh/2, imgw, imgh);
    rootX = p.x;
    rootY = p.y;
    toX = rootX + cos(rootDirection+M_PI_2) * (imgw + dist);
    toY = rootY + sin(rootDirection+M_PI_2) * (imgw + dist);
    
    layer.anchorPoint = CGPointMake(-dist/layer.frame.size.width, 0.5);
    layer.frame = CGRectMake(rootX + dist, rootY - imgh/2, layer.frame.size.width, layer.frame.size.height);
    
    layer.transform = CATransform3DMakeRotation( rootDirection + M_PI_2, 0, 0, 1);
    [view.layer addSublayer:layer];
    
    maxLifeCount = 2;
    
    [layers addObject:layer];
    [lifeCounts addObject:[NSNumber numberWithInt:maxLifeCount]];
    
    // 効果音
    if(!sparkBgm) {
        sparkBgm = [[Bgm alloc] initWithPath:@"spark.mp3"];
        [sparkBgm prepareToPlay];
    }
    [sparkBgm play];
    
    return self;
}

-(void)DoWithScene:(NSInteger)scene{
    float deleteCount = 0;
    for(int i = 0; i < [layers count]; i++){
        CALayer* layer = layers[i];
        
        lifeCounts[i] = [NSNumber numberWithInt:[lifeCounts[i] intValue] - 1];
        if([lifeCounts[i] intValue] < 0){
            deleteCount++;
        }else{
            layer.contentsRect = CGRectMake(0, 0, 1.0 + 1.0*([lifeCounts[i] floatValue]/maxLifeCount), 1);
        }
    }
    
    //全て寿命が切れた場合
    if(deleteCount == [layers count]){
        //火種からの火花の場合
        if(rootFlg){
            rootFlg = 0;
            //for(int i = 0; i < [layers count]; i++){
            //    [layers[i] removeFromSuperlayer];
            //}
            //layers = [NSMutableArray array];
            //lifeCounts = [NSMutableArray array];
            if(scene <= 2 || 6<= scene){
                for(int i = 0; i < [layers count]; i++){
                    [layers[i] removeFromSuperlayer];
                }
                layers = nil;
                lifeCounts = nil;
                deleteFlg = 1;
                return;
            }
            
            int r = -120 + (rand()% 40);
            //範囲は-120〜120度
            while(-120 <= r && r <= 120) {
                CALayer* layer = [CALayer layer];
                //int kind = (rand() % 4) + 2;
                int kind = 8;
                UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"hibana%d.png",kind]];
                layer.contents = (id)(img.CGImage);
                
                //30から80の大きさ
                int maxw = random()%50 + 30;
                int maxh = maxw;
                int dist = 0;
                float imgw,imgh;
                
                if(img.size.height < img.size.width){
                    imgw = maxw;
                    imgh = img.size.height*(maxw/img.size.width);
                }else{
                    imgw = img.size.width*(maxw/img.size.height);
                    imgh = maxh;
                }
                layer.frame = CGRectMake(toX, toY-imgh/2, imgw, imgh);
                layer.contentsRect = CGRectMake(0, 0, 2, 1);
                
                layer.anchorPoint = CGPointMake(-dist/layer.frame.size.width, 0.5);
                layer.frame = CGRectMake(toX + dist, toY - imgh/2, layer.frame.size.width, layer.frame.size.height);
                
                layer.transform = CATransform3DMakeRotation( rootDirection + (r*M_PI/180.0f) + M_PI_2, 0, 0, 1);
                [view.layer addSublayer:layer];
                
                [layers addObject:layer];
                [lifeCounts addObject:[NSNumber numberWithInt:maxLifeCount]];
                
                //間隔は41〜80度(2本から4本)
                r += (rand()% 40) + 41;
            }
            
        }else{
            //花の火花の場合
            for(int i = 0; i < [layers count]; i++){
                [layers[i] removeFromSuperlayer];
            }
            layers = nil;
            lifeCounts = nil;
            deleteFlg = 1;
        }
    }
}

@end
