<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output indent="yes"></xsl:output>

  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.jrn.'))"></xsl:value-of>
  </xsl:variable>
  <xsl:variable name="geo_count" xpath-default-namespace="">
    <xsl:value-of select="count($locations/root/row/id[text() = $date_match])"  xpath-default-namespace=""/>
  </xsl:variable>


  <!-- match everything and print out as is -->
  <xsl:template match="@* | node()">
    
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  

  <!-- Split Bibls into multiples absed on biblscope  -->
  <xsl:template match="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1]">
    <xsl:for-each select="biblScope">
      
      <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:for-each select="preceding-sibling::* except preceding-sibling::biblScope/following-sibling::*[1]/preceding-sibling::*"><xsl:copy-of select="."></xsl:copy-of></xsl:for-each>
        <xsl:copy-of select="."></xsl:copy-of>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Add normalized date when it is possible -->
  <xsl:template match="/TEI/text/body/head[@type='date']/date">
    <xsl:choose>
      <!-- These dates seem to be reports of the weather for the month, so I'm leaving them as is dated on the last day -->

      <xsl:when test="ends-with($date_match,'-2') or ends-with($date_match,'-1')">
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="when"><xsl:value-of select="substring($date_match,1,10)"/></xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <!-- Range dates (date not before date not after) -->
      <xsl:when test="string-length($date_match) > 10">
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="notBefore">
            <xsl:value-of select="substring($date_match,1,10)"/>
          </xsl:attribute>
          <xsl:attribute name="notAfter">
            <xsl:value-of select="substring($date_match,1,7)"/>
            <xsl:value-of select="substring($date_match,11,12)"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <!-- Everything else is hopefully a "normal" date -->
      <xsl:otherwise>
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="when"><xsl:value-of select="$date_match"/></xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- New xml:id's to indicate journal entries -->
  <xsl:template match="TEI">
    <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id">
      <xsl:text>lc.jrn.</xsl:text>
      <xsl:value-of select="$date_match"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Add xml:id's to individual entries -->
  <!-- if only one Geo entry, associate entries with it -->
  <xsl:template match="div[@type = 'entry']">
   
    <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
      
      <xsl:attribute name="type">entry</xsl:attribute>
      <xsl:attribute name="xml:id">
        <xsl:text>lc.jrn.</xsl:text>
        <xsl:value-of select="$date_match"/>
        <xsl:text>.</xsl:text>
        <xsl:number format="00"></xsl:number>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$geo_count = 1">
          <xsl:attribute name="n">
            <xsl:text>lc.geo.</xsl:text>
            <xsl:value-of select="$date_match"/>
            <xsl:text>.01</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="n">
            <!-- empty, will have to be hand filled in -->
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Add geographic information to TEI header -->
  <xsl:template match="/TEI/teiHeader[1]/encodingDesc[1]">
    <xsl:element name="encodingDesc" namespace="http://www.tei-c.org/ns/1.0">

      <xsl:apply-templates/>

      <xsl:for-each select="$locations/root/row/id[text() = $date_match]/parent::*" xpath-default-namespace="">
        <xsl:element name="geoDecl" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="datum">
            <xsl:text>WGS</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="xml:id">
            <xsl:text>lc.geo.</xsl:text>
            <xsl:value-of select="$date_match"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="format-number(position(),'00')"/>
          </xsl:attribute>
          <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="placeName"></xsl:value-of>
          </xsl:element>
          <xsl:element name="geo" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="Latitude"></xsl:value-of>
            <xsl:text> </xsl:text>
            <xsl:value-of select="Longitude"></xsl:value-of>
          </xsl:element>
          <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="notes"></xsl:value-of>
          </xsl:element>
          <xsl:if test="normalize-space(Notes) != ''">
            <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
              <xsl:value-of select="Notes"></xsl:value-of>
            </xsl:element>
          </xsl:if>
        </xsl:element>

      </xsl:for-each>
    </xsl:element>

  </xsl:template>
  

  
  

  <!-- Change Status Info depending on operation -->
  <xsl:template match="/TEI/teiHeader[1]/revisionDesc[1]" exclude-result-prefixes="">
    <xsl:element name="revisionDesc" namespace="http://www.tei-c.org/ns/1.0">

      <xsl:apply-templates></xsl:apply-templates>

      <xsl:element name="change" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:text>2016-09-26</xsl:text>
        </xsl:element>
        <xsl:element name="name" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:text>Karin Dalziel</xsl:text>
        </xsl:element>
        <xsl:text>Added Geo Information from spreadsheet</xsl:text>
      </xsl:element>
    </xsl:element>

  </xsl:template>



  <xsl:variable name="locations">
    
<root>
  <row>
    <id>1803-08-30</id>
    <notes>Started in Pittsburgh, camped at McKee&apos;s Rocks</notes>
    <Latitude>40.4687</Latitude>
    <Longitude>-80.0626</Longitude>
    <placeName>McKee&apos;s Rocks</placeName>
    <alt_notes></alt_notes>
    <City>McKees Rocks</City>
    <County>Allegheny County</County>
    <stateCode>PA</stateCode>
  </row>
  <row>
    <id>1803-09-01</id>
    <notes>Camped just downstream from Woollery&apos;s Trap</notes>
    <Latitude>40.5206</Latitude>
    <Longitude>-80.1571</Longitude>
    <placeName>Woollery&apos;s Trap</placeName>
    <alt_notes></alt_notes>
    <City>Coraopolis</City>
    <County>Allegheny County</County>
    <stateCode>PA</stateCode>
  </row>
  <row>
    <id>1803-09-02</id>
    <notes>Camped just outside of Waller&apos;s Riffle</notes>
    <Latitude>40.65</Latitude>
    <Longitude>-80.2333</Longitude>
    <placeName>Waller&apos;s Riffle</placeName>
    <alt_notes></alt_notes>
    <City>Baden</City>
    <County>Beaver County</County>
    <stateCode>PA</stateCode>
  </row>
  <row>
    <id>1803-09-03</id>
    <notes>Three miles down the Ohio, and three miles from Riffle below Mackintosh</notes>
    <Latitude>40.669</Latitude>
    <Longitude>-80.3517</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Beaver</City>
    <County>Beaver County</County>
    <stateCode>PA</stateCode>
  </row>
  <row>
    <id>1803-09-04</id>
    <notes>Two miles below state line, about two miles SW of Georgetown</notes>
    <Latitude>40.62</Latitude>
    <Longitude>-80.537</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chester</City>
    <County>Hancock County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-05</id>
    <notes>Northernmost part of Brown&apos;s Island</notes>
    <Latitude>40.4405</Latitude>
    <Longitude>-80.609</Longitude>
    <placeName>Brown&apos;s Island</placeName>
    <alt_notes></alt_notes>
    <City>Toronto</City>
    <County>Jefferson County</County>
    <stateCode>OH</stateCode>
  </row>
  <row>
    <id>1803-09-06</id>
    <notes>Four miles south of Steubenville, OH</notes>
    <Latitude>40.3</Latitude>
    <Longitude>-80.6</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wellsburg</City>
    <County>Brooke County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-07</id>
    <notes>Wheeling, stayed there for 1803-09-08</notes>
    <Latitude>40.0622</Latitude>
    <Longitude>-80.7208</Longitude>
    <placeName>Wheeling</placeName>
    <alt_notes></alt_notes>
    <City>Wheeling</City>
    <County>Ohio County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-09</id>
    <notes>Three miles south of Bellaire, OH (Seven miles south of Wheeling)</notes>
    <Latitude>40</Latitude>
    <Longitude>-80.74</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bellaire</City>
    <County>Belmont County</County>
    <stateCode>OH</stateCode>
  </row>
  <row>
    <id>1803-09-10</id>
    <notes>Opposite of Clarington, OH, a little north of Sunfish Creek</notes>
    <Latitude>39.7669</Latitude>
    <Longitude>-80.8643</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>New Martinsville</City>
    <County>Marshall County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-11</id>
    <notes>South of Grandview Island, East shore</notes>
    <Latitude>39.5094</Latitude>
    <Longitude>-81.0709</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Friendly</City>
    <County>Tyler County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-12</id>
    <notes>NW shore of Ohio River, Washington County, OH</notes>
    <Latitude>39.3501</Latitude>
    <Longitude>-81.3409</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Marietta</City>
    <County>Washington County</County>
    <stateCode>OH</stateCode>
  </row>
  <row>
    <id>1803-09-13</id>
    <notes>Marietta, OH</notes>
    <Latitude>39.4</Latitude>
    <Longitude>-81.45</Longitude>
    <placeName>Marietta, OH</placeName>
    <alt_notes></alt_notes>
    <City>Williamstown</City>
    <County>Wood County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-14</id>
    <notes>NW shore of Ohio River, directly opposite of Parkersburg, WV</notes>
    <Latitude>39.27</Latitude>
    <Longitude>-81.5736</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Belpre</City>
    <County>Washington County</County>
    <stateCode>OH</stateCode>
  </row>
  <row>
    <id>1803-09-15</id>
    <notes>West Virginia shore, around Belleville</notes>
    <Latitude>39.1271</Latitude>
    <Longitude>-81.7392</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Belleville</City>
    <County>Wood County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-16</id>
    <notes>Jackson County, WV</notes>
    <Latitude>38.95</Latitude>
    <Longitude>-81.77</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Portland</City>
    <County>Meigs County</County>
    <stateCode>OH</stateCode>
  </row>
  <row>
    <id>1803-09-17</id>
    <notes>Directly across from Oldtown Creek, OH</notes>
    <Latitude>38.943</Latitude>
    <Longitude>-81.822</Longitude>
    <placeName>Oldtown Creek</placeName>
    <alt_notes></alt_notes>
    <City>Millwood</City>
    <County>Jackson County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id>1803-09-18</id>
    <notes>Letart Falls, Ohio River between WV and OH</notes>
    <Latitude>38.895</Latitude>
    <Longitude>-81.933</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Letart</City>
    <County>Mason County</County>
    <stateCode>WV</stateCode>
  </row>
  <row>
    <id></id>
    <notes>Journal is picked up on November 11, 1803, in Massac, IL. Lewis had spent time in Cincinnati and Clarksville, Indiana Territory. Picked up Clark</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1803-11-11</id>
    <notes>Massac, IL, just above present day Metropolis, IL. Remained here 1803-11-12</notes>
    <Latitude>37.1439</Latitude>
    <Longitude>-88.6872</Longitude>
    <placeName>Fort Massac, IL</placeName>
    <alt_notes></alt_notes>
    <City>Metropolis</City>
    <County>Massac County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-13</id>
    <notes>McCracken County, KY, 3 miles from Massac</notes>
    <Latitude>37.14</Latitude>
    <Longitude>-88.746</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>West Paducah</City>
    <County>McCracken County</County>
    <stateCode>KY</stateCode>
  </row>
  <row>
    <id>1803-11-14</id>
    <notes>OH and MS River Junction, present day Cairo, IL. Stayed and surveyed land 1803-11-15</notes>
    <Latitude>37.0008</Latitude>
    <Longitude>-89.176</Longitude>
    <placeName>OH and MS River Junction</placeName>
    <alt_notes></alt_notes>
    <City>Cairo</City>
    <County>Alexander County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-16</id>
    <notes>Crossed the Mississippi River to the Missouri side. Stayed in this vacinity until 1803-11-20</notes>
    <Latitude>36.97</Latitude>
    <Longitude>-89.15</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Charleston</City>
    <County>Mississippi County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-11-20</id>
    <notes>10.5 miles from the river junction</notes>
    <Latitude>37.068</Latitude>
    <Longitude>-89.256</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cairo</City>
    <County>Alexander County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-21</id>
    <notes>Island between Alexander County, IL, and Mississippi County, MO</notes>
    <Latitude>37.01</Latitude>
    <Longitude>-89.32</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Miller City</City>
    <County>Alexander County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-22</id>
    <notes>Northwest Alexander County, IL, just north of Commerce, MO</notes>
    <Latitude>37.182</Latitude>
    <Longitude>-89.448</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Thebes</City>
    <County>Alexander County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-23</id>
    <notes>Cape Girardeau County, MO, just north of Cape Girardeau</notes>
    <Latitude>37.338</Latitude>
    <Longitude>-89.49</Longitude>
    <placeName>Cape Girardeau</placeName>
    <alt_notes></alt_notes>
    <City>Cape Girardeau</City>
    <County>Cape Girardeau County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-11-24</id>
    <notes>10 miles north of Cape Girardeau, MO</notes>
    <Latitude>37.46</Latitude>
    <Longitude>-89.471</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Jackson</City>
    <County>Cape Girardeau County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-11-25</id>
    <notes>Tower Rock, opposite Grand Tower, IL</notes>
    <Latitude>37.6167</Latitude>
    <Longitude>-89.5</Longitude>
    <placeName>Tower Rock</placeName>
    <alt_notes></alt_notes>
    <City>Grand Tower</City>
    <County></County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-26</id>
    <notes>Less than 10 miles north of the Grand Tower</notes>
    <Latitude>37.78</Latitude>
    <Longitude>-89.667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rockwood</City>
    <County>Jackson County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-11-27</id>
    <notes>Present day Horse Island, Perry County, MO</notes>
    <Latitude>37.898</Latitude>
    <Longitude>-89.838</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Perryville</City>
    <County>Perry County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-11-28</id>
    <notes>Opposite from Ste. Genevieve, MO. In Kaskaskia Island area</notes>
    <Latitude>37.997</Latitude>
    <Longitude>-90.028</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Modoc</City>
    <County>Randolph County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id></id>
    <notes>Gap in journal until December 3, 1803. Lewis breaks off for St. Louis and leaves Clark in charge. Clark stays in Kaskaskia Island area until December 4</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1803-12-04</id>
    <notes>Lee Island, MO</notes>
    <Latitude>38.107</Latitude>
    <Longitude>-90.242</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bloomsdale</City>
    <County>Ste. Genevieve County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-12-05</id>
    <notes>Monroe County, IL, just north of Fountain Creek</notes>
    <Latitude>38.332</Latitude>
    <Longitude>-90.368</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Imperial</City>
    <County>Jefferson County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-12-06</id>
    <notes>Above the Meramec River, St. Louis County</notes>
    <Latitude>38.399</Latitude>
    <Longitude>-90.336</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>St. Louis</City>
    <County>St. Louis County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-12-07</id>
    <notes>Cahokia, IL, a little less than a mile above the Cahokia Creek entrance. Stayed here until 1803-12-11</notes>
    <Latitude>38.563</Latitude>
    <Longitude>-90.231</Longitude>
    <placeName>Cahokia, IL / St. Louis</placeName>
    <alt_notes></alt_notes>
    <City>St. Louis</City>
    <County></County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-12-11</id>
    <notes>Cabaret Island, opposite Granite City</notes>
    <Latitude>38.691</Latitude>
    <Longitude>-90.193</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Venice</City>
    <County>Madison County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1803-12-12</id>
    <notes>Opposite side of Wood River in St. Charles County, MO. Because of the shifts in location of the Missouri and Wood rivers, this location is hard to find exactly. A camp was set up for the winter, and they stayed here until 1804-05-14</notes>
    <Latitude>38.8</Latitude>
    <Longitude>-90.12</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Hartford</City>
    <County>Madison County</County>
    <stateCode>IL</stateCode>
  </row>
  <row>
    <id>1804-05-14</id>
    <notes>Near Coldwater Creek, MO, on Missouri River</notes>
    <Latitude>38.83</Latitude>
    <Longitude>-90.2211</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>St. Louis</City>
    <County>St. Louis County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-15</id>
    <notes>Near Pelican Island, on the west shore</notes>
    <Latitude>38.87</Latitude>
    <Longitude>-90.35</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Saint Charles</City>
    <County>St. Charles County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-16</id>
    <notes>Clark and his men arrive in St. Charles, MO. They stay here to wait for Lewis until 1804-05-21</notes>
    <Latitude>38.789</Latitude>
    <Longitude>-90.514</Longitude>
    <placeName>St. Charles, MO Camp Dubois</placeName>
    <alt_notes></alt_notes>
    <City>Saint Charles</City>
    <County>St. Charles County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-21</id>
    <notes>St. Charles Island, which has since apparently disappeared.</notes>
    <Latitude>38.74</Latitude>
    <Longitude>-90.515</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Saint Charles</City>
    <County>St. Charles County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-22</id>
    <notes>&quot;Osage Woman&apos;s River&quot;, now Femme Osage River, on the west side of the Missouri</notes>
    <Latitude>38.663</Latitude>
    <Longitude>-90.732</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Saint Charles</City>
    <County>St. Charles County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-23</id>
    <notes>Close to Tavern Creek, in Franklin County, MO</notes>
    <Latitude>38.59</Latitude>
    <Longitude>-90.77</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chesterfield</City>
    <County>Franklin County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-24</id>
    <notes> An old house about 4 miles south of the present day town of Washington, MO. The camp appears to be very far inland because of the considerable change in the Missouri River&apos;s course over the years</notes>
    <Latitude>38.49</Latitude>
    <Longitude>-90.96</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Washington</City>
    <County>Franklin County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-25</id>
    <notes>La Charette, a small french village on the Missouri, and the last White settlement on the Missouri</notes>
    <Latitude>38.6044</Latitude>
    <Longitude>-91.0616</Longitude>
    <placeName>La Charette, MO</placeName>
    <alt_notes></alt_notes>
    <City>Washington</City>
    <County>Franklin County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-26</id>
    <notes>Bates Island as it is known now, near the Gasconade-Warren County line</notes>
    <Latitude>38.7017</Latitude>
    <Longitude>-91.3383</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Hermann</City>
    <County>Warren County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-27</id>
    <notes>Shore opposite mouth of the Gasconade River, MO. Remained here until 1804-05-29</notes>
    <Latitude>38.6795</Latitude>
    <Longitude>-91.5492</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rhineland</City>
    <County>Montgomery County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-29</id>
    <notes>Stopped at Deer Creek, now presently known as Bailey Creek</notes>
    <Latitude>38.6953</Latitude>
    <Longitude>-91.6105</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rhineland</City>
    <County>Montgomery County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-05-30</id>
    <notes>About 14 miles downstream from Bailey Creek, close to Little Muddy River. Stayed here until 1804-06-01</notes>
    <Latitude>38.6482</Latitude>
    <Longitude>-91.8812</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Mokane</City>
    <County>Callaway County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-01</id>
    <notes>At the mouth of the Osage River where it connects with the Missouri. They remained here until 1804-06-03</notes>
    <Latitude>38.5922</Latitude>
    <Longitude>-91.9532</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bonnots Mill</City>
    <County>Osage County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-03</id>
    <notes>At the mouth of Moreau River, south side of the Missouri</notes>
    <Latitude>38.5576</Latitude>
    <Longitude>-92.088</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Jefferson City</City>
    <County>Cole County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-04</id>
    <notes>A place that Clark called &quot;Mine Hill&quot;, between Workman Creek and Meadows Creek</notes>
    <Latitude>38.662</Latitude>
    <Longitude>-92.289</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Hartsburg</City>
    <County>Boone County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-05</id>
    <notes>Camped on the shore opposite modern day Sandy Hook, MO, roughly 11 miles up the Missouri</notes>
    <Latitude>38.753</Latitude>
    <Longitude>-92.4035</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Jamestown</City>
    <County>Moniteau County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-06</id>
    <notes>Boone County, MO, downstream from Highway 70</notes>
    <Latitude>38.928</Latitude>
    <Longitude>-92.505</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rocheport</City>
    <County>Boone County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-07</id>
    <notes>Camped at the mouth of the Bonne Femme Creek, Boone County, MO</notes>
    <Latitude>38.978</Latitude>
    <Longitude>-92.666</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>New Franklin</City>
    <County>Howard County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-08</id>
    <notes>Close to the county line between Saline and Cooper counties, MO. Most likely on the east side of the line</notes>
    <Latitude>39.05</Latitude>
    <Longitude>-92.928</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Blackwater</City>
    <County>Howard County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-09</id>
    <notes>An island in the middle of the Missouri, close to Richland Creek</notes>
    <Latitude>39.141</Latitude>
    <Longitude>-92.912</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Glasgow</City>
    <County>Howard County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-10</id>
    <notes>About 5 miles above the Chariton River in northeast Saline County, just past Harrison&apos;s Island. Stayed here for 1804-06-11 due to high winds prohibiting travel</notes>
    <Latitude>39.236</Latitude>
    <Longitude>-92.9234</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Gilliam</City>
    <County>Chariton County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-12</id>
    <notes>North Shore of the Missouri, South Central Chariton County, MO</notes>
    <Latitude>39.3181</Latitude>
    <Longitude>-92.9766</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dalton</City>
    <County>Chariton County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-13</id>
    <notes>Stopped at the mouth of the Grand River, which was likely farther north than where it is today.</notes>
    <Latitude>39.439</Latitude>
    <Longitude>-93.131</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Brunswick</City>
    <County>Chariton County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-14</id>
    <notes>Nearly opposite present day Miami, MO, on the northern shore of the Missouri</notes>
    <Latitude>39.3323</Latitude>
    <Longitude>-93.2274</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Miami</City>
    <County>Carroll County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-15</id>
    <notes>Stopped at the Gumbo Point Site with the Missouri Indians. Hard to pinpoint exactly where this was, as not much detail is used</notes>
    <Latitude>39.2427</Latitude>
    <Longitude>-93.3588</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Malta Bend</City>
    <County>Carroll County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-16</id>
    <notes>Opposite present day Waverly, MO on the north shore</notes>
    <Latitude>39.2171</Latitude>
    <Longitude>-93.5147</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Carrollton</City>
    <County>Carroll County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-17</id>
    <notes>Only moved one mile above their previous day&apos;s camp to make oars and rope. Remained here until 1804-06-19</notes>
    <Latitude>39.2173</Latitude>
    <Longitude>-93.5342</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Waverly</City>
    <County>Lafayette County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-19</id>
    <notes>About 2 miles west of Tabo Creek, and about 3 miles east of present day Lexington, MO</notes>
    <Latitude>39.2171</Latitude>
    <Longitude>-93.8291</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Hardin</City>
    <County>Ray County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-20</id>
    <notes>Hard to say exactly where they camped for the night, it was near present day Wellington. MO</notes>
    <Latitude>39.145</Latitude>
    <Longitude>-93.965</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Henrietta</City>
    <County>Ray County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-21</id>
    <notes>Because of the Missouri&apos;s course change, the camp on this day appears to be well north of the River. It was located near current Camden, MO</notes>
    <Latitude>39.195</Latitude>
    <Longitude>-94.0164</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Camden</City>
    <County>Lafayette County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-22</id>
    <notes>Very unclear as to where they camped exactly, as Fire Prairie River and Fire Prairie Creek are used many times. Based on the names of the rivers and creeks, a good estimate could be near or on Fishing River, Ray County, MO</notes>
    <Latitude>39.1825</Latitude>
    <Longitude>-94.1282</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Orrick</City>
    <County>Ray County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-23</id>
    <notes>Fishing River Island, Jackson County, MO</notes>
    <Latitude>39.1908</Latitude>
    <Longitude>-94.1875</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Sibley</City>
    <County>Jackson County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-24</id>
    <notes>Past Rush Creek in Jackson County, MO, on an island that used to be located there</notes>
    <Latitude>39.18</Latitude>
    <Longitude>-94.335</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Independence</City>
    <County>Jackson County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-25</id>
    <notes>Because of the Missouri&apos;s course change, where the company likely rested is off of the current location of the Missouri. Just off of Sugar Creek, Jackson County, MO</notes>
    <Latitude>39.125</Latitude>
    <Longitude>-94.448</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Sugar Creek</City>
    <County>Jackson County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-26</id>
    <notes>At the junction of the Missouri and Kansas rivers in Wyandotte County, KS. They stayed here until 1804-06-29</notes>
    <Latitude>39.1163</Latitude>
    <Longitude>-94.6115</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kansas City</City>
    <County>Wyandotte County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-06-29</id>
    <notes>In the vicinity of current Riverside, MO and Line Creek</notes>
    <Latitude>39.161</Latitude>
    <Longitude>-94.617</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Riverside</City>
    <County>Platte County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-06-30</id>
    <notes>In the vicinity of current Wolcott, KS, in Wyandotte County, KS</notes>
    <Latitude>39.185</Latitude>
    <Longitude>-94.7705</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kansas City</City>
    <County>Wyandotte County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-07-01</id>
    <notes>Leavenworth Island, opposite the city of Leavenworth, KS</notes>
    <Latitude>39.308</Latitude>
    <Longitude>-94.9014</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Leavenworth</City>
    <County>Leavenworth County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-07-02</id>
    <notes>Near Weston, MO, on north shore of the Missouri</notes>
    <Latitude>39.395</Latitude>
    <Longitude>-94.895</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Weston</City>
    <County>Platte County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-07-03</id>
    <notes>Somewhat above Atchison, KS on KS shore of the Missouri</notes>
    <Latitude>39.572</Latitude>
    <Longitude>-95.1101</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Atchison</City>
    <County>Atchison County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-07-04</id>
    <notes>Their camp was located at modern day Doniphan, KS</notes>
    <Latitude>39.636</Latitude>
    <Longitude>-95.053</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Troy</City>
    <County>Doniphan County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-07-05</id>
    <notes>Hard to tell where they camped, but it was on the south side of the Missouri River, and some miles northeast of Doniphan, KS</notes>
    <Latitude>39.677</Latitude>
    <Longitude>-94.985</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Wathena</City>
    <County>Doniphan County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-07-06</id>
    <notes>Probably at Peters Creek in Doniphan County, KS</notes>
    <Latitude>39.747</Latitude>
    <Longitude>-94.95</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wathena</City>
    <County>Doniphan County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1804-07-07</id>
    <notes>A little upstream from St Joseph, MO. The river&apos;s course change likely places them in Buchanan County, MO rather than Doniphan County, KS</notes>
    <Latitude>39.814</Latitude>
    <Longitude>-94.875</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Saint Joseph</City>
    <County>Buchanan County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-07-08</id>
    <notes>Camped at the mouth of the Nodaway River in Buchanan County, MO</notes>
    <Latitude>39.9016</Latitude>
    <Longitude>-94.9685</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Amazonia</City>
    <County>Andrew County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-07-09</id>
    <notes>Actual location not possible to find because of the Missouri&apos;s course change. Near Iowa Point, KS</notes>
    <Latitude>39.924</Latitude>
    <Longitude>-95.204</Longitude>
    <placeName></placeName>
    <alt_notes>*Based on Missouri&apos;s course today
Approximate location</alt_notes>
    <City>Oregon</City>
    <County>Holt County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1804-07-10</id>
    <notes>Holt County, MO, near the Nebraska-Kansas border on the opposite side</notes>
    <Latitude>40.004</Latitude>
    <Longitude>-95.307</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rulo</City>
    <County>Richardson County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-11</id>
    <notes>Stopped on an Island opposite the Big Nemaha River, Holt County, MO. The island is no longer there. Stayed here 1804-07-12 to scout out the Big Nemaha River a little</notes>
    <Latitude>40.029</Latitude>
    <Longitude>-95.383</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rulo</City>
    <County>Richardson County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-13</id>
    <notes>Around 20 miles up the Missouri from the previous camp, in northeastern Richardson County, NE</notes>
    <Latitude>40.248</Latitude>
    <Longitude>-95.499</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Falls City</City>
    <County>Richardson County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-14</id>
    <notes>Because of the change in location of the Nishnabotna River, it is hard to pinpoint exactly where they stopped, but it was likely very near the Nemaha-Richardson County Line in NE</notes>
    <Latitude>40.271</Latitude>
    <Longitude>-95.5593</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Falls City</City>
    <County>Nemaha County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-15</id>
    <notes>Somewhat above the present town of Nemaha, NE, in Nemaha County, NE</notes>
    <Latitude>40.362</Latitude>
    <Longitude>-95.641</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Brownville</City>
    <County>Nemaha County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-16</id>
    <notes>It&apos;s hard to pinpoint where they stopped tonight, with the Missouri changing dramatically since 1804, but we know it was on the bend that is now McKissick Island. They stayed here until 1804-07-18</notes>
    <Latitude>40.56</Latitude>
    <Longitude>-95.68</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Peru</City>
    <County>Nemaha County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-18</id>
    <notes>On the Neb. side of the Missouri, north of the Missouri-Iowa state line and south of Nebraska City</notes>
    <Latitude>40.631</Latitude>
    <Longitude>-95.772</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Nebraska City</City>
    <County>Otoe County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-19</id>
    <notes>A few miles above Nebraska City in Fremont County, IA</notes>
    <Latitude>40.719</Latitude>
    <Longitude>-95.881</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Nebraska City</City>
    <County>Otoe County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-20</id>
    <notes>Just north of Spring Creek in Cass County, NE, on the opposite side of the river, putting the camp in Fremont County, IA</notes>
    <Latitude>40.882</Latitude>
    <Longitude>-95.812</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Thurman</City>
    <County>Fremont County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-07-21</id>
    <notes>A few miles north of Papillion Creek, Sarpy County, NE</notes>
    <Latitude>41.102</Latitude>
    <Longitude>-95.8676</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Bellevue</City>
    <County>Sarpy County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-22</id>
    <notes>Sailed only a few miles up the Missouri to stay a few days and observe and rest. Near the Mills-Pottawattamie County line, IA, opposite Bellevue, NE. Stayed here until 1804-07-27</notes>
    <Latitude>41.16</Latitude>
    <Longitude>-95.8783</Longitude>
    <placeName>Camp White Catfish</placeName>
    <alt_notes></alt_notes>
    <City>Council Bluffs</City>
    <County>Pottawattamie County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-07-27</id>
    <notes>Just north of the current location where Interstate 480 crosses the Missouri, Douglas County, NE</notes>
    <Latitude>41.262</Latitude>
    <Longitude>-95.9241</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Omaha</City>
    <County>Douglas County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-28</id>
    <notes>A little north of Council Bluffs, IA, only a few miles upstream from their previous camp according to the current course of the Missouri</notes>
    <Latitude>41.306</Latitude>
    <Longitude>-95.872</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Council Bluffs</City>
    <County>Pottawattamie County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-07-29</id>
    <notes>Somewhat above the Douglas-Washington county line, NE, on the opposite shore in Pottawattamie County, IA</notes>
    <Latitude>41.398</Latitude>
    <Longitude>-95.936</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Omaha</City>
    <County>Washington County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-07-30</id>
    <notes>Near Fort Calhoun, NE, about 15 miles north of Omaha. Stayed here until 1804-08-03</notes>
    <Latitude>41.468</Latitude>
    <Longitude>-95.9934</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Fort Calhoun</City>
    <County>Washington County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-08-03</id>
    <notes>Again, the change in the Missouri here has made it difficult to find the exact camp, but it was likely southeast of Blair, NE</notes>
    <Latitude>41.518</Latitude>
    <Longitude>-95.9982</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Fort Calhoun</City>
    <County>Washington County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-08-04</id>
    <notes>In the vicinity of Blair, NE, but no exact location</notes>
    <Latitude>41.548</Latitude>
    <Longitude>-96.1</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Blair</City>
    <County>Washington County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-08-05</id>
    <notes>Near the Burt-Washington County line, NE, on the IA side of the river</notes>
    <Latitude>41.687</Latitude>
    <Longitude>-96.12</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Modale</City>
    <County>Harrison County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-06</id>
    <notes>With the considerable amount of the Missouri&apos;s course change, most of the camps on the Nebraska-Iowa border are hard to find. They camped halfway between Soldier Creek and Little Sioux River</notes>
    <Latitude>41.769</Latitude>
    <Longitude>-96.079</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Little Sioux</City>
    <County>Harrison County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-07</id>
    <notes>A couple miles below the mouth of the Little Sioux River, Harrison County, IA</notes>
    <Latitude>41.795</Latitude>
    <Longitude>-96.06</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Little Sioux</City>
    <County>Harrison County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-08</id>
    <notes>In Monona County, IA, most likely. It is possible for the camp to have been in Burt County, NE because of the course change</notes>
    <Latitude>41.976</Latitude>
    <Longitude>-96.181</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Decatur</City>
    <County>Burt County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-08-09</id>
    <notes>South of current Onawa, IA, and just west of Guard Lake. The campsite appears to be a few miles inland because of the Missouri&apos;s course change</notes>
    <Latitude>41.9899</Latitude>
    <Longitude>-96.1222</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Onawa</City>
    <County>Monona County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-10</id>
    <notes>East or southeast of Blackbird Hill, NE, significantly east of the Missouri&apos;s current course</notes>
    <Latitude>42.0565</Latitude>
    <Longitude>-96.2057</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Onawa</City>
    <County>Monona County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-11</id>
    <notes>In the vicinity of Badger Lake, IA, due to the dramatic change in the river</notes>
    <Latitude>42.1437</Latitude>
    <Longitude>-96.2288</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Whiting</City>
    <County>Monona County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-12</id>
    <notes>Around the Monona-Woodbury County line, IA, but it is unknown which side of this line the camp was on</notes>
    <Latitude>42.217</Latitude>
    <Longitude>-96.3496</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Sloan</City>
    <County>Woodbury County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-13</id>
    <notes>A few miles south of present Dakota City, NE, but could again be on either the Nebraska or Iowa side of the river. Either in Dakota County, NE, or Woodbury County, IA. Remained here and in the surrounding area until 1804-08-20</notes>
    <Latitude>42.3603</Latitude>
    <Longitude>-96.4179</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Sergeant Bluff</City>
    <County>Woodbury County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-20</id>
    <notes>Stopped in present day Sioux City, IA, next to Floyd River. Named after Charles Floyd, who died on this day and was the only casualty of the expedition</notes>
    <Latitude>42.4847</Latitude>
    <Longitude>-96.3939</Longitude>
    <placeName>Floyd River</placeName>
    <alt_notes></alt_notes>
    <City>Sioux City</City>
    <County>Woodbury County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1804-08-21</id>
    <notes>South of present Jefferson, SD, and north of Lake Goodenough, which no longer is on the Missouri</notes>
    <Latitude>42.5853</Latitude>
    <Longitude>-96.5605</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Jefferson</City>
    <County>Union County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-08-22</id>
    <notes>In Union County, SD, south of present Elk Point</notes>
    <Latitude>42.6642</Latitude>
    <Longitude>-96.6848</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Elk Point</City>
    <County>Union County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-08-23</id>
    <notes>In either Dixon County, NE, or Clay County, SD. About a mile or so southeast of Vermillion, SD, near the mouth of the Vermillion River</notes>
    <Latitude>42.7515</Latitude>
    <Longitude>-96.8748</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Burbank</City>
    <County>Clay County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-08-24</id>
    <notes>West and a little south of present Vermillion, SD, in Clay County, SD. Stayed here until 1804-08-26</notes>
    <Latitude>42.7677</Latitude>
    <Longitude>-96.9811</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Vermillion</City>
    <County>Clay County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-08-26</id>
    <notes>Opposite the mouth of Bow Creek, Clay County, SD</notes>
    <Latitude>42.7749</Latitude>
    <Longitude>-97.1308</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Vermillion</City>
    <County>Clay County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-08-27</id>
    <notes>Between Yankton, SD, and James Creek in Yankton County, SD</notes>
    <Latitude>42.8623</Latitude>
    <Longitude>-97.336</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Yankton</City>
    <County>Yankton County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-08-28</id>
    <notes>Just south of the present Gavins Point Dam in Cedar County, NE, which dams off Lewis and Clark Lake. Remained here until 1804-09-01</notes>
    <Latitude>42.845</Latitude>
    <Longitude>-97.479</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Crofton</City>
    <County>Cedar County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-09-01</id>
    <notes>Stopped on Bon Homme Island in Lewis and Clark Lake, between Bon Homme County, SD, and Knox County, NE. It has since been engulfed by the lake, so it can no longer be seen.</notes>
    <Latitude>42.8499</Latitude>
    <Longitude>-97.6313</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Crofton</City>
    <County>Knox County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-09-02</id>
    <notes>The Yellow Banks of Lewis and Clark Lake, Bon Homme County, SD</notes>
    <Latitude>42.8631</Latitude>
    <Longitude>-97.714</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Tabor</City>
    <County>Bon Homme County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-03</id>
    <notes>Near the western boundary of present Santee Sioux Recreation Park, Knox County, NE</notes>
    <Latitude>42.8417</Latitude>
    <Longitude>-97.8507</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Niobrara</City>
    <County>Knox County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-09-04</id>
    <notes>A little above the mouth of the Niobrara River, Knox County, NE, probably in Niobrara State Park</notes>
    <Latitude>42.7597</Latitude>
    <Longitude>-98.0291</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Niobrara</City>
    <County>Knox County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-09-05</id>
    <notes>On an island between Knox County, NE, and Charles Mix County, SD</notes>
    <Latitude>42.8398</Latitude>
    <Longitude>-98.1756</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Niobrara</City>
    <County>Knox County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-09-06</id>
    <notes>A little below the Knox-Boyd County line, NE, on the opposite shore in Charles Mix County, SD</notes>
    <Latitude>42.8841</Latitude>
    <Longitude>-98.305</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wagner</City>
    <County>Charles Mix County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-07</id>
    <notes>Old Baldy in Boyd County, NE</notes>
    <Latitude>42.9333</Latitude>
    <Longitude>-98.4667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lynch</City>
    <County>Boyd County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1804-09-08</id>
    <notes>Strehlow Island, Charles Mix County, SD. They are now completely in SD</notes>
    <Latitude>43.0667</Latitude>
    <Longitude>-98.6667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fairfax</City>
    <County>Gregory County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-09</id>
    <notes>On the south side of the Missouri in Gregory County, SD. Opposite Stony Point.</notes>
    <Latitude>43.1408</Latitude>
    <Longitude>-98.8401</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Fairfax</City>
    <County>Gregory County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-10</id>
    <notes>Pocahontas, or Towhead, Island in between Gregory and Charles Mix Counties, SD</notes>
    <Latitude>43.3333</Latitude>
    <Longitude>-99.0667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Platte</City>
    <County>Charles Mix County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-11</id>
    <notes>Just above the mouth of the Rosebud, or Landing, Creek in Gregory County, SD</notes>
    <Latitude>43.4624</Latitude>
    <Longitude>-99.3089</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Gregory</City>
    <County>Gregory County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-12</id>
    <notes>Only a few miles away from their previous camp due to shallow waters giving them trouble. A little above the Gregory-Lyman County line, SD</notes>
    <Latitude>43.5146</Latitude>
    <Longitude>-99.2985</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chamberlain</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-13</id>
    <notes>In Brule County, SD, on the north side of the river</notes>
    <Latitude>43.6551</Latitude>
    <Longitude>-99.3905</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Chamberlain</City>
    <County>Brule County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-14</id>
    <notes>Below current Bull Creek, in a spot now inundated by the Missouri. In Lyman County, SD</notes>
    <Latitude>43.6826</Latitude>
    <Longitude>-99.476</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Reliance</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-15</id>
    <notes>Opposite current American Crow Creek in Brule County, SD</notes>
    <Latitude>43.7786</Latitude>
    <Longitude>-99.3998</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chamberlain</City>
    <County>Brule County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-16</id>
    <notes>Camped where the current town of Oacoma is. Stayed here until 1804-09-18</notes>
    <Latitude>43.7943</Latitude>
    <Longitude>-99.3873</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Oacoma</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-18</id>
    <notes>In Lyman County, SD, a few miles northeast of Oacoma</notes>
    <Latitude>43.8813</Latitude>
    <Longitude>-99.3371</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Reliance</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-19</id>
    <notes>Hard to find exactly the area where the camp was located, with many name changes to rivers and creeks in the area. In Lyman County, SD</notes>
    <Latitude>44.0761</Latitude>
    <Longitude>-99.578</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lower Brule</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-20</id>
    <notes>On the north side of the river in Hughes County, SD, above an island that is now inundated by the Missouri</notes>
    <Latitude>44.1499</Latitude>
    <Longitude>-99.6613</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Harrold</City>
    <County>Hughes County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-21</id>
    <notes>Near what was known as Halfmoon Island in Hughes County, SD, a little above Medicine Creek</notes>
    <Latitude>44.1276</Latitude>
    <Longitude>-99.7204</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Harrold</City>
    <County>Hughes County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-22</id>
    <notes>Opposite of LaRoche Creek, Hughes County, SD</notes>
    <Latitude>44.2205</Latitude>
    <Longitude>-99.908</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Pierre</City>
    <County>Stanley County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-23</id>
    <notes>A little below Antelope Creek on the opposite side of the river, Hughes County, SD</notes>
    <Latitude>44.33</Latitude>
    <Longitude>-100.1622</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pierre</City>
    <County>Hughes County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-24</id>
    <notes>Just above the mouth of Bad River, opposite Pierre, SD, placing it in Stanley County. Remained here until 1804-09-26</notes>
    <Latitude>44.3546</Latitude>
    <Longitude>-100.3694</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Pierre</City>
    <County>Stanley County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-26</id>
    <notes>Four miles north of their previous camp, two miles south of the current Oahe Dam. Remained here until 1804-09-28</notes>
    <Latitude>44.4137</Latitude>
    <Longitude>-100.3748</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pierre</City>
    <County>Hughes County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-28</id>
    <notes>About 3 miles up the river from the Oahe Dam, in a spot inundated by the Missouri</notes>
    <Latitude>44.4653</Latitude>
    <Longitude>-100.4534</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pierre</City>
    <County>Hughes County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-29</id>
    <notes>While this precise location is hard to find, it could have been located on Okobojo Island, near the mouth of Okobojo Creek between Sully and Stanley Counties, SD</notes>
    <Latitude>44.5697</Latitude>
    <Longitude>-100.5093</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Pierre</City>
    <County>Sully County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-09-30</id>
    <notes>Again, this camp site has been inundated by the Missouri River. It is likely near the mouth of the Cheyenne River on the northern shore</notes>
    <Latitude>44.7771</Latitude>
    <Longitude>-100.6942</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Fort Pierre</City>
    <County>Stanley County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-01</id>
    <notes>While the coordinates do not suggest it, they traveled 10+ miles on this day because of a large bend in the Missouri. They camped in Dewey County, SD, a few mile from the mouth of the Cheyenne</notes>
    <Latitude>44.7813</Latitude>
    <Longitude>-100.5891</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Eagle Butte</City>
    <County>Dewey County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-02</id>
    <notes>Plum Island, which is now inundated by the river. Sully County, SD</notes>
    <Latitude>44.8</Latitude>
    <Longitude>-100.4833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pierre</City>
    <County>Sully County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-03</id>
    <notes>Landed on Good Hope Island, now known as Pascal Island. It is unclear as to whether or not the camped on the head of the island or elsewhere. In Potter County, SD </notes>
    <Latitude>44.9333</Latitude>
    <Longitude>-100.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Eagle Butte</City>
    <County>Dewey County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-04</id>
    <notes>After having to backtrack 3 miles, they reached Lafferty Island, between Dewey and Potter Counties, SD</notes>
    <Latitude>45</Latitude>
    <Longitude>-100.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Gettysburg</City>
    <County>Potter County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-05</id>
    <notes>An island that has been inundated by the river. In Potter County, SD</notes>
    <Latitude>45.1381</Latitude>
    <Longitude>-100.3045</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Mobridge</City>
    <County>Dewey County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-06</id>
    <notes>Opposite Swan Creek in Walworth County, SD. Campsite inundated by river</notes>
    <Latitude>45.3069</Latitude>
    <Longitude>-100.2905</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Selby</City>
    <County>Walworth County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-07</id>
    <notes>Above Blue Blanket Island, Walworth County, SD. Near Mobridge, SD</notes>
    <Latitude>45.4992</Latitude>
    <Longitude>-100.3597</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Glenham</City>
    <County>Walworth County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-08</id>
    <notes>Ashley Island, Corson County, SD. They remained here until 1804-10-12</notes>
    <Latitude>45.5989</Latitude>
    <Longitude>-100.4219</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mobridge</City>
    <County></County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-12</id>
    <notes>In Campbell County, SD, in an area inundated by the Missouri</notes>
    <Latitude>45.6975</Latitude>
    <Longitude>-100.2933</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Glenham</City>
    <County>Campbell County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-13</id>
    <notes>About a mile below the North Dakota-South Dakota state line, Campbell County, SD</notes>
    <Latitude>45.914</Latitude>
    <Longitude>-100.4175</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pollock</City>
    <County>Campbell County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1804-10-14</id>
    <notes>Emmons County, ND, in a spot also inundated by the river. Apparently some sort of ancient fortification was visible from the camp, but that too has been inundated by the river. This is their first camp in North Dakota</notes>
    <Latitude>46.0044</Latitude>
    <Longitude>-100.5384</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Linton</City>
    <County>Emmons County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-15</id>
    <notes>Near Fort Yates, ND, on the opposite shore and a little south. In Emmons County, ND</notes>
    <Latitude>46.0739</Latitude>
    <Longitude>-100.5916</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Linton</City>
    <County>Emmons County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-16</id>
    <notes>Sioux County, ND, roughly two miles above Beaver Creek</notes>
    <Latitude>46.2732</Latitude>
    <Longitude>-100.5865</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cannon Ball</City>
    <County>Sioux County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-17</id>
    <notes>A mile or two below present day Cannon Ball, ND. In Sioux County, ND</notes>
    <Latitude>46.3555</Latitude>
    <Longitude>-100.5719</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cannon Ball</City>
    <County>Sioux County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-18</id>
    <notes>A little above Rice Creek in Morton County, ND. Opposite of modern day Linova, ND</notes>
    <Latitude>46.5185</Latitude>
    <Longitude>-100.5818</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandan</City>
    <County>Morton County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-19</id>
    <notes>The camp would have been in Morton County, ND, a few miles upstream of Huff. It has since been inundated by the Missouri</notes>
    <Latitude>46.663</Latitude>
    <Longitude>-100.6406</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Missouri</City>
    <County>Burleigh County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-20</id>
    <notes>Camped in what is now known as Fort Lincoln State Park, about five miles south of Mandan, ND, and nearly opposite of Bismarck, ND. In Morton County, ND</notes>
    <Latitude>46.7582</Latitude>
    <Longitude>-100.8421</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandan</City>
    <County>Morton County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-21</id>
    <notes>In present day Mandan, Morton County, ND</notes>
    <Latitude>46.8305</Latitude>
    <Longitude>-100.8601</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandan</City>
    <County>Morton County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-22</id>
    <notes>In southeast Oliver County, just above the Oliver-Morton County line, ND</notes>
    <Latitude>46.9895</Latitude>
    <Longitude>-100.9374</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandan</City>
    <County>Oliver County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-23</id>
    <notes>Near Sanger, Oliver County, ND</notes>
    <Latitude>47.1698</Latitude>
    <Longitude>-100.9879</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Center</City>
    <County>Oliver County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-24</id>
    <notes>Probably a couple of miles below Washburn, ND, in Oliver County.</notes>
    <Latitude>47.268</Latitude>
    <Longitude>-101.0124</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Washburn</City>
    <County>Oliver County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-25</id>
    <notes>Near Fort Clark, ND. The campsite could have been in either Oliver or McLean County because of shifts in the river</notes>
    <Latitude>47.2515</Latitude>
    <Longitude>-101.2326</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Washburn</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-26</id>
    <notes>Camped at a spot called Matootonha, which is on or near the site of Deapolis, Mercer County, ND. The camp could also have been in McLean County because of shifts in the river</notes>
    <Latitude>47.29</Latitude>
    <Longitude>-101.3363</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Washburn</City>
    <County>Mercer County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-27</id>
    <notes>Opposite current Stanton, Mercer County, ND. In McLean County. The site has since been washed away by the Missouri. Remained here until 1804-10-30</notes>
    <Latitude>47.3257</Latitude>
    <Longitude>-101.3528</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Washburn</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-10-30</id>
    <notes>Above the last Hidatsa village in McLean County, ND. While it used to be an island, it has since joined up with the shore of McLean County.</notes>
    <Latitude>47.3988</Latitude>
    <Longitude>-101.3952</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Underwood</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1804-11-01</id>
    <notes>The company backtracks to the site of Fort Mandan, between the first and second villages they came across. About 14 miles west of Washburn, ND. They remained here for the winter and set out again on 1805-04-07</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Washburn</City>
    <County>Mercer County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-07</id>
    <notes>On the east side of the Missouri, about 3 miles southeast of Stanton, ND. In McLean County</notes>
    <Latitude>47.2967</Latitude>
    <Longitude>-101.3429</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Washburn</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-08</id>
    <notes>One mile or so downstream from the Garrison Dam, McLean County, ND</notes>
    <Latitude>47.4653</Latitude>
    <Longitude>-101.4379</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Hazen</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-09</id>
    <notes>In an area inundated by the Garrison Reservoir, a few mile southwest of Garrison, ND. In McLean County</notes>
    <Latitude>47.5813</Latitude>
    <Longitude>-101.5152</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Garrison</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-10</id>
    <notes>Just above the location of Fort Berthold, which is now under the Garrison Reservoir, McLean County, ND</notes>
    <Latitude>47.5283</Latitude>
    <Longitude>-101.8628</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Garrison</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-11</id>
    <notes>A few miles below the mouth of the Little Missouri river, McLean County, ND. The entire area has since been inundated by the Garrison Reservoir</notes>
    <Latitude>47.5598</Latitude>
    <Longitude>-102.1853</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Halliday</City>
    <County>Mercer County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-12</id>
    <notes>At the mouth of the Little Missouri river, only a few miles from their previous camp. With the change in location of the river, and the growth of the Garrison Reservoir, the site has been inundated</notes>
    <Latitude>47.6027</Latitude>
    <Longitude>-102.2787</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Halliday</City>
    <County>Dunn County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-13</id>
    <notes>In Mountrail County, ND. At a location called Fort Maneury Bend, which is now under the Garrison Reservoir</notes>
    <Latitude>47.7522</Latitude>
    <Longitude>-102.413</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandaree</City>
    <County>Dunn County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-14</id>
    <notes>In Mountrail County, ND, a little above the mouth of Bear Den Creek on the opposite shore</notes>
    <Latitude>47.817</Latitude>
    <Longitude>-102.6089</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>New Town</City>
    <County>Mountrail County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-15</id>
    <notes>In Mountrail County, ND, on the north shore of the river, past Little Knife River. The location is now under the Garrison Reservoir.</notes>
    <Latitude>48.0805</Latitude>
    <Longitude>-102.6759</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>New Town</City>
    <County>Mountrail County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-16</id>
    <notes>A little above the mouth of Beaver Creek on the opposite side of the Missouri. McKenzie County, ND</notes>
    <Latitude>48.1176</Latitude>
    <Longitude>-103.0088</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>North McKenzie</City>
    <County>McKenzie County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-17</id>
    <notes>McKenzie County, ND</notes>
    <Latitude>48.0656</Latitude>
    <Longitude>-103.2231</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Watford City</City>
    <County>McKenzie County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-18</id>
    <notes>Williams County, ND. They remained here until 1805-04-20</notes>
    <Latitude>48.0497</Latitude>
    <Longitude>-103.4104</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Epping</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-20</id>
    <notes>A short distance from their previous camp, in Williams County, ND</notes>
    <Latitude>48.0303</Latitude>
    <Longitude>-103.5207</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-21</id>
    <notes>Nearly opposite present day Williston, ND. In McKenzie County</notes>
    <Latitude>48.1116</Latitude>
    <Longitude>-103.63</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-22</id>
    <notes>A few miles above their previous camp opposite Williston. Also in McKenzie County, ND</notes>
    <Latitude>48.1007</Latitude>
    <Longitude>-103.7297</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-23</id>
    <notes>Williams County, ND. They remained here until 1805-04-25</notes>
    <Latitude>47.9868</Latitude>
    <Longitude>-103.8079</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Alexander</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-25</id>
    <notes>In the vicinity of Glass Bluffs on the opposite side, Williams County, ND</notes>
    <Latitude>47.9578</Latitude>
    <Longitude>-103.914</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-26</id>
    <notes>At the junction of the Missouri and Yellowstone Rivers in McKenzie County, ND. With shifts in both rivers, the exact spot is hard to find.</notes>
    <Latitude>47.9778</Latitude>
    <Longitude>-103.9808</Longitude>
    <placeName></placeName>
    <alt_notes>Based on junction location today</alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1805-04-27</id>
    <notes>Their first camp in MT, about a mile below and opposite of Nohly, MT. In Roosevelt County, MT</notes>
    <Latitude>48.0021</Latitude>
    <Longitude>-104.1014</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bainville</City>
    <County>Richland County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-04-28</id>
    <notes>Near Otis Creek, Richland County, MT, but on the opposite side of the Missouri in Roosevelt County, MT</notes>
    <Latitude>48.0439</Latitude>
    <Longitude>-104.2725</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Bainville</City>
    <County>Richland County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-04-29</id>
    <notes>Just above Big Muddy Creek, Roosevelt County, MT</notes>
    <Latitude>48.1416</Latitude>
    <Longitude>-104.6106</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Culbertson</City>
    <County>Roosevelt County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-04-30</id>
    <notes>In the neighborhood of Brockton, Roosevelt County, MT</notes>
    <Latitude>48.1465</Latitude>
    <Longitude>-104.9162</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Brockton</City>
    <County>Roosevelt County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-01</id>
    <notes>Near later Elkhorn Point in Roosevelt County, MT</notes>
    <Latitude>48.0667</Latitude>
    <Longitude>-104.9938</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Poplar</City>
    <County>Richland County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-02</id>
    <notes>Near the crossing of Montana Highway 480 in Roosevelt County, MT</notes>
    <Latitude>48.0659</Latitude>
    <Longitude>-105.0304</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Poplar</City>
    <County></County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-03</id>
    <notes>Past Poplar River and Redwater River in Roosevelt County, MT. About 4 mile away from the town of Poplar, MT</notes>
    <Latitude>48.0708</Latitude>
    <Longitude>-105.2224</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Poplar</City>
    <County>McCone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-04</id>
    <notes>In Roosevelt County, MT</notes>
    <Latitude>48.0692</Latitude>
    <Longitude>-105.5388</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Wolf Point</City>
    <County>Roosevelt County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-05</id>
    <notes>In McCone County, MT, southeast of the current town of Wolf Point. Because of the shifts of the river over time, the camp is about a mile away from the river today.</notes>
    <Latitude>48.0436</Latitude>
    <Longitude>-105.6833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Vida</City>
    <County>McCone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-06</id>
    <notes>A few miles southwest of present day Oswego, MT. Located in McCone County, MT</notes>
    <Latitude>48.0122</Latitude>
    <Longitude>-105.9625</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Wolf Point</City>
    <County>Valley County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-07</id>
    <notes>A few miles southwest of present day Frazer, MT. The camp was located in either McCone County or Valley County, MT</notes>
    <Latitude>48.0066</Latitude>
    <Longitude>-106.1462</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Peck</City>
    <County>McCone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-08</id>
    <notes>A mile or two above present Fort Peck Dam, and just south of Milk River. In Valley County, MT</notes>
    <Latitude>48.0495</Latitude>
    <Longitude>-106.3394</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Nashua</City>
    <County>McCone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-09</id>
    <notes>In a location inundated by the Fort Peck Reservoir, southwest of the town of Fort Peck, MT. Located in Valley County, MT, by Duck Creek.</notes>
    <Latitude>47.9833</Latitude>
    <Longitude>-106.5276</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Glasgow</City>
    <County>Valley County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-10</id>
    <notes>In either Garfield County or Valley County, MT. The area has been inundated by the Fort Peck Reservoir</notes>
    <Latitude>47.9247</Latitude>
    <Longitude>-106.5428</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Glasgow</City>
    <County>Valley County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-11</id>
    <notes>In Garfield County, MT, in a spot inundated by the reservoir</notes>
    <Latitude>47.8342</Latitude>
    <Longitude>-106.5442</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Jordan</City>
    <County>Garfield County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-12</id>
    <notes>Again, the area has been inundated by the river, but it would have been located in Garfield County, MT</notes>
    <Latitude>47.763</Latitude>
    <Longitude>-106.6487</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Jordan</City>
    <County>Garfield County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-13</id>
    <notes>A mile or two above the mouth of Crooked Creek in Garfield County, MT</notes>
    <Latitude>47.727</Latitude>
    <Longitude>-106.7926</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Glasgow</City>
    <County>Valley County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-14</id>
    <notes>A few miles above present Snow Creek in Valley County, MT. The location has been inundated by the reservoir. They remained here until 1805-05-16</notes>
    <Latitude>47.6533</Latitude>
    <Longitude>-107.0131</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Jordan</City>
    <County>Garfield County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-16</id>
    <notes>It is unclear which side of the river the camp was on, as different journals contradict each other. Either way, the site has been inundated by the reservoir</notes>
    <Latitude>47.658</Latitude>
    <Longitude>-107.1731</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Jordan</City>
    <County>Garfield County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-17</id>
    <notes>Located in Garfield County, MT, a little upstream from the mouth of Seven Blackfoot Creek</notes>
    <Latitude>47.6344</Latitude>
    <Longitude>-107.4303</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Malta</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-18</id>
    <notes>About two miles upstream of the current Devils Creek Recreation Area in Garfield County, MT. The area is now under the Fort Peck reservoir</notes>
    <Latitude>47.6285</Latitude>
    <Longitude>-107.6192</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Garfield County</City>
    <County>Garfield County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-19</id>
    <notes>Near the Musselshell river in either Phillips or Garfield County, MT</notes>
    <Latitude>47.4945</Latitude>
    <Longitude>-107.8577</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Malta</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-20</id>
    <notes>A little upstream of Musselshell river in either Garfield or Petroleum County. The site is now covered by the reservoir</notes>
    <Latitude>47.4481</Latitude>
    <Longitude>-107.8946</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Malta</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-21</id>
    <notes>The site was in Phillips County, MT, but has since been inundated by the Missouri</notes>
    <Latitude>47.5848</Latitude>
    <Longitude>-107.9986</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Malta</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-22</id>
    <notes>Phillips County, MT, just below present day C K Creek</notes>
    <Latitude>47.5886</Latitude>
    <Longitude>-108.1828</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Malta</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-23</id>
    <notes>Just below Rock Creek in Fergus County, MT</notes>
    <Latitude>47.6066</Latitude>
    <Longitude>-108.4617</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Zortman</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-24</id>
    <notes>In either Fergus County or Phillips County, MT, three miles above where present day U.S. Highway 191 crosses the Missouri</notes>
    <Latitude>47.6477</Latitude>
    <Longitude>-108.7444</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Roy</City>
    <County>Fergus County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-25</id>
    <notes>In Fergus County, MT, five or six miles below the present Cow Island</notes>
    <Latitude>47.7345</Latitude>
    <Longitude>-108.9079</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Blaine County</City>
    <County>Blaine County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-26</id>
    <notes>In Fergus County, MT, some two miles below the mouth of Windsor Creek</notes>
    <Latitude>47.7811</Latitude>
    <Longitude>-109.1478</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Blaine County</City>
    <County>Blaine County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-27</id>
    <notes>In Fergus County, MT, near later McGarry Bar</notes>
    <Latitude>47.7312</Latitude>
    <Longitude>-109.4061</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Winifred</City>
    <County>Fergus County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-28</id>
    <notes>Opposite Dog Creek in Fergus County, MT. Also near the Judith Landing Recreation Area</notes>
    <Latitude>47.7377</Latitude>
    <Longitude>-109.617</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Big Sandy</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-29</id>
    <notes>Camped at Arrow River in Chouteau County, MT</notes>
    <Latitude>47.7157</Latitude>
    <Longitude>-109.8366</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Big Sandy</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-30</id>
    <notes>In Chouteau County, MT, above Pablo Island. Nearly opposite Sheep Shed Coulee</notes>
    <Latitude>47.7613</Latitude>
    <Longitude>-109.9248</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Big Sandy</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-05-31</id>
    <notes>Above Eagle Creek in Chouteau County, MT.</notes>
    <Latitude>47.9154</Latitude>
    <Longitude>-110.0579</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Big Sandy</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-06-01</id>
    <notes>Camped in the vicinity of Boggs Island in Chouteau County, MT</notes>
    <Latitude>48.0132</Latitude>
    <Longitude>-110.2742</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Benton</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-06-02</id>
    <notes>About a mile or so below the mouth of the Marias River in Chouteau County, MT. They remained here until 1805-06-12</notes>
    <Latitude>47.9274</Latitude>
    <Longitude>-110.4734</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Benton</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-06-12</id>
    <notes>With Lewis and Clark on different paths for the time being, Clark and his party continued down the left branch of the river going south, which is the Missouri River. He stopped at Evans Bend, Chouteau County, MT. Lewis had gone ahead to Great Falls, and camped upstream of Black Coulee on this day</notes>
    <Latitude>47.852</Latitude>
    <Longitude>-110.5772</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Benton</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-06-13</id>
    <notes>Lewis arrived in Great Falls on this day, and Clark was still progressing up the Missouri. Camped in Chouteau County, MT, in the vicinity of Bird Coulee</notes>
    <Latitude>47.7736</Latitude>
    <Longitude>-110.7757</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Highwood</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-06-14</id>
    <notes>Clark and his party camp near Black Coulee, where Lewis camped only two days earlier. In Chouteau County, MT</notes>
    <Latitude>47.7289</Latitude>
    <Longitude>-110.9471</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Floweree</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-06-15</id>
    <notes>Just below the Chouteau - Cascade County line in Cascade County, MT. Below the mouth of Belt Creek. Lewis and Clark met up here and remained here until 1805-07-15</notes>
    <Latitude>47.5971</Latitude>
    <Longitude>-111.0486</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Highwood</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id></id>
    <notes>Company gradually moved down the river for exploration over the next month, stopping at the White Bear Islands, Cascade County, MT</notes>
    <Latitude>47.4597</Latitude>
    <Longitude>-111.3029</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-15</id>
    <notes>Cascade County, a few miles southwest of Ulm, MT</notes>
    <Latitude>47.4083</Latitude>
    <Longitude>-111.525</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-16</id>
    <notes>Near what is now known as Tintinger Slough, Cascade County, MT. At the base of the Rocky Mountains</notes>
    <Latitude>47.2367</Latitude>
    <Longitude>-111.7374</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Cascade</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-17</id>
    <notes>Near the location that Highway 15 crosses the Missouri, Lewis and Clark County, MT. A few miles past Dearborn River</notes>
    <Latitude>47.1006</Latitude>
    <Longitude>-111.9508</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wolf Creek</City>
    <County>Lewis and Clark County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-18</id>
    <notes>Camped in Lewis and Clark County, MT, above the present Holter Dam</notes>
    <Latitude>46.9925</Latitude>
    <Longitude>-112.005</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wolf Creek</City>
    <County>Lewis and Clark County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-19</id>
    <notes>Just below Upper Holter Lake, Lewis and Clark County, MT</notes>
    <Latitude>46.8117</Latitude>
    <Longitude>-111.9366</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Helena</City>
    <County>Lewis and Clark County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-20</id>
    <notes>At the point between Soup Creek and Trout Creek, Lewis and Clark County, MT</notes>
    <Latitude>46.7224</Latitude>
    <Longitude>-111.8023</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Helena</City>
    <County>Lewis and Clark County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-21</id>
    <notes>In the vicinity of the mouth of Beaver Creek, Broadwater County, MT</notes>
    <Latitude>46.5143</Latitude>
    <Longitude>-111.5876</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Helena</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-22</id>
    <notes>In Broadwater County, MT, a few miles upstream from Beaver Creek. Location is now under Canyon Ferry Lake</notes>
    <Latitude>46.4568</Latitude>
    <Longitude>-111.524</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Townsend</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-23</id>
    <notes>Near the south end of Canyon Ferry Lake, near the present town of Townsend</notes>
    <Latitude>46.3488</Latitude>
    <Longitude>-111.5217</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Townsend</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-24</id>
    <notes>About seven miles north of the  present town of Toston, Broadwater County, MT</notes>
    <Latitude>46.2701</Latitude>
    <Longitude>-111.504</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Townsend</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-25</id>
    <notes>Immediately above Toston Dam, Broadwater County, MT</notes>
    <Latitude>46.1202</Latitude>
    <Longitude>-111.4069</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Toston</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-26</id>
    <notes>A few miles above the mouth of the Gallatin River, Gallatin County, MT</notes>
    <Latitude>45.9861</Latitude>
    <Longitude>-111.4634</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Three Forks</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-27</id>
    <notes>Camped on what they called Barkers Island, Gallatin County, MT. About 2 miles northeast of the town of Three Forks on the Jefferson River. Stayed here until 1805-07-30</notes>
    <Latitude>45.9249</Latitude>
    <Longitude>-111.5214</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Three Forks</City>
    <County></County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-30</id>
    <notes>Just below one of the mouths of Willow Creek, in Jefferson County, MT. About two miles north of the town of Willow Creek</notes>
    <Latitude>45.8387</Latitude>
    <Longitude>-111.654</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Broadwater County</City>
    <County>Broadwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-07-31</id>
    <notes>Near the mouth of Antelope Creek, in either Gallatin or Madison County, MT</notes>
    <Latitude>45.7949</Latitude>
    <Longitude>-111.8006</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cardwell</City>
    <County>Gallatin County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-01</id>
    <notes>A little above the present town of Cardwell, Jefferson County, MT</notes>
    <Latitude>45.8475</Latitude>
    <Longitude>-111.98</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Whitehall</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-02</id>
    <notes>In the vicinity of Waterloo, Madison County, MT</notes>
    <Latitude>45.7295</Latitude>
    <Longitude>-112.2119</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Whitehall</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-03</id>
    <notes>Camped in Madison County, MT, above the mouth of the Big Hole River. The location of the mouth has shifted significantly since 1805, making it difficult to find an exact location</notes>
    <Latitude>45.5809</Latitude>
    <Longitude>-112.3387</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-04</id>
    <notes>Camped near the Madison-Beaverhead County line, above the mouth of the Nez Perce Creek</notes>
    <Latitude>45.4427</Latitude>
    <Longitude>-112.5054</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-05</id>
    <notes>Camped about a mile up the Big Hole River from its mouth, Madison County, northwest of present Twin Bridges.</notes>
    <Latitude>45.5559</Latitude>
    <Longitude>-112.3507</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-06</id>
    <notes>Camped opposite the mouth of the Big Hole River in Madison County, MT. The river&apos;s course change makes it seems as though the party travelled backwards</notes>
    <Latitude>45.5614</Latitude>
    <Longitude>-112.3376</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-07</id>
    <notes>Headed up Jefferson&apos;s River. Camped 7 miles from last location, north side, Madison County, MT. </notes>
    <Latitude>45.5333</Latitude>
    <Longitude>-112.3167</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-08</id>
    <notes>Headed upriver. Passed a south-eastward coursed river, named it Philanthropy. Camped on the left side, Madison County, MT, few miles above the mouth of the Ruby River.</notes>
    <Latitude>44.85</Latitude>
    <Longitude>-112.1333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-09</id>
    <notes>Camped downstream of Beaverhead County, on the Beaverhead River. Met with Shannon who had been at the Wisdom River</notes>
    <Latitude>45.5435</Latitude>
    <Longitude>-112.3321</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-10</id>
    <notes>Camped near the Madison-Beaverhead county line, above Beaverhead Rock. Mountains referred to are the Ruby Range</notes>
    <Latitude>45.4074</Latitude>
    <Longitude>-112.4585</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-11</id>
    <notes>Camped on what they called 3000 Mile Island. Island no longer exists due to new river flow. Was about halfway between Beaverhead Rock and present-day Dillon, Beaverhead County, MT.</notes>
    <Latitude>45.298</Latitude>
    <Longitude>-112.5721</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-12</id>
    <notes>Camped a few miles below the mouth of Blacktail Deer Creek. North of Dillon, Beaverhead County, MT.</notes>
    <Latitude>45.2313</Latitude>
    <Longitude>-112.6336</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-13</id>
    <notes>Went 15 miles from previous location, camped on the south side. McNeal Creek, named after the party&apos;s Hugh McNeal, now called Blacktail Deer Creek. Dillon, Beaverhead County, MT</notes>
    <Latitude>44.9</Latitude>
    <Longitude>-112.35</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-14</id>
    <notes>Camped in what they called the Rattlesnake Clifts where the river enters the mountains. Beaverhead County, MT</notes>
    <Latitude>45.2305</Latitude>
    <Longitude>-112.637</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-15</id>
    <notes>Camped just below the mouth of Gallagher&apos;s Creek, Beaverhead County, MT. Former Indian settlement.</notes>
    <Latitude>45.0333</Latitude>
    <Longitude>-112.7</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-16</id>
    <notes>Camped four miles below the forks of the Beaverhead River, Beaverhead County, MT.</notes>
    <Latitude>44.9833</Latitude>
    <Longitude>-112.85</Longitude>
    <placeName>Present-Day Clark Canyon Dam</placeName>
    <alt_notes></alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-17</id>
    <notes>Established camp at &quot;Camp Fortunate,&quot; Beaverhead River, Beaverhead County, MT.</notes>
    <Latitude>44.9987</Latitude>
    <Longitude>-112.8541</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-18</id>
    <notes>Camped along Horse Prairie Creek, near Red Butte, eight miles west of Grant, Beaverhead County, MT.</notes>
    <Latitude>44.7167</Latitude>
    <Longitude>-112.6667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lima</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-19</id>
    <notes>Camped 36 miles from Camp Fortunate. This camp was located on Pattee Creek, Lemhi County, ID</notes>
    <Latitude>45.05</Latitude>
    <Longitude>-113.45</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-20</id>
    <notes>Camped on the west side of the Lemhi River, close to Baker, Lemhi County, ID. Appears to be Withington Creek.</notes>
    <Latitude>45.0167</Latitude>
    <Longitude>-113.8333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Salmon</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-21</id>
    <notes>Camped &quot;where the mountains come close to the river.&quot; East side of the Salmon River, Lemhi County, ID. Few miles north of Carmen, below the mouth of Tower Creek.</notes>
    <Latitude>45.3367</Latitude>
    <Longitude>-113.7833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Carmen</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-22</id>
    <notes>Went 15 miles from previous location, camped down the Salmon River a few miles southwest of North Fork, Lemhi County, ID.</notes>
    <Latitude>45.4</Latitude>
    <Longitude>-113.9833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>North Fork</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-23</id>
    <notes>Clark camped in a different location from the rest of the group. Camped at Squaw Creek, Lemhi County, ID.</notes>
    <Latitude>44.3667</Latitude>
    <Longitude>-113.2833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate locations</alt_notes>
    <City>Leadore</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-23</id>
    <notes>The group was near the mouth of Dump Creek, Lemhi County, ID</notes>
    <Latitude>45.3333</Latitude>
    <Longitude>-114.03333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lemhi County</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-24</id>
    <notes>Clark camped in a different location again from the rest of the group. Camped near Shoup, Lemhi County, ID.</notes>
    <Latitude>44.3667</Latitude>
    <Longitude>-114.2667</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate locations</alt_notes>
    <City>Challis</City>
    <County>Custer County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-24</id>
    <notes>The group was at Shoshone Cove, Beaverhead County, MT.</notes>
    <Latitude>44.7667</Latitude>
    <Longitude>-113.1333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Leadore</City>
    <County></County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-25</id>
    <notes>Clark camped where they did back on August 21 near Carmen.</notes>
    <Latitude>45.3367</Latitude>
    <Longitude>-113.7833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate locations</alt_notes>
    <City>Carmen</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-25</id>
    <notes>The group camped on Trail Creek, Beaverhead County, MT, near where it meets Horse Prairie Creek.</notes>
    <Latitude>44.9833</Latitude>
    <Longitude>-113.2667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-08-26</id>
    <notes>Camped with Indians at the fish weir on the Lemhi River, five miles southeast of Salmon, Lemhi County, ID. Remained at this camp until 09-30.</notes>
    <Latitude>45.1667</Latitude>
    <Longitude>-113.8833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Salmon</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-30</id>
    <notes>Traveled 12 miles to camp near the fish weir, near present-day Baker, Lemhi County, Idaho.</notes>
    <Latitude>45.0833</Latitude>
    <Longitude>-113.7333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Salmon</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-08-31</id>
    <notes>Camped 4 miles upriver from previous location.</notes>
    <Latitude>45.1392</Latitude>
    <Longitude>-113.8065</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Salmon</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-01</id>
    <notes>Camped near Hull Creek on the other side of the North Fork. Gibbonsville, Lemhi County, ID.</notes>
    <Latitude>45.4833</Latitude>
    <Longitude>-114.05</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Gibbonsville</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-02</id>
    <notes>Camped near the mouth of Quartz Creek, Gibbonsville, Lemhi County, ID.</notes>
    <Latitude>45.5833</Latitude>
    <Longitude>-114</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Gibbonsville</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-03</id>
    <notes>Most controversial camp location. Supposedly hiked near Lost Trail Pass and camped in Ravalli County, MT.</notes>
    <Latitude>45.6833</Latitude>
    <Longitude>-113.9333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Sula</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-04</id>
    <notes>Camped between the forks of Camp Creek, Ravalli County, MT. Remained at this camp until 09-06.</notes>
    <Latitude>45.7883</Latitude>
    <Longitude>-113.9446</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Sula</City>
    <County>Ravalli County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-06</id>
    <notes>Camped along Cameron Creek, above Warm Springs Creek, Ravalli County, MT.</notes>
    <Latitude>45.9667</Latitude>
    <Longitude>-113.8333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Ravalli County</City>
    <County>Ravalli County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-07</id>
    <notes>Camped on the east side of the Bitterroot River, Grantsdale, Ravalli County, MT.</notes>
    <Latitude>46.2833</Latitude>
    <Longitude>-113.8333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Philipsburg</City>
    <County>Ravalli County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-08</id>
    <notes>Camped near present-day Stevensville, Ravalli County, MT.</notes>
    <Latitude>46.5</Latitude>
    <Longitude>-114.0833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Stevensville</City>
    <County>Ravalli County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-09</id>
    <notes>Camped a couple miles upstream from the Bitterroot River, on the south side of the creek. Present-day Lolo, Missoula County, MT. Remained here until 09-11.</notes>
    <Latitude>46.75</Latitude>
    <Longitude>-114.0667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lolo</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-11</id>
    <notes>Camp was half a mile east of Woodman Creek, Missoula County, MT.</notes>
    <Latitude>46.8167</Latitude>
    <Longitude>-114.2167</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lolo</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-12</id>
    <notes>Camped two miles east of Lolo Hot Springs, Missoula County, MT.</notes>
    <Latitude>46.7291</Latitude>
    <Longitude>-114.5319</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lolo</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-09-13</id>
    <notes>Camped at the lower end of Packer Meadows, Idaho County, ID.</notes>
    <Latitude>46.6376</Latitude>
    <Longitude>-114.553</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-14</id>
    <notes>Camped on the north bank of the Lochsa River, two miles below the mouth of White Sand Creek, near Powell Ranger Station. Idaho County, ID.</notes>
    <Latitude>46.4333</Latitude>
    <Longitude>-114.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-15</id>
    <notes>Camped where they reencountered the Lolo Trail, near present Forest Service Road 500, Idaho County, ID.</notes>
    <Latitude>46.5721</Latitude>
    <Longitude>-114.7323</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lolo</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-16</id>
    <notes>Camped at what was later called Indian Post Office. Perhaps camped on Moon Creek, Idaho County, ID.</notes>
    <Latitude>46.5963</Latitude>
    <Longitude>-114.7675</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lolo</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-17</id>
    <notes>Camped on the first saddle east of Indian Grave Peak, Idaho County, ID.</notes>
    <Latitude>46.5</Latitude>
    <Longitude>-115.1333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-18</id>
    <notes>Clark split from the group with a few hunters. Clark camped on Hungery Creek, just above the entrance of Doubt Creek, Idaho County, ID.</notes>
    <Latitude>46.4</Latitude>
    <Longitude>-115.5776</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-18</id>
    <notes>The group camped about three miles west of Bald Mountain, Idaho County, ID.</notes>
    <Latitude>45.4</Latitude>
    <Longitude>-116.4667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Riggins</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-19</id>
    <notes>Clark camped on Cedar Creek, near present Lewis and Clark Grove, ID.</notes>
    <Latitude>45.9</Latitude>
    <Longitude>-114.6333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-19</id>
    <notes>The group camped on Hungery Creek near a small, nameless stream, ID.</notes>
    <Latitude>46.4</Latitude>
    <Longitude>-115.5776</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-20</id>
    <notes>Clark spent the night at a seasonal Indian camp, about a mile southwest of Weippe, on a branch of Jim Ford Creek. Clearwater County, ID.</notes>
    <Latitude>46.3667</Latitude>
    <Longitude>-115.9333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Weippe</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-20</id>
    <notes>The group camped between Dollar and Sixbit Creeks, Idaho County, ID.</notes>
    <Latitude>46.3281</Latitude>
    <Longitude>-115.6193</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-21</id>
    <notes>Clark camped on the Clearwater River about a mile above present Orofino, Clearwater County, ID.</notes>
    <Latitude>46.4667</Latitude>
    <Longitude>-115.7833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Pierce</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-21</id>
    <notes>The group camped on Lolo Creek in Clearwater County, ID, along the boundary between Idaho and Clearwater counties.</notes>
    <Latitude>46.2599</Latitude>
    <Longitude>-115.8055</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Weippe</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-22</id>
    <notes>Clark reunited with the rest of the group. They camped at a Nez Perce village on Jim Ford Creek, Weippe Prairie, 3 miles southeast of Weippe, Clearwater County, ID.</notes>
    <Latitude>46.3167</Latitude>
    <Longitude>-115.8833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Weippe</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-23</id>
    <notes>Camped about a mile southwest of Weippe, Clearwater County, ID.</notes>
    <Latitude>46.3667</Latitude>
    <Longitude>-115.9333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Weippe</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-24</id>
    <notes>Camped just below Twisted Hair&apos;s camp, what was China Island of the Clearwater River, Orofino, Clearwater County, ID. Remained at this camp until 09-26</notes>
    <Latitude>46.4667</Latitude>
    <Longitude>-115.7833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pierce</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-09-26</id>
    <notes>&quot;Canoe Camp.&quot; Located about 5 miles west of Orofino, Clearwater County, ID, on the south bank of the Clearwater and opposite the mouth of the North Fork Clearwater. Remained at this camp until 10-07.</notes>
    <Latitude>46.5015</Latitude>
    <Longitude>-116.332</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Orofino</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-10-07</id>
    <notes>Camped near present-day Lenore, Nez Perce County, ID. Opposite Jacks Creek.</notes>
    <Latitude>46.5</Latitude>
    <Longitude>-116.55</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lenore</City>
    <County>Nez Perce County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-10-08</id>
    <notes>Camped on the north side in Nez Perce County, below the confluence of the Potlatch and Clearwater Rivers, a few miles from present Spalding. Near Arrowbeach. Remained here until 10-10.</notes>
    <Latitude>46.452</Latitude>
    <Longitude>-116.818</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Juliaetta</City>
    <County>Nez Perce County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-10-10</id>
    <notes>Camped in Whitman County, WA, opposite Clarkston.</notes>
    <Latitude>46.4</Latitude>
    <Longitude>-117.0333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lewiston</City>
    <County>Nez Perce County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1805-10-11</id>
    <notes>Camped below Almota Creek, near present Almota, Whitman County, WA. In between Lower Granite Dam, Lower Granite Lake and Lake Bryan. </notes>
    <Latitude>46.7</Latitude>
    <Longitude>-114.4667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lolo</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1805-10-12</id>
    <notes>Camped near present Riparia, Whitman County, WA, below the mouth of Alkali Flat Creek.</notes>
    <Latitude>46.5667</Latitude>
    <Longitude>-118.0833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dayton</City>
    <County>Columbia County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-13</id>
    <notes>Camped in Franklin County, WA, opposite Ayer, Walla Walla County, WA, on the opposite side of the Snake.</notes>
    <Latitude>46.5969</Latitude>
    <Longitude>-118.3688</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Prescott</City>
    <County>Walla Walla County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-14</id>
    <notes>Camped on an island, now sunk under Lake Sacajawea. Downstream from Burr Canyon, Franklin County, WA.</notes>
    <Latitude>46.3618</Latitude>
    <Longitude>-118.7275</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Pasco</City>
    <County>Franklin County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-15</id>
    <notes>Camped just above Fishhook Rapids, Franklin County, WA.</notes>
    <Latitude>46.3149</Latitude>
    <Longitude>-118.8361</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Pasco</City>
    <County>Franklin County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-16</id>
    <notes>Camped at the point between the Snake and the Columbia, Franklin County, WA. Just southeast of present Pasco and Sacajawea State Park. Remained here until 10-18.</notes>
    <Latitude>46.2333</Latitude>
    <Longitude>-119.0833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pasco</City>
    <County>Franklin County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-18</id>
    <notes>Camped in Walla Walla County, WA, south of the mouth of the Walla Walla River and above the Washington/Oregon line.</notes>
    <Latitude>46.0025</Latitude>
    <Longitude>-118.3787</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Walla Walla</City>
    <County>Walla Walla County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-19</id>
    <notes>Camped somewhere between Irrigon and Boardman, Morrow County, OR. Could potentially be Blalock Island.</notes>
    <Latitude>45.9</Latitude>
    <Longitude>-119.6167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Boardman</City>
    <County>Morrow County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-10-20</id>
    <notes>Camped near present Roosevelt, Klickitat County, WA.</notes>
    <Latitude>45.7333</Latitude>
    <Longitude>-120.2</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Arlington</City>
    <County>Gilliam County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-10-21</id>
    <notes>Camped near the present John Day Dam, Klickitat County, WA.</notes>
    <Latitude>45.7</Latitude>
    <Longitude>-120.6833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wasco</City>
    <County>Sherman County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-10-22</id>
    <notes>Camped near present Wishram, Klickitat County, WA. Remained here until 10-24.</notes>
    <Latitude>45.65</Latitude>
    <Longitude>-120.95</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>The Dalles</City>
    <County>Wasco County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-10-24</id>
    <notes>Camped near Horsethief Lake State Park, Klickitat County, WA.</notes>
    <Latitude>45.6654</Latitude>
    <Longitude>-121.1054</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Klickitat County</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-25</id>
    <notes>Camped at what they called &quot;Fort Rock Camp,&quot; at the mouth of Mill Creek, present-day The Dalles. Wasco, OR. Remained here until 10-28.</notes>
    <Latitude>45.5833</Latitude>
    <Longitude>-121.1667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>The Dalles</City>
    <County>Wasco County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-10-28</id>
    <notes>Camped near Crates Point, Wasco County, OR.</notes>
    <Latitude>45.65</Latitude>
    <Longitude>-121.2167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>The Dalles</City>
    <County>Wasco County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-10-29</id>
    <notes>Camped in Skamania County, WA, a little above the mouth of Little White Salmon River.</notes>
    <Latitude>45.8203</Latitude>
    <Longitude>-121.7011</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cook</City>
    <County>Skamania County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-10-30</id>
    <notes>Camped just above the Cascades of the Columbia (Ordway&apos;s &quot;Shoote&quot;), on an island in Skamania County, nearly opposite Cascade Locks, Hoodriver County, OR. Remained here until 11-01.</notes>
    <Latitude>45.6693</Latitude>
    <Longitude>-121.8912</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Cascade Locks</City>
    <County>Hood River County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-01</id>
    <notes>Camped above Bonneville Dam and near Fort Rains and North Bonneville, Skamania County, WA.</notes>
    <Latitude>45.6333</Latitude>
    <Longitude>-121.9333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cascade Locks</City>
    <County>Multnomah County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-02</id>
    <notes>Camped at Crown Point, Multnomah County, OR.</notes>
    <Latitude>45.5333</Latitude>
    <Longitude>-122.2333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Corbett</City>
    <County>Multnomah County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-03</id>
    <notes>Camped on Diamond Island, about 3 miles west of present Camas, Clark County, WA.</notes>
    <Latitude>45.5833</Latitude>
    <Longitude>-122.3833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Camas</City>
    <County>Clark County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-04</id>
    <notes>Camped near the entrance of present Salmon Creek, Clark County, WA.</notes>
    <Latitude>45.7333</Latitude>
    <Longitude>-122.3667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Brush Prairie</City>
    <County>Clark County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-05</id>
    <notes>Camped southwest of present Rainier, near Prescott, Columbia County, OR.</notes>
    <Latitude>46.0333</Latitude>
    <Longitude>-122.8833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rainier</City>
    <County>Columbia County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-06</id>
    <notes>Camped on perhaps Wallace Island, Wahkiakum County, WA. Later called Cape Horn.</notes>
    <Latitude>46.1333</Latitude>
    <Longitude>-123.25</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Clatskanie</City>
    <County>Columbia County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-07</id>
    <notes>Camped between Brookfield and Dahlia, west of Jim Crow Point, opposite Pillar Rock, Wahkiakum County, WA.</notes>
    <Latitude>46.2656</Latitude>
    <Longitude>-123.5491</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Rosburg</City>
    <County>Wahkiakum County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-08</id>
    <notes>Camped on the west side of Grays Bay (&quot;Shallow Bay&quot;), near the Wahkiakum Pacific County line, WA. Remained here until 11-10.</notes>
    <Latitude>46.2667</Latitude>
    <Longitude>-123.75</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Naselle</City>
    <County>Pacific County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-10</id>
    <notes>Camped on the eastern side of Point Ellice, Pacific County, WA. East of the Astoria Bridge and near Meglar. Remained here until 11-15 but for a slight move on 11-12.</notes>
    <Latitude>46.2333</Latitude>
    <Longitude>-123.8667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chinook</City>
    <County>Pacific County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-15</id>
    <notes>Camped southeast of Chinook Point, on the east side of Baker Bay, Pacific County, WA. West of present McGowan, adjacent to Fort Columbia State Park. Possibly remained at this camp until 11-25.</notes>
    <Latitude>46.25</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chinook</City>
    <County>Pacific County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-25</id>
    <notes>Camped near present Pillar Rock, Wahkiakum County, WA.</notes>
    <Latitude>46.25</Latitude>
    <Longitude>-123.5833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Rosburg</City>
    <County>Wahkiakum County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1805-11-26</id>
    <notes>Camped in Clatsop County, OR, near Svenson.</notes>
    <Latitude>46.1667</Latitude>
    <Longitude>-123.65</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Astoria</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-27</id>
    <notes>Camped on the west side of Tongue Point, Clatsop County, OR. Just east of present Astoria. Most of the group remained here when Lewis went searching for winter camp.</notes>
    <Latitude>46.2</Latitude>
    <Longitude>-123.75</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Astoria</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-29</id>
    <notes>Lewis camped on the shore of Youngs Bay, Clatsop County, OR. The rest of the group remained with Clark at the 11-27 camp.</notes>
    <Latitude>46.1667</Latitude>
    <Longitude>-123.85</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Astoria</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-11-30</id>
    <notes>Lewis camped on the left side of what appears to be the Little South Fork Lewis and Clark River, Clatsop County, OR. Clark and the others are still at the 11-27 camp. Remained at their respective camps until 12-07.</notes>
    <Latitude>45.95</Latitude>
    <Longitude>-123.8333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Seaside</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-12-07</id>
    <notes>Camped near the later site of Fort Clatsop, Clatsop County, OR.</notes>
    <Latitude>46.1333</Latitude>
    <Longitude>-123.8667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Astoria</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-12-08</id>
    <notes>Clark took a few men to go hunting elk. Camped near present Seaside, Clatsop County, OR. Returned to the Fort Clatsop camp on 12-09.</notes>
    <Latitude>45.9833</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Seaside</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1805-12-10</id>
    <notes>Lewis met up with Clark and they returned to the Fort Clatsop camp. Remained at this camp until 1806-01-06.</notes>
    <Latitude>45.9833</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Seaside</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-01-06</id>
    <notes>Clark camped at the forks of the Neacoxie Creek, Clatsop County, OR. The rest of the group remained at the Fort Clatsop camp. There is a typo in the footnotes on the website: note 6 spells it as &quot;Neacoxic Creek&quot; where it should really be &quot;Neacoxie Creek.&quot;</notes>
    <Latitude>46.0667</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Warrenton</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-01-07</id>
    <notes>Camped on Canyon Creek of Tillamook Head, Clatsop County, OR.</notes>
    <Latitude>45.95</Latitude>
    <Longitude>-123.95</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Seaside</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-01-08</id>
    <notes>Clark camped on the north side of Ecola Creek, north part of Cannon Beach, Clatsop County, OR.</notes>
    <Latitude>45.8833</Latitude>
    <Longitude>-123.9333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cannon Beach</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-01-09</id>
    <notes>Clark and his party return to the Fort Clatsop camp, Clatsop County, OR. Remained here until 03-23-1806.</notes>
    <Latitude>45.9833</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Seaside</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-23</id>
    <notes>Camped just below the mouth of John Day River, the captains&apos; Kekemarque Creek, Clatsop County, OR.</notes>
    <Latitude>46.1811</Latitude>
    <Longitude>-123.7395</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Astoria</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-24</id>
    <notes>Camped northeast of Brownsmead, on Aldrich Point, Clatsop County, OR.</notes>
    <Latitude>46.2333</Latitude>
    <Longitude>-123.4833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Astoria</City>
    <County>Clatsop County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-25</id>
    <notes>Campled below the mouth of the Clatskanie River, opposite Cape Horn, Columbia County, OR.</notes>
    <Latitude>46</Latitude>
    <Longitude>-123.0167</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Rainier</City>
    <County>Columbia County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-26</id>
    <notes>Camped on a small island below present Longview, Cowlitz County, WA. Camp was in Columbia County, OR. Possibly Walker or Dibblee island.</notes>
    <Latitude>46.1333</Latitude>
    <Longitude>-123.0333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Rainier</City>
    <County>Columbia County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-27</id>
    <notes>Camped in Columbia County, OR, near Goble, roughly opposite to present Kalama, Cowlitz County, WA. Now called Deer Island.</notes>
    <Latitude>46</Latitude>
    <Longitude>-122.8667</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Rainier</City>
    <County>Columbia County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-28</id>
    <notes>Camped near the upper end of Deer Island, Columbia County, OR.</notes>
    <Latitude>45.9167</Latitude>
    <Longitude>-122.8333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Deer Island</City>
    <County>Columbia County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-03-29</id>
    <notes>Camped behind Bachelor Island, Clark County, near present Ridgefield, WA.</notes>
    <Latitude>45.8</Latitude>
    <Longitude>-122.7333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Ridgefield</City>
    <County>Clark County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-03-30</id>
    <notes>Camped in present Vancouver, Clark County, WA. There is a typo in the footnotes on the website: note 5 spells it as &quot;Vanouver&quot; where it should really be &quot;Vancouver.&quot;</notes>
    <Latitude>45.6333</Latitude>
    <Longitude>-122.65</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Vancouver</City>
    <County>Clark County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-03-31</id>
    <notes>Camped in Clark County, WA, above the entrance of the Washougal River near present Washougal.</notes>
    <Latitude>45.5667</Latitude>
    <Longitude>-122.35</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Washougal</City>
    <County>Clark County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-02</id>
    <notes>Clark took a few men and camped near an old Indian lodge, located in the northwest part of Portland, Multnomah County, OR. The rest of the party remained at the 03-31 camp.</notes>
    <Latitude>45.5167</Latitude>
    <Longitude>-122.6667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Portland</City>
    <County>Multnomah County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-03</id>
    <notes>Clark and his party returned to the 03-31 camp to rejoin with Lewis and the rest of the party.</notes>
    <Latitude>45.5667</Latitude>
    <Longitude>-122.35</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Washougal</City>
    <County>Clark County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-04</id>
    <notes>Camped in Multnomah County, below Sandy River, OR. Remained at this camp until 04-06.</notes>
    <Latitude>45.4952</Latitude>
    <Longitude>-122.3351</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Troutdale</City>
    <County>Multnomah County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-06</id>
    <notes>Camped above Latourell Falls and Rooster Rock State Park, Multnomah County, OR. Remained at this camp until 04-09.</notes>
    <Latitude>45.5515</Latitude>
    <Longitude>-122.2148</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Corbett</City>
    <County>Multnomah County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-09</id>
    <notes>Camped at present Bonneville, Multnomah County, OR.</notes>
    <Latitude>45.6333</Latitude>
    <Longitude>-121.95</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cascade Locks</City>
    <County>Multnomah County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-10</id>
    <notes>Camped east of North Bonneville, Skamania County, WA. Remained at this camp until 04-12.</notes>
    <Latitude>45.6333</Latitude>
    <Longitude>-121.9667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>North Bonneville</City>
    <County>Skamania County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-12</id>
    <notes>Returned to the camp they inhabited on 10-30-1805, an island in Skamania County, WA.</notes>
    <Latitude>45.6693</Latitude>
    <Longitude>-121.8912</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cascade Locks</City>
    <County>Hood River County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-13</id>
    <notes>Camped in Skamania County, WA, south of Dog Mountain, between Collins Creek and Dog Creek.</notes>
    <Latitude>45.7167</Latitude>
    <Longitude>-121.7</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Stevenson</City>
    <County>Skamania County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-14</id>
    <notes>Camped on Major Creek, Klickitat County, WA, above and opposite Mosier, Wasco County, OR.</notes>
    <Latitude>45.8167</Latitude>
    <Longitude>-121.3833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>White Salmon</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-15</id>
    <notes>Returned to the camp they inhabited on 10-25-1805, &quot;Fort Rock.&quot; Located at The Dalles, Wasco County, OR.</notes>
    <Latitude>45.5833</Latitude>
    <Longitude>-121.1667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>The Dalles</City>
    <County>Wasco County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-16</id>
    <notes>Lewis and some of the party remained at the Fort Rock Camp, while Clark took some men and camped in Klickitat County, WA, probably a little above Dallesport and opposite The Dalles. Remained at their respective camps until 04-18.</notes>
    <Latitude>45.6167</Latitude>
    <Longitude>-121.1667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dallesport</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-18</id>
    <notes>Clark rejoined Lewis back at the Fort Rock Camp.</notes>
    <Latitude>45.5833</Latitude>
    <Longitude>-121.1667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>The Dalles</City>
    <County>Wasco County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-19</id>
    <notes>Camped above the Long Narrows of The Dalles, Klickitat County, Washington, near Horsethief Lake State Park and the 10-24-1805 camp. Remained at this camp until 04-21.</notes>
    <Latitude>45.6561</Latitude>
    <Longitude>-121.0823</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lyle</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-21</id>
    <notes>Camped in Klickitat County, WA, roughly opposite the lower end of Miller Island, below the mouth of the present Deschutes River.</notes>
    <Latitude>45.65</Latitude>
    <Longitude>-120.9</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wasco</City>
    <County>Sherman County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-22</id>
    <notes>Camped in a Tenino Indian village, Klickitat County, WA, near John Day Dam.</notes>
    <Latitude>45.7</Latitude>
    <Longitude>-120.6833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Wasco</City>
    <County>Sherman County</County>
    <stateCode>OR</stateCode>
  </row>
  <row>
    <id>1806-04-23</id>
    <notes>Camped at Rock Creek, Klickitat County, WA, at a Tenino Indian village.</notes>
    <Latitude>45.9667</Latitude>
    <Longitude>-121.5667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Trout Lake</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-24</id>
    <notes>Camped in Klickitat County, WA, opposite the town of Blalock, Gilliam County, OR, in Umatilla Indian territory.</notes>
    <Latitude>45.7099</Latitude>
    <Longitude>-120.383</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Goldendale</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-25</id>
    <notes>Difficult to identify camp for today. Best interpretation is the group camped near present Alderdale, Klickitat County, WA.</notes>
    <Latitude>45.8333</Latitude>
    <Longitude>-119.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Prosser</City>
    <County>Klickitat County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-26</id>
    <notes>Camped in Benton County, WA, near present Plymouth and opposite the mouth of the Umatilla River.</notes>
    <Latitude>45.9333</Latitude>
    <Longitude>-119.3333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Plymouth</City>
    <County></County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-27</id>
    <notes>Camped at a Walula village in Benton County, WA, below and opposite the mouth of the Walla Walla River, south of Yellepit. Remained at this camp until 04-29.</notes>
    <Latitude>46.0336</Latitude>
    <Longitude>-118.6835</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Touchet</City>
    <County>Walla Walla County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-29</id>
    <notes>Camped on the north bank of the Walla Walla River, Walla Walla County, WA.</notes>
    <Latitude>46.0605</Latitude>
    <Longitude>-118.9065</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Touchet</City>
    <County>Walla Walla County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-04-30</id>
    <notes>Camped on Touchet River, Walla Walla County, WA, south of present Eureka.</notes>
    <Latitude>46.3</Latitude>
    <Longitude>-118.6</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Prescott</City>
    <County>Walla Walla County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-05-01</id>
    <notes>Camped near Waitsburg, eastern Walla Walla County, WA.</notes>
    <Latitude>46.2667</Latitude>
    <Longitude>-118.15</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Waitsburg</City>
    <County>Walla Walla County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-05-02</id>
    <notes>Camped in Columbia County, WA, south of Marengo.</notes>
    <Latitude>46.4333</Latitude>
    <Longitude>-117.7333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pomeroy</City>
    <County>Columbia County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-05-03</id>
    <notes>Camped in Garfield County, WA, on Pataha Creek, east of Pataha City, near U.S. Highway 12.</notes>
    <Latitude>46.4667</Latitude>
    <Longitude>-117.5333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pomeroy</City>
    <County>Garfield County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-05-04</id>
    <notes>Camped in Whitman County, WA, on the Snake below Clarkston.</notes>
    <Latitude>46.4028</Latitude>
    <Longitude>-117.0425</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Clarkston</City>
    <County>Asotin County</County>
    <stateCode>WA</stateCode>
  </row>
  <row>
    <id>1806-05-05</id>
    <notes>Camped near Arrow, Nez Perce County, ID, below the confluence of the Potlatch River (Colters Creek) with the Clearwater River.</notes>
    <Latitude>46.4779</Latitude>
    <Longitude>-116.7766</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Juliaetta</City>
    <County>Nez Perce County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-06</id>
    <notes>Camped on the Clearwater River, Nez Perce County, ID, near the mouth of Pine Creek.</notes>
    <Latitude>46.6</Latitude>
    <Longitude>-116.5167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kendrick</City>
    <County>Nez Perce County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-07</id>
    <notes>Camped south of Peck on the east side of Big Canyon Creek in Nez Perce County, ID.</notes>
    <Latitude>46.4667</Latitude>
    <Longitude>-116.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Craigmont</City>
    <County>Lewis County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-08</id>
    <notes>Camped in Clearwater County, ID, a few miles out from Orofino.</notes>
    <Latitude>46.4667</Latitude>
    <Longitude>-115.7833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pierce</City>
    <County>Clearwater County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-09</id>
    <notes>Camped in Clearwater County, ID, naming location at Wheeler Draw. Actual location is quite disputed.</notes>
    <Latitude>46.5333</Latitude>
    <Longitude>-116.4833</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lenore</City>
    <County>Nez Perce County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-10</id>
    <notes>Camped on Lawyer Creek, Lewis County, ID. Southwest of Kamiah and near Broken Arm&apos;s village. Remained at this camp until 05-13.</notes>
    <Latitude>46.2167</Latitude>
    <Longitude>-116.0167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kamiah</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-13</id>
    <notes>Camped near the Kamiah railroad depot, Lewis County, ID.</notes>
    <Latitude>46.2299</Latitude>
    <Longitude>-116.0186</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Kamiah</City>
    <County>Lewis County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-14</id>
    <notes>Camped in Idaho County, ID, near the eastern boundary of the present Nez Perce Reservation, east bank of the Clearwater River, two miles below Lawyer Creek. Remained at this camp until 06-10.</notes>
    <Latitude>46.1426</Latitude>
    <Longitude>-115.8962</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-27</id>
    <notes>A few men left camp to go hunting and exploring. Camped at a Nez Perce village on  Lawyer Creek, near Orofino ID.</notes>
    <Latitude>46.05</Latitude>
    <Longitude>-116.5333</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Craigmont</City>
    <County>Lewis County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-28</id>
    <notes>Same party continued exploring on Lawyer Creek. Camped near the Lewis-Nez Perce county line, ID, above Deer Creek&apos;s entrance into the Salmon River. </notes>
    <Latitude>45.9995</Latitude>
    <Longitude>-116.6952</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Winchester</City>
    <County>Lewis County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-05-31</id>
    <notes>Party camped at the prominent Salmon River oxbow on Maloney Creek, ID. Returned to the 05-14 camp (Camp Chopunnish) on 06-02.</notes>
    <Latitude>46.038</Latitude>
    <Longitude>-116.6257</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Lewis County</City>
    <County>Lewis County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-10</id>
    <notes>Camped where they met the Nez Perces on 09-20-1805. Remained at this camp until 06-15.</notes>
    <Latitude>46.3281</Latitude>
    <Longitude>-115.6193</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-15</id>
    <notes>Camped on Eldorado Creek, Idaho County, ID, near the mouth of Lunch Creek.</notes>
    <Latitude>46.3667</Latitude>
    <Longitude>-115.6</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-16</id>
    <notes>Camped on a branch of Fish Creek, Idaho County, ID.</notes>
    <Latitude>45.8667</Latitude>
    <Longitude>-116.0833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Grangeville</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-17</id>
    <notes>Camped on the south side of Hungery Creek, Idaho County, ID.</notes>
    <Latitude>46.4</Latitude>
    <Longitude>-115.5667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-18</id>
    <notes>Camped on Eldorado Creek, Idaho County, ID, near the mouth of Dollar Creek. Remained at this camp until 06-21.</notes>
    <Latitude>46.3333</Latitude>
    <Longitude>-115.6</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-21</id>
    <notes>Camped where Lewis&apos; party had camped on 1805-09-21. Lolo Creek, Clearwater County, ID. Remained at this camp until 06-25.</notes>
    <Latitude>46.2599</Latitude>
    <Longitude>-115.8055</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Weippe</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-25</id>
    <notes>Camped at the main party camp of 1805-09-19. Unnamed creek running into Hungery Creek, Idaho County, ID.</notes>
    <Latitude>46.4</Latitude>
    <Longitude>-115.5776</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-26</id>
    <notes>Camped on Bald Mountain, Idaho County, ID.</notes>
    <Latitude>45.4</Latitude>
    <Longitude>-116.4667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Riggins</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-27</id>
    <notes>Camped in Idaho County, ID, on the first high point west of Indian Grave Peak. Near the camp of 1805-09-17.</notes>
    <Latitude>46.5</Latitude>
    <Longitude>-115.1333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Kooskia</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-28</id>
    <notes>Camped near Powell Junction on the present Forest Road 500, Idaho County, ID. Also near Papoose Saddle and north of Powell Ranger Station.</notes>
    <Latitude>46.5667</Latitude>
    <Longitude>-114.7167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lolo</City>
    <County>Idaho County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-06-29</id>
    <notes>Camped in Missoula County, MT, at the Lolo Hot Springs.</notes>
    <Latitude>46.7294</Latitude>
    <Longitude>-114.5486</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lolo</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-06-30</id>
    <notes>Camped at the Travelers&apos; Rest Camp, south side of Loko Creek, about two miles upriver from Bitterroot River, Missoula County, MT. Remained at this camp until 07-03.</notes>
    <Latitude>46.75</Latitude>
    <Longitude>-114.0667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lolo</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-03</id>
    <notes>Camped on Grant Creek near its junction with Clark Fork, northwest of Missoula, Missoula County, MT. Remained here until 07-05.</notes>
    <Latitude>47.0719</Latitude>
    <Longitude>-113.971</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Arlee</City>
    <County>Missoula County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-04</id>
    <notes>Clark went off and camped on the north side of the West Fork Bitterroot River, near its junction with the Bitterroot, Ravalli County, MT.</notes>
    <Latitude>45.45</Latitude>
    <Longitude>-114.3333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Lemhi County</City>
    <County>Lemhi County</County>
    <stateCode>ID</stateCode>
  </row>
  <row>
    <id>1806-07-05</id>
    <notes>Clark met up with the rest of the group and they all camped on Camp Creek near Camp Creek Ranger Station and U.S. Highway 93, Ravalli County, MT.</notes>
    <Latitude>47.1955</Latitude>
    <Longitude>-114.8959</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Superior</City>
    <County>Mineral County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-06</id>
    <notes>Camped on Moose Creek, in the western part of the big Hole Valley, Beaverhead County, MT.</notes>
    <Latitude>45.5655</Latitude>
    <Longitude>-113.6111</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Wisdom</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-07</id>
    <notes>Clark and a small party crossed Warm Spring Creek and camped near the head of Divide Creek, Beaverhead County, MT.</notes>
    <Latitude>45.3167</Latitude>
    <Longitude>-113.1833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Polaris</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-08</id>
    <notes>Clark camped at Camp Fortunate, where the party had camped on 1805-08-17. He remained here until 07-10.</notes>
    <Latitude>44.9987</Latitude>
    <Longitude>-112.8541</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Dillon</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-08</id>
    <notes>The rest of the party camped on an island in Sun River, and affluent of Grasshopper Creek, Beaverhead County, MT.</notes>
    <Latitude>47.65</Latitude>
    <Longitude>-113.1</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Augusta</City>
    <County>Lewis and Clark County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-09</id>
    <notes>Clark camped where the party had camped on Moose Creek on 1806-07-06.</notes>
    <Latitude>45.5655</Latitude>
    <Longitude>-113.6111</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wisdom</City>
    <County>Beaverhead County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-09</id>
    <notes>The rest of the party camped on the south side of Sun River, near the mouth of Simms Creek, Cascade County, MT.</notes>
    <Latitude>47.5052</Latitude>
    <Longitude>-112.0167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fairfield</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-10</id>
    <notes>Clark camped on the east bank of the Jefferson River, opposite Three Thousand Mile Island, Beaverhead County, MT.</notes>
    <Latitude>45.5695</Latitude>
    <Longitude>-112.338</Longitude>
    <placeName></placeName>
    <alt_notes>Clark: Approximate location</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-10</id>
    <notes>The rest of the party camped on the south side of Sun River, northwest of Great Falls, Cascade County, MT.</notes>
    <Latitude>47.5</Latitude>
    <Longitude>-111.3</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-11</id>
    <notes>Clark camped on the east side of Jefferson River, opposite the mouth of the Big Hole River, Beaverhead County, MT.</notes>
    <Latitude>45.5613</Latitude>
    <Longitude>-112.3374</Longitude>
    <placeName></placeName>
    <alt_notes>Both: Approximate locations</alt_notes>
    <City>Twin Bridges</City>
    <County>Madison County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-11</id>
    <notes>The rest of the party camped on the west bank of the Missouri, Cascade County, opposite the White Bear Islands and below the mouth of Sand Coulee Creek.</notes>
    <Latitude>47.4591</Latitude>
    <Longitude>-111.3151</Longitude>
    <placeName></placeName>
    <alt_notes>Both: Approximate locations</alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-12</id>
    <notes>Clark camped at or below the camp of 1805-07-31, below the mouth of Antelope Creek.</notes>
    <Latitude>45.7949</Latitude>
    <Longitude>-111.8006</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cardwell</City>
    <County>Gallatin County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-12</id>
    <notes>The rest of the party camped on the east bank of the Missouri, Cascade County, MT, below the White Bear Islands camp and south of Great Falls.</notes>
    <Latitude>47.5</Latitude>
    <Longitude>-111.3</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-13</id>
    <notes>Clark camped on the north side of the Gallatin River, Gallatin County, MT, about a mile east of present Logan.</notes>
    <Latitude>45.8833</Latitude>
    <Longitude>-111.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Manhattan</City>
    <County>Gallatin County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-13</id>
    <notes>The rest of the party returned to the camp of 1806-07-12. Party remained here until 07-27.</notes>
    <Latitude>47.4591</Latitude>
    <Longitude>-111.3151</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-14</id>
    <notes>Clark camped on Kelly Creek, a few miles east of Bozeman north of Interstate Highway 90 near the site of Fort Ellis, MT.</notes>
    <Latitude>45.6833</Latitude>
    <Longitude>-110.8667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bozeman</City>
    <County>Gallatin County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-15</id>
    <notes>Clark camped on the north side of the Yellowstone River, Park County, MT, just south of Sheep Mountain and a few miles below the mouth of Shields River.</notes>
    <Latitude>46.6667</Latitude>
    <Longitude>-110.4</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Meagher County</City>
    <County>Meagher County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-16</id>
    <notes>Lewis also broke away from the rest of the party and camped on the north side of the Missouri River at the Great Falls, Cascade County, MT. What remained of the party stayed at the 07-13 camp to await Lewis or meet Clark in the future.</notes>
    <Latitude>47.5</Latitude>
    <Longitude>-111.3</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Great Falls</City>
    <County>Cascade County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-16</id>
    <notes>Clark camped in Sweet Grass County, MT, on the north side of the Yellowstone just below the mouth of Little Timber Creek.</notes>
    <Latitude>45.8473</Latitude>
    <Longitude>-109.9408</Longitude>
    <placeName></placeName>
    <alt_notes>Clark: Approximate location</alt_notes>
    <City>Big Timber</City>
    <County>Sweet Grass County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-17</id>
    <notes>Lewis camped on the Teton River, Chouteau County, MT, northwest of present Carter.</notes>
    <Latitude>47.9319</Latitude>
    <Longitude>-110.5175</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Loma</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-17</id>
    <notes>Clark camped on the north side of the Yellowstone a couple miles below the mouth of Hump Creek, Sweet Grass County, MT.</notes>
    <Latitude>45.7116</Latitude>
    <Longitude>-109.6019</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Reed Point</City>
    <County>Sweet Grass County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-18</id>
    <notes>Lewis camped on Marias River, Liberty County, MT, a few miles above the mouth of Dugout Coulee.</notes>
    <Latitude>48.2697</Latitude>
    <Longitude>-110.9084</Longitude>
    <placeName></placeName>
    <alt_notes>Lewis: Approximate location</alt_notes>
    <City>Chester</City>
    <County>Liberty County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-18</id>
    <notes>Clark camped in Stillwater County, MT, a few miles west of Columbus and the mouth of the Stillwater River.</notes>
    <Latitude>45.6333</Latitude>
    <Longitude>-109.25</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Columbus</City>
    <County>Stillwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-19</id>
    <notes>Lewis camped on the Marias, in Toole County, MT, about a mile west of the Liberty County line.</notes>
    <Latitude>48.34</Latitude>
    <Longitude>-111.2766</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Ledger</City>
    <County>Toole County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-19</id>
    <notes>Clark camped on the north side of the Yellowstone River in Stillwater County, south of present Park City, and remained here until 07-24. &quot;Canoe Camp.&quot;</notes>
    <Latitude>45.6167</Latitude>
    <Longitude>-108.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Park City</City>
    <County>Stillwater County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-20</id>
    <notes>Lewis camped on the north side of the Marias River, southern Toole County, MT, five miles southwest of the present town Shelby.</notes>
    <Latitude>48.5</Latitude>
    <Longitude>-111.85</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Shelby</City>
    <County>Toole County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-21</id>
    <notes>Lewis camped on the west side of Cut Bank Creek, Glacier County, MT, about a mile southwest of present Cut Bank.</notes>
    <Latitude>48.5667</Latitude>
    <Longitude>-113.1167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Glacier County</City>
    <County>Glacier County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-22</id>
    <notes>Lewis camped at what he named &quot;Camp Disappointment,&quot; on the Blackfeet Indian Reservation, MT, south side of Cut Bank Creek, just above the mouth of Cut Bank John Coulee. Remained here until 07-26.</notes>
    <Latitude>48.6667</Latitude>
    <Longitude>-112.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cut Bank</City>
    <County>Glacier County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-24</id>
    <notes>Clark camped just below the mouth of Dry Creek on the opposite side of the river in Yellowstone County, MT.</notes>
    <Latitude>45.6505</Latitude>
    <Longitude>-108.7186</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Laurel</City>
    <County>Yellowstone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-25</id>
    <notes>Clark camped on the south side of the Yellowstone in Yellowstone County, MT, just below the mouth of Fly Creek and two miles northeast of present Pompeys Pillar.</notes>
    <Latitude>45.9948</Latitude>
    <Longitude>-107.9464</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Pompeys Pillar</City>
    <County>Yellowstone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-26</id>
    <notes>Lewis camped in Pondera County, MT, on the Blackfeet Reservation, along the south side of Two Medicine River and four miles below the mouth of Badger Creek and downstream from Kipps Coulee.</notes>
    <Latitude>48.4658</Latitude>
    <Longitude>-112.2291</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Shelby</City>
    <County>Pondera County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-26</id>
    <notes>Clark camped above the junction of the Bighorn River with the Yellowstone and on the stream&apos;s east in Treasure County, MT.</notes>
    <Latitude>46.1546</Latitude>
    <Longitude>-107.4731</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bighorn</City>
    <County></County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-27</id>
    <notes>Lewis camped somewhat near Fort Benton, Chouteau County, MT.</notes>
    <Latitude>47.8273</Latitude>
    <Longitude>-110.6751</Longitude>
    <placeName></placeName>
    <alt_notes>Lewis: Approximate location</alt_notes>
    <City>Fort Benton</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-27</id>
    <notes>Clark camped in Rosebud County, MT, two miles above the mouth of Big Porcupine Creek and eight miles west of present Forsyth.</notes>
    <Latitude>46.2874</Latitude>
    <Longitude>-106.8039</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Forsyth</City>
    <County>Rosebud County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-28</id>
    <notes>Lewis camped on the south bank of the Missouri, Chouteau County, MT, a little below the mouth of Crow Coulee.</notes>
    <Latitude>47.8</Latitude>
    <Longitude>-110.2</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Geraldine</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-28</id>
    <notes>Clark camped opposite the creek mouth in Rosebud County, MT, of Graveyard Creek.</notes>
    <Latitude>46.2854</Latitude>
    <Longitude>-106.1801</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Hathaway</City>
    <County>Rosebud County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-29</id>
    <notes>Lewis camped where the party had camped 1805-05-29.</notes>
    <Latitude>47.7157</Latitude>
    <Longitude>-109.8366</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Big Sandy</City>
    <County>Chouteau County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-29</id>
    <notes>Clark camped on the north side of the Yellowstone, Custer County, a little below Tongue River, and North of Miles City.</notes>
    <Latitude>46.4559</Latitude>
    <Longitude>-105.8253</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Miles City</City>
    <County>Custer County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-30</id>
    <notes>Lewis camped on Goodrich&apos;s Island, MT, extremely close to the campsite of 1805-05-25. At this camp the rest of the party joined him, minus Clark.</notes>
    <Latitude>47.7345</Latitude>
    <Longitude>-108.9079</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Blaine County</City>
    <County>Blaine County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-30</id>
    <notes>Clark camped in Prairie County, MT, a little below and opposite the mouth of Powder River; the mouth of Crooked Creek.</notes>
    <Latitude>46.7431</Latitude>
    <Longitude>-105.4345</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Terry</City>
    <County>Prairie County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-31</id>
    <notes>Clark camped in Dawson County, MT, seven miles from present Glendive.</notes>
    <Latitude>47.1</Latitude>
    <Longitude>-104.7</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Glendive</City>
    <County>Dawson County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-07-31</id>
    <notes>The party camped on Rock Creek, Phillips County, MT.</notes>
    <Latitude>47.603</Latitude>
    <Longitude>-108.4867</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Zortman</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-01</id>
    <notes>Clark camped in Dawson County, MT, just below the mouth of Cottonwood Creek in Wibaux County.</notes>
    <Latitude>47.3337</Latitude>
    <Longitude>-104.4298</Longitude>
    <placeName></placeName>
    <alt_notes>Clark: Approximate location</alt_notes>
    <City>Wibaux</City>
    <County>Wibaux County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-01</id>
    <notes>The rest of the party camped in either Petroleum or Phillips County, a few miles below the camp of 1805-05-19. They remained at this camp until 08-03.</notes>
    <Latitude>47.4945</Latitude>
    <Longitude>-107.8577</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Malta</City>
    <County>Phillips County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-02</id>
    <notes>Clark camped just above the mouth of Charbonneau Creek in McKenzie County, ND.</notes>
    <Latitude>47.8574</Latitude>
    <Longitude>-103.9634</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Cartwright</City>
    <County>McKenzie County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-03</id>
    <notes>Clark camped in McKenzie County, ND, at the campsite of 1805-04-26.</notes>
    <Latitude>47.9778</Latitude>
    <Longitude>-103.9808</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-03</id>
    <notes>The rest of the party camped on the north side of the Missouri in Valley County, MT, below the mouth of Cattle Creek, and a couple miles above the camp of 1805-05-12.</notes>
    <Latitude>47.763</Latitude>
    <Longitude>-106.6487</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Jordan</City>
    <County>Garfield County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-04</id>
    <notes>Clark camped in either McKenzie or Williams County, ND, possibly near the camp of 1805-04-25.</notes>
    <Latitude>47.9578</Latitude>
    <Longitude>-103.914</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-04</id>
    <notes>The rest of the party camped in either Valley or McCone County, MT, a couple miles above the camp of 1805-05-07.</notes>
    <Latitude>48.0066</Latitude>
    <Longitude>-106.1462</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Peck</City>
    <County>McCone County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-05</id>
    <notes>Clark camped above Little Muddy River, McKenzie County, which reaches the Missouri at Williston, Williams County, ND.</notes>
    <Latitude>48.3667</Latitude>
    <Longitude>-103.2667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Ray</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-05</id>
    <notes>The rest of the party camped on Prairie Elk Creek, McCone County, MT, four miles southwest of present Wolf Point.</notes>
    <Latitude>48.0833</Latitude>
    <Longitude>-105.6833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wolf Point</City>
    <County>Roosevelt County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-06</id>
    <notes>Clark camped somewhat above Tobacco Creek, the site now submerged by Garrison Reservoir, McKenzie County, ND.</notes>
    <Latitude>47.4833</Latitude>
    <Longitude>-101.4</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Coleharbor</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-06</id>
    <notes>The rest of the party camped in Richland County, MT, 10 miles east of present Poplar.</notes>
    <Latitude>48.1072</Latitude>
    <Longitude>-105.1732</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Poplar</City>
    <County>Roosevelt County</County>
    <stateCode>MT</stateCode>
  </row>
  <row>
    <id>1806-08-07</id>
    <notes>Clark camped, again, above Tobacco Creek at a location submerged under Garrison Reservoir. Minimal information provided by Clark. Remained here until 08-09.</notes>
    <Latitude>48.2</Latitude>
    <Longitude>-103.2333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Ray</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-07</id>
    <notes>The rest of the party camped in Williams County, ND, a few miles south of present Trenton.</notes>
    <Latitude>48.0667</Latitude>
    <Longitude>-103.8333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-08</id>
    <notes>The party camped in Williams County, several miles southwest of Williston, ND. Remained at this camp until 08-10.</notes>
    <Latitude>48.1333</Latitude>
    <Longitude>-103.6333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-09</id>
    <notes>Clark camped &quot;1800 miles up the Missouri&quot; at a location now inundated by Garrison Reservoir. Remained here until 08-11.</notes>
    <Latitude>47.9363</Latitude>
    <Longitude>-103.2154</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Watford City</City>
    <County>McKenzie County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-10</id>
    <notes>The party camped in McKenzie County, ND, nearly opposite present Williston and a little above Little Muddy River. Just above the camp of 1805-04-21.</notes>
    <Latitude>48.1116</Latitude>
    <Longitude>-103.63</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Williston</City>
    <County>Williams County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-11</id>
    <notes>Clark camped on the present Little Knife River, Mountrail County, ND, which the party had passed on 1805-04-15. </notes>
    <Latitude>48.3</Latitude>
    <Longitude>-102.3</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Palermo</City>
    <County>Mountrail County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-11</id>
    <notes>The party camped in southwestern Mountrail County, ND, a little above the mouth of present White Earth River.</notes>
    <Latitude>48.1465</Latitude>
    <Longitude>-102.7815</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>White Earth</City>
    <County>Mountrail County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-12</id>
    <notes>Clark and the rest of the party reunited today. Their camp was located at Bear Den Creek, McKenzie County, ND.</notes>
    <Latitude>47.8111</Latitude>
    <Longitude>-102.701</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandaree</City>
    <County>McKenzie County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-13</id>
    <notes>Camped in McLean County, northeast of present Riverdale, ND.</notes>
    <Latitude>47.4833</Latitude>
    <Longitude>-101.3667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Riverdale</City>
    <County>McLean County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-14</id>
    <notes>Camped on the west side in Mercer County, ND, below the first Mandan village, Matootonha. Remained here until 08-17.</notes>
    <Latitude>47.5009</Latitude>
    <Longitude>-101.9429</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Golden Valley</City>
    <County>Mercer County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-17</id>
    <notes>Camped near one of the old Arikara villages, Oliver County, ND, near present Hensler. First noted 1804-10-24 and -25.</notes>
    <Latitude>47.25</Latitude>
    <Longitude>-101.0833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Center</City>
    <County>Oliver County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-18</id>
    <notes>Camped in Burleigh County, ND, a little south of Bismarck and below the mouth of the Heart River and camp of 1804-10-20.</notes>
    <Latitude>46.7582</Latitude>
    <Longitude>-100.8421</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mandan</City>
    <County>Morton County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-19</id>
    <notes>Camped near or at the camp of 1804-10-19, with the site probably now inundated by Oahe Reservoir.</notes>
    <Latitude>46.663</Latitude>
    <Longitude>-100.6406</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Missouri</City>
    <County>Burleigh County</County>
    <stateCode>ND</stateCode>
  </row>
  <row>
    <id>1806-08-20</id>
    <notes>Camped in Campbell County, SD, probably below the mouth of Spring Creek.</notes>
    <Latitude>45.8733</Latitude>
    <Longitude>-100.2427</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Pollock</City>
    <County>Campbell County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-21</id>
    <notes>Camped at Ashley Island, between Campbell and Corson Counties, SD.</notes>
    <Latitude>45.6</Latitude>
    <Longitude>-100.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mobridge</City>
    <County>Campbell County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-22</id>
    <notes>Camped below the island in Walworth County, SD, 6 miles southeast of present Mobridge.</notes>
    <Latitude>45.5333</Latitude>
    <Longitude>-100.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Mobridge</City>
    <County>Walworth County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-23</id>
    <notes>Camped in Potter County, SD, below the present U.S. Highway 212 and very near the camp of 1804-10-04, on Dolphees Island.</notes>
    <Latitude>45</Latitude>
    <Longitude>-100.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Gettysburg</City>
    <County>Potter County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-24</id>
    <notes>Camped near the upper end of Lookout Bend, Dewey County, SD, near the camp of 1804-10-01.</notes>
    <Latitude>44.7813</Latitude>
    <Longitude>-100.5891</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Eagle Butte</City>
    <County>Dewey County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-25</id>
    <notes>Camped in Hughes County, SD, below the entrance of Chantier Creek.</notes>
    <Latitude>44.5167</Latitude>
    <Longitude>-100.8</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Pierre</City>
    <County>Stanley County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-26</id>
    <notes>Camped in Lyman County, SD, four miles above the mouth of Medicine River. Now inundated by Lake Sharpe.</notes>
    <Latitude>44.05</Latitude>
    <Longitude>-99.45</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Fort Thompson</City>
    <County>Buffalo County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-27</id>
    <notes>Camped on perhaps Brule Island of Mattison, now under Lake Sharpe, between Lyman and Buffalo Counties, SD.</notes>
    <Latitude>43.75</Latitude>
    <Longitude>-99.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chamberlain</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-28</id>
    <notes>Camped at the party&apos;s camp of 1804-09-16 to -18, also referred to as Plumb Camp or Pleasant Camp. Near present Oacoma, Lyman County, SD.</notes>
    <Latitude>43.7943</Latitude>
    <Longitude>-99.3873</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Oacoma</City>
    <County>Lyman County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-29</id>
    <notes>Camped in Lyman County, SD, a little below the Round Island and camp of 1804-09-13.</notes>
    <Latitude>43.6551</Latitude>
    <Longitude>-99.3905</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Chamberlain</City>
    <County>Brule County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-30</id>
    <notes>Camped between Gregory and Charles Mix Counties, SD, near the later Hot Springs Island.</notes>
    <Latitude>43.3667</Latitude>
    <Longitude>-99.1</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Platte</City>
    <County>Charles Mix County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-08-31</id>
    <notes>Camped in Charles Mix County, near the camp of 1804-09-05. Near the mouth of Chouteau Creek.</notes>
    <Latitude>42.8398</Latitude>
    <Longitude>-98.1756</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Niobrara</City>
    <County>Knox County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1806-09-01</id>
    <notes>Camped in Yankton County, SD, opposite the present Gavins Point Dam.</notes>
    <Latitude>42.8619</Latitude>
    <Longitude>-97.4875</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Yankton</City>
    <County>Yankton County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-09-02</id>
    <notes>Camped a few miles below the mouth of James River. Could be either in Yankton County, SD, or Cedar County, NE.</notes>
    <Latitude>42.8742</Latitude>
    <Longitude>-97.2898</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Yankton</City>
    <County>Yankton County</County>
    <stateCode>SD</stateCode>
  </row>
  <row>
    <id>1806-09-03</id>
    <notes>Camped either in Union County, SD, or Dakota County, NE, some miles up the Missouri from present Sioux City.</notes>
    <Latitude>42.5167</Latitude>
    <Longitude>-96.4667</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Sioux City</City>
    <County>Woodbury County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1806-09-04</id>
    <notes>Camped where the party had camped on 1804-08-13. Either Woodbury County, IA or Dakota County, NE. Also called the &quot;Fishing Camp.&quot;</notes>
    <Latitude>42.3603</Latitude>
    <Longitude>-96.4179</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Sergeant Bluff</City>
    <County>Woodbury County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1806-09-05</id>
    <notes>Camped in Monona County, IA, a few miles south of present Onawa. Near the southern end of Guard Lake.</notes>
    <Latitude>42.0167</Latitude>
    <Longitude>-96.0833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Onawa</City>
    <County>Monona County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1806-09-06</id>
    <notes>Camped in between Little Sioux River and Soldier River. Would have been in either Harrison County, IA, or Burt/Washington County, NE.</notes>
    <Latitude>42.6273</Latitude>
    <Longitude>-95.6206</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Quimby</City>
    <County>Cherokee County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1806-09-07</id>
    <notes>Camped in either Harrison County or Washington County, NE, near present Blair.</notes>
    <Latitude>41.5333</Latitude>
    <Longitude>-96.1167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Blair</City>
    <County>Washington County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1806-09-08</id>
    <notes>Camped near the Mills-Pottawattamie County line, IA. Camped here 1804-07-22 to -27.</notes>
    <Latitude>41.16</Latitude>
    <Longitude>-95.8783</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Council Bluffs</City>
    <County>Pottawattamie County</County>
    <stateCode>IA</stateCode>
  </row>
  <row>
    <id>1806-09-09</id>
    <notes>Camped either in Nemaha County, NE, or Atchison County, MO. Northeast of Peru, NE.</notes>
    <Latitude>40.4667</Latitude>
    <Longitude>-95.7333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Peru</City>
    <County>Nemaha County</County>
    <stateCode>NE</stateCode>
  </row>
  <row>
    <id>1806-09-10</id>
    <notes>Camped on the sandbar either in Richardson County, NE, or Holt County, MO. Above the Big Nemaha River near Rulo, NE.</notes>
    <Latitude>40.05</Latitude>
    <Longitude>-95.4167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Craig</City>
    <County></County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-11</id>
    <notes>Camped either in Andrew or Buchanan County, MO, on Nodaway Island. First noted 1804-07-08.</notes>
    <Latitude>39.9016</Latitude>
    <Longitude>-94.9685</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Amazonia</City>
    <County>Andrew County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-12</id>
    <notes>Camped at St. Michael&apos;s Prairie, Buchanan County, MO, at present St. Joseph.</notes>
    <Latitude>39.7667</Latitude>
    <Longitude>-94.8333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Saint Joseph</City>
    <County>Buchanan County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-13</id>
    <notes>Camped in either Buchanan County, MO, or Doniphan County, KS. Near present Brush Creek, noted 1804-07-05.</notes>
    <Latitude>39.677</Latitude>
    <Longitude>-94.985</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Wathena</City>
    <County>Doniphan County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1806-09-14</id>
    <notes>Camped where the party had camped on 1804-07-01, on Leavenworth Island, opposite present Leavenworth, KS.</notes>
    <Latitude>39.308</Latitude>
    <Longitude>-94.9014</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Leavenworth</City>
    <County>Leavenworth County</County>
    <stateCode>KS</stateCode>
  </row>
  <row>
    <id>1806-09-15</id>
    <notes>Camped in Clay County, MO, on the present Little Blue River. First passed this area on 1804-06-24.</notes>
    <Latitude>39.18</Latitude>
    <Longitude>-94.335</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Independence</City>
    <County>Jackson County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-16</id>
    <notes>Camped in between Carroll and Lafayette Counties, MO, a few miles above the camp of 1804-06-16.</notes>
    <Latitude>39.2176</Latitude>
    <Longitude>-93.5211</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City>Waverly</City>
    <County>Lafayette County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-17</id>
    <notes>Camped four miles above the mouth of Grand River, in the area of Malta Bend, Saline County, MO.</notes>
    <Latitude>39.1833</Latitude>
    <Longitude>-93.35</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Malta Bend</City>
    <County>Saline County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-18</id>
    <notes>Camped where the party first camped on the Lamine River on 1804-06-08. Cooper County, MO.</notes>
    <Latitude>39.05</Latitude>
    <Longitude>-92.928</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Blackwater</City>
    <County>Howard County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-19</id>
    <notes>Camped where the party had camped on 1804-06-01 to -03. On the Osage River at the Osage-Cole County line, MO.</notes>
    <Latitude>38.5922</Latitude>
    <Longitude>-91.9532</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Bonnots Mill</City>
    <County>Osage County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-20</id>
    <notes>Camped where the party had camped on 1804-05-25. La Charette, Warren County, MO.</notes>
    <Latitude>38.65</Latitude>
    <Longitude>-91.0833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Marthasville</City>
    <County>Warren County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-21</id>
    <notes>Camped in St. Charles, St. Charles County, MO, where the party had first camped on 1804-05-16.</notes>
    <Latitude>38.789</Latitude>
    <Longitude>-90.514</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Saint Charles</City>
    <County>St. Charles County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-22</id>
    <notes>Camped at Fort Bellefontaine, Saint Louis County, MO, near the mouth of Coldwater Creek.</notes>
    <Latitude>38.8333</Latitude>
    <Longitude>-90.2333</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>Florissant</City>
    <County>St. Louis County</County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1806-09-23</id>
    <notes>Camped in St. Louis, Saint Louis County, MO. This concludes the expedition camp locations.</notes>
    <Latitude>38.6167</Latitude>
    <Longitude>-90.1833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City>St. Louis</City>
    <County></County>
    <stateCode>MO</stateCode>
  </row>
  <row>
    <id>1803-11-15-19</id>
    <notes>Entry recorded more than likely at the time when the party was at the juncture of the Ohio and Mississippi Rivers.</notes>
    <Latitude>37.0008</Latitude>
    <Longitude>-89.176</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1803-12-19-20</id>
    <notes>No location. A rough draft for a letter in response to a request from Andrew MacFarlane.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-01-03-04</id>
    <notes>No location. Field notes.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-01-21-1</id>
    <notes>No location. Clark&apos;s attempts to calculate the duration of the trip.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-01-21-2</id>
    <notes>Observations on the day at their winter camp location from 1803-12-12 to 1804-05-14.</notes>
    <Latitude>38.8</Latitude>
    <Longitude>-90.12</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-01-31-1</id>
    <notes>Weather observation, as well as flow patterns of the Mississippi. Study commenced on 1804-01-01.</notes>
    <Latitude>38.9225</Latitude>
    <Longitude>-89.9644</Longitude>
    <placeName></placeName>
    <alt_notes>Approximate location</alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-03-29-1</id>
    <notes>No location. Various journal entries.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-03-31-1</id>
    <notes>No location. Daily weather record for the month of March.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-04-12-1</id>
    <notes>No location. List of party members, as well as planning the expedition and supply needs.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-04-16-1</id>
    <notes>No location. Figure calculations made by Clark.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-04-22-24</id>
    <notes>Spent a few days (April 22, 23, 24) in St. Louis.</notes>
    <Latitude>38.6167</Latitude>
    <Longitude>-90.1833</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-04-30-1</id>
    <notes>No location. Daily weather record for the month of April.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-05-14-1</id>
    <notes>Extension of Clark&apos;s entry from 1804-05-14. Also various additional entries and notes. Camped near a limestone rock edge called Colewater.</notes>
    <Latitude>38.83</Latitude>
    <Longitude>-90.2211</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-05-31-1</id>
    <notes>No location. Daily weather record for the month of May.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-06-26-29</id>
    <notes>Clark&apos;s notes about the Missouri River at the campsite from 1804-06-26. Wyandotte County, KS.</notes>
    <Latitude>39.1163</Latitude>
    <Longitude>-94.6115</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-06-30-1</id>
    <notes>No location. Food and animal observations from the 10th, 11th, and 16th of June.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-07-31-1</id>
    <notes>No location. Animal observations for the 4th, 12th, and 23rd days in July.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-09-30-1</id>
    <notes>No location. Daily weather record for a majority of the month of September.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-10-31-1</id>
    <notes>No location. Daily weather record for the month of October.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-11-16-28</id>
    <notes>In reference to the winter camp on 1804-11-16. Discussion of storms and preservation of food.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-11-30-1</id>
    <notes>No location. Daily weather record for the month of November.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-12-20-21</id>
    <notes>No location. Weather report from 1804-12-20-21.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-12-31-1</id>
    <notes>No location. Daily weather record for the month of December.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.introduction</id>
    <notes>No location. Introduction to records from the winter of 1804.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.part1</id>
    <notes>No location. Notes in compliment to Clark&apos;s map of the West.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.part2</id>
    <notes>No location. Copies of various letters to different recipients.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.part3</id>
    <notes>No location. Records of different botanical specimens by Lewis.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.part4</id>
    <notes>No location. Record of mineral specimens from the American Philosophical Society Donation Book.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.part5</id>
    <notes>No location. Collection of random documents and notes made by Clark.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1804-1805.winter.part6</id>
    <notes>No location. Various invoices to be given to Native American chiefs.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-13-12</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-05-08</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-09-10</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-15-16</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-22-23</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-27-28</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-01-31-1</id>
    <notes>No location. Daily weather report for the month of January 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-05-13</id>
    <notes>Record of various campsites. 02-05: camped at the earth villages on or near Mandan Island.</notes>
    <Latitude>47.5667</Latitude>
    <Longitude>-102.2167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-05-13</id>
    <notes>Record of various campsites. 02-06: camped at another Native American village.</notes>
    <Latitude>47.0667</Latitude>
    <Longitude>-101.4667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-05-13</id>
    <notes>Record of various campsites. 02-09: returned to the original established winter camp.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-06-12</id>
    <notes>Record of various campsites. 02-06: camped at the mouth of Square Butte Creek.</notes>
    <Latitude>47.0667</Latitude>
    <Longitude>-101.4667</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-06-12</id>
    <notes>Record of various campsites. 02-09: returned to the original established winter camp.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-19-20</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-02-28-1</id>
    <notes>No location. Daily weather report for the month of February 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-03-24-25</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-03-30-31</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-03-31-1</id>
    <notes>No location. Daily weather report for the month of March 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-04-04-06</id>
    <notes>Referring to actions at the winter campsite of 1804. Established camp on 1804-11-01 and remained here until 1805-04-07.</notes>
    <Latitude>47.2893</Latitude>
    <Longitude>-101.3295</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-04-30-1</id>
    <notes>No location. Daily weather report for the month of April 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-05-31-1</id>
    <notes>No location. Daily weather report for the month of May 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-06-17-19</id>
    <notes>No location. Additional in-depth survey notes for the Great Falls trip during 06-17 to 06-19.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-06-30-1</id>
    <notes>No location. Daily weather report for the month of June 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-07-31-1</id>
    <notes>No location. Daily weather report for the month of July 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-08-31-1</id>
    <notes>No location. Daily weather report for the month of August 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-09-30-1</id>
    <notes>No location. Daily weather report for the month of September 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-10-31-1</id>
    <notes>No location. Daily weather report for the month of October 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-11-30-1</id>
    <notes>No location. Daily weather report for the month of November 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-12-22-24</id>
    <notes>Referring to actions at the winter campsite of 1805. Established camp on 1805-12-10 and remained here until 1806-01-06.</notes>
    <Latitude>45.9833</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-12-31-1</id>
    <notes>No location. Daily weather report for the month of December 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-1806.winter.introduction</id>
    <notes>No location. Introduction to records from the winter of 1805.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-1806.winter.part1</id>
    <notes>No location. Estimated distances from Fort Mandan to the Pacific Coast.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-1806.winter.part2</id>
    <notes>No location. Estimation of Native American population size and locations.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1805-1806.winter.part3</id>
    <notes>No location. Collection of miscellaneous documents.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-01-15-16</id>
    <notes>Referring to actions at the winter campsite of 1805. Established camp on 1806-01-06 and remained here until 1806-03-23.</notes>
    <Latitude>45.9833</Latitude>
    <Longitude>-123.9167</Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-01-31-1</id>
    <notes>No location. Daily weather report for the month of January 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-02-28-1</id>
    <notes>No location. Daily weather report for the month of February 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-03-31-1</id>
    <notes>No location. Daily weather report for the month of March 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-04-30-1</id>
    <notes>No location. Daily weather report for the month of April 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-05-31-1</id>
    <notes>No location. Daily weather report for the month of May 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-06-30-1</id>
    <notes>No location. Daily weather report for the month of June 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-07-31-1</id>
    <notes>No location. Daily weather report for the month of July 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-08-31-1</id>
    <notes>No location. Daily weather report for the month of August 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806-09-30-1</id>
    <notes>No location. Daily weather report for the month of September 1806.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806.postexpedition.introduction.xml</id>
    <notes>No location. Miscellaneous notes following the end of the expedition.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806.postexpedition.part1</id>
    <notes>No location. Estimated distances from St. Charles, Missouri, to the Pacific Coast.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
  <row>
    <id>1806.postexpedition.part2</id>
    <notes>No location. Miscellaneous notes following the end of the expedition.</notes>
    <Latitude></Latitude>
    <Longitude></Longitude>
    <placeName></placeName>
    <alt_notes></alt_notes>
    <City></City>
    <County></County>
    <stateCode></stateCode>
  </row>
</root>
    
    
  </xsl:variable>

</xsl:stylesheet>
