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
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="teiHeader">
</xsl:template>

<xsl:template match="body">
  <xsl:apply-templates/>
<raw/><B>version</B> 
   Edition <xsl:value-of select="//edition/@n"/> ---
   <xsl:value-of select="normalize-space(//edition/text())"/>
<!--   <xsl:value-of select="count(//entry)"/> entries -->
</xsl:template>

<xsl:template match="div0">
<xsl:for-each select="entry">
<raw/><xsl:apply-templates/><xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="sense">
  <xsl:text> </xsl:text>
  <xsl:if test="@n">
    <xsl:choose>
      <xsl:when test="@n = '1'"><B>1.</B> </xsl:when>
      <xsl:otherwise>--- <B><xsl:value-of select="@n"/>.</B> </xsl:otherwise>
    </xsl:choose>
  </xsl:if><xsl:apply-templates/>
</xsl:template>

<xsl:template match="def"><xsl:apply-templates/></xsl:template>
<xsl:template match="trans"><xsl:apply-templates/></xsl:template>

<xsl:template match="lbl">
    <SMALL><I><xsl:apply-templates/></I></SMALL>
</xsl:template>

<xsl:template match="pos|tns|mood|per|gen|number">
<SMALL><I><xsl:apply-templates/></I></SMALL>
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
  <xsl:when test="@type = 'deduced'"><I><B><xsl:apply-templates/></B></I></xsl:when>
  <xsl:otherwise><B><xsl:apply-templates/></B></xsl:otherwise>
</xsl:choose>
<!-- Misreadings -->
<xsl:if test="corr/@sic">
<xsl:text> </xsl:text><FONT color="#00cc00;"><STRIKE><xsl:value-of select="corr/@sic"/></STRIKE></FONT>
</xsl:if>
</xsl:template>

<xsl:template match="usg[@type = 'lang']">
<xsl:if test="contains(@norm,'S')"><xsl:text>°</xsl:text></xsl:if>
<xsl:text> </xsl:text>
<xsl:if test="../../@n"><xsl:text> </xsl:text><FONT FACE="helvetica" COLOR="#cc0000;"><xsl:number format="I" value="../../@n"/></FONT></xsl:if>
</xsl:template>

<!-- TODO pas assez general, ne repond qu'a ce qu'on utilise actuellement dans le dico,
     i.e. <usg type='gram'>as a noun</usg>texte -->
<xsl:template match="usg[@type = 'gram']">
<SMALL><I><xsl:apply-templates/>, </I></SMALL>
</xsl:template>

<xsl:template match="pron">[<xsl:apply-templates/>]
<xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="note">
  <xsl:choose>
    <xsl:when test="@type ='source'">
      @ <SMALL><xsl:apply-templates/></SMALL></xsl:when>
    <xsl:when test="@type ='source,deduced'">
      &lt; <SMALL><xsl:apply-templates/></SMALL></xsl:when>
    <xsl:when test="@type ='comment'">
      # <SMALL><xsl:apply-templates/></SMALL></xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="etym">
  ## <SMALL><xsl:apply-templates/></SMALL>
</xsl:template>

<xsl:template match="mentioned"><I><xsl:apply-templates/></I> </xsl:template>
<xsl:template match="hi"><I><xsl:apply-templates/></I></xsl:template>
<xsl:template match="ref"><A><B><xsl:apply-templates/></B></A></xsl:template>
<xsl:template match="re"># <xsl:apply-templates/></xsl:template>
</xsl:stylesheet>