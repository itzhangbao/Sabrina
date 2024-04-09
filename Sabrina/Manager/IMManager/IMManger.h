//
//  IMManger.h
//  Sabrina
//
//  Created by Jumbo on 2021/2/8.
//

#import <Foundation/Foundation.h>
#import "ImSDK.h"
#import "TUIKit.h"
#import "GenerateTestUserSig.h"
#import <MapKit/MKFoundation.h>
#import <MapKit/MKAnnotation.h>

@class CLLocation;


static NSString * chatUserMe = @"Jumbo";
static NSString * chatUserTa = @"Sabrina";

NS_ASSUME_NONNULL_BEGIN

@interface IMManger : NSObject

+ (instancetype)shared;

- (void)setupSDK;

- (void)sendLocation:(CLLocation *)location;
@end

NS_ASSUME_NONNULL_END
