//
//  CPPluginScreenRecorder.h
//  UAS
//
//  Created by haojiajia on 2020/5/12.
//  Copyright © 2020 郝佳佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReplayKit/ReplayKit.h>
#import <AVFoundation/AVFoundation.h>

//系统版本需要是iOS9.0及以上才支持ReplayKit框架录制
@interface CPPluginScreenRecorder : NSObject


typedef NS_ENUM(NSInteger, EMRecordState) {
    EMRecordStateInit = 0,
    EMRecordStatePrepareRecording,
    EMRecordStateRecording,
    EMRecordStateFinish,
    EMRecordStateFail,
};

@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) CMTime firstVideoFrameTime;
@property (nonatomic) EMRecordState writeState;

+ (instancetype)shareScreenRecorder;
- (void)getScreenRecorderInfo:(id)info;
- (void)startScreenRecorderWithInfo:(id)info;

-(void)startRecord;
-(void)stopRecordAndShowVideoPreviewController:(BOOL)isShow;
-(void)stopRecordNotSave;

@end
