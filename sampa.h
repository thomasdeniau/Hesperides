/*
 * Summary: X-SAMPA extension
 * Description: XPath extension functions for X-SAMPA to
 *   Unicode conversion.
 *
 * Copy: This file is distributed with the same 
 *       MIT-like licence as libxslt.
 *
 * Author: Didier Willis
 */

/* HOWTO USE THE SAMPA EXTENSION
 * Just add a call to xsltRegisterSampaModule() after
 * libexslt's initialization.
 * 
 * #include <libxml/xmlmemory.h>
 * #include <libxml/debugXML.h>
 * #include <libxml/HTMLtree.h>
 * #include <libxml/xmlIO.h>
 * #include <libxml/xinclude.h>
 * #include <libxml/catalog.h>
 * #include <libxml/nanohttp.h>
 * 
 * #include <libxslt/xslt.h>
 * #include <libxslt/xsltInternals.h>
 * #include <libxslt/transform.h>
 * #include <libxslt/xsltutils.h>
 * 
 * ...
 *
 *  xmlSubstituteEntitiesDefault( 1 );
 *  xmlLoadExtDtdDefaultValue = 1;
 *	xsltRegisterSampaModule(); 
 *
 *  ...
 *
 *	xsltCleanupGlobals();
 *	xmlCleanupParser();
 */

#ifndef _WSAMPA_H_
#define _WSAMPA_H_

#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>
#include <libxslt/xsltexports.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SAMPA_NS_URI "http://www.jrrvf.com/hisweloke/sindar/sampa"

XSLTPUBFUN void XSLTCALL xsltRegisterSampaModule();

#ifdef __cplusplus
}
#endif

#endif /* _WSAMPA_H_ */


