//
//  fadeObject.h
//  SenkoHanabi
//
//  Created by 丹後 偉也 on 2013/09/05.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fadeObject : NSObject {
    id object; // アニメーションの対象となるオブジェクト
    int isImage; // オブジェクトが画像であるかどうか
    NSMutableArray* uilabels;
    NSMutableArray* alphaFlags;
    int alphaFlag;
    float x, y, w, h; // 画像の位置と幅，高さ
    float maxw, maxh; // 画像の幅，高さの最大値
    int deleteFlg; // 画像が消えているかどうか
    int animationPattern; // アニメーションのパターンを表す変数
}
@property int deleteFlg;
-(id)initWithImage:(UIImageView*)img view:(UIView*)view;
-(id)initWithString:(NSString*)str view:(UIView*)view;
-(void)Do;
-(void)DeleteDo;

@end