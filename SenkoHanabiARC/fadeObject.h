//
//  fadeObject.h
//  SenkoHanabi
//
//  Created by 丹後 偉也 on 2013/09/05.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fadeObject : NSObject {
    id object;
    int isImage;
    NSMutableArray* uilabels;
    NSMutableArray* alphaFlags;
    float x, y, w, h;
    float maxw, maxh;
    int deleteFlg;
}
@property int deleteFlg;
-(id)initWithImage:(UIImageView*)img view:(UIView*)view;
-(id)initWithString:(NSString*)str view:(UIView*)view;
-(void)Do;
-(void)DeleteDo;

@end