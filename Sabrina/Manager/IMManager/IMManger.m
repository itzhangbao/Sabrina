//
//  IMManger.m
//  Sabrina
//
//  Created by Jumbo on 2021/2/8.
//

#import "IMManger.h"

@implementation IMManger

+ (instancetype)shared {
    static IMManger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IMManger alloc] init];
    });
    return instance;
}

- (void)setupSDK {
    // 初始化
    [[TUIKit sharedInstance] setupWithAppId:SDKAPPID];
    
    // 登录
    NSString *userSig = [GenerateTestUserSig genTestUserSig:chatUserMe];
    [[TUIKit sharedInstance] login:chatUserMe userSig:userSig succ:^{
        NSLog(@"-----> 登录成功");
    } fail:^(int code, NSString *msg) {
        NSLog(@"-----> 登录失败");
    }];
    
    TUIKitConfig *config = [TUIKitConfig defaultConfig];
    config.avatarType = TAvatarTypeRadiusCorner;
    config.avatarCornerRadius = 5.f;
    
                        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];
}

- (void)onNewMessage:(NSNotification *)notification
{
    V2TIMMessage *msg = notification.object;
    
    if (msg.elemType == V2TIM_ELEM_TYPE_LOCATION && msg.locationElem != nil) {
        // 当前定位
        double currentlat = msg.locationElem.latitude;
        double currentlong = msg.locationElem.longitude;
        
        // 本地存储定位
        double localLat = [NSUserDefaults.standardUserDefaults doubleForKey:@"TaLocationLat"];
        double localLong = [NSUserDefaults.standardUserDefaults doubleForKey:@"TaLocationLong"];
        
        if (currentlat != localLat || currentlong != localLong) {
            [NSUserDefaults.standardUserDefaults setDouble:currentlat forKey:@"TaLocationLat"];
            [NSUserDefaults.standardUserDefaults setDouble:currentlong forKey:@"TaLocationLong"];
            [NSUserDefaults.standardUserDefaults synchronize];
            
            // 规划路线
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationReceivedTaLocationChanged" object:nil];
            
        }
        
    }
}

- (void)sendLocation:(CLLocation *)location {
//    message.elemType = V2TIM_ELEM_TYPE_CUSTOM;
    // 设置推送
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
//    info.ext = [TUICallUtils dictionary2JsonStr:extParam];
    
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createLocationMessage:@"定位" longitude:location.coordinate.longitude latitude:location.coordinate.latitude];
    
//    @weakify(self)
    [[V2TIMManager sharedInstance] sendMessage:message receiver:chatUserTa groupID:nil priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:info progress:^(uint32_t progress) {
        
    } succ:^{
        NSLog(@"发送定位成功");
    } fail:^(int code, NSString *desc) {
        NSLog(@"发送失败%@", desc);
    }];
    
}

@end
