<?xml version='1.0' encoding='ISO-8859-1'?>

<!-- Copyright (c) 1999-2001 by Didier Willis.

     Produce a RTF files from the Sindarin indexed entries.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- HACK: 
     Unicode is not supported by all RTF parsers, so we will stick 
     to ISO Latin 1. But if we set the output method to "text", 
     then the special characters in Unicode (e.g. circumflex y)
     will fail to be converted.
     Unicorn XSLT engine 1.04.00 keeps the entities unparsed
     when outputing XML in ISO Latin 1. So let it believe that
     the output format is actually XML. We will handle the
     escape sequence (&nnn;) elsewhere.
-->
<xsl:output method="xml" encoding="iso-8859-1" 
            indent="no" omit-xml-declaration="yes"/>

<xsl:strip-space elements="*"/>

<xsl:template match="list">
<xsl:text>{\rtf1\ansi\deff0\deftab720{\fonttbl{\f0\fnil MS Sans Serif;}{\f1\fnil\fcharset2 Symbol;}{\f2\fswiss\fprq2 System;}{\f3\fnil Times New Roman;}{\f4\froman Times New Roman;}{\f5\fswiss Arial;}}
{\colortbl\red0\green0\blue0;}
\deflang1036\pard
\plain\f4\fs20\b SINDARIN DICTIONARY - INDEX
\par
\par\plain\f4\fs20 Edition </xsl:text><xsl:value-of select="@n"/>
<xsl:text>\par\plain\f4\fs20 </xsl:text><xsl:value-of select="@id"/>
<xsl:text>\par
\par\plain\f4\fs20 Generated automatically from 'dict8.xml' (applying stylesheet 
'dict8idx.xsl' and then 'sdrtfidx.xsl') with Unicorn XSLT Engine version 1.04.00.
\par
\par\plain\f4\fs20 Copyright (c) 1999-2001 by Didier Willis. This material may be 
distributed only subject to the terms and conditions set forth in 
the Open Publication License, v1.0 or later (the latest version is 
presently available at http://www.opencontent.org/openpub/).
\par
\par\plain\f4\fs20 Distribution of substantively modified versions of this document is 
prohibited without the explicit permission of the copyright holder.
\par
\par\plain\f4\fs20 Distribution of this work or derivative of this work in any standard 
(paper) book form is prohibited unless prior permission is obtained from the copyright holder.
\par
\pard\li284\fi-284
</xsl:text><xsl:apply-templates/><xsl:text>
\par }
</xsl:text>
</xsl:template>

<xsl:template match="item">
<xsl:choose>
<xsl:when test="@n = preceding-sibling::item[1]/@n">
<xsl:text>\plain\f4\fs20\b , </xsl:text><xsl:apply-templates select="entry"/></xsl:when>
<xsl:otherwise>
<xsl:text>
\par </xsl:text>
<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="pos|tns|mood">
<xsl:apply-templates/>
<xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="gloss"><xsl:text>\plain\f4\fs20 </xsl:text>
<xsl:apply-templates/><xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="gramGrp">
<xsl:if test="../@n != ''"><xsl:text>\~\plain\f5\fs20\b </xsl:text><xsl:number format="I" value="../@n"/></xsl:if>
<xsl:text>\~\plain\f4\fs16\i </xsl:text>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="orth">
<!-- note: in the index, we ignore the corrections (<corr>) -->
<xsl:choose>
<xsl:when test="@type = 'deduced'"><xsl:text>\plain\f4\fs20\b\i </xsl:text>
<xsl:apply-templates/></xsl:when>
<xsl:otherwise><xsl:text>\plain\f4\fs20\b </xsl:text><xsl:apply-templates/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="usg[@type = 'lang']">
<xsl:if test="contains(@norm,'S')"><xsl:text>\plain\f4\fs20 *</xsl:text></xsl:if>
</xsl:template>

<xsl:template match="text()|@*">
<!-- note: replace y-circumflex by y-diaeresis -->
<xsl:value-of select="translate(.,'&#375;','ÿ')"/>
</xsl:template>

</xsl:stylesheet>