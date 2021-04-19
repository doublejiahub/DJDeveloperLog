//
//  CPPluginScreenRecorder+DeviceInput.m
//  EMiOSDemo
//
//  Created by 杜洁鹏 on 2020/7/14.
//  Copyright © 2020 杜洁鹏. All rights reserved.
//

#import "CPPluginScreenRecorder+DeviceInput.h"
#import <Photos/Photos.h>


@implementation CPPluginScreenRecorder (DeviceInput)

- (void)setupAssetWrite {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH-mm-ss";
    NSString *time = [formatter stringFromDate:[NSDate date]];

    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4",time];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        [fm removeItemAtPath:path error:nil];
    }
    
    self.writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie error:nil];
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{
        AVVideoExpectedSourceFrameRateKey : @(30), //帧率 每秒刷新的帧数(FPS)
        AVVideoMaxKeyFrameIntervalKey : @(30),
        AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
    };
       
    //视频属性
    NSDictionary *videoCompressionSettings = @{
        AVVideoHeightKey : @(UIScreen.mainScreen.bounds.size.height),
        AVVideoWidthKey : @(UIScreen.mainScreen.bounds.size.width),
        AVVideoCodecKey : AVVideoCodecTypeH264,
        AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
        AVVideoCompressionPropertiesKey : compressionProperties,
    };

    self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                         outputSettings:videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    self.videoInput.expectsMediaDataInRealTime = YES;
       
    
    
    if ([self.writer canAddInput:self.videoInput]) {
        [self.writer addInput:self.videoInput];
    }else {
        NSLog(@"AssetWriter videoInput Append Failed");
    }
       
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    // 音频设置
    compressionProperties = @{
        AVSampleRateKey : @(44100),
        AVFormatIDKey : @(kAudioFormatAppleLossless),
        AVEncoderBitDepthHintKey : @(16),
        AVNumberOfChannelsKey : @(1),
        AVChannelLayoutKey : [NSData dataWithBytes:&acl length:sizeof(acl)],
    };
       
    self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                         outputSettings:compressionProperties];
    self.audioInput.expectsMediaDataInRealTime = YES;
       
    
    if ([self.writer canAddInput:self.audioInput]) {
        [self.writer addInput:self.audioInput];
    }else {
        NSLog(@"AssetWriter audioInput append Failed");
    }
    
    self.isRecording = NO;
    self.writeState = EMRecordStateInit;
}

- (void)start {
    if (RPScreenRecorder.sharedRecorder.isRecording) {
           return;
    }
       
    [self setupAssetWrite];
    
    self.writeState = EMRecordStateRecording;
    [self.writer startWriting];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [session setActive:YES error:nil];
    
    RPScreenRecorder.sharedRecorder.microphoneEnabled = YES;
       
    __weak typeof(self) weakSelf = self;
    [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef _Nonnull
                                                                 sampleBuffer,RPSampleBufferType bufferType,
                                                                 NSError *_Nullable error)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!CMSampleBufferDataIsReady(sampleBuffer)) {
            return;
        }
        
        if (strongSelf.writeState != EMRecordStateRecording) {
            return;
        }
        
        if (strongSelf.writer.status == AVAssetWriterStatusFailed) {
            NSLog(@"[录屏]AVAssetWriterStatusFailed");
            return;
        }
        if (strongSelf.writer.status == AVAssetWriterStatusWriting) {
            if (bufferType == RPSampleBufferTypeVideo) {
                if (!strongSelf.isRecording) {
                    [strongSelf.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                    strongSelf.isRecording = YES;
                    NSLog(@"[录屏]开启session 视频处");
                }
                if (CMTimeCompare(kCMTimeInvalid, strongSelf.firstVideoFrameTime) == 0) {
                    strongSelf.firstVideoFrameTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                }
                if ([strongSelf.videoInput isReadyForMoreMediaData]) {
                    @try {
                        [strongSelf.videoInput appendSampleBuffer:sampleBuffer];
                        NSLog(@"[录屏]写入视频数据");
                    } @catch (NSException *exception) {
                        NSLog(@"[录屏]写入视频数据失败");
                    }
                }
            }
            if (bufferType == RPSampleBufferTypeAudioApp || bufferType == RPSampleBufferTypeAudioMic) {

                if (bufferType == RPSampleBufferTypeAudioMic) {
                    return;
                }
                
                if (CMTimeCompare(kCMTimeInvalid, strongSelf.firstVideoFrameTime) == 0
                    || CMTimeCompare(strongSelf.firstVideoFrameTime, CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) == 1) {
                    return;
                }
                if (!strongSelf.isRecording) {
                    [strongSelf.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                    strongSelf.isRecording = YES;
                    NSLog(@"[录屏]开启session 音频处");
                }
                if ([strongSelf.audioInput isReadyForMoreMediaData]) {
                    @try {
                        [strongSelf.audioInput appendSampleBuffer:sampleBuffer];
                        NSLog(@"[录屏]写入音频数据");
                    } @catch (NSException *exception) {
                        NSLog(@"[录屏]写入音频数据失败");
                    }
                }
            }
        }
    } completionHandler:^(NSError *_Nullable error) {
       
    }];
}


- (void)stop {
    __weak typeof(self) weakSelf = self;
    self.isRecording = NO;
    self.writeState = EMRecordStateFinish;
    [RPScreenRecorder.sharedRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
        if (weakSelf.writer) {
            [weakSelf.writer finishWritingWithCompletionHandler:^{
                NSLog(@"录制结束");
                // TODO: 存到相册
            }];
        }
    }];
}



@end
