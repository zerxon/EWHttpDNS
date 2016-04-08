//
//  NSURLRequest+EWHosts.h
//  Beauty
//
//  Created by wallace-leung on 16/4/5.
//  Copyright © 2016年 Zerxon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWHostsMappingProtocol.h"

@interface NSURLRequest (EWHosts)

+ (void)enableHostsWitMapping:(id<EWHostsMappingProtocol>)mapping;

@end
