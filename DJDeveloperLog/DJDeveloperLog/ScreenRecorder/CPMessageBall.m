//
//  CPMessageBall.m
//  UAS
//
//  Created by haojiajia on 2020/5/25.
//  Copyright © 2020 郝佳佳. All rights reserved.
//

#import "CPMessageBall.h"
#import "CPPluginScreenRecorder.h"

@interface CPMessageBall()


@end

@implementation CPMessageBall

+ (instancetype)shareMessageBall {
    static CPMessageBall *messageBall;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize ballSize = CGSizeMake(60, 120);
         messageBall = [[CPMessageBall alloc] initWithFrame:CGRectMake(0, 200, ballSize.width, ballSize.height)];
        [messageBall setupUI];
    });
    return messageBall;
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

- (UIButton *)addTestButton:(NSString *)title YScale:(CGFloat)YScale action:(SEL)action{
    CGFloat buttonH = 40;
    UIButton *testButton = [[UIButton alloc]initWithFrame:CGRectMake(0, YScale*buttonH+10*YScale, 60, buttonH)];
    [testButton setTitle:title forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    testButton.titleLabel.font = [UIFont systemFontOfSize:16];
    testButton.backgroundColor = [UIColor redColor];
    [self addSubview:testButton];
    [testButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return testButton;
}


- (void)setupUI {
    UIButton *testButton = [self addTestButton:@"start" YScale:0 action:@selector(startRecord)];
    UIButton *testButton2 = [self addTestButton:@"end" YScale:1 action:@selector(stopRecord)];
}

- (void)startRecord {
    [[CPPluginScreenRecorder shareScreenRecorder] startRecord];
//    [[CPPluginScreenStreamRecorder shareScreenRecorder] startRecord];
}


- (void)stopRecord {
    [[CPPluginScreenRecorder shareScreenRecorder] stopRecordAndShowVideoPreviewController:YES];
//    [[CPPluginScreenStreamRecorder shareScreenRecorder] stopRecord];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    if (self.frame.size.width == [UIScreen mainScreen].bounds.size.width) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.superview];
    // 上一个触摸点
    CGPoint previousPoint = [touch previousLocationInView:self.superview];
    
    // 当前view的中点
    CGPoint center = self.center;
    
    center.x += (currentPoint.x - previousPoint.x);
    center.y += (currentPoint.y - previousPoint.y);
    // 修改当前view的中点(中点改变view的位置就会改变)
    self.center = center;
}


@end
