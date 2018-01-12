//
//  ViewController.m
//  Hanzi
//
//  Created by MINGFENWANG on 2017/12/30.
//  Copyright © 2017年 MINGFENWANG. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property(strong, nonatomic) HanziView *teach_view;
@property(strong, nonatomic) NSArray *graphics_array;
@property(strong, nonatomic) NSMutableDictionary *graphics_dictionary;
@property(strong, nonatomic) NSString *text_book;
@property(strong, nonatomic) NSArray *titles;
@property(nonatomic) NSUInteger book_index;
@property(nonatomic) NSUInteger word_index;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger timer_status;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *demo_btn;
@property (strong, nonatomic) IBOutlet UIToolbar *book_shell;
@property (strong, nonatomic) IBOutlet UIToolbar *command_shell;

- (void)speakWord:(NSString*)keyword;
- (NSString *)pinyin:(NSString*)keyword;
- (void)openTimer;
- (void)closeTimer;
- (void)timerAction:(NSTimer *)timer;
- (IBAction)selectBook:(id)sender;
- (IBAction)selectWord:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSError *error;

    // Read graphics text to array
    NSString *graphicsPath = [[NSBundle mainBundle] pathForResource:@"graphics" ofType:@"txt"];
    _graphics_array = [[NSString stringWithContentsOfFile:graphicsPath
                                                encoding:NSUTF8StringEncoding
                                                   error:&error]
                      componentsSeparatedByString:@"\n"];
    
    if (_graphics_array) {
        // Create dictionary
        _graphics_dictionary = [NSMutableDictionary dictionary];

        // Ignore last empty line
        for (int i=0; i<[_graphics_array count]-1; i++) {
            NSString *token = [_graphics_array objectAtIndex:i];

            // Cut keyword
            NSString *startStr = @"{\"character\":\"";
            NSString *EndStr = @"\",\"strokes\":";
            NSRange firstInstance = [token rangeOfString:startStr];
            NSRange secondInstance = [token rangeOfString:EndStr];
            NSUInteger startLocation = firstInstance.location + firstInstance.length;
            NSRange finalRange = NSMakeRange(startLocation, secondInstance.location - startLocation);
            NSString *keyword = [token substringWithRange:finalRange];

            // Add {keyword, line} to dictionary
            [_graphics_dictionary setObject:[NSNumber numberWithInt:i] forKey:keyword];
        }
    }
    
    // Read text book
    NSString *textBookPath = [[NSBundle mainBundle] pathForResource:@"textbook" ofType:@"txt"];
    _text_book = [NSString stringWithContentsOfFile:textBookPath
                                           encoding:NSUTF8StringEncoding
                                              error:&error];
    
    // Initial titles
    _titles = [NSArray arrayWithObjects:@"三字經", @"千字文", @"百家姓", nil];

    // Initial book index
    _book_index = 0;

    // Initial word index
    _word_index = 0;
    
    _teach_view = [[HanziView alloc] init];
    [[self view] addSubview:_teach_view];
    
    // Initial speech synthesizer
    _synthesizer = [[AVSpeechSynthesizer alloc] init];

    [self selectBook:nil];
    
    _timer = nil;
    _timer_status = 0;
}

- (void)openTimer {
    [self closeTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f / 60.0f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (void)closeTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        _timer_status = 0;
    }
}

- (void)timerAction:(NSTimer *)timer{
    switch (_timer_status) {
        case 0:
            [_teach_view simulateTouchesBegan];
            _timer_status++;
            break;
            
        case 1:
            [_teach_view simulateTouchesMoved];
            if ([_teach_view touchesMoveCompleted]) {
                _timer_status++;
            }
            break;
            
        case 2:
            // Forward to next word
            if ([_teach_view isLastStroke]) {
                [self selectWord:nil];
            } else {
                [_teach_view simulateTouchesEnded];
            }
            _timer_status = 0;
            break;
            
        default:
            break;
    }
}

- (void)viewDidLayoutSubviews {
    CGRect content_box = self.view.readableContentGuide.layoutFrame;
    CGFloat min_size = MIN(content_box.size.width, content_box.size.height);
    BOOL horizon_mode = UIScreen.mainScreen.bounds.size.width > UIScreen.mainScreen.bounds.size.height;
    if (horizon_mode) {
        min_size -= _book_shell.bounds.size.height + _command_shell.bounds.size.height + 20.0f;
    }
    [_teach_view setFrame:CGRectMake((content_box.origin.x + (content_box.origin.x + content_box.size.width)) * 0.5f - min_size * 0.5f, (content_box.origin.y + (content_box.origin.y + content_box.size.height)) * 0.5f - min_size * 0.5f, min_size, min_size)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)speakWord:(NSString*)keyword {
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:keyword];
//    utterance.rate = 0.5f;
//    utterance.pitchMultiplier = 0.8f;
//    utterance.postUtteranceDelay = 0.1f;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"];
    [_synthesizer speakUtterance:utterance];
    //NSLog(@"%@", [self pinyin:keyword]);
}

- (NSString *)pinyin:(NSString*)keyword {
    NSMutableString *str = [keyword mutableCopy];
    CFStringTransform(( CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    
    return [str stringByReplacingOccurrencesOfString: @" " withString: @""];
}

- (IBAction)selectBook:(id)sender {
    UIBarButtonItem *btn = sender;
    _book_index = btn ? [btn tag] : 0;

    NSString *keyword = nil;
    _word_index = [_text_book rangeOfString:[_titles objectAtIndex:_book_index]].location;
    keyword = [[_text_book substringFromIndex:_word_index] substringToIndex:1];
    NSNumber *line = [_graphics_dictionary valueForKey:keyword];
    
    [self speakWord:[_titles objectAtIndex:_book_index]];
    [_teach_view setJson:[_graphics_array objectAtIndex:[line intValue]]];
}

- (IBAction)selectWord:(id)sender {
    UIBarButtonItem *btn = sender;
    NSInteger btn_tag = btn ? [btn tag] : 101;

    if (btn_tag == 200) {
        if (_timer) {
            [self closeTimer];
            [_demo_btn setTitle:@"演示筆順"];
        } else {
            [self openTimer];
            [_demo_btn setTitle:@"停止演示"];
        }
        return;
    }

    NSString *keyword = nil;
    NSNumber *line = nil;
    while (true) {
        if (btn_tag == 100) {
            _word_index--;
            if (_word_index == -1) {
                _word_index = [_text_book length] - 1;
            }
        }
        if (btn_tag == 101) {
            _word_index++;
            if (_word_index == [_text_book length]) {
                _word_index = 0;
            }
        }
        keyword = [[_text_book substringFromIndex:_word_index] substringToIndex:1];
        line = [_graphics_dictionary valueForKey:keyword];
        if (line) {
            break;
        }
    }
    
    [self speakWord:keyword];
    [_teach_view setJson:[_graphics_array objectAtIndex:[line intValue]]];
}

@end
