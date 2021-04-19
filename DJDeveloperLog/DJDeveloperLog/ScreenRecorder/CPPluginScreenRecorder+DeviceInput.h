//
//  CPPluginScreenRecorder+DeviceInput.h
//  EMiOSDemo
//
//  Created by 杜洁鹏 on 2020/7/14.
//  Copyright © 2020 杜洁鹏. All rights reserved.
//

#import "CPPluginScreenRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPPluginScreenRecorder (DeviceInput)
- (void)setupAssetWrite;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
