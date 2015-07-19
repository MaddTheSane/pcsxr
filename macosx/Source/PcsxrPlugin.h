//
//  PcsxrPlugin.h
//  Pcsxr
//
//  Created by Gil Pedersen on Fri Oct 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PcsxrPlugin : NSObject
@property (readonly, copy, nonnull) NSString *path;
@property (readonly, copy, nullable) NSString *name;
@property (readonly) int type;

+ (nonnull NSString *)prefixForType:(int)type;
+ (nonnull NSString *)defaultKeyForType:(int)type;
+ (char *__nullable *__nonnull)configEntriesForType:(int)type;
+ (nonnull NSArray<NSString*> *)pluginsPaths;

- (nullable instancetype)initWithPath:(nonnull NSString *)aPath NS_DESIGNATED_INITIALIZER;

@property (readonly, copy, nonnull) NSString *displayVersion;
- (BOOL)hasAboutAs:(int)type;
- (BOOL)hasConfigureAs:(int)type;
- (long)runAs:(int)aType;
- (long)shutdownAs:(int)aType;
- (void)aboutAs:(int)type;
- (void)configureAs:(int)type;
- (BOOL)verifyOK;

@end
