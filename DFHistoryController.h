/* DFHistoryController */

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
// License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
// Hesperides comes with ABSOLUTELY NO WARRANTY.

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
