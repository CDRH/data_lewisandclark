<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all">

  <!-- ==================================================================== -->
  <!--                               IMPORTS                                -->
  <!-- ==================================================================== -->

  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"></xsl:import>
  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/tei_personography.xsl"></xsl:import>
  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/cdrh_tei.xsl"></xsl:import>
  <!-- If this file is living in a projects directory, the paths will be
       ../../../scripts/xslt/cdrh_to_solr/lib/common.xsl -->

  <xsl:output indent="yes" omit-xml-declaration="yes"></xsl:output>

  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <!-- Defined in project config files -->
  <xsl:param name="fig_location"></xsl:param>
  <!-- url for figures -->
  <xsl:param name="file_location"></xsl:param>
  <!-- url for tei files -->
  <xsl:param name="figures"></xsl:param>
  <!-- boolean for if figs should be displayed (not for this script, for html script) -->
  <xsl:param name="fw"></xsl:param>
  <!-- boolean for html not for this script -->
  <xsl:param name="pb"></xsl:param>
  <!-- boolean for page breaks in html, not this script -->
  <xsl:param name="project"></xsl:param>
  <!-- longer name of project -->
  <xsl:param name="slug"></xsl:param>
  <!-- slug of project -->
  <xsl:param name="site_url"></xsl:param>

  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.jrn.'))"></xsl:value-of>
  </xsl:variable>


  <!-- ==================================================================== -->
  <!--              OVERRIDES    - individual fields                        -->
  <!-- ==================================================================== -->
  
  <!-- ========== uriXML ========== -->
  
  <xsl:template name="uriXML">
    <xsl:param name="id"/>
    <field name="uriXML">
      <xsl:value-of select="$file_location"/>
      <xsl:text>data/</xsl:text>
      <xsl:value-of select="$slug"/>
      <xsl:text>/tei/</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>.xml</xsl:text>
    </field>
  </xsl:template>
  
  <!-- ========== uriHTML ========== -->
  
  <xsl:template name="uriHTML">
    <xsl:param name="id"/>
    <field name="uriHTML">
      <xsl:value-of select="$file_location"/>
      <xsl:text>data/</xsl:text>
      <xsl:value-of select="$slug"/>
      <xsl:text>/html-generated/</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>.txt</xsl:text>
    </field>
  </xsl:template>
  


  <!-- ========== title ========== -->
  <xsl:template name="title">
    <xsl:param name="type"></xsl:param>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when
          test="
            normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type = 'main']) =
            'The Journals of the Lewis and Clark Expedition Online'">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type = 'sub'][1]"
          ></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
            select="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type = 'main'][1])"></xsl:value-of>
          <xsl:text> </xsl:text>
          <xsl:value-of
            select="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type = 'sub'][1])"
          ></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$type = 'entry'">
        <xsl:text> - </xsl:text>
        <xsl:variable name="author">
          <xsl:value-of select="sp/@who"></xsl:value-of>
        </xsl:variable>
        <!-- Call template which will deal with special cases -->
        <xsl:call-template name="set_author">
          <xsl:with-param name="who" select="$author"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <field name="title">
      <xsl:value-of select="normalize-space($title)"></xsl:value-of>
    </field>

    <field name="titleSort">
      <xsl:call-template name="normalize_name">
        <xsl:with-param name="string">
          <xsl:value-of select="$title"></xsl:value-of>
        </xsl:with-param>
      </xsl:call-template>
    </field>
  </xsl:template>

  <!-- ========== source ========== -->

  <xsl:template name="source">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[1] != ''">
      <field name="source">
        <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[1])"
        ></xsl:value-of>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- ========== name ========== -->

  <xsl:template match="name">
    <xsl:apply-templates></xsl:apply-templates>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@key"></xsl:value-of>
    <xsl:text>) </xsl:text>
  </xsl:template>
  
  <!-- ========== set author ============= -->
  
  <xsl:template name="set_author">
    <xsl:param name="who"/>
    <xsl:choose>
      <xsl:when test="$who = ''">
        <xsl:text>Unknown</xsl:text>
      </xsl:when>
      <xsl:when test="$who = 'mlwc'">
        <xsl:text>Clark, William; Lewis, Meriwether</xsl:text>
      </xsl:when>
      <xsl:when test="$who = 'mlwcunk'">
        <xsl:text>Clark, William; Lewis, Meriwether; Unknown</xsl:text>
      </xsl:when>
      <xsl:when test="$who = 'unk'">
        <xsl:text>Unknown</xsl:text>
      </xsl:when>
      <xsl:when test="$who = 'wcjw'">
        <xsl:text>Clark, William; Whitehouse, Joseph</xsl:text>
      </xsl:when>
      <xsl:when test="$who = 'jv'">
        <xsl:text>Vaughan</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//author[@xml:id = $who][1]/@n"></xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  

  <!-- ==================================================================== -->
  <!--                          Doc setup                                   -->
  <!-- ==================================================================== -->
  
  <!-- This template is used to create named entity facets from the entries and from the footnotes -->
  <xsl:template name="named_entity_entry">
    <xsl:param name="type"/>
    <xsl:param name="key"/>
    <xsl:variable name="type_pluralized">
      <xsl:choose>
        <xsl:when test="$type = 'native_nation'"><xsl:text>lc_native_nation_ss</xsl:text></xsl:when>
        <xsl:when test="$type = 'place'"><xsl:text>places</xsl:text></xsl:when>
        <xsl:when test="$type = 'person'"><xsl:text>people</xsl:text></xsl:when>
      </xsl:choose>
    </xsl:variable>
    
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="$type_pluralized"/>
        </xsl:attribute>
        <xsl:value-of select="$key"></xsl:value-of>
      </field>
      <field name="lc_index_combined_ss">
        <xsl:value-of select="$key"></xsl:value-of>
        <xsl:text>||</xsl:text>
        <xsl:value-of select="$type"></xsl:value-of>
      </field>
  </xsl:template>

  <xsl:template name="tei_template" exclude-result-prefixes="#all">
    <xsl:param name="filenamepart"></xsl:param>

    <add>
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                      Journal Files
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
      <!-- if journal file and has divs with xml:id's -->
      <xsl:if test="starts-with($filenamepart, 'lc.jrn.1') and //div[@xml:id]">
        <!-- repeat for each entry -->
        <xsl:for-each select="//div[@xml:id]">
          <doc>
            
            <!-- ========== id ========== -->
            
            <xsl:call-template name="id">
              <xsl:with-param name="id" select="@xml:id"></xsl:with-param>
            </xsl:call-template>

            <!-- ========== title and titleSort ========== -->
            <xsl:call-template name="title">
              <xsl:with-param name="type">entry</xsl:with-param>
            </xsl:call-template>

            <!-- ========== source ========== -->
            <field name="source">
              <xsl:variable name="author">
                <xsl:value-of select="sp/@who"></xsl:value-of>
              </xsl:variable>
              <xsl:choose>
                <!-- When author choose the source title that matches bibl containing author/@xml:id -->
                <xsl:when test="sp/@who = ml or 
                  sp/@who = wc or 
                  sp/@who = jo or 
                  sp/@who = pg or 
                  sp/@who = jw or 
                  sp/@who = cf">
                  <xsl:value-of select="//author[@xml:id = $author][1]/parent::*/title[1]"
                  ></xsl:value-of>
                </xsl:when>
                <!-- Otherwise use first bibl -->
                <xsl:otherwise>
                  <xsl:value-of
                    select="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1]/title[1]"
                  ></xsl:value-of>
                </xsl:otherwise>
              </xsl:choose>
            </field>

            <!-- ========== creator/creators ========== -->
            <xsl:variable name="author">
              <xsl:value-of select="sp/@who"></xsl:value-of>
            </xsl:variable>
            <xsl:variable name="author_expanded">
              <!-- Call template which will deal with special cases -->
              <xsl:call-template name="set_author">
                <xsl:with-param name="who" select="$author"/>
              </xsl:call-template>
            </xsl:variable>
            
            <field name="creator">
              <xsl:value-of select="$author_expanded"/>
            </field>
            <xsl:for-each select="tokenize($author_expanded,'; ')">
              <field name="creators">
                <xsl:value-of select="."/>
              </field>
            </xsl:for-each>

            <!-- ========== lc_searchtype_s ========== -->
            
            <field name="lc_searchtype_s">journal_entry</field>

            <!-- ========== lc_geo_coordinates_p ========== -->

            <xsl:variable name="georef" select="@n"></xsl:variable>
            <xsl:variable name="geo">
              <xsl:value-of
                select="/TEI/teiHeader[1]/encodingDesc[1]/geoDecl[@xml:id = $georef]/geo"
              ></xsl:value-of>
            </xsl:variable>
            <xsl:if test="normalize-space($geo) != ''">
              <field name="lc_geo_coordinates_p">
                <xsl:value-of select="translate($geo, ' ', ',')"></xsl:value-of>
              </field>
            </xsl:if>
            
            <!-- ========== lc_city_ss lc_county_ss lc_state_ss ========== -->

            <xsl:if test="normalize-space(//geoDecl[1]/geo) != ''">
              <xsl:for-each select="doc('tei_data_ingest_helpers/journals_geo_info.xml')/root/row"
                xpath-default-namespace="">
                <xsl:if test="@date = $date_match">
                  <field name="lc_city_ss">
                    <xsl:value-of select="City"></xsl:value-of>
                  </field>
                  <field name="lc_county_ss">
                    <xsl:value-of select="County"></xsl:value-of>
                  </field>
                  <field name="lc_state_ss">
                    <xsl:value-of select="stateCode"></xsl:value-of>
                  </field>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
            
            <!-- ======= INDEX ======= -->

            
             <xsl:for-each select=".//ref">
              <xsl:variable name="target" select="@target"/>
              <xsl:variable name="reference"><xsl:copy-of select="//back/div[@type='notes']//note[@xml:id = $target]"/></xsl:variable>
              
              <!-- KMD TODO - this is a ton of repeated code but I'm having trouble figureing out how to simplify. My problem is I can't just go a for-each-group grouped by key, because we could have a key that's a place and another that's a native nation witht he same name -->
                
                <!-- ========== lc_native_nation_ss ========== -->
                
                <xsl:for-each-group select="$reference//name[@type = 'native_nation']" group-by="normalize-space(@key)">
                  <xsl:call-template name="named_entity_entry">
                    <xsl:with-param name="type">native_nation</xsl:with-param>
                    <xsl:with-param name="key" select="current-grouping-key()"/>
                  </xsl:call-template>
                </xsl:for-each-group>
                
                <!-- ========== people ========== -->
                <xsl:for-each-group select="$reference//name[@type = 'person']" group-by="normalize-space(@key)">
                  <xsl:call-template name="named_entity_entry">
                    <xsl:with-param name="type">person</xsl:with-param>
                    <xsl:with-param name="key" select="current-grouping-key()"/>
                  </xsl:call-template>
                </xsl:for-each-group>
                
                <!-- ========== places ========== -->
                
                <xsl:for-each-group select="$reference//name[@type = 'place']" group-by="normalize-space(@key)">
                  <xsl:call-template name="named_entity_entry">
                    <xsl:with-param name="type">place</xsl:with-param>
                    <xsl:with-param name="key" select="current-grouping-key()"/>
                  </xsl:call-template>
                </xsl:for-each-group>
                <!-- END repeated code -->
              
              
             
            </xsl:for-each>
            
          
            
            <!-- ========== lc_native_nation_ss ========== -->

            <xsl:for-each-group select=".//name[@type = 'native_nation']" group-by="normalize-space(@key)">
              <xsl:call-template name="named_entity_entry">
                <xsl:with-param name="type">native_nation</xsl:with-param>
                <xsl:with-param name="key" select="current-grouping-key()"/>
              </xsl:call-template>
            </xsl:for-each-group>
            
            <!-- ========== people ========== -->
            <xsl:for-each-group select=".//name[@type = 'person']" group-by="normalize-space(@key)">
              <xsl:call-template name="named_entity_entry">
                <xsl:with-param name="type">person</xsl:with-param>
                <xsl:with-param name="key" select="current-grouping-key()"/>
              </xsl:call-template>
            </xsl:for-each-group>
            
            <!-- ========== places ========== -->
            
            <xsl:for-each-group select=".//name[@type = 'place']" group-by="normalize-space(@key)">
              <xsl:call-template name="named_entity_entry">
                <xsl:with-param name="type">place</xsl:with-param>
                <xsl:with-param name="key" select="current-grouping-key()"/>
              </xsl:call-template>
            </xsl:for-each-group>
            
            <!-- ========== text ========== -->
            
            <field name="text">
                <xsl:apply-templates select="."/>
                <!-- grab refs for searching -->
                <xsl:for-each select=".//ref">
                  <xsl:variable name="target" select="@target"/>
                  <xsl:apply-templates select="/TEI/text/back//note[@xml:id=$target]"/><xsl:text>  </xsl:text>
                </xsl:for-each>
              </field>
            
     

            <!-- Call template with shared fields -->
            <xsl:call-template name="tei_template_part">
              <xsl:with-param name="filenamepart" select="$filenamepart"></xsl:with-param>
            </xsl:call-template>  
          </doc>
        </xsl:for-each>
      </xsl:if><!-- END if journal file and has divs with xml:id's -->


      <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                      Non Journal Entry files
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

      <doc>
        
        <!-- ========== id ========== -->
        
        <xsl:call-template name="id">
          <xsl:with-param name="id" select="$filenamepart"></xsl:with-param>
        </xsl:call-template>

        <!-- ========== title and titleSort ========== -->
        
        <xsl:call-template name="title">
          <xsl:with-param name="type">all</xsl:with-param>
        </xsl:call-template>

        <!-- ========== source ========== -->

        <xsl:choose>
          <xsl:when test="starts-with($filenamepart, 'lc.jrn.18')">
            <field name="source">
              <xsl:text>The Journals of the Lewis and Clark Expedition</xsl:text>
            </field>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="source"></xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <!-- ========== lc_searchtype_s ========== -->
        <field name="lc_searchtype_s">
          <xsl:choose>
            <xsl:when test="starts-with($filenamepart, 'lc.jrn.18')">journal_file</xsl:when>
            <xsl:when test="starts-with($filenamepart, 'lc.jrn')">journal_sup</xsl:when>
            <xsl:otherwise>non_journal</xsl:otherwise>
          </xsl:choose>
        </field>

        <!-- ========== creator and creators ========== -->
        
        <xsl:variable name="author_list">
          <xsl:for-each select="//div[@xml:id]">
            <xsl:variable name="author_who"><xsl:value-of select="sp/@who"/></xsl:variable>
            <!-- Call template which will deal with special cases -->
            <xsl:call-template name="set_author">
              <xsl:with-param name="who" select="$author_who"/>
            </xsl:call-template>
            <xsl:if test="position() != last()">; </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="author_list_normalized">
          <xsl:for-each-group select="tokenize($author_list,'; ')" group-by=".">
            <xsl:sort select="."/>
            <xsl:value-of select="current-grouping-key()"/>
            <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
          </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:choose>
          <!-- When a journal, choose creator based on author/@xml:id -->
          <xsl:when test="starts-with($filenamepart, 'lc.jrn.18')">
            <xsl:for-each select="tokenize($author_list_normalized,'; ')">
              <field name="creators"><xsl:value-of select="."/></field>
            </xsl:for-each>
            <field name="creator"><xsl:value-of select="$author_list_normalized"/></field>

          </xsl:when>
          <!-- When not a journal, choose creator as normal -->
          <xsl:otherwise>
            <xsl:call-template name="creators"></xsl:call-template>
          </xsl:otherwise>
        </xsl:choose><!-- /creator/creators -->
        
        <!-- Only index Journal files for regularized names. 
         After cleanup, we can remove this if and index all. -->
        
        <xsl:if test="normalize-space(//keywords[@n='category']/term[1]) = 'Journals'">
          <!-- ========== lc_native_nation_ss ========== -->
          
          <xsl:for-each-group select="/TEI/text//name[@type = 'native_nation']/@key" group-by="normalize-space(.)">
            <field name="lc_native_nation_ss">
              <xsl:value-of select="normalize-space(current-grouping-key())"></xsl:value-of>
            </field>
          </xsl:for-each-group>
          
          <!-- ========== people ========== -->
          
          <xsl:for-each-group select="/TEI/text//name[@type = 'person']/@key" group-by="normalize-space(.)">
            <field name="people">
              <xsl:value-of select="normalize-space(current-grouping-key())"></xsl:value-of>
            </field>
          </xsl:for-each-group>
          
          <!-- ========== places ========== -->
          
          <xsl:for-each-group select="/TEI/text//name[@type = 'place']/@key" group-by="normalize-space(.)">
            <field name="places">
              <xsl:value-of select="normalize-space(current-grouping-key())"></xsl:value-of>
            </field>
          </xsl:for-each-group>
          
          <!-- ========== lc_index_combined_ss ========== -->
          <!--  Combined field to build the index -->
          
          <xsl:for-each-group select="/TEI/text//name" group-by="normalize-space(@key)">
            <field name="lc_index_combined_ss">
              <xsl:value-of select="normalize-space(current-grouping-key())"></xsl:value-of>
              <xsl:text>||</xsl:text>
              <xsl:value-of select="@type"></xsl:value-of>
            </field>
          </xsl:for-each-group>
          
        </xsl:if>

        <!-- ========== text ========== -->
        <!-- call when not a journal file, all that text will go into entries -->
        <xsl:choose>
          <xsl:when test="not(starts-with($filenamepart, 'lc.jrn'))">
            <xsl:call-template name="text"></xsl:call-template>
          </xsl:when>
        </xsl:choose>

        <!-- ========== uniHTML ========== -->
        <!-- call default -->
        <xsl:call-template name="uriHTML">
          <xsl:with-param name="id" select="$filenamepart"></xsl:with-param>
        </xsl:call-template>

        <!-- Call template with shared fields -->
        <xsl:call-template name="tei_template_part">
          <xsl:with-param name="filenamepart" select="$filenamepart"></xsl:with-param>
        </xsl:call-template> 
      </doc>


    </add>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                      Combined
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template name="tei_template_part">
    <xsl:param name="filenamepart"></xsl:param>

   
    <!-- ========== date and dateDisplay ========== -->
    <xsl:variable name="dateNotAfter">
      <xsl:choose>
        <xsl:when test="/TEI/text[1]/body[1]/head[@type = 'date']/date[1]/@when">
          <xsl:value-of select="/TEI/text[1]/body[1]/head[@type = 'date']/date[1]/@when"
          ></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/TEI/text[1]/body[1]/head[@type = 'date']/date[1]/@notAfter"
          ></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="dateNotBefore">
      <xsl:choose>
        <xsl:when test="/TEI/text[1]/body[1]/head[@type = 'date']/date[1]/@notBefore">
          <xsl:value-of select="/TEI/text[1]/body[1]/head[@type = 'date']/date[1]/@notBefore"
          ></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$dateNotAfter"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <field name="date">
      <xsl:value-of select="$dateNotAfter"></xsl:value-of>
    </field>
    
    <!-- ========== lc_timeline_place_s ========== -->
    
    <!-- grab order from separate file date_numbering.xml -->
    <xsl:for-each select="doc('tei_data_ingest_helpers/date_numbering.xml')/root/date"
      xpath-default-namespace="">
      <xsl:if test=". = $dateNotAfter">
        <field name="lc_timeline_place_s">
          
          <!-- following rounds the place in the timeline based on 1100 total days -->
          <xsl:value-of select="format-number(((@id div 1100) * 100), '#.00')"></xsl:value-of>
        </field>
      </xsl:if>
    </xsl:for-each>
    
    
    <field name="dateDisplay">
      <xsl:choose>
        <xsl:when test="/TEI/text/body/head/date and (/TEI/text/body/head/date != '')">
          <xsl:value-of select="normalize-space(/TEI/text/body/head/date)"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="extractDate">
            <xsl:with-param name="date">
              <xsl:value-of select="$dateNotAfter"></xsl:value-of>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </field>
    
    <!-- ========== lc_dateNotBefore_s and lc_dateNotAfter_s ========== -->

    <xsl:if test="$dateNotAfter != ''">
      <field name="lc_dateNotBefore_s">
        <xsl:value-of select="$dateNotBefore"></xsl:value-of>
      </field>
      <field name="lc_dateNotAfter_s">
        <xsl:value-of select="$dateNotAfter"></xsl:value-of>
      </field>
    </xsl:if>

    <!-- ========== lc_previous_s and lc_next_s ========== -->

    <xsl:if test="//back//ptr[@type = 'prev']/@n">
      <field name="lc_previous_s">
        <xsl:text>lc.jrn.</xsl:text>
        <xsl:value-of select="//back//ptr[@type = 'prev']/@n"></xsl:value-of>
      </field>
    </xsl:if>

    <xsl:if test="//back//ptr[@type = 'next']">
      <field name="lc_next_s">
        <xsl:text>lc.jrn.</xsl:text>
        <xsl:value-of select="//back//ptr[@type = 'next']/@n"></xsl:value-of>
      </field>
    </xsl:if>

    <!-- ========== lc_filename_s ========== -->
    <!-- filename (because entries may be different ID) -->
    <field name="lc_filename_s">
      <xsl:value-of select="$filenamepart"></xsl:value-of>
    </field>

  

    <!-- Begin what remains of the regular fields -->

    <!-- ========== slug ========== -->
    
    <xsl:call-template name="slug"/>

    <!-- ========== project ========== -->
    
    <xsl:call-template name="project"/>

    <!-- ========== uri ========== -->
    
    <xsl:call-template name="uri">
      <xsl:with-param name="id" select="$filenamepart"/>
    </xsl:call-template>

    <!-- ========== uriXML ========== -->
    
    <xsl:call-template name="uriXML">
      <xsl:with-param name="id" select="$filenamepart"/>
    </xsl:call-template>

    <!-- ========== image_id ========== -->
    
    <xsl:call-template name="image_id"/>

    <!-- ========== dataType ========== -->
    
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
    <xsl:call-template name="publisher"></xsl:call-template>

    <!-- contributor -->
    <!-- contributors -->
    <xsl:call-template name="contributors"></xsl:call-template>



    <!-- type -->

    <!-- format -->
    <xsl:call-template name="format"></xsl:call-template>

    <!-- medium -->
    <!-- extent -->

    <!-- language -->
    <!-- relation -->
    <!-- coverage -->


    <!-- rightsHolder -->
    <xsl:call-template name="rightsHolder"></xsl:call-template>

    <!-- rights -->
    <!-- rightsURI -->
    <xsl:call-template name="rightsURI"></xsl:call-template>

    <!-- ==============================
        Other elements 
        ===================================-->

    <!-- principalInvestigator -->
    <!-- principalInvestigators -->
    <xsl:call-template name="investigators"></xsl:call-template>

    <!-- place -->
    <!-- placeName -->

    <!-- recipient -->
    <!-- recipients -->
    <xsl:call-template name="recipients"></xsl:call-template>


    <!-- ==============================
        CDRH specific 
        ===================================-->

    <!-- category -->
    <xsl:call-template name="category"></xsl:call-template>

    <!-- subCategory -->
    <xsl:call-template name="subCategory"></xsl:call-template>

    <!-- topic -->
    <xsl:call-template name="topic"></xsl:call-template>

    <!-- keywords -->
    <xsl:call-template name="keywords"></xsl:call-template>

    <!-- People and places handled differently above -->

    <!-- people -->
    <!--<xsl:call-template name="people"/>-->

    <!-- places -->
    <!--<xsl:call-template name="places"/>-->

    <!-- works -->
    <xsl:call-template name="works"></xsl:call-template>



    <!-- fig_location -->
    <xsl:call-template name="fig_location"></xsl:call-template>


    <!-- ==============================
        Project specific 
        ===================================-->

    <!-- extra fields -->
    <xsl:call-template name="extras"></xsl:call-template>
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
