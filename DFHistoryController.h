/* DFHistoryController */

#import <Cocoa/Cocoa.h>
#import "DFDictionaryParser.h"

@class DFController;

extern NSString *DFHistoryCapacity;

@interface DFHistoryController : NSObject
{
    IBOutlet NSMenuItem *backItem;
    IBOutlet DFController *controller;
    IBOutlet NSMenuItem *forwardItem;
    IBOutlet NSMenu *menu;
	
	int currentItem;
	int capacity;
}

- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)selectEntry:(id)sender;

- (void)addEntry:(NSString *)word language:(DFLanguage)lang;

@end
