//
//  NSFileManager-DFExtensions.m
//  Hesperides
//
//  Created by Thomas Deniau on Fri May 14 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
// License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
// Hesperides comes with ABSOLUTELY NO WARRANTY.

#import "NSFileManager-DFExtensions.h"


@implementation NSFileManager(DFExtensions)

-(NSString *)findFolder:(OSType)folder inDomain:(short)domain
{
	CFStringRef     appSupportPath=nil;
	CFURLRef        appSupportURL=nil;
	FSRef           appSupportRef;
	OSErr           err;

	err = FSFindFolder(domain, folder, kDontCreateFolder, &appSupportRef);
	if (err == noErr) appSupportURL = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &appSupportRef);
	if (appSupportURL)  appSupportPath = CFURLCopyFileSystemPath(appSupportURL, kCFURLPOSIXPathStyle);

	return (NSString *)appSupportPath;
}

-(NSArray *)filesWithPathExtension:(NSString *)extension inDomain:(OSType)domain subFolder:(NSString *)sub;
{
	OSType domains[3]={kUserDomain, kLocalDomain, kNetworkDomain};
	NSMutableArray *files=[NSMutableArray array];
	int i;

	for (i=0;i<3;i++)
	{
		NSString *path = [[self findFolder:domain inDomain:domains[i]] stringByAppendingPathComponent:sub];
		
		NSDirectoryEnumerator *e=[[NSFileManager defaultManager] enumeratorAtPath:path];
		NSString *file;
		
		while (file=[e nextObject])
		{
			if ([[[file pathExtension] lowercaseString] isEqual:extension]) 
				[files addObject:[path stringByAppendingPathComponent:file]];
		}
	}
	
	return [NSArray arrayWithArray:files];
}

@end
