//
//  EWHostsProtocol.h
//  Beauty
//
//  Created by wallace-leung on 16/4/5.
//  Copyright © 2016年 Zerxon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EWHostsMappingProtocol <NSObject>

- (NSString *)ipForHost:(NSString *)host;

@end