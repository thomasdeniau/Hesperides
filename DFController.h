//
//  DFController.h
//  Hesperides
//
//  Created by Thomas Deniau on Mon May 4 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libxml/parserInternals.h>
#include "transcription.h"
#import "DFDictionaryParser.h"

@class DFArrayController;
@class AGRegex;
@class DFSampaConverter;
@class DFAutoUpdater;
@class DFHistoryController;

@interface DFController : NSObject
{
    IBOutlet NSArrayController *engController;
    IBOutlet NSTableView *engList;
    IBOutlet NSSearchField *engSearchField;
    IBOutlet NSPopUpButton *fontPopup;
    IBOutlet NSPopUpButton *modePopup;
    IBOutlet NSArrayController *sindController;
    IBOutlet NSTableView *sindList;
    IBOutlet NSSearchField *sindSearchField;
    IBOutlet NSTabView *tabView;
    IBOutlet NSTextView *tengwar;
    IBOutlet WebView *webView;
	
	IBOutlet NSSplitView *mainSplitView;
	IBOutlet NSSplitView *secondarySplitView;
	IBOutlet NSBox *box;
	
	IBOutlet DFAutoUpdater *updater;
	IBOutlet DFHistoryController *historyController;
	
	NSArray *modes;
	NSArray *fonts;
	DFDictionaryParser *dictionary;
	
	xsltStylesheetPtr xslt;
	
	CTranscription *narmacil;
	//DFSampaConverter *converter;
	
	AGRegex *leftparen, *rightparen, *leftcomma;
}

- (IBAction)display:(id)sender;
- (IBAction)fontChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;
- (IBAction)setUseRegexp:(id)sender;

-(NSFont *)loadFontAtPath:(NSString *)path;
-(NSString *)lexiconVersion;
-(DFDictionaryParser *)parser;

-(void)displayWord:(NSString *)key language:(DFLanguage)language silent:(BOOL)silent;

@end
