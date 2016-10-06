<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output indent="yes"></xsl:output>

  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.'))"></xsl:value-of>
  </xsl:variable>

  <!-- match everything and print out as is -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!-- If existing profileDesc check for data and rebuild -->
  <xsl:template match="/TEI/teiHeader[1]/profileDesc[1]">
    <xsl:element name="profileDesc"  namespace="http://www.tei-c.org/ns/1.0">
      <xsl:element name="textClass" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="scheme">lcsh</xsl:attribute>
          <xsl:attribute name="n">category</xsl:attribute>
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
        </xsl:element><!-- /category -->
        <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="scheme">original</xsl:attribute>
          <xsl:attribute name="n">subcategory</xsl:attribute>
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
        </xsl:element><!-- /subcategory -->
        <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="scheme">original</xsl:attribute>
          <xsl:attribute name="n">topic</xsl:attribute>
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
        </xsl:element><!-- /topic -->
        <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="scheme">lcsh</xsl:attribute>
          <xsl:attribute name="n">keywords</xsl:attribute>
          <xsl:choose>
            <xsl:when test="textClass/keywords/term != ''">
              <xsl:for-each select="textClass/keywords/term">
                <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"><xsl:value-of select="normalize-space(.)"/></xsl:element>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise><xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element></xsl:otherwise>
          </xsl:choose>
        </xsl:element><!-- /keywords -->
      </xsl:element>
    </xsl:element>
    
  </xsl:template>
  
  <!-- Add a new one before revisionDesc -->
  <xsl:template match="/TEI/teiHeader[1]/revisionDesc[1]">
  
  
  <!-- only apply if there is no profileDesc already -->
  <xsl:if test="not(//profileDesc)">
  <xsl:element name="profileDesc"  namespace="http://www.tei-c.org/ns/1.0">
    <xsl:element name="textClass" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="scheme">lcsh</xsl:attribute>
        <xsl:attribute name="n">category</xsl:attribute>
        <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
      </xsl:element><!-- /category -->
      <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="scheme">original</xsl:attribute>
        <xsl:attribute name="n">subcategory</xsl:attribute>
        <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
      </xsl:element><!-- /subcategory -->
      <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="scheme">original</xsl:attribute>
        <xsl:attribute name="n">topic</xsl:attribute>
        <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
      </xsl:element><!-- /topic -->
      <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="scheme">original</xsl:attribute>
        <xsl:attribute name="n">keywords</xsl:attribute>
        <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"></xsl:element>
      </xsl:element><!-- /keywords -->
    </xsl:element>
  </xsl:element>
  </xsl:if>
    
    <xsl:element name="revisionDesc"  namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </xsl:element>
  
</xsl:template>
  
</xsl:stylesheet>
