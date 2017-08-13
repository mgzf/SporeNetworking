//
//  SporeNetworking.h
//  SporeNetworking
//
//  Created by luhao on 2017/8/13.
//  Copyright © 2017年 luhao. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SporeNetworking.
FOUNDATION_EXPORT double SporeNetworkingVersionNumber;

//! Project version string for SporeNetworking.
FOUNDATION_EXPORT const unsigned char SporeNetworkingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SporeNetworking/PublicHeader.h>

@interface AbstractInputStream : NSInputStream

// Workaround for http://www.openradar.me/19809067
// This issue only occurs on iOS 8
- (instancetype)init;

@end
