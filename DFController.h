//
//  DFController.h
//  Hesperides
//
//  Created by Thomas Deniau on Mon May 4 2004.

// Copyright (c) 2004-2015, Thomas Deniau
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "DFDictionaryParser.h"

@class DFArrayController;
@class DFSampaConverter;
@class DFAutoUpdater;
@class DFHistoryController;
@class DFLexiconAccessor;

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
	
	DFLexiconAccessor * englishAccessor, * sindarinAccessor;
	
	void * narmacil;
	NSDictionary *modeLanguages;
}

- (IBAction)display:(id)sender;
- (IBAction)fontChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;
- (IBAction)setUseRegexp:(id)sender;

-(NSFont *)loadFontAtPath:(NSString *)path;
-(NSString *)lexiconVersion;
-(DFDictionaryParser *)parser;

-(void)displayWord:(NSString *)key language:(DFLanguage)language silent:(BOOL)silent;
-(NSString *)transcribeWord:(NSString *)word fromLanguage:(DFLanguage)language;

+(id)sharedInstance;

@property (retain) DFLexiconAccessor * englishAccessor;
@property (retain) DFLexiconAccessor * sindarinAccessor;

@end
