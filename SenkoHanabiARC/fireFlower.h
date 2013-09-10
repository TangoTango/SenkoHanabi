//
//  fireFlower.h
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/07.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "ObjectAL.h"
#import <Foundation/Foundation.h>

@interface fireFlower : NSObject{
    NSMutableArray* layers;//花の火花
    NSMutableArray* lifeCounts;//花の火花の寿命
    int rootX, rootY;//火種の座標
    int toX, toY;//行き先の座標
    float rootDirection;//火種の飛ぶ方向
    int rootFlg;//火種からの火花のアニメーションをしているかどうか
    int maxLifeCount;//全体の寿命上限
    int deleteFlg; // 使われていないかどうか
    UIView* view;//画面全体のビュー
}
@property int deleteFlg;
-(id)initWithPoint:(CGPoint)p view:(UIView*)v;
-(void)DoWithScene:(NSInteger)scene;

@end
