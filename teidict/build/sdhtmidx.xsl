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
<xsl:output method="html" encoding="iso-8859-1" indent="no" />

<xsl:strip-space elements="*"/>

<xsl:template match="list">
<html>
<body>
<center><font size="+1"><b>SINDARIN DICTIONARY - INDEX</b></font></center>
<div align="justify">
<p>Edition <xsl:value-of select="@n"/><br/>
<xsl:value-of select="@id"/></p>

<p>Generated automatically from 'dict8.xml' (applying stylesheet 
'dict8idx.xsl' and then 'sdhtmidx.xsl') with Unicorn XSLT Engine version 1.04.00.</p>

<p>Copyright (c) 1999-2002 by Didier Willis. This material may be 
distributed only subject to the terms and conditions set forth in 
the Open Publication License, v1.0 or later (the latest version is 
presently available at http://www.opencontent.org/openpub/).</p>

<p>Distribution of substantively modified versions of this document is 
prohibited without the explicit permission of the copyright holder.
Distribution of this work or derivative of this work in any standard 
(paper) book form is prohibited unless prior permission is obtained 
from the copyright holder.</p>
<p><font color="red">This HTML file is provided for your personal use and
shall not be published on your website.</font></p>
</div>
<center><hr width="30%"/></center>
<!-- TODO VOIR SI ON PEUT EVITER L'UNICODE OU SI C'EST OBLIGATOIRE -->
<font face="Lucida Sans Unicode">
<xsl:apply-templates/>
</font>
</body>
</html>
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
<xsl:if test="@n != following-sibling::item[1]/@n"><BR/></xsl:if>
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
<FONT FACE="Helvetica" COLOR="#cc00000;"><B><xsl:number format="I" value="../@n"/></B></FONT>
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
<xsl:if test="contains(@norm,'S')"><xsl:text>*</xsl:text></xsl:if>
</xsl:template>

</xsl:stylesheet>