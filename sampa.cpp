/*
 * Summary: X-SAMPA extension for libxslt
 * Description: XPath extension function for X-SAMPA to
 *   Unicode (UTF-8) conversion.
 *
 * Copy: This file is distributed with the same 
 *       MIT-like licence as libxslt.
 *
 * Author: Didier Willis
 */
#include "sampa.h"

#include <libxslt/extensions.h>
#include <libxslt/xsltutils.h>

// TODO REWRITE THE FUNCTION TO HANDLE ALL X-SAMPA, RATHER
// THAN ONLY THE SUBSET WE NEED FOR THE SINDARIN DICTIONARY
/*
 * -- wSampaTUF8Code
 *    Converts a given X-SAMPA point code into an Unicode point code
 */
#define COMP( a, b ) (a + 256 * b)
static
int wSampaTUF8Code( int code )
{
	int utf;

	switch( code )
	{
		case COMP( '_', '0' )  :  utf = 0x0325; break;
		
		case COMP( 'r', '\\' ) :  utf = 0x0279; break;
		case COMP( ':', '/' )  :  utf = 0x02D1; break;

		case '=':  utf = 0x0329; break;
		case ',':  utf = 0x0321; break; /* Non standard */

		case 'A':  utf = 0x0251; break;
		case '{':  utf = 0x00E6; break;
		case '6':  utf = 0x0250; break;
		case 'Q':  utf = 0x0252; break;
		case 'E':  utf = 0x025B; break;
		case '@':  utf = 0x0259; break;
		case '3':  utf = 0x025C; break;
		case 'I':  utf = 0x026A; break;
		case 'O':  utf = 0x0254; break;
		case '2':  utf = 0x00F8; break;
		case '9':  utf = 0x0153; break;
		case '&':  utf = 0x0276; break;
		case 'U':  utf = 0x028A; break;
		case '}':  utf = 0x0289; break;
		case 'V':  utf = 0x028C; break;
		case 'Y':  utf = 0x028F; break;

		case 'B':  utf = 0x03B2; break;
		case 'C':  utf = 0x00E7; break;
		case 'D':  utf = 0x00F0; break;
		case 'G':  utf = 0x0263; break;
		case 'L':  utf = 0x028E; break;
		case 'J':  utf = 0x0272; break;
		case 'N':  utf = 0x014B; break;
		case 'R':  utf = 0x0281; break;
		case 'S':  utf = 0x0283; break;
		case 'T':  utf = 0x03B8; break;
		case 'H':  utf = 0x0265; break;
		case 'Z':  utf = 0x0292; break;
		case '?':  utf = 0x0294; break;

		case 'W':  utf = 0x028D; break;
		case 'K':  utf = 0x026C; break;
      
		case ':':  utf = 0x02D0; break;
		case '"':  utf = 0x02C8; break;
		case '%':  utf = 0x02CC; break;

		default:   utf = 0; break;
	}
	return utf;
}

/*
 * -- wEncodeUTF8PointCode()
 *    Encodes a given Unicode point code in UTF-8
 *
 * U-00000000 - U-0000007F: 0xxxxxxx 
 * U-00000080 - U-000007FF: 110xxxxx 10xxxxxx 
 * U-00000800 - U-0000FFFF: 1110xxxx 10xxxxxx 10xxxxxx 
 * U-00010000 - U-001FFFFF: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx 
 * U-00200000 - U-03FFFFFF: 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 
 * U-04000000 - U-7FFFFFFF: 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 */
static
xmlChar *wEncodeUTF8PointCode( int code, xmlChar *tmp )
{
	int i = 0;
	if (code <= 0x7F)
	{
		tmp[0] = (xmlChar)code;
		tmp[1] = 0;
		return( tmp );
	}
	else
	{
		while (code > 0x3F)
		{
			tmp[5-i] = (code & 0x3F) | 0x80;
			code = code >> 6;
			i++;
		}
		tmp[5-i] = (0xFF << (7-i)) | code;
		tmp[6] = 0;
		return( tmp+5-i );
	}
}

/*
 * -- wSampaConvertFunc()
 *    Converts a character sequence from SAMPA to IPA
 */
static
xmlChar *wSampaConvertFunc( xmlChar *input, xmlChar *aux, int &len )
{
	int c;
	int utf;

	if (*(input+len) != 0)
	{
		c = COMP( *(input+len), *(input+len+1) );
		utf = wSampaTUF8Code( c );
		if (utf != 0)
		{
			xmlChar tmp[7];
			aux = xmlStrcat( aux, wEncodeUTF8PointCode( utf, tmp ));
			len += 2;
			return( aux );
		}
	}
	
	c = *(input+len);
	utf = wSampaTUF8Code( c );
	if (utf != 0)
	{
		xmlChar tmp[7];
		aux = xmlStrcat( aux, wEncodeUTF8PointCode( utf, tmp ));
		
	}
	else
	{
		aux = xmlStrncat( aux, input+len, 1 );
	}
	len++;
	return( aux );
}

/*
 * -- xsltExtSampaToUnicode
 *    (X-)SAMPA to Unicode XPath extension
 */
static void
xsltExtSampaToUnicode( xmlXPathParserContextPtr ctxt, int nargs )
{
	xmlXPathObjectPtr obj;
    xmlChar *str;

    if ((nargs != 1) || (ctxt->value == NULL)) 
	{
        xsltGenericError( xsltGenericErrorContext,
						  "unicode() : expects one string arg\n" );
		ctxt->error = XPATH_INVALID_ARITY;
		return;
    }

    obj = valuePop( ctxt );
	if (XPATH_NODESET == obj->type)
	{
		str = xmlXPathCastNodeSetToString( obj->nodesetval );
	}
	else if (XPATH_STRING == obj->type)
	{
		str = xmlStrdup( obj->stringval );
	}

    if (str == NULL) 
	{
		xmlXPathReturnEmptyString( ctxt );
    }
	else
	{
		int i = 0;
		xmlChar *ret = NULL;

		while (i < xmlStrlen( str ))
		{
			ret = wSampaConvertFunc( str, ret, i );
		}
		xmlFree( str );
		xmlXPathReturnString(ctxt, ret);
    }
    xmlXPathFreeObject( obj );
}

/*
 * -- xsltSampaModuleInit
 *    Module initialization
 */
static
void *xsltSampaModuleInit( xsltTransformContextPtr ctxt, const xmlChar *URI )
{
  /* sampa:unicode() */
  xsltRegisterExtFunction( ctxt, 
                          (xmlChar *)"unicode",
                          URI,
                          xsltExtSampaToUnicode );
  return( NULL );
}

/*
 * -- Module registration
 */
void xsltRegisterSampaModule()
{
  xsltRegisterExtModule( (xmlChar *)SAMPA_NS_URI,
                         xsltSampaModuleInit,
                         NULL );
}

