<?xml version='1.0' encoding='ISO-8859-1'?>

<!-- Copyright (c) 2002 by Didier Willis.

     Produce a text file from the Sindarin indexed entries.
     (to be used in the on-line search engine)
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

<xsl:template match="list"><xsl:apply-templates/><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="item">
<xsl:choose>
<xsl:when test="@n = preceding-sibling::item[1]/@n">, <xsl:apply-templates select="entry"/>
</xsl:when>
<xsl:otherwise>
<xsl:if test="preceding-sibling::item[1]/@n"><xsl:text>
</xsl:text></xsl:if>
<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
<xsl:if test="@n != following-sibling::item[1]/@n"><P/></xsl:if>
</xsl:template>

<xsl:template match="pos|tns|mood">
<xsl:apply-templates/>
<xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="gloss">
<xsl:apply-templates/><xsl:text>  </xsl:text>
</xsl:template>

<xsl:template match="gramGrp">
<!-- If present, entry number in Helvetica, roman numeral -->
<xsl:if test="../@n != ''"><xsl:text> </xsl:text>
<FONT FACE="Helvetica"><xsl:number format="I" value="../@n"/></FONT>
</xsl:if>
<!-- White space then grammatical information in small italic -->
<xsl:text> </xsl:text>
<SMALL><I>
<xsl:apply-templates/>
</I></SMALL>
</xsl:template>

<xsl:template match="orth">
<!-- note: in the index, we ignore the corrections (<corr>) -->
<xsl:choose>
<xsl:when test="@type = 'deduced'"><I><B><xsl:apply-templates/></B></I></xsl:when>
<xsl:otherwise><B><xsl:apply-templates/></B></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="usg[@type = 'lang']">
<xsl:if test="contains(@norm,'S')"><xsl:text>°</xsl:text></xsl:if>
</xsl:template>

<xsl:template match="text()|@*">
<!-- note: replace y-circumflex by y-diaeresis -->
<xsl:value-of select="translate(.,'&#375;','ÿ')"/>
</xsl:template>

</xsl:stylesheet>