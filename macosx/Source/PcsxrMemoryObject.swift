//
//  PcsxrMemoryObject.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa
import SwiftAdditions

@objc enum PCSXRMemFlag: Int8 {
	case Deleted
	case Free
	case Used
	case Link
	case EndLink
};


private func ImagesFromMcd(theBlock: UnsafePointer<McdBlock>) -> [NSImage] {
	var toRet = [NSImage]()
	let unwrapped = theBlock.memory
	let iconArray: [Int16] = getArrayFromMirror(reflect(unwrapped.Icon))
	for i in 0..<unwrapped.IconCount {
		autoreleasepool() {
			if let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 16, pixelsHigh: 16, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0) {
				for v in 0..<256 {
					let x = v % 16
					let y = v / 16
					let c = iconArray[Int(i * 256) + v]
					let r: Int32 = Int32(c & 0x001F) << 3
					let g: Int32 = (Int32(c & 0x03E0) >> 5) << 3
					let b: Int32 = (Int32(c & 0x7C00) >> 10) << 3
					imageRep.setColor(NSColor(calibratedRed: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1), atX: Int(x), y: Int(y))
				}
				let memImage = NSImage()
				memImage.addRepresentation(imageRep)
				memImage.size = NSSize(width: 32, height: 32)
				toRet.append(memImage)
			}
		}
	}
	return toRet
}

private func MemoryLabelFromFlag(flagNameIndex: PCSXRMemFlag) -> String {
	switch (flagNameIndex) {
	case .EndLink:
		return MemLabelEndLink;
		
	case .Link:
		return MemLabelLink;
		
	case .Used:
		return MemLabelUsed;
		
	case .Deleted:
		return MemLabelDeleted;
		
	default:
		return MemLabelFree;
	}
}

private let MemLabelDeleted = NSLocalizedString("MemCard_Deleted", comment: "MemCard_Deleted")
private let MemLabelFree = NSLocalizedString("MemCard_Free", comment: "MemCard_Free")
private let MemLabelUsed = NSLocalizedString("MemCard_Used", comment: "MemCard_Used")
private let MemLabelLink = NSLocalizedString("MemCard_Link", comment: "MemCard_Link")
private let MemLabelEndLink = NSLocalizedString("MemCard_EndLink", comment: "MemCard_EndLink")

private var attribMemLabelDeleted = NSAttributedString()
private var attribMemLabelFree = NSAttributedString()
private var attribMemLabelUsed = NSAttributedString()
private var attribMemLabelLink = NSAttributedString()
private var attribMemLabelEndLink = NSAttributedString()

private var attribsInit: dispatch_once_t = 0

private var imageBlank: NSImage? = nil
private func BlankImage() -> NSImage {
	if imageBlank == nil {
		let imageRect = NSRect(x: 0, y: 0, width: 16, height: 16)
		let anImg = NSImage(size: imageRect.size)
		anImg.lockFocus()
		NSColor.blackColor().set()
		NSBezierPath.fillRect(imageRect)
		anImg.unlockFocus()
		imageBlank = anImg
	}
	return imageBlank!.copy() as! NSImage
}

func MemFlagsFromBlockFlags(blockFlags: UInt8) -> PCSXRMemFlag {
	if ((blockFlags & 0xF0) == 0xA0) {
		if ((blockFlags & 0xF) >= 1 && (blockFlags & 0xF) <= 3) {
			return .Deleted;
		} else {
			return .Free
		}
	} else if ((blockFlags & 0xF0) == 0x50) {
		if ((blockFlags & 0xF) == 0x1) {
			return .Used
		} else if ((blockFlags & 0xF) == 0x2) {
			return .Link
		} else if ((blockFlags & 0xF) == 0x3) {
			return .EndLink
		}
	} else {
		return .Free;
	}
	
	//Xcode complains unless we do this...
	NSLog("Unknown flag %x", blockFlags);
	return .Free;
}

class PcsxrMemoryObject: NSObject {
	let title: String
	let name: String
	let identifier: String
	let imageArray: [NSImage]
	let flag: PCSXRMemFlag
	let startingIndex: Int
	let blockSize: Int
	let hasImages: Bool
	
	init(mcdBlock infoBlock: UnsafePointer<McdBlock>, startingIndex startIdx: Int, size memSize: Int) {
		startingIndex = startIdx
		blockSize = memSize
		let unwrapped = infoBlock.memory
		flag = MemFlagsFromBlockFlags(unwrapped.Flags)
		if flag == .Free {
			imageArray = []
			hasImages = false
			title = "Free block"
			identifier = ""
			name = ""
		} else {
			let sjisName: [CChar] = getArrayFromMirror(reflect(unwrapped.sTitle), appendLastObject: 0)
			if let aname = String(CString: sjisName, encoding:NSShiftJISStringEncoding) {
				title = aname
			} else {
				let usName: [CChar] = getArrayFromMirror(reflect(unwrapped.Title), appendLastObject: 0)
				title = String(CString: usName, encoding: NSASCIIStringEncoding)!
			}
			imageArray = ImagesFromMcd(infoBlock)
			if imageArray.count == 0 {
				hasImages = false
			} else {
				hasImages = true
			}
			let memNameCArray: [CChar] = getArrayFromMirror(reflect(unwrapped.Name), appendLastObject: 0)
			let memIDCArray: [CChar] = getArrayFromMirror(reflect(unwrapped.ID), appendLastObject: 0)
			name = String(UTF8String: memNameCArray)!
			identifier = String(UTF8String: memIDCArray)!
		}
		
		super.init()
	}
	
	var iconCount: Int {
		return imageArray.count
	}

	class func memFlagsFromBlockFlags(blockFlags: UInt8) -> PCSXRMemFlag {
		return MemFlagsFromBlockFlags(blockFlags)
	}
	
	private(set) lazy var image: NSImage = {
		if (self.hasImages == false) {
			let tmpBlank = BlankImage()
			tmpBlank.size = NSMakeSize(32, 32);
			return tmpBlank;
		}
		
		var gifData = NSMutableData()
		
		var dst = CGImageDestinationCreateWithData(gifData, kUTTypeGIF, self.iconCount, nil);
		let gifPrep: NSDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: Float(0.30)]];
		for theImage in self.imageArray {
			let imageRef = theImage.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue()
			CGImageDestinationAddImage(dst, imageRef, gifPrep)
		}
		CGImageDestinationFinalize(dst);
		
		var _memImage = NSImage(data: gifData)!
		_memImage.size = NSMakeSize(32, 32);
		return _memImage
		}()
	
	var attributedFlagName: NSAttributedString {
		dispatch_once(&attribsInit) {
			func SetupAttrStr(mutStr: NSMutableAttributedString, txtclr: NSColor) {
				let wholeStrRange = NSMakeRange(0, count(mutStr.string));
				let ourAttrs: [String: AnyObject] = [NSFontAttributeName : NSFont.systemFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize)),
					NSForegroundColorAttributeName: txtclr]
				mutStr.addAttributes(ourAttrs, range: wholeStrRange)
				mutStr.setAlignment(.CenterTextAlignment, range: wholeStrRange)
			}
			
			var tmpStr = NSMutableAttributedString(string: MemLabelFree)
			SetupAttrStr(tmpStr, NSColor.greenColor())
			attribMemLabelFree = NSAttributedString(attributedString: tmpStr)
			
			#if DEBUG
				tmpStr = NSMutableAttributedString(string: MemLabelEndLink)
				SetupAttrStr(tmpStr, NSColor.blueColor())
				attribMemLabelEndLink = NSAttributedString(attributedString: tmpStr)
				
				tmpStr = NSMutableAttributedString(string: MemLabelLink)
				SetupAttrStr(tmpStr, NSColor.blueColor())
				attribMemLabelLink = NSAttributedString(attributedString: tmpStr)
				
				tmpStr = NSMutableAttributedString(string: MemLabelUsed)
				SetupAttrStr(tmpStr, NSColor.controlTextColor())
				attribMemLabelUsed = NSAttributedString(attributedString: tmpStr)
				#else
				tmpStr = NSMutableAttributedString(string: "Multi-save")
				SetupAttrStr(tmpStr, NSColor.blueColor())
				attribMemLabelEndLink = NSAttributedString(attributedString: tmpStr)
				attribMemLabelLink = attribMemLabelEndLink;

				//display nothing
				attribMemLabelUsed = NSAttributedString(string: "")
				
				#endif
			tmpStr = NSMutableAttributedString(string: MemLabelDeleted)
			SetupAttrStr(tmpStr, NSColor.redColor())
			attribMemLabelDeleted = NSAttributedString(attributedString: tmpStr)
		}
		switch (flag) {
		case .EndLink:
			return attribMemLabelEndLink;
			
		case .Link:
			return attribMemLabelLink;
			
		case .Used:
			return attribMemLabelUsed;
			
		case .Deleted:
			return attribMemLabelDeleted;
			
		default:
			return attribMemLabelFree;
		}

	}
	
	var firstImage: NSImage {
		if hasImages == false {
			return BlankImage()
		}
		return imageArray[0]
	}
	
	class func memoryLabelFromFlag(flagNameIdx: PCSXRMemFlag) -> String {
		return MemoryLabelFromFlag(flagNameIdx)
	}
	
	var flagName: String {
		return MemoryLabelFromFlag(flag)
	}

	override var description: String {
		return "\(title): Name: \(name) ID: \(identifier), type: \(flagName), start: \(startingIndex) size: \(blockSize)"
	}
	
	var showCount: Bool {
		if flag == .Free {
			//Always show the size of the free blocks
			return true;
		} else {
			return blockSize != 1;
		}
	}
}
