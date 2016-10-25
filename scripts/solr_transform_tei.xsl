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
  
  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.jrn.'))"></xsl:value-of>
  </xsl:variable>
        

  <!-- ==================================================================== -->
  <!--              OVERRIDES    - individual fields                        -->
  <!-- ==================================================================== -->
  
  <xsl:template name="title">
    <xsl:param name="type"/>
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
      <xsl:if test="$type = 'entry'">
        <xsl:text> - </xsl:text>
        <xsl:variable name="author"><xsl:value-of select="sp/@who"/></xsl:variable>
            <xsl:value-of select="//author[@xml:id=$author][1]"/>
      </xsl:if>
    </xsl:variable>
    
    <field name="title">
      <xsl:value-of select="normalize-space($title)"/>
    </field>
    
    <field name="titleSort">
      <xsl:call-template name="normalize_name">
        <xsl:with-param name="string">
          <xsl:value-of select="$title"/>
        </xsl:with-param>
      </xsl:call-template>
    </field>
  </xsl:template>
  

  
  <!-- ========== source ========== -->
 
  <xsl:template name="source">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[1] != ''">
      <field name="source">
        <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[1])"/>
      </field>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="name">
    <xsl:apply-templates/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@key"/>
    <xsl:text>) </xsl:text>
  </xsl:template>
  
  <!-- ==================================================================== -->
  <!--                            OVERRIDES   - Doc setup                              -->
  <!-- ==================================================================== -->

  <xsl:template name="journal_entry">
    
    
  </xsl:template>
  
 
  
  <xsl:template name="tei_template" exclude-result-prefixes="#all">
    <xsl:param name="filenamepart"/>
    
    <add>
    
        <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          Journal Files
          (In addition to below)
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
        <xsl:if test="starts-with($filenamepart,'lc.jrn.1') and //div[@xml:id]">
          <xsl:for-each select="//div[@xml:id]">
            <doc>
              <!-- id -->
              <xsl:call-template name="id">
                <xsl:with-param name="id" select="@xml:id"/>
              </xsl:call-template>
              
              <!-- title and titleSort-->
              <xsl:call-template name="title"><xsl:with-param name="type">entry</xsl:with-param></xsl:call-template>
              
              <!-- source -->
              <field name="source">
                    <xsl:variable name="author"><xsl:value-of select="sp/@who"/></xsl:variable>
                <xsl:choose>
                  <!-- When author choose the source title that matches bibl containing author/@xml:id -->
                  <xsl:when test="sp/@who">
                    <xsl:value-of select="//author[@xml:id=$author][1]/parent::*/title[1]"/>
                  </xsl:when>
                  <!-- Otherwise use first bibl -->
                  <xsl:otherwise>
                    <xsl:value-of select="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1]/title[1]"/>
                  </xsl:otherwise>
                </xsl:choose>
              </field>
              
              
              
              
              <!-- creator/creators -->
              <xsl:variable name="author"><xsl:value-of select="sp/@who"/></xsl:variable>
              
              <xsl:if test="sp/@who">
                <field name="creators">
                  <xsl:value-of select="//author[@xml:id=$author][1]"/>
                </field>
                <field name="creator">
                  <xsl:value-of select="//author[@xml:id=$author][1]"/>
                </field>
                <field name="lc_who_s">
                  <xsl:value-of select="$author"/>
                </field>
              </xsl:if>
              
              
              <!-- lc_searchtype_s Two types: all and journalfile. The journalfile fields are the combined files with all entries. -->
         <!-- yyy -->     <field name="lc_searchtype_s">journal_entry</field>
              
              
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

              <!-- lc_city_ss lc_county_ss lc_state_ss -->
              <xsl:if test="normalize-space(//geoDecl[1]/geo) != ''">
              <xsl:for-each select="doc('data_ingest_helpers/journals_geo_info.xml')/root/row" xpath-default-namespace="">
                <xsl:if test="@date = $date_match">
                  <field name="lc_city_ss">
                    <xsl:value-of select="City"/>
                  </field>
                  <field name="lc_county_ss">
                    <xsl:value-of select="County"/>
                  </field>
                  <field name="lc_state_ss">
                    <xsl:value-of select="stateCode"/>
                  </field>
                </xsl:if>
               
                
              </xsl:for-each> 
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
              
              <!-- Call template with shared fields -->
              <xsl:call-template name="tei_template_part"><xsl:with-param name="filenamepart" select="$filenamepart"/></xsl:call-template>
            </doc>
          </xsl:for-each>
        </xsl:if>
      
      
        <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~
          All files 
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
      
          <doc>
            <!-- id -->
            <xsl:call-template name="id">
              <xsl:with-param name="id" select="$filenamepart"/>
            </xsl:call-template>
            
            <!-- title and titleSort-->
            <xsl:call-template name="title"><xsl:with-param name="type">all</xsl:with-param></xsl:call-template>
            
            <!-- source -->
            
            
            
              <xsl:choose>
                <xsl:when test="starts-with($filenamepart,'lc.jrn.18')">
                  <field name="source">
                  <xsl:text>The Journals of the Lewis and Clark Expedition</xsl:text>
                  </field>
                </xsl:when>
                <xsl:otherwise><xsl:call-template name="source"/></xsl:otherwise>       
              </xsl:choose>
            
            
            <!-- lc_searchtype_s Two types: all and journalfile. The journalfile fields are the combined files with all entries. -->
            <field name="lc_searchtype_s">
              <xsl:choose>
                <xsl:when test="starts-with($filenamepart,'lc.jrn.18')">journal_file</xsl:when>
                <xsl:when test="starts-with($filenamepart,'lc.jrn')">journal_sup</xsl:when>
                <xsl:otherwise>non_journal</xsl:otherwise>       
            </xsl:choose>
            </field>
            
            <!-- creator -->
            <!-- creators -->
            
            
            <xsl:choose>
              <!-- When a journal, choose creator based on author/@xml:id -->
              <xsl:when test="starts-with($filenamepart,'lc.jrn.18')">
                <xsl:for-each select="//div[@type='entry']">
                  <xsl:variable name="author"><xsl:value-of select="sp/@who"/></xsl:variable>
                  <field name="creators">
                    <xsl:value-of select="//author[@xml:id=$author][1]"/>
                  </field>
                </xsl:for-each>
                
                <field name="creator">
                  <xsl:for-each select="//div[@type='entry']">
                    <xsl:variable name="author"><xsl:value-of select="sp/@who"/></xsl:variable>
                      <xsl:value-of select="//author[@xml:id=$author][1]"/>
                    <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                  </xsl:for-each>
                </field>
                
              </xsl:when>
              <!-- When not a journal, choose creator as normal -->
              <xsl:otherwise><xsl:call-template name="creators"/></xsl:otherwise>       
            </xsl:choose>
            
            
            <!-- Text -->
            <xsl:choose>
              <xsl:when test="not(starts-with($filenamepart,'lc.jrn'))"><xsl:call-template name="text"/></xsl:when>
            </xsl:choose>
            
            
            <!-- uriHTML -->
            <xsl:call-template name="uriHTML">
              <xsl:with-param name="id" select="$filenamepart"/>
            </xsl:call-template>
            
            <!-- Call template with shared fields -->
          <xsl:call-template name="tei_template_part"><xsl:with-param name="filenamepart" select="$filenamepart"/></xsl:call-template>
          </doc>
        
      
    </add>
  </xsl:template>
  
  <xsl:template name="tei_template_part">
    <xsl:param name="filenamepart"/>
    
    <!--lc_timeline_place_s-->
    
    <!-- @notAfter or @when -->
    
    <xsl:variable name="entry_date">
      <xsl:choose>
        <xsl:when test="parent::*/head/date/@notAfter">
          <xsl:value-of select="parent::*/head/date/@notAfter"/>
        </xsl:when>
        <xsl:when test="parent::*/head/date/@when">
          <xsl:value-of select="parent::*/head/date/@when"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$date_match"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:for-each select="doc('data_ingest_helpers/date_numbering.xml')/root/date" xpath-default-namespace="">
      <xsl:if test=". = $entry_date">
        <field name="lc_timeline_place_s"><xsl:value-of select="@id"/></field>
      </xsl:if>
    </xsl:for-each>
    
    
    <!-- date and dateDisplay-->
    <xsl:variable name="dateNotAfter">
      <xsl:choose>
        <xsl:when test="/TEI/text[1]/body[1]/head[@type='date']/date[1]/@when"><xsl:value-of select="/TEI/text[1]/body[1]/head[@type='date']/date[1]/@when"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="/TEI/text[1]/body[1]/head[@type='date']/date[1]/@notAfter"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dateNotBefore">
      <xsl:choose>
        <xsl:when test="/TEI/text[1]/body[1]/head[@type='date']/date[1]/@notBefore"><xsl:value-of select="/TEI/text[1]/body[1]/head[@type='date']/date[1]/@notBefore"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$dateNotAfter"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <field name="date">
      <xsl:value-of select="$dateNotAfter"/>
    </field>
    <field name="dateDisplay">
      <xsl:choose>
        <xsl:when test="/TEI/text/body/head/date and (/TEI/text/body/head/date != '')">
          <xsl:value-of select="normalize-space(/TEI/text/body/head/date)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="extractDate">
            <xsl:with-param name="date"><xsl:value-of select="$dateNotAfter"/></xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </field>
    
    <xsl:if test="$dateNotAfter != ''">
    <field name="lc_dateNotBefore_s">
      <xsl:value-of select="$dateNotBefore"/>
    </field>
    <field name="lc_dateNotAfter_s">
      <xsl:value-of select="$dateNotAfter"/>
    </field>
    </xsl:if>
    
    
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
    
    <!-- lc_native_nation_ss -->
    <xsl:for-each-group select="//name[@type='native_nation']/@key" group-by=".">
      <field name="lc_native_nation_ss">
        <xsl:value-of select="current-grouping-key()"/>
      </field>
    </xsl:for-each-group>
    
    <!-- people -->
    <xsl:for-each-group select="//name[@type='person']/@key" group-by=".">
      <field name="people">
        <xsl:value-of select="current-grouping-key()"/>
      </field>
    </xsl:for-each-group>
    
    <!-- places -->
    <xsl:for-each-group select="//name[@type='place']/@key" group-by=".">
      <field name="places">
        <xsl:value-of select="current-grouping-key()"/>
      </field>
    </xsl:for-each-group>
    
    <!-- lc_index_combined_ss Combined field to build the index -->
    <xsl:for-each-group select="//name" group-by="@key">
      <field name="lc_index_combined_ss">
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
