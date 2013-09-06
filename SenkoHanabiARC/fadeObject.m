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

-(id)initWithObject:(UIImageView*)obj isImage:(int)isimg view:(UIView*)view{
    if( !bokashiImage ){
        bokashiImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradation2.png"]];
        bokashiImage.alpha = 1.0f;
        [view addSubview:bokashiImage];
        [view bringSubviewToFront:bokashiImage];
    }
    object = obj;
    isImage = isimg;
    obj.alpha = 0.0f;
    deleteFlg = 0;
    
    maxw = 100;
    maxh = 100;
    if(obj.image.size.height < obj.image.size.width){
        obj.frame = CGRectMake(0, 60, maxw, obj.image.size.height*(maxw/obj.image.size.width));
    }else{
        obj.frame = CGRectMake(0, 60, obj.image.size.width*(maxw/obj.image.size.height), maxh);
    }
    
    CGRect f = obj.frame;
    x = f.origin.x;
    y = f.origin.y;
    w = f.size.width;
    h = f.size.height;
    
    [view addSubview:obj];
    return self;
}

-(void)Do{
    if(isImage){
        UIImageView *img = object;
        CGRect f = img.frame;
        if(f.origin.x + f.size.width/2 < img.superview.frame.size.width/2){
            img.alpha += 0.02f;
            img.frame = CGRectMake(f.origin.x + 1.5f - w * 0.01f, f.origin.y - h * 0.01f,
                                   f.size.width + w * 0.02f, f.size.height + h * 0.02f);
            
        }else{
            img.alpha -= 0.02f;
            img.frame = CGRectMake(f.origin.x + 1.5f + w * 0.01f, f.origin.y + h * 0.01f,
                                   f.size.width - w * 0.02f, f.size.height - h * 0.02f);
            if(img.alpha < 0){
                [img removeFromSuperview];
                deleteFlg = 1;
            }
        }
        
        bokashiImage.frame = img.frame;
        [bokashiImage.superview bringSubviewToFront:bokashiImage];
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