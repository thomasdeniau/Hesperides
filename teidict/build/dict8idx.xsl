<?xml version='1.0' encoding='ISO-8859-1'?>

<!-- Copyright (c) 1999-2001 by Didier Willis.

     Extract the indexed entries (index, TEI P3 §6.9.3) and
     build a reversed glossary for the Sindarin Dictionary. 
     Each item in the glossary is output on a single line, 
     for easier processing by external conversion tools.

     Warning: Note that the resulting document is not a valid 
     TEI document, as it uses dictionary entries (<entry>) 
     inside the list.

     Note also that the resulting document is not a valid XML
     document either, since it does not include a DTD.

     This stylesheet is only intended to be used a front-end 
     for subsequent conversions (e.g. TeX).
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" encoding="iso-8859-1" indent="no"/>

<xsl:variable name="language">en</xsl:variable>

<xsl:strip-space elements="*"/>

<xsl:template match="TEI.2">
<xsl:text>
</xsl:text>
<xsl:comment> SINDARIN DICTIONARY - INDEX ('COGNATE ENGLISH WORDS')

     Generated automatically from 'dict8.xml' (applying stylesheet 
     'dict8idx.xsl') with Unicorn XSLT Engine version 1.04.00.

     Copyright (c) 1999-2001 by Didier Willis. This material may be
     distributed only subject to the terms and conditions set forth in
     the Open Publication License, v1.0 or later (the latest version is
     presently available at http://www.opencontent.org/openpub/).

     Distribution of substantively modified versions of this document is
     prohibited without the explicit permission of the copyright holder.

     Distribution of this work or derivative of this work in any standard
     (paper) book form is prohibited unless prior permission is obtained
     from the copyright holder.
</xsl:comment><xsl:text>
</xsl:text>
<list n="{//edition/@n}" id="{normalize-space(//edition/text())}" lang="{$language}"><xsl:text>
</xsl:text>
<xsl:for-each select="//index[@lang = $language]">
<xsl:sort select="@level1"/>
<xsl:call-template name="indexed"/>
</xsl:for-each>
</list>
</xsl:template>

<xsl:template name="indexed">
<item n="{@level1}"><gloss><xsl:value-of select="@level1"/></gloss><xsl:text> </xsl:text>
<entry n='{ancestor::entry/@n}'>
<xsl:copy-of select="ancestor::entry/form/orth"/><xsl:text> </xsl:text>
<xsl:copy-of select="ancestor::entry/form/usg"/><xsl:text> </xsl:text>
<xsl:copy-of select="ancestor::entry/gramGrp"/>
</entry>
</item>
<xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>