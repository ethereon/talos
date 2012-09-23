//
//  KeychainSession.h
//  Talos
//
//  Created by Saumitro Dasgupta on 9/18/12.
//  Copyright (c) 2012 Saumitro Dasgupta. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeychainSessionDelegate <NSObject>

-(void) sessionDidTimeout:(id)session;

@end

@interface KeychainSession : NSObject

+(id) sessionWithTimeout:(NSTimeInterval)timeout;
-(void) begin;
-(void) end;

@property (assign) id<KeychainSessionDelegate> delegate;

@end
