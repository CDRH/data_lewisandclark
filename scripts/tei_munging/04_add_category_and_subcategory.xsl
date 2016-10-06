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
  
  
  <xsl:template match="/TEI/teiHeader[1]/profileDesc[1]/textClass[1]/keywords[@n='category']">
    <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="scheme">original</xsl:attribute>
      <xsl:attribute name="n">category</xsl:attribute>
        <xsl:choose>
          <!-- Journals -->
          <xsl:when test="starts-with(/TEI/@xml:id,'lc.jrn')">
              <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Journals</xsl:element>
          </xsl:when>
          <!-- About -->
          <xsl:when test="starts-with(/TEI/@xml:id,'lc.about')">
            <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">About</xsl:element>
          </xsl:when>
          <!-- Image -->
          <xsl:when test="starts-with(/TEI/@xml:id,'lc.img')">
            <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Images</xsl:element>
          </xsl:when>
          <!-- Multimedia -->
          <xsl:when test="starts-with(/TEI/@xml:id,'lc.mult')">
            <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Multimedia</xsl:element>
          </xsl:when>
          <!-- Supplementary -->
          <xsl:when test="starts-with(/TEI/@xml:id,'lc.sup')">
            <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Supplements</xsl:element>
          </xsl:when>
          <!-- Set NONE so I can find uncategorized -->
          <xsl:otherwise>
              <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">NONE</xsl:element>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="/TEI/teiHeader[1]/profileDesc[1]/textClass[1]/keywords[@n='subcategory']">
    <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="scheme">original</xsl:attribute>
      <xsl:attribute name="n">subcategory</xsl:attribute>
      <xsl:choose>
        <!-- Journals -->
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.jrn') and 
          (contains(/TEI/@xml:id,'appendix') or 
          contains(/TEI/@xml:id,'preface') or 
          contains(/TEI/@xml:id,'intro') or 
          contains(/TEI/@xml:id,'sources') or 
          contains(/TEI/@xml:id,'toc') or
          contains(/TEI/@xml:id,'abbreviations')
          )">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Journal Editorial</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.jrn')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Journal Entries</xsl:element>
        </xsl:when>
        <!-- About -->
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.about.faq')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">FAQ</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.about.links')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Links</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.about')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Information</xsl:element>
        </xsl:when>
        <!-- Image -->
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.img.18')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Journal</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.img.18')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">People and Places</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.img.johnsgard')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Plants and Animals</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.img.loc')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Plants and Animals</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.img')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">NO IMAGE SUBCATEGORY</xsl:element>
        </xsl:when>
        <!-- Multimedia -->
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.mult.multimedia')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Introduction</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.mult') and contains(/TEI/@xml:id,'video')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Video</xsl:element>
        </xsl:when>
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.mult')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Audio</xsl:element>
        </xsl:when>
        <!-- Supplementary -->
        <xsl:when test="starts-with(/TEI/@xml:id,'lc.sup')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">Texts</xsl:element>
        </xsl:when>
        <!-- Set NONE so I can find uncategorized -->
        <xsl:otherwise>
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">NONE</xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  
  
</xsl:stylesheet>
