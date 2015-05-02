/* PluginController */

#import <Cocoa/Cocoa.h>

@interface PluginController : NSObject

@property (weak, null_unspecified) IBOutlet NSButton *aboutButton;
@property (weak, null_unspecified) IBOutlet NSButton *configureButton;
@property (weak, null_unspecified) IBOutlet NSPopUpButton *pluginMenu;

- (IBAction)doAbout:(nullable id)sender;
- (IBAction)doConfigure:(nullable id)sender;
- (IBAction)selectPlugin:(nullable id)sender;

- (void)setPluginsTo:(nonnull NSArray *)list withType:(int)type;

@end
