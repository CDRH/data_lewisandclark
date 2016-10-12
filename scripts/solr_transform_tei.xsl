<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="#all">
  
  <!-- ==================================================================== -->
  <!--                               IMPORTS                                -->
  <!-- ==================================================================== -->

  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/tei_personography.xsl"/>
  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/cdrh_tei.xsl"/>
  <!-- If this file is living in a projects directory, the paths will be
       ../../../scripts/xslt/cdrh_to_solr/lib/common.xsl -->

  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <!-- Defined in project config files -->
  <xsl:param name="fig_location"/>  <!-- url for figures -->
  <xsl:param name="file_location"/> <!-- url for tei files -->
  <xsl:param name="figures"/>       <!-- boolean for if figs should be displayed (not for this script, for html script) -->
  <xsl:param name="fw"/>            <!-- boolean for html not for this script -->
  <xsl:param name="pb"/>            <!-- boolean for page breaks in html, not this script -->
  <xsl:param name="project"/>       <!-- longer name of project -->
  <xsl:param name="slug"/>          <!-- slug of project -->
  <xsl:param name="site_url"/>
        

  <!-- ==================================================================== -->
  <!--              OVERRIDES    - individual fields                        -->
  <!-- ==================================================================== -->
  
  <xsl:template name="title">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']) = 
                        'The Journals of the Lewis and Clark Expedition Online'">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='sub'][1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1])"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type='sub'][1])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <field name="title">
      <xsl:value-of select="$title"/>
    </field>
    
    <field name="titleSort">
      <xsl:call-template name="normalize_name">
        <xsl:with-param name="string">
          <xsl:value-of select="$title"/>
        </xsl:with-param>
      </xsl:call-template>
    </field>
  </xsl:template>
  
  
  <!-- ==================================================================== -->
  <!--                            OVERRIDES   - Doc setup                              -->
  <!-- ==================================================================== -->
  <xsl:template match="name">
    <xsl:apply-templates/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@key"/>
    <xsl:text>) </xsl:text>
  </xsl:template>
  
  <!-- If journal, call tei template twice? -->
  
  <xsl:template name="tei_template" exclude-result-prefixes="#all">
    <xsl:param name="filenamepart"/>
    
    <add>
      <xsl:choose>
        <!-- When Journal, select different stuff -->
        <xsl:when test="starts-with($filenamepart,'lc.jrn.1') and //div[@type='entry']">
          <xsl:for-each select="//div[@type='entry']">
            <doc>
              <!-- id -->
              <xsl:call-template name="id">
                <xsl:with-param name="id" select="@xml:id"/>
              </xsl:call-template>
              <!-- date and dateDisplay-->
              <xsl:variable name="journal_date">
                <xsl:choose>
                  <xsl:when test="/TEI/text[1]/body[1]/head[1]/date[1]/@when"><xsl:value-of select="/TEI/text[1]/body[1]/head[1]/date[1]/@when"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="/TEI/text[1]/body[1]/head[1]/date[1]/@notafter"/></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <field name="date">
                <xsl:value-of select="$journal_date"/>
              </field>
              <field name="dateDisplay">
                <xsl:call-template name="extractDate"><xsl:with-param name="date"><xsl:value-of select="$journal_date"/></xsl:with-param></xsl:call-template>
              </field>
              <!-- geo coordinates -->
              <!-- todo change ref to n when files are changed -->
              
              <xsl:variable name="georef" select="@ref"/>
              <xsl:variable name="geo">
                <xsl:value-of select="/TEI/teiHeader[1]/encodingDesc[1]/geoDecl[@xml:id=$georef]/geo"/>
              </xsl:variable>
              <xsl:if test="normalize-space($geo) != ''">
                <field name="lc_geo_coordinates_p">
                  <xsl:value-of select="translate($geo,' ',',')"/>
                </field>
              </xsl:if>
              <!-- text -->
              <field name="text">
                <xsl:apply-templates select="."/>
                <!-- grab refs for searching -->
                <xsl:for-each select=".//ref">
                  <xsl:variable name="target" select="@target"/>
                  <xsl:apply-templates select="/TEI/text/back//note[@xml:id=$target]"/><xsl:text>  </xsl:text>
                </xsl:for-each>
                
              </field>
              
              <!-- uriHTML -->
                <field name="uriHTML">
                  <xsl:value-of select="$file_location"/>
                  <xsl:value-of select="$slug"/>
                  <xsl:text>/html-generated/</xsl:text>
                  <xsl:value-of select="/TEI/@xml:id"/>
                  <xsl:text>.txt</xsl:text>
                </field>
              
              
              <xsl:call-template name="tei_template_part"><xsl:with-param name="filenamepart" select="$filenamepart"/></xsl:call-template>
            </doc>
          </xsl:for-each>
        </xsl:when>
        <!-- All other files -->
        <xsl:otherwise>
          <doc>
            <!-- id -->
            <xsl:call-template name="id">
              <xsl:with-param name="id" select="$filenamepart"/>
            </xsl:call-template>
            <!-- date and dateDisplay-->
            
            <xsl:choose>
              <xsl:when test="/TEI/text[1]/body[1]/list[1]/item[1]/figure[1]/p[1]/bibl[1]/date[1]">
                <xsl:variable name="image_date" select="/TEI/text[1]/body[1]/list[1]/item[1]/figure[1]/p[1]/bibl[1]/date[1]"></xsl:variable>
                <field name="date">
                  <xsl:value-of select="$image_date"/>
                </field>
                <field name="dateDisplay">
                  <xsl:call-template name="extractDate"><xsl:with-param name="date"><xsl:value-of select="$image_date"/></xsl:with-param></xsl:call-template>
                </field>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="date"/>
              </xsl:otherwise>
            </xsl:choose>
            
            <!-- Text -->
            <xsl:call-template name="text"/>
            
            <!-- uriHTML -->
            <xsl:call-template name="uriHTML">
              <xsl:with-param name="id" select="$filenamepart"/>
            </xsl:call-template>
            
            
          <xsl:call-template name="tei_template_part"><xsl:with-param name="filenamepart" select="$filenamepart"/></xsl:call-template>
          </doc>
        </xsl:otherwise>
      </xsl:choose>
    </add>
  </xsl:template>
  
  <xsl:template name="tei_template_part">
    <xsl:param name="filenamepart"/>
    
   
      
      <!-- ==============================
        resource identification (I have removed the fields that need to be treated individually and added them above -kmd)
        ===================================-->
    
      <!-- lc_previous_s -->
      
      <xsl:if test="//back//ptr[@type='prev']/@n">
        <field name="lc_previous_s">
          <xsl:text>lc.jrn.</xsl:text>
          <xsl:value-of select="//back//ptr[@type='prev']/@n"/>
        </field>
      </xsl:if>
      
      <!-- lc_next_s -->
    
      <xsl:if test="//back//ptr[@type='next']">
        <field name="lc_next_s">
          <xsl:text>lc.jrn.</xsl:text>
          <xsl:value-of select="//back//ptr[@type='next']/@n"/>
        </field>
      </xsl:if>
      
      <!-- lc_filename_s -->
      <!-- filename (because entries may be different ID) -->
      <field name="lc_filename_s"><xsl:value-of select="$filenamepart"/></field>
    
    <!-- lc_native_nation_s -->
    <xsl:for-each-group select="//name[@type='native_nation']/@key" group-by=".">
      <field name="lc_native_nation_s">
        <xsl:value-of select="current-grouping-key()"/>
      </field>
    </xsl:for-each-group>
    
    <!-- people -->
    <xsl:for-each-group select="//name[@type='person']/@key" group-by=".">
      <field name="person">
        <xsl:value-of select="current-grouping-key()"/>
      </field>
    </xsl:for-each-group>
    
    <!-- places -->
    <xsl:for-each-group select="//name[@type='place']/@key" group-by=".">
      <field name="place">
        <xsl:value-of select="current-grouping-key()"/>
      </field>
    </xsl:for-each-group>
    
    <!-- lc_index_combined_s Combined field to build the index -->
    <xsl:for-each-group select="//name" group-by="@key">
      <field name="lc_index_combined_s">
        <xsl:value-of select="current-grouping-key()"/>
        <xsl:text>||</xsl:text>
        <xsl:value-of select="@type"/>
      </field>
    </xsl:for-each-group>
    
    
    
    <!-- Begin what remains of the regular fields -->
      
      <!-- slug -->
      <xsl:call-template name="slug"/>
      
      <!-- project -->
      <xsl:call-template name="project"/>
      
      <!-- uri -->
      <xsl:call-template name="uri">
        <xsl:with-param name="id" select="$filenamepart"/>
      </xsl:call-template>
      
      <!-- uriXML -->
      <xsl:call-template name="uriXML">
        <xsl:with-param name="id" select="$filenamepart"/>
      </xsl:call-template>
      
      
      
      <!-- image_id -->
      <xsl:call-template name="image_id"/>
      
      <!-- dataType -->
      <field name="dataType"> 
        <xsl:text>tei</xsl:text>
      </field>
      
      <!-- ==============================
        Dublin Core 
        ===================================-->
      
      <!-- title and titleSort-->
      <xsl:call-template name="title"/>
      
      <!-- creator -->
      <!-- creators -->
      <xsl:call-template name="creators"/>
      
      <!-- subject -->
      <!-- subjects -->
      <!-- description -->
      <!-- publisher -->
      <xsl:call-template name="publisher"/>
      
      <!-- contributor -->
      <!-- contributors -->
      <xsl:call-template name="contributors"/>
      
      
      
      <!-- type -->
      
      <!-- format -->
      <xsl:call-template name="format"/>
      
      <!-- medium -->
      <!-- extent -->
      
      <!-- language -->
      <!-- relation -->
      <!-- coverage -->
      <!-- source -->
      <xsl:call-template name="source"/>
      
      <!-- rightsHolder -->
      <xsl:call-template name="rightsHolder"/>
      
      <!-- rights -->
      <!-- rightsURI -->
      <xsl:call-template name="rightsURI"/>
      
      <!-- ==============================
        Other elements 
        ===================================-->
      
      <!-- principalInvestigator -->
      <!-- principalInvestigators -->
      <xsl:call-template name="investigators"/>
      
      <!-- place -->
      <!-- placeName -->
      
      <!-- recipient -->
      <!-- recipients -->
      <xsl:call-template name="recipients"/>
      
      
      <!-- ==============================
        CDRH specific 
        ===================================-->
      
      <!-- category -->
      <xsl:call-template name="category"/>
      
      <!-- subCategory -->
      <xsl:call-template name="subCategory"/>        
      
      <!-- topic -->
      <xsl:call-template name="topic"/>
      
      <!-- keywords -->
      <xsl:call-template name="keywords"/>
    
    <!-- People and places handled differently above -->
      
      <!-- people -->
      <!--<xsl:call-template name="people"/>-->
      
      <!-- places -->
      <!--<xsl:call-template name="places"/>-->
      
      <!-- works -->
      <xsl:call-template name="works"/>
      
      
      
      <!-- fig_location -->
      <xsl:call-template name="fig_location"/>
      
      
      <!-- ==============================
        Project specific 
        ===================================-->
      
      <!-- extra fields -->
      <xsl:call-template name="extras"/>
      <!-- because you really need some fancy field
               with an underscore like planet_class_s -->
    
    
  </xsl:template>
  
  
  
  
  
  

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


  <!-- Uncomment this to prevent personography behavior -->
  <!-- <xsl:template name="personography"/> -->

  <!-- Uncomment this and fill it in with your own fields
       this will not affect the personography solr entries -->
  <!-- <xsl:template name="extras">
    <field name="new_field_s">Your thing here</field>
  </xsl:template> -->
</xsl:stylesheet>
