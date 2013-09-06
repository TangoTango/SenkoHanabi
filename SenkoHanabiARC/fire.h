//
//  fire.h
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/06.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fire : NSObject{
    UIImageView* image;
    float x, y, w, h;
    float maxw, maxh;
    int deleteFlg;
    int alphaFlg;
}
@property int deleteFlg;
-(id)initWithObject:(UIImageView*)img view:(UIView*)view point:(CGPoint)p;
-(void)Do;


@end
