//
//  HanziView.m
//  Hanzi
//
//  Created by MINGFENWANG on 2017/12/30.
//  Copyright © 2017年 MINGFENWANG. All rights reserved.
//

#import "HanziView.h"

@implementation HanziView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Do something
    }
    return self;
}

- (CGFloat)getStrokeRatio {
    CGSize size = [self bounds].size;
    CGFloat max_size = MAX(size.width, size.height);
    return max_size / 1024.0f;
}

- (NSUInteger)getStrokeCount {
    NSArray *pathArray = [_outline_dictionary valueForKey:@"medians"];
    return [pathArray count];
}

- (CGFloat)getStrokeLength:(NSUInteger)index {
    NSArray *pathArray = [_outline_dictionary valueForKey:@"medians"];
    NSArray *finalPathArray = [pathArray objectAtIndex:index];
    
    CGFloat distance = 0.0f;
    CGFloat save_x = 0.0f;
    CGFloat save_y = 0.0f;
    for (int i=0; i<[finalPathArray count]; i++) {
        NSArray *token = [finalPathArray objectAtIndex:i];
        CGFloat x = [[token objectAtIndex:0] intValue];
        CGFloat y = [[token objectAtIndex:1] intValue];
        if (i > 0) {
            distance += sqrtf((x - save_x) * (x - save_x) + (y - save_y) * (y - save_y));
        }
        save_x = x;
        save_y = y;
    }
    
    return distance;
}

- (NSString *)getSubstring:(NSString *)value betweenString:(NSString *)separator {
    NSRange firstInstance = [value rangeOfString:separator];
    NSRange secondInstance = [[value substringFromIndex:firstInstance.location + firstInstance.length] rangeOfString:separator];
    NSRange finalRange = NSMakeRange(firstInstance.location + separator.length, secondInstance.location);
    
    return [value substringWithRange:finalRange];
}

- (void)makeFrame {
    // Get current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGFloat ratio = [self getStrokeRatio];
    CGContextMoveToPoint(context, 1.0f * ratio, 1.0f * ratio);
    CGContextAddLineToPoint(context, 1.0f * ratio, 1023.0f * ratio);
    CGContextAddLineToPoint(context, 1023.0f * ratio, 1023.0f * ratio);
    CGContextAddLineToPoint(context, 1023.0f * ratio, 1.0f * ratio);
    CGContextAddLineToPoint(context, 1.0f * ratio, 1.0f * ratio);

    CGContextClosePath(context);
}

- (void)makeCross1 {
    // Get current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGFloat ratio = [self getStrokeRatio];
    CGContextMoveToPoint(context, 0.0f, 512.0f * ratio);
    CGContextAddLineToPoint(context, 1024.0f * ratio, 512.0f * ratio);
    CGContextMoveToPoint(context, 512.0f * ratio, 0.0f);
    CGContextAddLineToPoint(context, 512.0f * ratio, 1024.0f * ratio);

    CGContextClosePath(context);
}

- (void)makeCross2 {
    // Get current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGFloat ratio = [self getStrokeRatio];
    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, 1024.0f * ratio, 1024.0f * ratio);
    CGContextMoveToPoint(context, 0.0f, 1024.0f * ratio);
    CGContextAddLineToPoint(context, 1024.0f * ratio, 0.0f);
    
    CGContextClosePath(context);
}

- (void)makePath:(NSUInteger)index {
    NSArray *pathArray = [_outline_dictionary valueForKey:@"strokes"];
    NSString *pathContent = [pathArray objectAtIndex:index];
    NSArray *finalPathArray = [pathContent componentsSeparatedByString:@" "];

    // Get current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    int counter = 0;
    CGFloat ratio = [self getStrokeRatio];
    CGFloat offset = 900.0f * ratio;
    while (counter < [finalPathArray count]) {
        NSString *token = [finalPathArray objectAtIndex:counter];
        //NSLog(@"%@", token);
        if ([token isEqualToString:@"M"]) {
            CGFloat x = [[finalPathArray objectAtIndex:counter + 1] intValue] * ratio;
            CGFloat y = [[finalPathArray objectAtIndex:counter + 2] intValue] * ratio;
            CGContextMoveToPoint(context, x, offset - y);
            counter += 3;
        }
        if ([token isEqualToString:@"Q"]) {
            CGFloat x1 = [[finalPathArray objectAtIndex:counter + 1] intValue] * ratio;
            CGFloat y1 = [[finalPathArray objectAtIndex:counter + 2] intValue] * ratio;
            CGFloat x2 = [[finalPathArray objectAtIndex:counter + 3] intValue] * ratio;
            CGFloat y2 = [[finalPathArray objectAtIndex:counter + 4] intValue] * ratio;
            CGContextAddQuadCurveToPoint(context, x1, offset - y1, x2, offset - y2);
            counter += 5;
        }
        if ([token isEqualToString:@"L"]) {
            CGFloat x = [[finalPathArray objectAtIndex:counter + 1] intValue] * ratio;
            CGFloat y = [[finalPathArray objectAtIndex:counter + 2] intValue] * ratio;
            CGContextAddLineToPoint(context, x, offset - y);
            counter += 3;
        }
        if ([token isEqualToString:@"Z"]) {
            break;
        }
    }
    CGContextClosePath(context);
}

- (void)makeMedian:(NSUInteger)index {
    NSArray *pathArray = [_outline_dictionary valueForKey:@"medians"];
    NSArray *finalPathArray = [pathArray objectAtIndex:index];

    // Get current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGFloat ratio = [self getStrokeRatio];
    CGFloat offset = 900.0f * ratio;
    for (int i=0; i<[finalPathArray count]; i++) {
        NSArray *token = [finalPathArray objectAtIndex:i];
        CGFloat x = [[token objectAtIndex:0] intValue] * ratio;
        CGFloat y = [[token objectAtIndex:1] intValue] * ratio;
        if (i == 0) {
            CGContextMoveToPoint(context, x, offset - y);
        } else {
            CGContextAddLineToPoint(context, x, offset - y);
        }
    }
    CGContextClosePath(context);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat ratio = [self getStrokeRatio];

    // Get current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set fill color
    [[UIColor lightGrayColor] setFill];
    // Fill the canvas
    CGContextFillRect(context, [self bounds]);

    // Set stroke color
    [[UIColor redColor] setStroke];
    // Set line width
    CGContextSetLineWidth(context, 12.0f * ratio);
    [self makeFrame];
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 6.0f * ratio);
    CGFloat dashLengths[] = {20.0f * ratio, 20.0f * ratio};
    CGContextSetLineDash(context, 0.0f, dashLengths, 2);
    [self makeCross1];
    CGContextStrokePath(context);
    [self makeCross2];
    CGContextStrokePath(context);
    // Cancel dash line mode
    CGContextSetLineDash(context, 0, dashLengths, 0);

    NSArray *pathArray = [_outline_dictionary valueForKey:@"strokes"];
    for (int i=0; i<[pathArray count]; i++) {
        [self makePath:i];
        // Set stroke color
        [[UIColor whiteColor] setStroke];
        // Set fill color
        if (i < _current_stroke) {
            [[UIColor blackColor] setFill];
        }
        if (i == _current_stroke) {
            [[UIColor redColor] setFill];
        }
        if (i > _current_stroke) {
            [[UIColor darkGrayColor] setFill];
        }
        // Set line width
        CGContextSetLineWidth(context, 6.0f * ratio);
        // Stroke and fill the path
        CGContextDrawPath(context, kCGPathFillStroke);
    }

    if (_current_stroke < [self getStrokeCount]) {
        // Make a path
        [self makePath:_current_stroke];
        
        // Set the drawing clip area
        CGContextClip (context);
        
        // Make a median
        [self makeMedian:_current_stroke];
        
        // Set stroke color
        [[UIColor blueColor] setStroke];
        // Set line width
        CGContextSetLineWidth(context, _current_stroke_width * ratio);
        CGContextSetLineCap(context, kCGLineCapRound);
        // Fill the path with dash line, change phase from length to zero is wonderful.
        CGFloat dashLengths[] = {2048.0f * ratio, 2048.0f * ratio};
        CGContextSetLineDash(context, _current_stroke_phase * ratio, dashLengths, 2);
        CGContextStrokePath(context);
    }
}

- (void)setJson:(NSString*)jsonString {
    // Convert to data
    NSData *dataInfo = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Convert to dictionary
    NSError *error;
    _outline_dictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:dataInfo options:NSJSONReadingAllowFragments error:&error];
    
    _current_stroke = 0;
    _current_stroke_phase = 2047.0f;
    _current_stroke_width = 0.0f;
    _current_stroke_length = [self getStrokeLength:_current_stroke];

    [self setNeedsDisplay];
}

- (BOOL)isLastStroke {
    return _current_stroke == [self getStrokeCount] - 1;
}

- (BOOL)touchesMoveCompleted {
    return 2047.0f - _current_stroke_phase >= _current_stroke_length - 10.0f;
}

- (void)simulateTouchesBegan {
    [self myTouchesBegan:nil withEvent:nil];
}

- (void)simulateTouchesMoved {
    [self myTouchesMoved:nil withEvent:nil];
}

- (void)simulateTouchesEnded {
    [self myTouchesEnded:nil withEvent:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self myTouchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self myTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self myTouchesEnded:touches withEvent:event];
}

- (void)myTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        _start_point = touchPoint;
    }

    _current_stroke_length = [self getStrokeLength:_current_stroke];
}

- (void)myTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGFloat distance = [self getStrokeRatio] * 10.0f;

    if (touches) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        distance = sqrtf((touchPoint.x - _start_point.x) * (touchPoint.x - _start_point.x) + (touchPoint.y - _start_point.y) * (touchPoint.y - _start_point.y));
        _start_point = touchPoint;
    }

    CGFloat ratio = [self getStrokeRatio];
    if (_current_stroke_width < 150.0f) {
        _current_stroke_width += 2.0f * distance / ratio;
    } else {
        if (![self touchesMoveCompleted]) {
            _current_stroke_phase -= distance / ratio;
        }
    }
    [self setNeedsDisplay];
}

- (void)myTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    _current_stroke++;
    if (_current_stroke == [self getStrokeCount]) {
        _current_stroke = 0;
    }
    _current_stroke_phase = 2047.0f;
    _current_stroke_width = 0.0f;
    [self setNeedsDisplay];
}

@end
