//
//  PcsxrMemoryObject.h
//  Pcsxr
//
//  Created by Charles Betts on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "sio.h"

typedef NS_ENUM(char, PCSXRMemFlags) {
	memFlagDeleted,
	memFlagFree,
	memFlagUsed,
	memFlagLink,
	memFlagEndLink
};
