//
//  EWHttpDNS.h
//
//  Created by intermate on 16/4/5.
//  Copyright © 2016年 intermate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWHostsMappingProtocol.h"

#define EWHTTPDNS_SERVER_IP @"119.29.29.29"
#define EWHTTPDNS_CACHE_KEY @"EWHTTPDNS_CACHE_KEY"
#define EWHTTPDNS_TIMEOUT   15

typedef void(^EWHttpDNSParseSuccessBlock)(NSString *host, NSString *ip);
typedef void(^EWHttpDNSParseFailureBlock)(NSString *host, NSError *error);

@interface EWHttpDNS : NSObject <EWHostsMappingProtocol>

/**
 本地缓存
 */
@property(nonatomic, assign) BOOL localStorageEnable; //default is YES

/**
 缓存时长 单位为秒, 默认为0, 代表不缓存
 */
@property(nonatomic, assign) NSTimeInterval cacheInterval;

/**
 默认域名IP映射
 */
@property(nonatomic, strong) NSDictionary *defaultMapping;


+ (instancetype)shareInstance;
- (void)clearLocalStorage;
- (void)startAsyncParse;
- (void)asyncPasreIpByHost:(NSString *)host
                   success:(EWHttpDNSParseSuccessBlock)success
                   failure:(EWHttpDNSParseFailureBlock)failure;

@end
