<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
				xmlns:sampa="http://www.jrrvf.com/hisweloke/sindar/sampa"
                extension-element-prefixes="sampa">

<xsl:output
    method="html"
    encoding="iso-8859-1" indent="no"/>

<xsl:strip-space elements="TEI.2 text body div0 teiHeader re"/>
<xsl:param name="print"/>
<xsl:param name="header"/>
<xsl:param name="body"/>
<xsl:param name="search"/>
<xsl:param name="embed"/>

<xsl:template match="div0">
<html>
<head>
<style type="text/css">
body {
        font: 100% Lucida Sans Unicode;
}
p.text {
    padding-top: 1pt;
    padding-bottom: 1pt;
    text-align: justify;
}
p.sindict {
	margin-top: 2pt;
    margin-left: 1.5em;
    text-indent: -1.5em;
    text-align: justify;
}
small {
   font-size: 8pt;
}
</style>
</head>
<body>
<xsl:for-each select="entry">
<p id="{@id}" class="sindict"><xsl:apply-templates/></p>
</xsl:for-each>
</body>
</html>
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
<xsl:template match="index">

<!-- ugly ! and I don't want to support xrefs in other languages
<xsl:if test="$print != 'yes'"><a href=';{@lang}?{@level1}'>_</a></xsl:if> -->

</xsl:template>

<xsl:template match="lbl">
  <xsl:choose>
    <xsl:when test="text() = 'see'">&#x2192;</xsl:when>
    <xsl:otherwise><small><i><xsl:apply-templates/></i></small></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="pos|tns|mood|per|gen|number|itype">
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
<!-- Trick for style handling: we use the name of the grand-father node
     as a class name. Main entries will therefore be labeled with 'entry'
     and secondary entries as 'form'. This will allow to set different
     properties for main headwords (line breaking, etc.) and secondary
     entries such as variants, references, etc.
  -->
<span class="{name(../..)}">
<xsl:choose>
  <xsl:when test="contains(@type,'deduced') or contains(@type,'coined')"><i><b><xsl:apply-templates/></b></i></xsl:when>
  <xsl:otherwise><b><xsl:apply-templates/></b></xsl:otherwise>
</xsl:choose>
</span>
<!-- Misreadings and corrections -->
<xsl:if test="corr/@sic">
<xsl:text> </xsl:text>(<small><i>corr.</i><xsl:text> </xsl:text></small><font color="#777777"><xsl:value-of select="corr/@sic"/></font>)
</xsl:if>
</xsl:template>

<xsl:template match="usg[@type = 'lang']">
<xsl:apply-templates/>
<xsl:text> </xsl:text>
<xsl:if test="../../@n"><xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="$print = 'yes'">
<b><font face="helvetica"><xsl:number format="I" value="../../@n"/></font></b></xsl:when>
<xsl:otherwise>
<b><font face="helvetica" color="#cc0000"><xsl:number format="I" value="../../@n"/></font></b>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

<!-- WARNING: The following rules for the <usg> tag are not general 
     and only handles some of the TEI structures as used in the 
     Sindarin dictionary (i.e. <usg type='gram'>as a noun</usg>texte).
  -->
<xsl:template match="usg[@type = 'gram']">
<small><i><xsl:apply-templates/>, </i></small>
</xsl:template>

<xsl:template match="usg[@type = 'dom']|usg[@type = 'reg']">
<small><i><xsl:apply-templates/></i></small>
</xsl:template>

<xsl:template match="usg[@type='hint']">
<i><xsl:apply-templates/></i>
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
      <p class="text"><xsl:apply-templates/></p></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="etym">
  &#x25C7; <small><xsl:apply-templates/></small>
</xsl:template>

<xsl:template match="mentioned"><i><xsl:apply-templates/></i> </xsl:template>
<xsl:template match="hi"><i><xsl:apply-templates/></i></xsl:template>

<xsl:template match="ref">
<xsl:choose>
<xsl:when test="$print = 'yes'">
  <xsl:choose>
  <xsl:when test='@n'>
  <b><xsl:apply-templates/></b><xsl:text> </xsl:text><b><font face="helvetica"><xsl:number format="I" value="@n"/></font></b>
  </xsl:when>
  <xsl:otherwise>
  <b><xsl:apply-templates/></b>
  </xsl:otherwise>
  </xsl:choose>
</xsl:when>
<xsl:otherwise>
  <xsl:choose>
  <xsl:when test='@n'>
  <b><a href="?{@target}"><xsl:apply-templates/></a></b><xsl:text> </xsl:text><b><font face="helvetica" color="#cc0000"><xsl:number 
format="I" value="@n"/></font></b>
  </xsl:when>
  <xsl:otherwise>
    <xsl:choose>
    <xsl:when test='@target'>
      <b><a href="?{@target}"><xsl:apply-templates/></a></b>
    </xsl:when>
    <xsl:otherwise>
      <b><a href="?{./text()}"><xsl:apply-templates/></a></b>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="re">&#x25C8; <xsl:apply-templates/></xsl:template>

<xsl:template match="pron">[<xsl:value-of select="sampa:unicode(.)"/>]
</xsl:template>

</xsl:stylesheet>