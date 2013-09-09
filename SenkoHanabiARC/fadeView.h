//
//  fadeView.h
//  SenkoHanabiARC
//
//  Created by 丹後 偉也 on 2013/09/08.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fadeView : NSObject{
    float upAlpha, downAlpha, topAlpha;
    UIView *superview;
    UIView *obj;
    int fontSize, Line;
    CGPoint P;
    NSString *Text;
    UIView *View;
}
@property int alphaFlag;
-(id)initWithImageName:(NSString*)name superview:(UIView*)view upAlpha:(float)up downAlpha:(float)down topAlpha:(float)top;
-(id)initWithLableText:(NSString*)text point:(CGPoint)p line:(NSInteger)line fontsize:(NSInteger)fontsize upAlpha:(float)up downAlpha:(float)down topAlpha:(float)top superview:(UIView*)view;
-(void)reInit;
-(int)Do;
-(void)hide;
-(void)changeTextWithString:(NSString *)newText;
-(void)reverse;
-(int)hideDo;
@end
