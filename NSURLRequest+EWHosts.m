//
//  NSURLRequest+EWHosts.m
//  Beauty
//
//  Created by wallace-leung on 16/4/5.
//  Copyright © 2016年 Zerxon. All rights reserved.
//

#import "NSURLRequest+EWHosts.h"
#import <objc/runtime.h>

@implementation NSURLRequest (EWHosts)

static id<EWHostsMappingProtocol> hostMapping ;

+ (void)enableHostsWitMapping:(id<EWHostsMappingProtocol>)mapping;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hostMapping = mapping;
        
        Class clazz = NSClassFromString(@"NSURLRequest");
        Method origMethod = class_getInstanceMethod(clazz, @selector(initWithURL:cachePolicy:timeoutInterval:));
        Method newMethod = class_getInstanceMethod(clazz, @selector(initWithNewURL:cachePolicy:timeoutInterval:));
        
        if (origMethod && newMethod) {
            method_exchangeImplementations(origMethod, newMethod);
        }else{
            //NSLog(@"origMethod:%@ newMethod:%@",origMethod,newMethod);
        }
    });
}

- (id)initWithNewURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    NSString *scheme = URL.scheme;
    
    if ([scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame
        || [scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSString *host = URL.host;
        NSString *ip = [hostMapping ipForHost:host];
        
        if (ip) {
            NSLog(@"NSURLRequest: host:%@ -> ip:%@",host,ip);
            NSString *absoluteString = [URL absoluteString];
            NSRange hostRange = [absoluteString rangeOfString:host];
            if (hostRange.location != NSNotFound) {
                absoluteString = [absoluteString stringByReplacingCharactersInRange:hostRange withString:ip];
                NSURL *newURL = [NSURL URLWithString:absoluteString];
                NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc] initWithNewURL:newURL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
                [newRequest setValue:host forHTTPHeaderField:@"Host"];
                
                self = newRequest;
                return self;
            }
        }
    }
    
    return [self initWithNewURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
}

@end
