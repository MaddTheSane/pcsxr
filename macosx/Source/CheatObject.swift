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
	return rhs.cheatName == lhs.cheatName && rhs.values == lhs.values
}

class CheatObject: NSObject, Hashable, Printable, SequenceType {
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
	
	func addValuesObject(aVal: CheatValue) {
		values.append(aVal)
	}
	
	func addValueObject(aVal: CheatValue) {
		addValuesObject(aVal)
	}
	
	var countOfValues: Int {
		return values.count
	}
	
	subscript(index: Int) -> CheatValue {
		get {
			return values[index]
		}
		set {
			values[index] = newValue
		}
	}
	
	func generate() -> IndexingGenerator<[CheatValue]> {
		return values.generate()
	}
	
	init(name: String, enabled: Bool = false) {
		cheatName = name
		self.enabled = enabled
		values = [CheatValue()]
		
		super.init()
	}
	
	override convenience init() {
		self.init(name: "")
	}
	
	override var hashValue: Int {
		return cheatName.hashValue ^ values.count
	}
	
	override var hash: Int {
		return self.hashValue
	}
	
	override func isEqual(object: AnyObject?) -> Bool {
		if object == nil {
			return false
		}
		
		if let unwrapped = object as? CheatObject {
			return self == unwrapped
		} else {
			return false
		}
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
