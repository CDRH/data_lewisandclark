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
  <!--                            OVERRIDES    - individual fields                             -->
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
  
  
  <!-- If journal, call tei template twice? -->
  
  <xsl:template name="tei_template" exclude-result-prefixes="#all">
    <xsl:param name="filenamepart"/>
    
    <add>
      <xsl:choose>
        <xsl:when test="starts-with($filenamepart,'lc.jrn')">
          <xsl:for-each select="//div[@type='entry']">
            <doc>
              <!-- id -->
              <xsl:call-template name="id">
                <xsl:with-param name="id" select="@xml:id"/>
              </xsl:call-template>
              
              <xsl:call-template name="tei_template_part"><xsl:with-param name="filenamepart" select="$filenamepart"/></xsl:call-template>
            </doc>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <doc>
            <!-- id -->
            <xsl:call-template name="id">
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
        resource identification 
        ===================================-->
      
      <!-- lc_filename_s -->
      <!-- filename (because entries may be different ID) -->
      <field name="lc_filename_s"><xsl:value-of select="$filenamepart"/></field>
      
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
      
      <!-- uriHTML -->
      <xsl:call-template name="uriHTML">
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
      
      <!-- date and dateDisplay-->
      <xsl:call-template name="date"/>
      
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
      
      <!-- people -->
      <xsl:call-template name="people"/>
      
      <!-- places -->
      <xsl:call-template name="places"/>
      
      <!-- works -->
      <xsl:call-template name="works"/>
      
      <!-- text -->
      <!--        <xsl:call-template name="text"/>-->
      
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
