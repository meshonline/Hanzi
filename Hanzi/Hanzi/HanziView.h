//
//  HanziView.h
//  Hanzi
//
//  Created by MINGFENWANG on 2017/12/30.
//  Copyright © 2017年 MINGFENWANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HanziView : UIView

@property(nonatomic) NSUInteger current_stroke;
@property(nonatomic) CGFloat current_stroke_phase;
@property(nonatomic) CGFloat current_stroke_width;
@property(nonatomic) CGFloat current_stroke_length;
@property(strong, nonatomic, nonnull) NSDictionary *outline_dictionary;
@property(nonatomic) CGPoint start_point;

- (CGFloat)getStrokeRatio;
- (NSUInteger)getStrokeCount;
- (CGFloat)getStrokeLength:(NSUInteger)index;
- (void)setJson:(nonnull NSString*)jsonString;
- (BOOL)isLastStroke;
- (BOOL)touchesMoveCompleted;
- (void)simulateTouchesBegan;
- (void)simulateTouchesMoved;
- (void)simulateTouchesEnded;
- (void)myTouchesBegan:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)myTouchesMoved:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)myTouchesEnded:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)makeFrame;
- (void)makeCross1;
- (void)makeCross2;
- (void)makePath:(NSUInteger)index;
- (void)makeMedian:(NSUInteger)index;

@end
