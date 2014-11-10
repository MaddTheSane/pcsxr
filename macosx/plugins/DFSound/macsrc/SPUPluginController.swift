//
//  SPUPluginController.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa

private let PrefsKey = APP_ID + " Settings"


class SPUPluginController: NSWindowController {
	@IBOutlet var hiCompBox: NSCell!
	@IBOutlet var interpolValue: NamedSlider!
	@IBOutlet var irqWaitBox: NSCell!
	@IBOutlet var monoSoundBox: NSCell!
	@IBOutlet var reverbValue: NamedSlider!
	@IBOutlet var xaEnableBox: NSCell?
	@IBOutlet var xaSpeedBox: NSCell!
	@IBOutlet var volumeValue: NamedSlider!
	
	var keyValues = [NSObject: AnyObject]()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let spuBundle = NSBundle(forClass: self.dynamicType)
		
		interpolValue.strings = [NSLocalizedString("(No Interpolation)", bundle: spuBundle, comment: "(No Interpolation)"),
			NSLocalizedString("(Simple Interpolation)", bundle: spuBundle, comment: "(Simple Interpolation)"),
			NSLocalizedString("(Gaussian Interpolation)", bundle: spuBundle, comment: "(Gaussian Interpolation)"),
			NSLocalizedString("(Cubic Interpolation)", bundle: spuBundle, comment: "(Cubic Interpolation)")]
		
		reverbValue.strings = [NSLocalizedString("(No Reverb)", bundle: spuBundle, comment: "(No Reverb)"),
			NSLocalizedString("(Simple Reverb)", bundle: spuBundle, comment: "(Simple Reverb)"),
			NSLocalizedString("(PSX Reverb)", bundle: spuBundle, comment: "(PSX Reverb)")]
		
		volumeValue.strings = [NSLocalizedString("(Muted)", bundle: spuBundle, comment: "(Muted)"),
			NSLocalizedString("(Low)", bundle: spuBundle, comment: "(Low)"),
			NSLocalizedString("(Medium)", bundle: spuBundle, comment: "(Medium)"),
			NSLocalizedString("(Loud)", bundle: spuBundle, comment: "(Loud)"),
			NSLocalizedString("(Loudest)", bundle: spuBundle, comment: "(Loudest)")]
		
	}
	
	func loadValues() {
		let defaults = NSUserDefaults.standardUserDefaults()
		ReadConfig();
		
		self.keyValues = defaults.dictionaryForKey(PrefsKey)!
		
		hiCompBox.integerValue = (keyValues[kHighCompMode] as NSNumber).boolValue ? NSOnState : NSOffState
		irqWaitBox.integerValue = (keyValues[kSPUIRQWait] as NSNumber).boolValue ? NSOnState : NSOffState
		monoSoundBox.integerValue = (keyValues[kMonoSoundOut] as NSNumber).boolValue ? NSOnState : NSOffState
		xaSpeedBox.integerValue = (keyValues[kXAPitch] as NSNumber).boolValue ? NSOnState : NSOffState

		/*
		[hiCompBox setIntValue:[keyValues[@"High Compatibility Mode"] boolValue]];
		[irqWaitBox setIntValue:[keyValues[@"SPU IRQ Wait"] boolValue]];
		[monoSoundBox setIntValue:[keyValues[@"Mono Sound Output"] boolValue]];
		[xaSpeedBox setIntValue:[keyValues[@"XA Pitch"] boolValue]];

*/
		
		interpolValue.intValue = (keyValues[kInterpolQual] as NSNumber).intValue
		reverbValue.intValue = (keyValues[kReverbQual] as NSNumber).intValue
		volumeValue.intValue = (keyValues[kVolume] as NSNumber).intValue
		
		
	}
	
	@IBAction func ok(sender: AnyObject?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		
		//var writeDic = NSMutableDictionary(dictionary: self.keyValues)
		
		
		/*
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSMutableDictionary *writeDic = [NSMutableDictionary dictionaryWithDictionary:self.keyValues];
		writeDic[@"High Compatibility Mode"] = ([hiCompBox intValue] ? @YES : @NO);
		writeDic[@"SPU IRQ Wait"] = ([irqWaitBox intValue] ? @YES : @NO);
		writeDic[@"Mono Sound Output"] = ([monoSoundBox intValue] ? @YES : @NO);
		writeDic[@"XA Pitch"] = ([xaSpeedBox intValue] ? @YES : @NO);
		
		writeDic[@"Interpolation Quality"] = @([interpolValue intValue]);
		writeDic[@"Reverb Quality"] = @([reverbValue intValue]);
		
		writeDic[@"Volume"] = @([volumeValue intValue]);
		
		// write to defaults
		[defaults setObject:writeDic forKey:PrefsKey];
		[defaults synchronize];
		
		// and set global values accordingly
		ReadConfig();
		
		[self close];

*/
		
		self.close()
	}
	
	@IBAction func cancel(sender: AnyObject?) {
		self.close()
	}
	
	@IBAction func reset(sender: AnyObject?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(PrefsKey)
		loadValues()
	}
}
