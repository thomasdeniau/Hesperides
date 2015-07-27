//
//  DFController.mm
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


#import "DFController.h"
#import "DFArrayController.h"
// import "DFSampaConverter.h"
#import "NSFileManager-DFExtensions.h"
#import "DFAutoUpdater.h"
#import "DFHistoryController.h"
#import "DFDictionaryParser.h"
#import "DFWord.h"
#import "DFLexiconAccessor.h"

#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libxml/parserInternals.h>
#include "transcription.h"

NSString *DFAutomaticCheck = @"DFAutomaticCheck";
NSString *DFSearchModeDefault = @"DFSearchMode";

id sharedInstance = nil;

@implementation DFController

@synthesize englishAccessor, sindarinAccessor;

+(id)sharedInstance
{
	if (sharedInstance) return sharedInstance;
	else return [[self alloc] init];
}

-(id)init
{
	if (sharedInstance) [super dealloc];
	
	else
	{
		if (self = [super init])
		{
			
			NSFileManager *fm=[NSFileManager defaultManager];
			
			//converter=[[DFSampaConverter alloc] init];
			
			dictionary = [[DFDictionaryParser alloc] init];
			
#pragma mark -- create Application Support/Hesperides
			
			BOOL isDir;
			NSString *appSupportPath=[[fm findFolder:kApplicationSupportFolderType inDomain:kUserDomain] stringByAppendingPathComponent:@"Hesperides"];
			if (! ([fm fileExistsAtPath:appSupportPath isDirectory:&isDir] && isDir))
			{
				NSError *error;
				if (! [fm createDirectoryAtPath:appSupportPath withIntermediateDirectories:FALSE attributes:nil error:&error]) {
					NSLog(@"Error creating the Hesperides folder in Application Support: %@", error);
				}
			}
			
#pragma mark -- Modes & Fonts --
			
			modes = [[[NSBundle mainBundle] pathsForResourcesOfType:@"mod" inDirectory:nil] arrayByAddingObjectsFromArray:
				[fm filesWithPathExtension:@"mod" inDomain:kApplicationSupportFolderType subFolder:@"Hesperides"]];
			fonts = [[[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:nil] arrayByAddingObjectsFromArray:
				[fm filesWithPathExtension:@"ttf" inDomain:kApplicationSupportFolderType subFolder:@"Hesperides"]];
			
			modeLanguages = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"KnownModules" ofType:@"plist"]];
			
			narmacil = new CTranscription;
			
			// all the code for this is actually in awakeFromNib
			
			sindarinAccessor = [[DFLexiconAccessor alloc] init];
			sindarinAccessor.dictionary = dictionary;
			sindarinAccessor.language = DFSindarin;

			englishAccessor = [[DFLexiconAccessor alloc] init];
			englishAccessor.dictionary = dictionary;
			englishAccessor.language = DFEnglish;
		}
		sharedInstance = self;
	}
	return sharedInstance;
}

-(void)dealloc
{
	//[converter release];
	[dictionary release];
	[modeLanguages release];
	[englishAccessor release];
	[sindarinAccessor release];
	
	delete (CTranscription *)narmacil;
	
	[super dealloc];
}

-(NSString *)lexiconVersion
{
	return [dictionary lexiconVersion];
}

-(DFDictionaryParser *)parser 
{
	return dictionary;
}

-(IBAction)setUseRegexp:(id)sender
{
	[[sindSearchField cell] setSendsWholeSearchString:([sender state]==NSOnState)];
	[[engSearchField cell] setSendsWholeSearchString:([sender state]==NSOnState)];
}

+(void) initialize
{
	NSDictionary *initial=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],DFAutomaticCheck,
																	 [NSNumber numberWithInt:0],DFSearchModeDefault,
																	 [NSNumber numberWithInt:10],DFHistoryCapacity,NULL];
	[[NSUserDefaults standardUserDefaults] registerDefaults:initial];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initial];
}

-(void)applicationDidFinishLaunching:(NSNotification *)n
{
	NSNumber *check=[[NSUserDefaults standardUserDefaults] objectForKey:DFAutomaticCheck];
	if (check && [check boolValue])
	{
		[updater checkForUpdates:self];
	}
	
	NSNumber *regex=[[NSUserDefaults standardUserDefaults] objectForKey:DFSearchModeDefault];
	if (regex)
	{
		if ([regex intValue] == DFPlainSearch)
		{
			[[sindSearchField cell] setSendsWholeSearchString:[regex boolValue]];
			[[engSearchField cell] setSendsWholeSearchString:[regex boolValue]];
		}		
	}
}

-(void)awakeFromNib
{
	[modePopup removeAllItems];
	[fontPopup removeAllItems];
	
	NSEnumerator *e=[modes objectEnumerator];
	NSString *s;
	while (s=[e nextObject]) 
	{
		NSMenuItem *m=[[NSMenuItem alloc] initWithTitle:[[s lastPathComponent] stringByDeletingPathExtension] 
												 action:NULL 
										  keyEquivalent:@""];
		[m setRepresentedObject:s];
		[[modePopup menu] addItem:m];
	}
	e= [fonts objectEnumerator];
	while (s=[e nextObject]) 
	{
		NSFont *f=[self loadFontAtPath:s];
		if (f)
		{
			NSMenuItem *m=[[NSMenuItem alloc] initWithTitle:[f displayName] 
													 action:NULL 
											  keyEquivalent:@""];
			[m setRepresentedObject:f];
			[[fontPopup menu] addItem:m];
	//		NSLog(@"Successfully loaded %@",[f displayName]);
		}
	}
	
	if ([fontPopup indexOfItemWithTitle:@"Tengwar Sindarin Regular"] != -1)
		[fontPopup selectItemWithTitle:@"Tengwar Sindarin Regular"]; //TengwarSindarin.ttf
	else if ([fontPopup indexOfItemWithTitle:@"TengwarSindarin"] != -1)
		[fontPopup selectItemWithTitle:@"TengwarSindarin"];
	else [fontPopup selectItemAtIndex:0];
	
	[self fontChanged:fontPopup];
	
	((CTranscription *)narmacil)->LoadMode([[[modePopup itemWithTitle:@"Sindarin Classic"] representedObject] UTF8String]);
	
	[engList setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"identifier" 
																					   ascending:YES 		
																						selector:@selector(caseInsensitiveCompare:)] 
		autorelease]]];
	
	[sindController bind:@"contentArray" toObject:dictionary withKeyPath:@"sindIndex" options:nil];
	[engController bind:@"contentArray" toObject:dictionary withKeyPath:@"engIndex" options:nil];
	
	[NSApp setServicesProvider:self];
}

#pragma mark -- Transcribe Service --

- (void)transcript:(NSPasteboard *)pboard
			 userData:(NSString *)userData
				error:(NSString **)error
{
    NSString  *pboardString=nil;
    NSAttributedString *newString;
    NSArray *types;
	NSDictionary *dic=[NSDictionary dictionary];
	
    types = [pboard types];
	
    if (![types containsObject:NSStringPboardType] && ![types containsObject:NSRTFPboardType]) {
        *error = NSLocalizedString(@"Error: couldn't transcribe text.",								   
								   @"There is no text available here.");
        return;
    }
	
	if ([types containsObject:NSRTFPboardType])
	{
		NSAttributedString *str=[[NSAttributedString alloc] initWithRTF:[pboard dataForType:NSRTFPboardType] documentAttributes:&dic];
		pboardString=[[[str string] copy] autorelease];
		[str release];
	}
	else pboardString=[pboard stringForType:NSStringPboardType];
	
	if (pboardString)
	{
		newString = [[NSAttributedString alloc] initWithString:[self transcribeWord:pboardString fromLanguage:DFUnknown]
												attributes:[NSDictionary dictionaryWithObject:[[fontPopup selectedItem] representedObject]
																					   forKey:NSFontAttributeName]];
	
		types = [NSArray arrayWithObject:NSRTFPboardType];
		[pboard declareTypes:types owner:nil];
	
		[pboard setData:[newString RTFFromRange:NSMakeRange(0,[newString length]) documentAttributes:dic] forType:NSRTFPboardType];
		[newString release];
	}
	
    return;
}

#pragma mark -- Load Font --

-(NSFont *)loadFontAtPath:(NSString *)path
{
	NSFont *f=nil;
	CFStringRef fontName=NULL;
	ATSFontContainerRef container;
	FSRef fsRef; 
	ItemCount count;
	int osstatus = FSPathMakeRef((const UInt8*)[path UTF8String], &fsRef, NULL); 
	
	osstatus = ATSFontActivateFromFileReference ( &fsRef, kATSFontContextLocal, kATSFontFormatUnspecified, 
												  NULL, kATSOptionFlagsDefault, &container);
	if (osstatus != noErr) 
	{
		NSLog(@"Got error %d loading %@ !!!",osstatus,path);
		return nil;
	} else {
		osstatus = ATSFontFindFromContainer (container, kATSOptionFlagsDefault, 0, NULL,&count);
		
		ATSFontRef *ioArray=(ATSFontRef *)malloc(count * sizeof(ATSFontRef));
		osstatus = ATSFontFindFromContainer (container, kATSOptionFlagsDefault, count, ioArray,&count);
		osstatus = ATSFontGetName (ioArray[0], kATSOptionFlagsDefault, &fontName);
		
		if (fontName) f = [NSFont fontWithName:(NSString*)fontName size:24];
		if ((osstatus != noErr) || !f)
		{
			NSRunAlertPanel(@"Unavailable Font",@"Sorry, Hesperides can't load the font %@ ! Your font file may be invalid.",
							@"OK",nil,nil,fontName?(NSString *)fontName:[path lastPathComponent]);
			return nil;
		}
		else return f;
	}
}

- (IBAction)fontChanged:(id)sender;
{
	NSFont *path = [[sender selectedItem] representedObject];
	if (path)
	{
		[tengwar setFont:path];
		[tengwar setFont:path range:NSMakeRange(0,[[tengwar string] length])];
		[tengwar setAlignment:NSCenterTextAlignment];
		[tengwar setContinuousSpellCheckingEnabled:NO];
	}
}

- (IBAction)modeChanged:(id)sender;
{
	((CTranscription *)narmacil)->LoadMode([[[sender selectedItem] representedObject] UTF8String]);
	[self display:self];
}

-(NSString *)transcribeWord:(NSString *)word fromLanguage:(DFLanguage)language;
{
	if (! [word canBeConvertedToEncoding:NSISOLatin1StringEncoding]) return nil;
	
	NSString *path = [[modePopup selectedItem] representedObject];
	NSString *mode = [[path lastPathComponent] stringByDeletingPathExtension];
	NSString *lang=nil;
	if ((language != DFUnknown) && ((lang=[modeLanguages objectForKey:mode])))
	{
		if (([lang isEqualToString:@"English"] && (language == DFSindarin))
			|| ([lang isEqualToString:@"Sindarin"] && (language == DFEnglish)))
		{
			[modePopup selectItemWithTitle:(language==DFEnglish)?@"English":@"Sindarin"];
			[self modeChanged:modePopup];
		}
	}
	
	NSString *tengText;
	CFIndex size = CFStringGetMaximumSizeForEncoding([word length],kCFStringEncodingISOLatin1);
	char *cString = (char *)calloc(size+1, sizeof(char));
	CFStringGetCString((CFStringRef)word,cString,size+1,kCFStringEncodingISOLatin1);
	char *tengwarResult = (char*) ((CTranscription *)narmacil)->Roman2Tengwar(cString);
	tengText = (NSString *)CFStringCreateWithCString(NULL,tengwarResult,kCFStringEncodingISOLatin1);

	free(cString);

	return [tengText autorelease];			
}

#pragma mark -- XSLT & displaying --

-(void)displayWord:(NSString *)key language:(DFLanguage)language silent:(BOOL)silent;
{	
	DFWord *word=[dictionary word:key language:language];
	
	[self fontChanged:fontPopup];
	
	[tengwar setString:[self transcribeWord:key	fromLanguage:language]];
	[tabView selectTabViewItemAtIndex:language];
	
	[((language == DFSindarin)?sindController:engController) setSelectedObjects:
		[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:key forKey:@"identifier"]]];
	if (! silent) [historyController addEntry:key language:language];
	
	[[webView mainFrame] loadHTMLString:[word htmlString] 
								baseURL: [NSURL URLWithString:@""]];
	
}

- (IBAction)display:(id)sender
{
	DFLanguage language=(DFLanguage)[tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	int row=[(language == DFSindarin)?sindList:engList selectedRow];
	if (row != -1) [self displayWord:[[[(language == DFSindarin)?sindController:engController arrangedObjects] objectAtIndex:row] objectForKey:@"identifier"] language:language silent:NO];
}

#pragma mark -- Cross - references --

- (void)						webView: (WebView *) sender 
		decidePolicyForNavigationAction: (NSDictionary *) actionInformation
								request: (NSURLRequest *) request
								  frame: (WebFrame *) frame
					   decisionListener: (id ) listener

// we override clicks on links (cross-references)

{
	int key = [[actionInformation objectForKey: WebActionNavigationTypeKey] intValue];
	NSURL *url=[actionInformation objectForKey:WebActionOriginalURLKey];
	NSString *word=nil;
	NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"?."];
	NSScanner *scanner=nil;
	
	switch(key){
		case WebNavigationTypeLinkClicked:
			scanner = [NSScanner scannerWithString:[url resourceSpecifier]];
			[scanner scanUpToCharactersFromSet:set intoString:NULL];
			[scanner scanCharactersFromSet:set intoString:NULL];
			[scanner scanUpToCharactersFromSet:set intoString:&word];
			
		//	NSLog(@"%@ -> %@",[url resourceSpecifier],word);
			if (word)
			{
				word=(NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,(CFStringRef)word,CFSTR(""));
				[listener ignore];
				[self displayWord:word language:DFSindarin silent:NO];
				[word release];
			}
				else [listener ignore];
			break;
		default:
			[listener use];
	}
}

#pragma mark -- Resizing --

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset{
	if (sender == mainSplitView) return ((offset == 0) && (proposedMin < 165))?165:proposedMin;
	else return ((offset == 0) && (proposedMin <50))?50:proposedMin;
}

- (void)splitView:(NSSplitView *)sender 
resizeSubviewsWithOldSize:(NSSize)oldSize 
{
	if (sender == mainSplitView)
	{
		NSSize splitViewSize = [sender frame].size; 
		NSSize rightSize, leftSize = [tabView frame].size; 
		rightSize.height = leftSize.height = splitViewSize.height; 
		rightSize.width = splitViewSize.width - [sender dividerThickness] - leftSize.width; 
		
		[tabView setFrameSize:leftSize]; 
		[secondarySplitView setFrameSize:rightSize]; 
	} 
	else
	{
		NSSize splitViewSize = [sender frame].size; 
		NSSize rightSize, leftSize = [box frame].size; 
		rightSize.width = leftSize.width = splitViewSize.width; 
		rightSize.height = splitViewSize.height - [sender dividerThickness] - leftSize.height; 
		
		[box setFrameSize:leftSize]; 
		[webView setFrameSize:rightSize];
	}
}

-(void)windowWillClose:(NSNotification*)notif
{
	[NSApp terminate:[notif object]];
}


-(BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{
	//NSLog(@"Asked %@",key);
	if ([key isEqualToString:@"sindarinAccessor"]) return YES;
	if ([key isEqualToString:@"englishAccessor"]) return YES;
	return NO;
}

@end
