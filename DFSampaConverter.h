//
//  DFSampaConverter.h
//  Hesperides
//
//  Created by Thomas Deniau on Wed May 05 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.


// This is legacy code. I keep it in case we suddenly decide not to use the libxslt SAMPA extension.

#import <Foundation/Foundation.h>
#import <AGRegex/AGRegex.h>

@interface DFSampaConverter : NSObject
{
	AGRegex *re;
	NSDictionary *sampa;
}

- (NSString *)convertString:(NSString *)str;

@end
