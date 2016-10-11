<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output indent="yes"></xsl:output>

  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.'))"></xsl:value-of>
  </xsl:variable>
  
  <xsl:variable name="file_id">
    <xsl:value-of select="/tei:TEI/@xml:id"/>
  </xsl:variable>

   
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/TEI//textClass/keywords[@n='subcategory']">

    
    <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="scheme">original</xsl:attribute>
      <xsl:attribute name="n">subcategory</xsl:attribute>
      
      <xsl:choose>
        <xsl:when test="$journal/*:image_list/*:image/@id = $file_id">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:text>Journal Images</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$maps/*:image_list/*:image/@id = $file_id">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:text>Map Images</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:when test="($people_places/*:image_list/*:image/@id  = $file_id) or (starts-with($file_id,'lc.img.000'))">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:text>People and Place Images</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$plants_animals/*:image_list/*:image/@id  = $file_id or contains($file_id,'johnsgard')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:text>Plant and Animal Images</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
       
      </xsl:choose>
      
      
      
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="/TEI//textClass/keywords[@n='topic']">
    <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="scheme">original</xsl:attribute>
      <xsl:attribute name="n">topic</xsl:attribute>
    
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''"></xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
      
      
        <xsl:if test="$journal/*:image_list/*:image/@id = $file_id">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">image</xsl:attribute>
            <xsl:text>journal</xsl:text>
          </xsl:element>
        </xsl:if>
      
      
      <xsl:if test="$maps/*:image_list/*:image/@id = $file_id">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">image</xsl:attribute>
            <xsl:text>Map</xsl:text>
          </xsl:element>
      </xsl:if>
      
      
      <xsl:if test="($people_places/*:image_list/*:image/@id = $file_id) or (starts-with($file_id,'lc.img.000'))">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">image</xsl:attribute>
            <xsl:text>people_and_places</xsl:text>
          </xsl:element>
        </xsl:if>
      
      
      <xsl:if test="$plants_animals/*:image_list/*:image/@id = $file_id or contains($file_id,'johnsgard')">
          <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">image</xsl:attribute>
            <xsl:text>plants_and_animals</xsl:text>
            </xsl:element>
        </xsl:if>
      
    
    </xsl:element>
  </xsl:template>
  
  
  <!-- template for changing image id's below -->
 <!--<xsl:template match="/" xpath-default-namespace="">
   <xsl:for-each select="$plants_animals/image_list/image">
     <xsl:element name="image">
       <xsl:attribute name="id">
         <xsl:text>lc.img.</xsl:text>
         <xsl:choose>
           <xsl:when test="starts-with(@id,'lc')">
             <xsl:value-of select="substring-after(substring-before(@id,'.jpg'),'lc.')"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="substring-before(@id,'.jpg')"/>
           </xsl:otherwise>
         </xsl:choose>
         
         
       </xsl:attribute>
     </xsl:element>
   </xsl:for-each>
 </xsl:template>-->
 
  <xsl:variable name="journal">
    <image_list>
      <image id="lc.img.1803-11-20.01"/>
      <image id="lc.img.1803-11-20.02"/>
      <image id="lc.img.1803-11-21.01"/>
      <image id="lc.img.1804-06-05.01"/>
      <image id="lc.img.1804-1805.winter.part1.01"/>
      <image id="lc.img.1804-1805.winter.part3.01"/>
      <image id="lc.img.1805-01-28.01"/>
      <image id="lc.img.1805-02-05.01"/>
      <image id="lc.img.1805-07-04.01"/>
      <image id="lc.img.1805-08-13.01"/>
      <image id="lc.img.1805-08-21.01"/>
      <image id="lc.img.1805-10-22.01"/>
      <image id="lc.img.1805-10-24.01"/>
      <image id="lc.img.1805-10-24.03"/>
      <image id="lc.img.1805-11-01.02"/>
      <image id="lc.img.1805-11-16.01"/>
      <image id="lc.img.1805-12-01.01"/>
      <image id="lc.img.1805-12-29.02"/>
      <image id="lc.img.1805-1806.winter.part1.01"/>
      <image id="lc.img.1806-01-01.01"/>
      <image id="lc.img.1806-01-06.01"/>
      <image id="lc.img.1806-01-07.01"/>
      <image id="lc.img.1806-01-15.02"/>
      <image id="lc.img.1806-01-16.01"/>
      <image id="lc.img.1806-01-23.01"/>
      <image id="lc.img.1806-01-24.01"/>
      <image id="lc.img.1806-01-29.01"/>
      <image id="lc.img.1806-02-01.01"/>
      <image id="lc.img.1806-02-01.02"/>
      <image id="lc.img.1806-02-09.01"/>
      <image id="lc.img.1806-02-10.01"/>
      <image id="lc.img.1806-02-13.01"/>
      <image id="lc.img.1806-02-17.01"/>
      <image id="lc.img.1806-02-18.01"/>
      <image id="lc.img.1806-02-24.01"/>
      <image id="lc.img.1806-03-02.01"/>
      <image id="lc.img.1806-03-07.01"/>
      <image id="lc.img.1806-03-15.01"/>
      <image id="lc.img.1806-03-16.01"/>
      <image id="lc.img.1806-03-29.01"/>
      <image id="lc.img.1806-04-03.01"/>
      <image id="lc.img.1806-04-06.01"/>
      <image id="lc.img.1806-04-26.01"/>
      <image id="lc.img.1806-05-18.01"/>
      <image id="lc.img.1806-05-31.01"/>
      <image id="lc.img.1806-07-11.01"/>
      <image id="lc.img.1804-1805.winter.part5.01"/>
      <image id="lc.img.1805-04-28.01"/>
      <image id="lc.img.1805-05-25.01"/>
      <image id="lc.img.1805-07-02.01"/>
      <image id="lc.img.1805-07-03.01"/>
      <image id="lc.img.1805-07-03.02"/>
      <image id="lc.img.1805-07-03.03"/>
      <image id="lc.img.1805-09-11.01"/>
      <image id="lc.img.1805-09-16.01"/>
      <image id="lc.img.1805-09-18.01"/>
      <image id="lc.img.1805-09-20.01"/>
      <image id="lc.img.1805-09-20.02"/>
      <image id="lc.img.1805-10-10.01"/>
      <image id="lc.img.1805-10-13.01"/>
      <image id="lc.img.1805-10-14.01"/>
      <image id="lc.img.1805-10-15.01"/>
      <image id="lc.img.1805-10-18.01"/>
      <image id="lc.img.1805-10-18.02"/>
      <image id="lc.img.1805-10-18.04"/>
      <image id="lc.img.1805-10-19.01"/>
      <image id="lc.img.1805-10-20.01"/>
      <image id="lc.img.1805-10-20.02"/>
      <image id="lc.img.1805-10-21.01"/>
      <image id="lc.img.1805-10-22.02"/>
      <image id="lc.img.1805-10-24.01"/>
      <image id="lc.img.1805-11-01.01"/>
      <image id="lc.img.1805-11-01.03"/>
      <image id="lc.img.1805-11-18.01"/>
      <image id="lc.img.1805-11-18.02"/>
      <image id="lc.img.1805-12-07.01"/>
      <image id="lc.img.1805-12-07.02"/>
      <image id="lc.img.1805-12-29.01"/>
      <image id="lc.img.1806-01-30.01"/>
      <image id="lc.img.1806-02-01.03"/>
      <image id="lc.img.1806-02-01.04"/>
      <image id="lc.img.1806-02-01.05"/>
      <image id="lc.img.1806-02-08.01"/>
      <image id="lc.img.1806-02-09.02"/>
      <image id="lc.img.1806-02-10.02"/>
      <image id="lc.img.1806-02-12.01"/>
      <image id="lc.img.1806-02-12.02"/>
      <image id="lc.img.1806-02-13.02"/>
      <image id="lc.img.1806-02-16.01"/>
      <image id="lc.img.1806-02-25.01"/>
      <image id="lc.img.1806-03-02.02"/>
      <image id="lc.img.1806-03-06.01"/>
      <image id="lc.img.1806-03-15.02"/>
      <image id="lc.img.1806-03-16.02"/>
      <image id="lc.img.1806-03-30.01"/>
      <image id="lc.img.1806-04-03.02"/>
      <image id="lc.img.1806-04-03.03"/>
      <image id="lc.img.1806-04-03.03"/>
      <image id="lc.img.1806-04-04.01"/>
      <image id="lc.img.1806-04-18.01"/>
      <image id="lc.img.1806-04-20.01"/>
      <image id="lc.img.1806-04-26.02"/>
      <image id="lc.img.1806-04-29.01"/>
      <image id="lc.img.1806-05-11.01"/>
      <image id="lc.img.1806-07-18.01"/>
      <image id="lc.img.1806-07-18.02"/>
      <image id="lc.img.1803-11-15.01"/>
      <image id="lc.img.1803-12-29.01"/>
      <image id="lc.img.1804-01-03.01"/>
      <image id="lc.img.1804-01-21.01"/>
      <image id="lc.img.1804-04-12.01"/>
      <image id="lc.img.1804-06-01.01"/>
      <image id="lc.img.1804-06-01.01"/>
      <image id="lc.img.1804-06-05.01"/>
      <image id="lc.img.1804-06-07.01"/>
      <image id="lc.img.1804-06-13.01"/>
      <image id="lc.img.1804-07-01.01"/>
      <image id="lc.img.1804-08-12.01"/>
      <image id="lc.img.1804-08-19.01"/>
      <image id="lc.img.1804-09-02.01"/>
      <image id="lc.img.1804-09-09.01"/>
      <image id="lc.img.1804-09-21.01"/>
      <image id="lc.img.1804-12-17.01"/>
      <image id="lc.img.1805-03-29.01"/>
    </image_list>
  </xsl:variable>
  
  <xsl:variable name="maps">
    <image_list>
      <image id="lc.img.1803-08-30.01"/>
      <image id="lc.img.1804-05-14-1.01"/>
      <image id="lc.img.1804-08-25.01"/>
      <image id="lc.img.1805-06-21.01"/>
      <image id="lc.img.1805-07-28.01"/>
      <image id="lc.img.1805-08-17.01"/>
      <image id="lc.img.1805-08-28.01"/>
      <image id="lc.img.1805-07-28.01"/>
      <image id="lc.img.1805-11-22.01"/>
      <image id="lc.img.1806-06-10.01"/>
      <image id="lc.img.1806-06-24.01"/>
      <image id="lc.img.1806-07-03.01"/>
      <image id="lc.img.1804-1805.winter.part1.01"/>
      <image id="lc.img.1805-07-04.01"/>
      <image id="lc.img.1805-10-22.01"/>
      <image id="lc.img.1805-10-24.01"/>
      <image id="lc.img.1805-11-01.02"/>
      <image id="lc.img.1805-07-04.01"/>
      <image id="lc.img.1805-12-01.01"/>
      <image id="lc.img.1806-01-06.01"/>
      <image id="lc.img.1806-04-03.01"/>
    </image_list>
  </xsl:variable>
  
  <xsl:variable name="people_places">
    <image_list>
      <image id="lc.img.lewis"/>
      <image id="lc.img.clark"/>
      <image id="lc.img.Arapaho_75-bae-208e"/>
      <image id="lc.img.Arapaho_75-bae-45c"/>
      <image id="lc.img.Arapaho_75-se-1"/>
      <image id="lc.img.Assinniboine_111-sc-82392"/>
      <image id="lc.img.Assinniboine_111-sc-82394"/>
      <image id="lc.img.Assinniboine_111-sc-82396"/>
      <image id="lc.img.Assinniboine_111-sc-82398"/>
      <image id="lc.img.Assinniboine_111-sc-82403"/>
      <image id="lc.img.Assinniboine_111-sc-82419"/>
      <image id="lc.img.Cheyenne_75-bae-48c"/>
      <image id="lc.img.Chippewa_111-sc-82417"/>
      <image id="lc.img.Columbia_09-1429a"/>
      <image id="lc.img.Columbia_09-1430a"/>
      <image id="lc.img.Crow_75-gir-3"/>
      <image id="lc.img.Flathead_75-gir-37"/>
      <image id="lc.img.GreatFalls_111-sc-82601"/>
      <image id="lc.img.Kiowa_75-bae-2581a"/>
      <image id="lc.img.Mandan_19-1307a"/>
      <image id="lc.img.NezPerce_111-sc-87744"/>
      <image id="lc.img.Pawnee_19-1356a"/>
      <image id="lc.img.Shoshoni_111-sc-83537"/>
      <image id="lc.img.Sioux_111-sc-82381"/>
      <image id="lc.img.Sioux_111-sc-82534"/>
      <image id="lc.img.Sioux_111-sc-83147"/>
      <image id="lc.img.loc.3a40649r"/>
      <image id="lc.img.loc.3a47158r"/>
      <image id="lc.img.loc.3a55033v"/>
      <image id="lc.img.loc.3b01641r"/>
      <image id="lc.img.loc.3b12438r"/>
      <image id="lc.img.loc.3b14159r"/>
      <image id="lc.img.loc.3b14188r"/>
      <image id="lc.img.loc.3b24366r"/>
      <image id="lc.img.loc.3b30539r"/>
      <image id="lc.img.loc.3b42297r"/>
      <image id="lc.img.loc.3b42303r"/>
      <image id="lc.img.loc.3b42305r"/>
      <image id="lc.img.loc.3b43934r"/>
      <image id="lc.img.loc.3b44160r"/>
      <image id="lc.img.loc.3b45409r"/>
      <image id="lc.img.loc.3b45412r"/>
      <image id="lc.img.loc.3b45832r"/>
      <image id="lc.img.loc.3b45839r"/>
      <image id="lc.img.loc.3c07916v"/>
      <image id="lc.img.loc.3c01162v"/>
      <image id="lc.img.loc.3c01186v"/>
      <image id="lc.img.loc.3c01187v"/>
      <image id="lc.img.loc.3c01328v"/>
      <image id="lc.img.loc.3c01329v"/>
      <image id="lc.img.loc.3c01331v"/>
      <image id="lc.img.loc.3c02138v"/>
      <image id="lc.img.loc.3c25926v"/>
      <image id="lc.img.loc.3c04564v"/>
      <image id="lc.img.loc.3c04565v"/>
      <image id="lc.img.loc.3c04709v"/>
      <image id="lc.img.loc.3c05371v"/>
      <image id="lc.img.loc.3c05388v"/>
      <image id="lc.img.loc.3c05497v"/>
      <image id="lc.img.loc.3c06369v"/>
      <image id="lc.img.loc.3c06478v"/>
      <image id="lc.img.loc.3c06742v"/>
      <image id="lc.img.loc.3c06768v"/>
      <image id="lc.img.loc.3c07602v"/>
      <image id="lc.img.loc.3c07614v"/>
      <image id="lc.img.loc.3c07915v"/>
      <image id="lc.img.loc.3c08467v"/>
      <image id="lc.img.loc.3c09713v"/>
      <image id="lc.img.loc.3c11136v"/>
      <image id="lc.img.loc.3c11287v"/>
      <image id="lc.img.loc.3c11294v"/>
      <image id="lc.img.loc.3c12259v"/>
      <image id="lc.img.loc.3c12265v"/>
      <image id="lc.img.loc.3c12266v"/>
      <image id="lc.img.loc.3c13214v"/>
      <image id="lc.img.loc.3c14582v"/>
      <image id="lc.img.loc.3c14840v"/>
      <image id="lc.img.loc.3c15019v"/>
      <image id="lc.img.loc.3c15030v"/>
      <image id="lc.img.loc.3c15033v"/>
      <image id="lc.img.loc.3c15453v"/>
      <image id="lc.img.loc.3c15461v"/>
      <image id="lc.img.loc.3c15806v"/>
      <image id="lc.img.loc.3c17305v"/>
      <image id="lc.img.loc.3c17609v"/>
      <image id="lc.img.loc.3c18592v"/>
      <image id="lc.img.loc.3c21686v"/>
      <image id="lc.img.loc.3c26490v"/>
      <image id="lc.img.loc.3c26697v"/>
      <image id="lc.img.loc.3b30540r"/>
      <image id="lc.img.loc.3g04752v"/>
      <image id="lc.img.loc.3f06294v"/>
      <image id="lc.img.loc.3g03416v"/>
      <image id="lc.img.loc.3g03417v"/>
      <image id="lc.img.loc.3g04754v"/>
    </image_list>
  </xsl:variable>
  
  <xsl:variable name="plants_animals">
    <image_list>
      <image id="lc.img.johnsgard.01.fig01"/>
      <image id="lc.img.johnsgard.01.fig02"/>
      <image id="lc.img.johnsgard.01.fig03"/>
      <image id="lc.img.johnsgard.01.fig04"/>
      <image id="lc.img.johnsgard.01.fig05"/>
      <image id="lc.img.johnsgard.01.fig06"/>
      <image id="lc.img.johnsgard.01.fig07"/>
      <image id="lc.img.johnsgard.01.fig08"/>
      <image id="lc.img.johnsgard.01.fig09"/>
      <image id="lc.img.johnsgard.01.fig10"/>
      <image id="lc.img.johnsgard.01.fig11"/>
      <image id="lc.img.johnsgard.01.fig12"/>
      <image id="lc.img.johnsgard.01.fig13"/>
      <image id="lc.img.johnsgard.01.fig14"/>
      <image id="lc.img.johnsgard.01.fig15"/>
      <image id="lc.img.johnsgard.01.fig16"/>
      <image id="lc.img.johnsgard.01.fig17"/>
      <image id="lc.img.johnsgard.01.fig18"/>
      <image id="lc.img.johnsgard.01.fig19"/>
      <image id="lc.img.johnsgard.01.fig20"/>
      <image id="lc.img.johnsgard.01.fig21"/>
      <image id="lc.img.johnsgard.01.fig22"/>
      <image id="lc.img.johnsgard.01.fig23"/>
      <image id="lc.img.johnsgard.01.fig24"/>
      <image id="lc.img.johnsgard.01.fig25"/>
      <image id="lc.img.johnsgard.01.fig26"/>
      <image id="lc.img.johnsgard.01.fig27"/>
      <image id="lc.img.johnsgard.01.fig28"/>
      <image id="lc.img.johnsgard.01.fig29"/>
      <image id="lc.img.johnsgard.01.fig30"/>
      <image id="lc.img.johnsgard.01.fig31"/>
      <image id="lc.img.johnsgard.01.fig32"/>
      <image id="lc.img.johnsgard.01.fig33"/>
      <image id="lc.img.johnsgard.01.fig34"/>
      <image id="lc.img.johnsgard.01.fig35"/>
      <image id="lc.img.johnsgard.01.fig36"/>
      <image id="lc.img.johnsgard.01.fig37"/>
      <image id="lc.img.johnsgard.01.fig38"/>
      <image id="lc.img.1804-1805.winter.part3.01"/>
      <image id="lc.img.1806-01-07.01"/>
      <image id="lc.img.1806-02-09.01"/>
      <image id="lc.img.1806-02-10.01"/>
      <image id="lc.img.1806-02-13.01"/>
      <image id="lc.img.1806-02-17.01"/>
      <image id="lc.img.1806-02-18.01"/>
      <image id="lc.img.1806-02-24.01"/>
      <image id="lc.img.1806-03-02.01"/>
      <image id="lc.img.1806-03-07.01"/>
      <image id="lc.img.1806-03-15.01"/>
      <image id="lc.img.1806-03-16.01"/>
    </image_list>
  </xsl:variable>
  
</xsl:stylesheet>
