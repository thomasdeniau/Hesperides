<?xml version='1.0' encoding='ISO-8859-1'?>

<!-- Copyright (c) 2002 by Didier Willis.

     Produce a text file from the Sindarin indexed entries.
     (to be used in the on-line search engine)
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" encoding="iso-8859-1" indent="yes" />

<xsl:strip-space elements="*"/>

<xsl:template match="list">
<xsl:comment>
SINDARIN DICTIONARY REVERSED INDEX

Generated automatically from 'dict8.xml' (applying stylesheet 'dict8idx.xsl' 
and then 'sdteiidx.xsl') with Unicorn XSLT Engine version 1.04.00.

Copyright (c) 1999-2002 by Didier Willis. This material may be 
distributed only subject to the terms and conditions set forth in 
the Open Publication License, v1.0 or later (the latest version is 
presently available at http://www.opencontent.org/openpub/).

Distribution of substantively modified versions of this document is 
prohibited without the explicit permission of the copyright holder.
Distribution of this work or derivative of this work in any standard 
(paper) book form is prohibited unless prior permission is obtained 
from the copyright holder.
</xsl:comment>
<TEI.2>
<teiHeader>
  <fileDesc>
    <titleStmt>
      <title>Reversed index for the Sindarin dictionary</title>
      <respStmt>
      <resp>Compiled by <name>Didier Willis</name></resp>
      </respStmt>
    </titleStmt>

    <editionStmt>
      <edition n='{@n}'>
        <xsl:value-of select="@id"/>
      </edition>
    </editionStmt>

    <publicationStmt>
      <publisher>Didier Willis</publisher>
      <availability status='restricted'>
        <p>This material may be distributed only subject to the terms and
           conditions set forth in the Open Publication License, v1.0 or
           later (the latest version is presently available at
           http://www.opencontent.org/openpub/).</p>
        <p>Distribution of substantively modified versions of this document
           is prohibited without the explicit permission of the copyright
           holder.</p>
        <p>Distribution of the work or derivative of the work in any
           standard (paper) book form is prohibited unless prior permission
           is obtained from the copyright holder.</p>
      </availability>
      <date>2002</date>
    </publicationStmt>

    <sourceDesc>
      <p>Generated automatically from 'dict8.xml' (applying stylesheet 'dict8idx.xsl' 
         and then 'sdteiidx.xsl') with Unicorn XSLT Engine version 1.04.00.</p>
    </sourceDesc>
  </fileDesc>

  <encodingDesc>
    <projectDesc>
      <p>Dictionary based on J.R.R. Tolkien's books, and extended
         with etymological notes, phonetics and other information.</p>
    </projectDesc>
  </encodingDesc>
</teiHeader>

<text>
  <body>
    <div0 type="dictionary">
<xsl:apply-templates/>
    </div0>
  </body>
</text>
</TEI.2>
</xsl:template>

<xsl:template match="item">
<xsl:if test="preceding-sibling::item[1]/@n != @n">
<entry id="{@n}">
<xsl:apply-templates/>
<xsl:if test="@n = following-sibling::item[1]/@n">
  <xsl:apply-templates select="following-sibling::item[1]/entry"/>
</xsl:if>
</entry>
</xsl:if>
</xsl:template>

<xsl:template match="entry">
<sense>
<trans><xsl:apply-templates/></trans>
</sense>
</xsl:template>

<xsl:template match="gloss">
<form>
<orth><xsl:apply-templates/></orth>
</form>
</xsl:template>

<xsl:template match="gramGrp">
<!-- If present, entry number in Helvetica, roman numeral -->
<xsl:if test="../@n != ''">
<lbl><xsl:number format="I" value="../@n"/></lbl>
</xsl:if>
<xsl:copy><xsl:copy-of select="node()|@*"/></xsl:copy>
</xsl:template>

<xsl:template match="usg[@type = 'lang']">
<xsl:copy><xsl:copy-of select="node()|@*"/></xsl:copy>
</xsl:template>

<xsl:template match="orth">
<!-- note: in the index, we ignore the corrections (<corr>) -->
<tr><xsl:apply-templates/></tr>
</xsl:template>


</xsl:stylesheet>