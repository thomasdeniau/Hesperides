<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output
    method="html"
    encoding="iso-8859-1" indent="no"/>

<!-- Pour HTML conserver les espaces  redondants -->
<!-- <xsl:strip-space elements="*"/> -->

<xsl:template match="TEI.2">
<html>
<body>
<center><font size="+1"><b>SINDARIN DICTIONARY - INDEX</b></font></center>
<div align="justify">
<p>Edition <xsl:value-of select="//edition/@n"/><br/>
<xsl:value-of select="normalize-space(//edition/text())"/></p>

<p>Generated automatically from 'dict8.xml' (applying the Perl script
 'synphony.pl' to convert the phonetics in SAMPA into Unicode entities,
 and then the stylesheet 'sdhtmdct.xsl' with Unicorn XSLT Engine version 1.04.00).</p>

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

<xsl:template match="teiHeader">
</xsl:template>


<xsl:template match="body">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="div0">
<xsl:for-each select="entry">
<p><xsl:apply-templates/></p><xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="sense">
  <xsl:text> </xsl:text>
  <xsl:if test="@n">
    <xsl:choose>
      <xsl:when test="@n = '1'"><b>1.</b> </xsl:when>
      <xsl:otherwise>&#x25CB; <b><xsl:value-of select="@n"/>.</b> </xsl:otherwise>
    </xsl:choose>
  </xsl:if><xsl:apply-templates/>
</xsl:template>

<xsl:template match="def"><xsl:apply-templates/></xsl:template>
<xsl:template match="trans"><xsl:apply-templates/></xsl:template>

<xsl:template match="lbl">
  <xsl:choose>
    <xsl:when test="text() = 'see'">&#x2192;</xsl:when>
    <xsl:otherwise><small><i><xsl:apply-templates/></i></small></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="pos|tns|mood|per|gen|number">
<small><i><xsl:apply-templates/></i></small>
</xsl:template>

<xsl:template match="gloss"><xsl:text>\gloss{</xsl:text>
<xsl:apply-templates/><xsl:text>} </xsl:text>
</xsl:template>

<xsl:template match="gramGrp">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="form">
<xsl:if test="@rend= 'paren'">(</xsl:if>
<xsl:if test="@rend= 'leftparen'">(</xsl:if>
<xsl:apply-templates/>
<xsl:if test="@rend= 'paren'">)</xsl:if>
<xsl:if test="@rend= 'leftcomma'">,</xsl:if>
<xsl:if test="@rend= 'leftparen'">,</xsl:if>
<xsl:if test="@rend= 'rightparen'">)</xsl:if>
</xsl:template>

<xsl:template match="orth">
<xsl:choose>
  <xsl:when test="@type = 'deduced'"><i><b><xsl:apply-templates/></b></i></xsl:when>
  <xsl:otherwise><b><xsl:apply-templates/></b></xsl:otherwise>
</xsl:choose>
<!-- Misreadings -->
<xsl:if test="corr/@sic">
<xsl:text> </xsl:text><font color="#00cc00;"><strike><xsl:value-of select="corr/@sic"/></strike></font>
</xsl:if>
</xsl:template>

<xsl:template match="usg[@type = 'lang']">
<xsl:if test="contains(@norm,'S')"><xsl:text>*</xsl:text></xsl:if>
<xsl:text> </xsl:text>
<xsl:if test="../../@n"><xsl:text> </xsl:text><b><font face="helvetica" color="#cc0000;"><xsl:number format="I" value="../../@n"/></font></b></xsl:if>
</xsl:template>

<!-- TODO pas assez general, ne repond qu'a ce qu'on utilise actuellement dans le dico,
     i.e. <usg type='gram'>as a noun</usg>texte -->
<xsl:template match="usg[@type = 'gram']">
<small><i><xsl:apply-templates/>, </i></small>
</xsl:template>

<xsl:template match="pron">[<xsl:apply-templates/>]
</xsl:template>

<xsl:template match="note">
  <xsl:choose>
    <xsl:when test="@type ='source'">
      &#x25C7; <small><xsl:apply-templates/></small></xsl:when>
    <xsl:when test="@type ='source,deduced'">
      &#x2190; <small><xsl:apply-templates/></small></xsl:when>
    <xsl:when test="@type ='comment'">
      &#x25C8; <small><xsl:apply-templates/></small></xsl:when>
    <xsl:otherwise>
     <!-- Used in the TEI header -->
      <p><xsl:apply-templates/></p></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="etym">
  &#x25C7; <small><xsl:apply-templates/></small>
</xsl:template>

<xsl:template match="mentioned"><i><xsl:apply-templates/></i> </xsl:template>
<xsl:template match="hi"><i><xsl:apply-templates/></i></xsl:template>

<xsl:template match="ref"><b><xsl:apply-templates/></b>
<xsl:if test='@n'><xsl:text> </xsl:text><b><font face="helvetica" color="red"><xsl:number format="I" value="@n"/></font></b></xsl:if>
</xsl:template>

<xsl:template match="re">&#x25C8; <xsl:apply-templates/></xsl:template>

</xsl:stylesheet>