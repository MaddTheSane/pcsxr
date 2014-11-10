//
//  LaunchArg.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa

class LaunchArg: NSObject {
	let launchOrder: UInt32
	let theBlock: dispatch_block_t
	let argument: String

	init(launchOrder order: UInt32, argument arg: String, block: dispatch_block_t) {
		launchOrder = order
		argument = arg
		theBlock = block
		
		super.init()
	}
	
	func addToDictionary(toAdd: NSMutableDictionary) {
		toAdd[argument] = self;
	}
	
	override var description: String {
		return "Arg: \(argument), order: \(launchOrder), block addr: \(theBlock)"
	}
}
