//
//  CheatController.m
//  Pcsxr
//

#import <Cocoa/Cocoa.h>
#import "CheatController.h"
#import "PcsxrCheatHandler.h"
#import "PcsxrHexadecimalFormatter.h"

#import "PCSXR-Swift.h"

#define kTempCheatCodesName @"tempCheatCodes"
#define kCheatsName @"cheats"

@implementation CheatController
@synthesize addressFormatter;
@synthesize cheatView;
@synthesize editCheatView;
@synthesize editCheatWindow;
@synthesize valueFormatter;

- (NSString *)windowNibName
{
	return @"CheatWindow";
}

- (instancetype)init
{
	return self = [self initWithWindowNibName:@"CheatWindow"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		self.tempCheatCodes = [NSMutableArray array];
	}
	return self;
}

- (instancetype)initWithWindow:(NSWindow *)window
{
	if (self = [super initWithWindow:window]) {
		self.tempCheatCodes = [NSMutableArray array];
	}
	return self;
}

- (void)refreshNSCheatArray
{
	NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:NumCheats];
	for (int i = 0; i < NumCheats; i++) {
		CheatObject *tmpObj = [[CheatObject alloc] initWithCheat:&Cheats[i]];
		[tmpArray addObject:tmpObj];
	}
	self.cheats = tmpArray;
	[self setDocumentEdited:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:kCheatsName]) {
		[self setDocumentEdited:YES];
	}
}

- (void)refresh
{
	[cheatView reloadData];
	[self refreshNSCheatArray];
}

- (void)awakeFromNib
{
	[valueFormatter setHexPadding:4];
	[addressFormatter setHexPadding:8];
	[self refreshNSCheatArray];
	[self addObserver:self forKeyPath:kCheatsName options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (IBAction)loadCheats:(id)sender
{
	NSOpenPanel *openDlg = [NSOpenPanel openPanel];
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setAllowedFileTypes:[PcsxrCheatHandler supportedUTIs]];
	
	if ([openDlg runModal] == NSFileHandlingPanelOKButton) {
		NSURL *file = [openDlg URL];
		LoadCheats([[file path] fileSystemRepresentation]);
		[self refresh];
	}
}

- (IBAction)saveCheats:(id)sender
{
	NSSavePanel *saveDlg = [NSSavePanel savePanel];
	[saveDlg setAllowedFileTypes:[PcsxrCheatHandler supportedUTIs]];
	[saveDlg setCanSelectHiddenExtension:YES];
	[saveDlg setCanCreateDirectories:YES];
	[saveDlg setPrompt:NSLocalizedString(@"Save Cheats", nil)];
	if ([saveDlg runModal] == NSFileHandlingPanelOKButton) {
		NSURL *url = [saveDlg URL];
		NSString *saveString = [self.cheats componentsJoinedByString:@"\n"];
		[saveString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	}
}

- (IBAction)clear:(id)sender
{
	self.cheats = [[NSMutableArray alloc] init];
}

- (IBAction)closeCheatEdit:(id)sender
{
	[NSApp endSheet:editCheatWindow returnCode:[sender tag] == 1 ? NSCancelButton : NSOKButton];
}

- (IBAction)changeCheat:(id)sender
{
	[self setDocumentEdited:YES];
}

- (IBAction)removeCheatValue:(id)sender
{
	if ([editCheatView selectedRow] < 0) {
		NSBeep();
		return;
	}

	NSIndexSet *toRemoveIndex = [editCheatView selectedRowIndexes];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:toRemoveIndex forKey:kTempCheatCodesName];
	[self.tempCheatCodes removeObjectsAtIndexes:toRemoveIndex];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:toRemoveIndex forKey:kTempCheatCodesName];	
}

- (IBAction)addCheatValue:(id)sender
{
	NSIndexSet *newSet = [NSIndexSet indexSetWithIndex:[self.tempCheatCodes count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:newSet forKey:kTempCheatCodesName];
	[self.tempCheatCodes addObject:[[CheatObject alloc] init]];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:newSet forKey:kTempCheatCodesName];
}

- (void)reloadCheats
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSURL *tmpURL = [[manager URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:[[NSBundle mainBundle] bundleURL] create:YES error:nil] URLByAppendingPathComponent:@"temp.cht" isDirectory:NO];
	NSString *tmpStr = [self.cheats componentsJoinedByString:@"\n"];
	[tmpStr writeToURL:tmpURL atomically:NO encoding:NSUTF8StringEncoding error:NULL];
	LoadCheats([[tmpURL path] fileSystemRepresentation]);
	[manager removeItemAtURL:tmpURL error:NULL];
}

- (IBAction)editCheat:(id)sender
{
	if ([cheatView selectedRow] < 0) {
		NSBeep();
		return;
	}
	NSMutableArray *tmpArray = [(self.cheats)[[cheatView selectedRow]] values];
	NSMutableArray *newCheats = [[NSMutableArray alloc] initWithArray:tmpArray copyItems:YES];
	self.tempCheatCodes = newCheats;
	[[self window] beginSheet:editCheatWindow completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == NSOKButton) {
			CheatObject *tmpCheat = (self.cheats)[[cheatView selectedRow]];
			if (![tmpCheat.values isEqualToArray:self.tempCheatCodes]) {
				tmpCheat.values = self.tempCheatCodes;
				[self setDocumentEdited:YES];
			}
		}
		
		[editCheatWindow orderOut:nil];
	}];
}

- (IBAction)addCheat:(id)sender
{
	NSIndexSet *newSet = [NSIndexSet indexSetWithIndex:[self.cheats count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:newSet forKey:kCheatsName];
	CheatObject *tmpCheat = [[CheatObject alloc] init];
	tmpCheat.cheatName = NSLocalizedString(@"New Cheat", @"New Cheat Name" );
	CheatValue *tmpObj = [[CheatValue alloc] initWithAddress:0x10000000 value:0];
	NSMutableArray *tmpArray = [NSMutableArray arrayWithObject:tmpObj];
	tmpCheat.values = tmpArray;
	[self.cheats addObject:tmpCheat];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:newSet forKey:kCheatsName];
	[self setDocumentEdited:YES];
}

- (IBAction)applyCheats:(id)sender
{
	[self reloadCheats];
	[self setDocumentEdited:NO];
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	switch (returnCode) {
		case NSAlertDefaultReturn:
			[self reloadCheats];
			[self close];
			break;
			
		default:
			[self refreshNSCheatArray];
			[self close];
			break;
			
		case NSAlertOtherReturn:
			break;
	}
}

- (BOOL)windowShouldClose:(id)sender
{
	if (![sender isDocumentEdited] || ![[self window] isEqual:sender]) {
		return YES;
	} else {
		NSBeginAlertSheet(NSLocalizedString(@"Unsaved Changes", @"Unsaved changes"),
						  NSLocalizedString(@"Save", @"Save"),
						  NSLocalizedString(@"Don't Save",@"Don't Save"),
						  NSLocalizedString(@"Cancel", @"Cancel"), [self window], self,
						  NULL, @selector(sheetDidDismiss:returnCode:contextInfo:), NULL,
						  NSLocalizedString(@"The cheat codes have not been applied. Unapplied cheats will not run nor be saved. Do you wish to save?", nil));
		
		return NO;
	}
}

- (IBAction)removeCheats:(id)sender
{
	if ([cheatView selectedRow] < 0) {
		NSBeep();
		return;
	}
	
	NSIndexSet *toRemoveIndex = [cheatView selectedRowIndexes];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:toRemoveIndex forKey:kCheatsName];
	[self.cheats removeObjectsAtIndexes:toRemoveIndex];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:toRemoveIndex forKey:kCheatsName];
	[self setDocumentEdited:YES];
}

@end
