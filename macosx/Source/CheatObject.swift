//
//  CheatObject.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/10/14.
//
//

import Cocoa
import SwiftAdditions

func ==(rhs: CheatObject, lhs: CheatObject) -> Bool {
	return false
}

class CheatObject: NSObject, Hashable, Printable {
	var cheatName: String
	var values: [CheatValue]
	var enabled: Bool
	
	init(cheat: UnsafePointer<Cheat>) {
		cheatName = String(UTF8String: cheat.memory.Descr)!
		enabled = cheat.memory.Enabled == 0 ? false : true
		values = [CheatValue]()
		for i in 0..<cheat.memory.n {
			let aCheat = CheatValue(cheatCode: CheatCodes[Int(i + cheat.memory.First)])
			values.append(aCheat)
		}
		
		super.init()
	}
	
	override var hashValue: Int {
		return cheatName.hashValue ^ values.count
	}
	
	override var hash: Int {
		return self.hashValue
	}
	
	override var description: String {
		let asterisk = "*"
		let blank = ""
		var valueString = ""
		for aCheat in values {
			valueString += aCheat.description + "\n"
		}
		return "\(enabled ? asterisk : blank)\(cheatName)\n" + valueString
	}
	
}
