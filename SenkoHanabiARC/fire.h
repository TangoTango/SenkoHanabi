//
//  fire.h
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/06.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fire : NSObject{
    UIImageView* image; // 画像
    float x, y, w, h; // 位置と高さ・幅
    float maxw, maxh; // 高さ・幅の最大値
    int deleteFlg; // 使われていないかどうか
    int alphaFlg; //
    
}
@property int deleteFlg;
-(id)initWithObject:(UIImageView*)img view:(UIView*)view point:(CGPoint)p;
-(void)Do;


@end
