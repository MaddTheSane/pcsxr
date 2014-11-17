//
//  CheatController.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/11/14.
//
//

import Cocoa

let kCheatsName = "cheats"

class CheatController: NSWindowController {
	var cheats: [CheatObject]
	var cheatValues = [CheatValue]()
	@IBOutlet weak var cheatView: NSTableView!
	@IBOutlet weak var editCheatWindow: NSWindow!
	@IBOutlet weak var editCheatView: NSTableView!
	@IBOutlet weak var addressFormatter: PcsxrHexadecimalFormatter!
	@IBOutlet weak var valueFormatter: PcsxrHexadecimalFormatter!
	
	required init?(coder: NSCoder) {
		cheats = [CheatObject]()
		
		super.init(coder: coder)
	}
	
	override init(window: NSWindow?) {
		cheats = [CheatObject]()
		
		super.init(window: window)
	}
	
	override convenience init() {
		self.init(windowNibName: "CheatWindow")
	}
	
	override var windowNibName: String {
		return "CheatWindow"
	}
	
	func refresh() {
		cheatView.reloadData()
		refreshCheatArray()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		valueFormatter.hexPadding = 4
		addressFormatter.hexPadding = 8
		refreshCheatArray()
		self.addObserver(self, forKeyPath: kCheatsName, options: .New | .Old, context: nil)
	}
	
	func refreshCheatArray() {
		var tmpArray = [CheatObject]()
		for i in 0..<Int(NumCheats) {
			let tmpObj = CheatObject(cheat: Cheats[i])
			tmpArray.append(tmpObj)
		}
		self.cheats = tmpArray
		self.setDocumentEdited(false)
	}
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		if keyPath == kCheatsName {
			self.setDocumentEdited(true)
		}
	}
	
	func reloadCheats() {
		let manager = NSFileManager.defaultManager()
		let tmpURL = manager.URLForDirectory(.ItemReplacementDirectory, inDomain: .UserDomainMask, appropriateForURL: NSBundle.mainBundle().bundleURL, create: true, error: nil)!.URLByAppendingPathComponent("temp.cht", isDirectory: false)
		var tmpStr = ""
		for aCheat in cheats {
			tmpStr += aCheat.description + "\n"
		}
		(tmpStr as NSString).writeToURL(tmpURL, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
		LoadCheats(tmpURL.fileSystemRepresentation)
		manager.removeItemAtURL(tmpURL, error: nil)
	}
	
}
