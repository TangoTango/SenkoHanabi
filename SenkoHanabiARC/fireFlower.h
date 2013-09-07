//
//  fireFlower.h
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/07.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fireFlower : NSObject{
    NSMutableArray* layers;
    NSMutableArray* alphaFlags;
    int deleteFlg; // 使われていないかどうか
}
@property int deleteFlg;
-(id)initWithPoint:(CGPoint)p view:(UIView*)view;
-(void)Do;

@end
