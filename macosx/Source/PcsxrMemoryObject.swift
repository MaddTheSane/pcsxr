//
//  PcsxrMemoryObject.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa


private func imagesFromMcd(theBlock: UnsafePointer<McdBlock>) -> [NSImage] {
	var toRet = [NSImage]()
	let unwrapped = theBlock.memory
	for i in 0..<unwrapped.IconCount {
		
	}
	return toRet
}
/*
+ (NSArray *)imagesFromMcd:(McdBlock *)block
{
NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithCapacity:block->IconCount];
for (int i = 0; i < block->IconCount; i++) {
NSImage *memImage;
@autoreleasepool {
NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:16 pixelsHigh:16 bitsPerSample:8 samplesPerPixel:3 hasAlpha:NO isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];

short *icon = block->Icon;

int x, y, c, v, r, g, b;
for (v = 0; v < 256; v++) {
x = (v % 16);
y = (v / 16);
c = icon[(i * 256) + v];
r = (c & 0x001f) << 3;
g = ((c & 0x03e0) >> 5) << 3;
b = ((c & 0x7c00) >> 10) << 3;
[imageRep setColor:[NSColor colorWithCalibratedRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0] atX:x y:y];
}
memImage = [[NSImage alloc] init];
[memImage addRepresentation:imageRep];
[memImage setSize:NSMakeSize(32, 32)];
}
[imagesArray addObject:memImage];
}
return [NSArray arrayWithArray:imagesArray];
}

*/

class PcsxrMemoryObject: NSObject {

}
