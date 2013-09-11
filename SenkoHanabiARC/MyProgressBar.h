//
//  MyProgressBar.h
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/11.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyProgressBar : NSObject{
    UIView *parentView;
    NSMutableArray* bars;//プログレスバー画像
    UIView *view;//画面全体のビュー
}
-(id)initWithView:(UIView*)v;
-(void)DoWithRate:(float)rate;
-(void)reInit;-(void)hide;
-(int)hideDo;

@end
