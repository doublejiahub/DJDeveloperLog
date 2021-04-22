//
//  CPPluginScreenRecorder.m
//  UAS
//
//  Created by haojiajia on 2020/5/12.
//  Copyright © 2020 郝佳佳. All rights reserved.
//

#import <Photos/Photos.h>
#import "CPPluginScreenRecorder.h"
#import "CPPluginScreenRecorder+DeviceInput.h"

@interface CPPluginScreenRecorder()

@property (nonatomic, copy) NSString *fileName;

@end


@implementation CPPluginScreenRecorder

+ (instancetype)shareScreenRecorder {
    static CPPluginScreenRecorder *shareRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareRecorder = [[CPPluginScreenRecorder alloc] init];
    });
    return shareRecorder;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - 开始录制
-(void)startRecord{
    [self start];
}


#pragma mark - 结束录制
- (void)stopRecordNotSave {
    if ([RPScreenRecorder sharedRecorder].recording == YES) {
        [self stopRecordAndShowVideoPreviewController:NO];
    }
}

//结束录制
-(void)stopRecordAndShowVideoPreviewController:(BOOL)isShow{
    [self stop];
}




- (void)uploadAliyun {
    //获取最近一次的相册图片/视频的信息PHAsset
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.includeAssetSourceTypes = PHAssetSourceTypeNone;//默认相册
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = [assetsFetchResults firstObject];
    
    PHVideoRequestOptions *videoRequestOption = [[PHVideoRequestOptions alloc] init];
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequestOption resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL];
        NSLog(@"%@",videoData);
        
//        AliyunOSSProvider *ossProvider = [AliyunOSSProvider shareProvider];
//        NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4",[NSString getCurrentTimeOfMonth],[NSString getCurrentTime]];
//        [ossProvider uploadVideoWithData:videoData uploadPath:videoPath];
//        [ossProvider resumeUploadWithData:videoData uploadPath:videoPath fileURL:urlAsset.URL];
    }];


}


#pragma mark - 其他方法
//判断对应系统版本是否支持ReplayKit
-(BOOL)systemVersionOK{
    if ([[UIDevice currentDevice].systemVersion floatValue]<9.0) {
        return NO;
    } else {
        return YES;
    }
}
//获取rootVC
-(UIViewController *)getRootVC{
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}


- (BOOL) isAuthorizedCameraAuthority {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    if (status != PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
    if (status != PHAuthorizationStatusAuthorized) {
        // 申请权限
       [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status != PHAuthorizationStatusAuthorized) {
                    [self handleCameraDeny];
                    return;
                }else {
                    [self startRecord];
                }
            });
        }];
    }else {
        return YES;
    }
    
    return NO;
}

/**
 *  跳转到设置界面
 */
- (void) handleCameraDeny {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"没有相机权限无法进行屏幕录制，请到设置中打开相册权限" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertController animated:YES completion:nil];

}




@end

