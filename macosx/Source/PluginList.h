//
//  PluginList.h
//  Pcsxr
//
//  Created by Gil Pedersen on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PcsxrPlugin.h"

//extern NSMutableArray *plugins;
@class PcsxrPlugin;

@interface PluginList : NSObject <NSFastEnumeration>

+ (nullable PluginList *)sharedList;

- (void)refreshPlugins;
- (nonnull NSArray *)pluginsForType:(int)typeMask;
- (BOOL)hasPluginAtPath:(nonnull NSString *)path;
@property (readonly) BOOL configured;
- (nullable PcsxrPlugin *)activePluginForType:(int)type;
- (BOOL)setActivePlugin:(nonnull PcsxrPlugin *)plugin forType:(int)type;

- (void)disableNetPlug;
- (void)enableNetPlug;

- (nonnull PcsxrPlugin*)objectAtIndexedSubscript:(NSInteger)index;
- (NSInteger)count;

@end
