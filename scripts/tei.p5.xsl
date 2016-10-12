<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">

<!-- ==================================================================== -->
<!--                             IMPORTS                                  -->
<!-- ==================================================================== -->

<xsl:import href="lib/html_formatting.xsl"/>
<xsl:import href="lib/personography_encyclopedia.xsl"/>
<xsl:import href="lib/cdrh.xsl"/>
<!-- If this file is living in a projects directory, the paths will be
     ../../../scripts/xslt/cdrh_tei_to_html/lib/html_formatting.xsl -->

<!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>


<!-- ==================================================================== -->
<!--                           PARAMETERS                                 -->
<!-- ==================================================================== -->

<xsl:param name="figures">true</xsl:param>  <!-- true/false Toggle figures on and off  -->
<xsl:param name="fw">true</xsl:param>       <!-- true/false Toggle fw's on and off  -->
<xsl:param name="pb">true</xsl:param>       <!-- true/false Toggle pb's on and off  -->
<xsl:param name="site_url"/>                <!-- the site url (http://codyarchive.org) -->
<xsl:param name="fig_location"></xsl:param> <!-- set figure location  -->

<!-- ==================================================================== -->
<!--                            OVERRIDES                                 -->
<!-- ==================================================================== -->
  
  <!-- Footnote references -->
  
  <xsl:template match="ref">
  <a>
    <xsl:attribute name="href">#<xsl:value-of select="@target"/></xsl:attribute>
    <xsl:attribute name="id">l<xsl:value-of select="@target"/></xsl:attribute>
    <sup>[<xsl:value-of select="@n"/>]</sup>
  </a>
  </xsl:template>
  
  <xsl:template match="/TEI//back/div[@type='notes']">
    <div class="footnotes">
      <h4>Footnotes</h4>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="/TEI//back/div[@type='notes']/note">
    <div>
      <xsl:attribute name="class">footnote</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:value-of select="@n"/>
      <xsl:text>. </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> (</xsl:text>
      <a>
        <xsl:attribute name="href">#l<xsl:value-of select="@xml:id"/></xsl:attribute>
        <xsl:text>back</xsl:text>
      </a>
      <xsl:text>)</xsl:text>
    </div>
  </xsl:template>
  
  <!-- related references (these will need to be filled in more) -->
  
  <xsl:template match="ref[@type='related']">
    <a>
      <xsl:attribute name="href">
        <xsl:text>lc.jrn.</xsl:text>
        <xsl:value-of select="@n"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <!-- div entry -->
  
  <xsl:template match="div[@type='entry']">
    <div class="entry">
    <xsl:apply-templates/>
    </div>
  </xsl:template>  
  
  <!-- Speaker -->
  
  <xsl:template match="div[@type='entry']//sp//speaker">
    <h4>[<xsl:apply-templates/>]</h4>
  </xsl:template> 
  
  <!-- names/places/tribes -->
  
  <xsl:template match="name">
    <a>
      <xsl:attribute name="class">regularization</xsl:attribute>
      <xsl:attribute name="title"><xsl:value-of select="@key"/></xsl:attribute>
      <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
      <xsl:attribute name="data-placement">top</xsl:attribute>
      <xsl:attribute name="href">
        <xsl:text>search?</xsl:text>
        <xsl:choose>
          <xsl:when test="@type = place">places</xsl:when>
          <xsl:when test="@type = person">people</xsl:when>
          <xsl:when test="@type = native_nation">lc_native_nation_ss</xsl:when>
        </xsl:choose>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="@key"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <!-- Previous/next links: don't show, pull from solr -->
  
  <xsl:template match="div[@type='file_references']"></xsl:template>
  

<!-- Individual projects can override matched templates from the
     imported stylesheets above by including new templates here -->
<!-- Named templates can be overridden if included in matched templates
     here.  You cannot call a named template from directly within the stylesheet tag
     but you can redefine one here to be called by an imported template -->

    <!-- The below will override the entire text matching template -->
    <!-- <xsl:template match="text">
      <xsl:call-template name="fake_template"/>
    </xsl:template> -->

    <!-- The below will override templates with the same name -->
    <!-- <xsl:template name="fake_template">
      This fake template would override fake_template if it was defined
      in one of the imported files
    </xsl:template> -->
</xsl:stylesheet>