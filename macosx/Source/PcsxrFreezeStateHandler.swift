//
//  PcsxrFreezeStateHandler.swift
//  Pcsxr
//
//  Created by C.W. Betts on 1/18/15.
//
//

import Cocoa

class PcsxrFreezeStateHandler: NSObject, PcsxrFileHandle {
	class func supportedUTIs() -> [AnyObject] {
		return ["com.codeplex.pcsxr.freeze"]
	}
	
	func handleFile(theFile: String) -> Bool {
		if CheckState(theFile.fileSystemRepresentation()) != 0 {
			return false
		}
		
		if !EmuThread.active() {
			let pluginList = PluginList.sharedList()
			if NSUserDefaults.standardUserDefaults().boolForKey("NetPlay") {
				pluginList!.enableNetPlug()
			} else {
				pluginList!.disableNetPlug()
			}
			
			EmuThread.run()
		}
		
		return EmuThread.defrostAt(theFile)
	}
}
