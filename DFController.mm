//
//  DFController.mm
//  Hesperides
//
//  Created by Thomas Deniau on Mon May 4 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.

#import "DFController.h"
#import "DFArrayController.h"
// import "DFSampaConverter.h"
#import <AGRegex/AGRegex.h>
#import "NSFileManager-DFExtensions.h"
#import "DFAutoUpdater.h"
#import "DFHistoryController.h"
#import "DFDictionaryParser.h"
#import "sampa.h"

NSString *DFAutomaticCheck = @"DFAutomaticCheck";
NSString *DFSearchModeDefault = @"DFSearchMode";

id sharedInstance = nil;

@implementation DFController

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
			
			leftparen=[[AGRegex alloc] initWithPattern:@"\\(\\s+" options:AGRegexMultiline];
			rightparen=[[AGRegex alloc] initWithPattern:@"\\s+\\)" options:AGRegexMultiline];
			leftcomma=[[AGRegex alloc] initWithPattern:@"\\s+," options:AGRegexMultiline];
			
			dictionary = [[DFDictionaryParser alloc] init];
			xsltRegisterSampaModule();
			
#pragma mark -- create Application Support/Hesperides
			
			BOOL isDir;
			NSString *appSupportPath=[[fm findFolder:kApplicationSupportFolderType inDomain:kUserDomain] stringByAppendingPathComponent:@"Hesperides"];
			if (! ([fm fileExistsAtPath:appSupportPath isDirectory:&isDir] && isDir))
			{
				[fm createDirectoryAtPath:appSupportPath attributes:nil];
			}
			
#pragma mark -- Parse XSLT --
			
			NSString *xslPath=[[NSBundle mainBundle] pathForResource:@"entry" ofType:@"xsl"];
			
			xslt=xsltParseStylesheetFile((xmlChar*)[xslPath UTF8String]);
			// we don't check for errors... assume the dictionary and XSL are correct
			
#pragma mark -- Modes & Fonts --
			
			modes = [[[NSBundle mainBundle] pathsForResourcesOfType:@"mod" inDirectory:nil] arrayByAddingObjectsFromArray:
				[fm filesWithPathExtension:@"mod" inDomain:kApplicationSupportFolderType subFolder:@"Hesperides"]];
			fonts = [[[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:nil] arrayByAddingObjectsFromArray:
				[fm filesWithPathExtension:@"ttf" inDomain:kApplicationSupportFolderType subFolder:@"Hesperides"]];
			
			narmacil = new CTranscription;
			
			// all the code for this is actually in awakeFromNib
			
		}
		sharedInstance = self;
	}
	return sharedInstance;
}

-(void)dealloc
{
	//[converter release];
	[dictionary release];
	
	[leftparen release];
	[rightparen release];
	[leftcomma release];
	
	xsltFreeStylesheet(xslt);
	
	xsltCleanupGlobals();
	xmlCleanupParser();
	
	delete narmacil;
	
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
	
	narmacil->LoadMode([[[modePopup itemWithTitle:@"Sindarin Classic"] representedObject] UTF8String]);
	
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
	char *tengwarResult;
    NSAttributedString *newString;
    NSArray *types;
	NSDictionary *dic=[NSDictionary dictionary];
	
    types = [pboard types];
	
    if (![types containsObject:NSStringPboardType] && ![types containsObject:NSRTFPboardType]) {
        *error = NSLocalizedString(@"Error: couldn't transcript text.",								   
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
		//NSLog(@"%@",pboardString);
		tengwarResult = (char*) narmacil->Roman2Tengwar([pboardString UTF8String]);
		newString = [[NSAttributedString alloc] initWithString:[NSString stringWithCString:tengwarResult]
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
	FSSpec fsSpec; 
	ItemCount count;
	int osstatus = FSPathMakeRef((const UInt8*)[path UTF8String], &fsRef, NULL); 
	osstatus = FSGetCatalogInfo(&fsRef,kFSCatInfoNone,NULL,NULL,&fsSpec,NULL);
	osstatus = ATSFontActivateFromFileSpecification ( &fsSpec, kATSFontContextLocal, kATSFontFormatUnspecified, 
													  NULL, kATSOptionFlagsDefault, &container);
	if (osstatus != noErr) 
	{
		//NSLog(@"Got error %d loading %@ !!!",osstatus,path);
		return nil;
	}
	else {
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
	narmacil->LoadMode([[[sender selectedItem] representedObject] UTF8String]);
	[self display:self];
}

#pragma mark -- XSLT & displaying --

-(void)displayWord:(NSString *)key language:(DFLanguage)language silent:(BOOL)silent;
{	
	const char *params[3];
	params[0] = "print";
	params[1] = "'no'";
	params[2] = NULL;
	
	xmlNodePtr node=[dictionary nodeForKey:key language:language];
	
	xmlDocPtr nDoc=xmlNewDoc((xmlChar*)"1.0");
	xmlDocPtr result;
	xmlChar *resCharTab=NULL;
	NSString *resString;
	
	int resSize=0;

#pragma mark -- tengwar --
	
	[self fontChanged:fontPopup];
	if (language == DFSindarin)
	{
		char *tengwarResult = (char*) narmacil->Roman2Tengwar([key UTF8String]);
		[tengwar setString:[NSString stringWithCString:tengwarResult]];
	} else [tengwar setString:@""];

	[tabView selectTabViewItemAtIndex:language];
	
	[((language == DFSindarin)?sindController:engController) setSelectedObjects:
			[NSArray arrayWithObject:[dictionary infoForKey:key	language:language]]];
	if (! silent) [historyController addEntry:key language:language];
	
	xmlDocSetRootElement(nDoc, node);
	// we create a new document with only a div0 node containing relevant entries

#pragma mark -- SAMPA conversion --
	
/*	
		
 LEGACY CODE
 (manual SAMPA conversion)
 xmlChar *pronPath =  (xmlChar *) "//pron";
	xmlXPathContextPtr context;
	xmlNodeSetPtr items;
	int i;
	
 context = xmlXPathNewContext(nDoc);
	items = xmlXPathEvalExpression(pronPath,context)->nodesetval;
	xmlXPathFreeContext(context);
	
	for (i=0; i<items->nodeNr;i++)
	{
		xmlNodePtr item=items->nodeTab[i];
		xmlNodePtr parent=item->parent;
		xmlBufferPtr buffer=xmlBufferCreate();
		xmlNodeBufGetContent(buffer,item);
		
		NSString *newString=[[NSString alloc] initWithUTF8String:(const char*)xmlBufferContent(buffer)];
		
		xmlUnlinkNode(item);
		xmlFreeNode(item);
		
		xmlNewChild (parent, NULL,(const xmlChar*)"pron", (const xmlChar*)[[converter convertString:newString] UTF8String]);
		[newString release];
	}
 
 */
	
#pragma mark -- final generation --
	
	// to pass it to xslt
	result = xsltApplyStylesheet(xslt, nDoc, params);
	xmlFreeDoc(nDoc);
	xsltSaveResultToString(&resCharTab, &resSize, result, xslt);
	
	resString = [[[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:resCharTab length:resSize] encoding:NSISOLatin1StringEncoding] autorelease];
	resString = [leftparen replaceWithString:@"(" inString:resString];
	resString = [rightparen replaceWithString:@")" inString:resString];
	resString = [leftcomma replaceWithString:@"," inString:resString];
	[[webView mainFrame] loadHTMLString:resString 
								baseURL: [NSURL URLWithString:@""]];
	
}

- (IBAction)display:(id)sender
{
	DFLanguage language=(DFLanguage)[tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	int row=[(language == DFSindarin)?sindList:engList selectedRow];
	if (row != -1) [self displayWord:[[[(language == DFSindarin)?sindController:engController arrangedObjects] objectAtIndex:row] objectForKey:@"id"] language:language silent:NO];
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


@end
