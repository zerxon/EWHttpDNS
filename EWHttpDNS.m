//
//  EWHttpDNS.m
//
//  Created by intermate on 16/4/5.
//  Copyright © 2016年 intermate. All rights reserved.
//

#import "EWHttpDNS.h"

@interface EWHttpDNS()

/**
 HTTPDNS解析后的域名IP映射
 */
@property(nonatomic, strong) NSMutableDictionary *httpDNSMapping;

@property(nonatomic, strong) NSMutableDictionary *cacheExpires;

@end

@implementation EWHttpDNS

+ (instancetype)shareInstance
{
    static EWHttpDNS *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.localStorageEnable = YES;
}

- (NSMutableDictionary *)httpDNSMapping
{
    if (_httpDNSMapping == nil) {
        _httpDNSMapping = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    if ([_httpDNSMapping count] == 0 && self.localStorageEnable) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [_httpDNSMapping addEntriesFromDictionary:[defaults objectForKey:EWHTTPDNS_CACHE_KEY]];
    }
    
    return _httpDNSMapping;
}

- (NSMutableDictionary *)cacheExpires
{
    if (_cacheExpires == nil) {
        _cacheExpires = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    return _cacheExpires;
}

- (void)storeLocalStorage
{
    if (self.localStorageEnable) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.httpDNSMapping forKey:EWHTTPDNS_CACHE_KEY];
        [defaults synchronize];
    }
}

- (void)addCacheExpiryWithHost:(NSString *)host
{
    if (self.cacheInterval > 0) {
        NSTimeInterval expiryTime = [[NSDate date] timeIntervalSince1970] + self.cacheInterval;
        [self.cacheExpires setObject:[NSNumber numberWithDouble:expiryTime] forKey:host];
    }
}

- (BOOL)isExpiryForHost:(NSString *)host
{
    if (self.cacheInterval > 0 && self.cacheExpires[host]) {
        return [self.cacheExpires[host] doubleValue] < [[NSDate date] timeIntervalSince1970];
    }
    
    return YES;
}

- (void)asyncPasreIpByHost:(NSString *)host
                   success:(EWHttpDNSParseSuccessBlock)success
                   failure:(EWHttpDNSParseFailureBlock)failure
{
    if (![self isExpiryForHost:host]) {
    
        if (success) {
            success(host, [self ipForHost:host]);
        }
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/d?dn=%@", EWHTTPDNS_SERVER_IP, host]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:EWHTTPDNS_TIMEOUT];
    
    NSURLSessionTask *task = [urlSession dataTaskWithRequest:request
                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            
                                               //__strong typeof(&*weakSelf) strongSelf = weakSelf;
                                               
                                               BOOL status = NO;
                                               NSString *ip;
                                               
                                               if (error == nil) {
                                                   ip = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                   
                                                   if ([ip length] > 0) {
                                                       status = YES;
                                                       
                                                       [weakSelf.httpDNSMapping setObject:ip forKey:host];
                                                       [weakSelf storeLocalStorage];
                                                       [weakSelf addCacheExpiryWithHost:host];
                                                   }
                                                   else {
                                                       NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"IP is null"};
                                                       error = [[NSError alloc] initWithDomain:NSStringFromClass([weakSelf class])
                                                                                          code:100001
                                                                                      userInfo:userInfo];
                                                   }
                                               }
                                               
                                               if (status) {
                                                   if (success) {
                                                       success(host, ip);
                                                   }
                                               }
                                               else if(failure){
                                                   failure(host, error);
                                               }
                                               
                                           }];
    
    [task resume];
}

- (void)startAsyncParse
{
    if (self.defaultMapping) {
        NSArray *hosts = [self.defaultMapping allKeys];
        for (NSString *host in hosts) {
            [self asyncPasreIpByHost:host
                             success:nil
                             failure:^(NSString *host, NSError *error) {
                                 NSLog(@"[Error]: %@", error);
                             }];
        }
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"[%@]: Nothing to parse.", NSStringFromClass([self class])];
        NSLog(@"%@", msg);
    }
}

- (NSString *)ipForHost:(NSString *)host
{
    if (self.httpDNSMapping[host]) {
        return self.httpDNSMapping[host];
    }
    else {
        return self.defaultMapping[host];
    }
}

- (void)clearLocalStorage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:EWHTTPDNS_CACHE_KEY];
    [defaults synchronize];
}

@end