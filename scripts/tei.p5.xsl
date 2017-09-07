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

  <xsl:import href="../../../scripts/xslt/cdrh_to_html/lib/html_formatting.xsl"/>
  <xsl:import href="../../../scripts/xslt/cdrh_to_html/lib/personography_encyclopedia.xsl"/>
  <xsl:import href="../../../scripts/xslt/cdrh_to_html/lib/cdrh.xsl"/>
<!-- If this file is living in a projects directory, the paths will be
     ../../../scripts/xslt/cdrh_tei_to_html/lib/html_formatting.xsl -->

<!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
<xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>


<!-- ==================================================================== -->
<!--                           PARAMETERS                                 -->
<!-- ==================================================================== -->

<xsl:param name="site_url"/>     <!-- the site url (http://codyarchive.org) -->
<xsl:param name="fig_location"/> <!-- set figure location  -->
<xsl:param name="file_location"/>
<!--<xsl:param name="audio_root_url"/>-->


<!-- ==================================================================== -->
<!--                            OVERRIDES                                 -->
<!-- ==================================================================== -->
  

  
  
  <xsl:template match="list">
    <xsl:if test="head">
      <div class="tei_list_head"><xsl:apply-templates select="head/node()"/></div>
    </xsl:if>
    <xsl:choose>
      <!-- images are all in a list for some reason. This takes them out -->
      <xsl:when test="//keywords[@n='category']/term[1] = 'Images'">
        <!-- page title, use label when it exists or caption -->
        <h2>
        <xsl:choose>
          <xsl:when test="//list//label[1] and //list//label[1] != ''"><xsl:value-of select="//list//label[1]"/></xsl:when>
          <xsl:when test="//list//caption[1]"><xsl:value-of select="//list//caption[1]"/></xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
        </h2>
        
        <div class="image_page">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:attribute name="class">
            <xsl:text>tei_list</xsl:text>
            <xsl:if test="@type"><xsl:text> </xsl:text><xsl:value-of select="@type"/></xsl:if>
          </xsl:attribute><xsl:apply-templates select="item"/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
  <xsl:template match="item">
    <xsl:choose>
      <xsl:when test="//keywords[@n='category']/term[1] = 'Images'"><xsl:apply-templates/></xsl:when>
      <xsl:when test="@n">
        <li>
          <xsl:value-of select="@n"/>
          <xsl:text>. </xsl:text>
          <xsl:apply-templates/>
        </li>
      </xsl:when>
      <xsl:otherwise><li><xsl:apply-templates/></li></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="title">
    <span class="tei_title"><xsl:apply-templates/></span>
  </xsl:template>
  
  <xsl:template match="bibl">
    <div class="tei_bibl"><xsl:apply-templates/></div>
  </xsl:template>
  
  <xsl:template match="lg">
    <div class="tei_lg">
      <xsl:apply-templates/>
    </div>
    
  </xsl:template>
  <xsl:template match="l">
    <xsl:apply-templates/><br></br>
  </xsl:template>
  

  
  <!-- set up the document -->
  
  <xsl:template name="book_navigation">
    <xsl:if test="/TEI/text[1]/back[1]/div[@type='file_references']">
      <div class="book_pagination">
        <xsl:for-each select="/TEI/text/back/div/list/item/ptr[@type='prev']">
          <span class="previous_link">
            <a>
              <xsl:attribute name="href">
                <!--<xsl:text>../</xsl:text>-->
                <xsl:value-of select="@n"/>
                <!--<xsl:text>/</xsl:text>-->
              </xsl:attribute>
              <xsl:text>Previous</xsl:text>
            </a></span>
        </xsl:for-each>
        
        <xsl:variable name="author_slug">
          <xsl:value-of select="substring-before(substring-after(/TEI/@xml:id, 'lc.sup.'),'.')"/>
        </xsl:variable>
        <xsl:variable name="book_id"><xsl:value-of select="$author_slug"/><xsl:text>.01</xsl:text></xsl:variable>
        
        <!-- don't show if book -->
        <xsl:if test="not(ends-with(/TEI/@xml:id,$book_id))">
        <xsl:for-each select="/TEI/text/back/div/list/item/ptr[@type='contents']">
          <xsl:if test="@n != /TEI/@xml:id">
            <span class="toc_link">
              <a>
                <xsl:attribute name="href">
                  <!--<xsl:text>../</xsl:text>-->
                  <xsl:value-of select="@n"/>
                  <!--<xsl:text>/</xsl:text>-->
                </xsl:attribute>
                <xsl:text>Contents</xsl:text>
              </a></span>
          </xsl:if>
        </xsl:for-each>
        
       
        
        <span class="entire_text_link">
          <a>
            <xsl:attribute name="href">
              <xsl:text>lc.sup.</xsl:text>
              <xsl:value-of select="$author_slug"/>
              <xsl:text>.01</xsl:text>
            </xsl:attribute>
            <xsl:text>Entire Text</xsl:text>
          </a></span>
        </xsl:if>
        <xsl:if test="ends-with(/TEI/@xml:id,$book_id)">
          <span class="back_to_book_link">
            <a>
              <xsl:attribute name="href">
                <xsl:text>lc.sup.</xsl:text>
                <xsl:value-of select="$author_slug"/>
                <xsl:text>.01.00</xsl:text>
              </xsl:attribute>
              <xsl:text>Back to Book Main Page</xsl:text>
            </a></span>
        </xsl:if>
        
        <xsl:for-each select="/TEI/text/back/div/list/item/ptr[@type='next']">
          <span class="next_link">
            <a>
              <xsl:attribute name="href">
                <!--<xsl:text>../</xsl:text>-->
                <xsl:value-of select="@n"/>
                <!--<xsl:text>/</xsl:text>-->
              </xsl:attribute>
              <xsl:text>Next</xsl:text>
            </a></span>
        </xsl:for-each>
        
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text">
    
    <!-- title -->
    <xsl:if test="//keywords[@n='subcategory']/term[1] = 'Books'">
      <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']">
        <xsl:if test=". != ''">
          <h2 class="title_main"><xsl:apply-templates/>
            
            <!-- if subtitles -->
            <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='sub']">
              <xsl:if test=". != ''">
                <xsl:text> </xsl:text><span class="title_sub"><xsl:apply-templates/></span>
              </xsl:if>
            </xsl:for-each>
          
          </h2>
        </xsl:if>
      </xsl:for-each>
      
      <div class="book_bibl">
      
      <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
        <xsl:if test=". != ''">
          <span class="title_author"><xsl:apply-templates/></span>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date[1]">
        <xsl:if test=". != ''">
          <span class="year_published"><xsl:text>©  </xsl:text><xsl:apply-templates/></span>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]">
        <xsl:if test=". != ''">
          <span class="publisher"><xsl:apply-templates/></span>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[2]">
        <xsl:if test=". != ''">
          <span class="publisher"><xsl:apply-templates/></span>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/pubPlace[1]">
        <xsl:if test=". != ''">
          <span class="pub_place"><xsl:apply-templates/></span>
        </xsl:if>
      </xsl:for-each>
        
      </div>
      
      <xsl:call-template name="book_navigation"/>
        
    </xsl:if><!-- end if book -->
    
     
    <xsl:apply-templates/>
    
    <xsl:if test="//keywords[@n='subcategory']/term[1] = 'Books'">
      <xsl:call-template name="book_navigation"/>
    </xsl:if>
    
  </xsl:template>
  
  <!-- re-matching on tbles to add the table responsive bootstrap attribute -->
  
  <xsl:template match="table">
    
    <xsl:for-each select="head">
      <xsl:apply-templates select="." mode="show"/>
    </xsl:for-each>
    <div class="table-responsive">
    <table>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
        <xsl:text> tei_table</xsl:text> 
        <xsl:if test="@n"><xsl:text> </xsl:text><xsl:value-of select="@n"/></xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </table>
    </div>
  </xsl:template>
  
  <!-- Table Cell -->
  
  <xsl:template match="cell">
    <td>
      <xsl:if test="@rows"><xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute></xsl:if>
      <xsl:if test="@cols"><xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute></xsl:if>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
        <xsl:text> tei_td</xsl:text>
        <xsl:if test="@rows"><xsl:text> rowspan_</xsl:text><xsl:value-of select="@rows"/></xsl:if>
        <xsl:if test="@cols"><xsl:text> colspan_</xsl:text><xsl:value-of select="@cols"/></xsl:if>
        <xsl:if test="@rows &gt; 1"><xsl:text> table_valign_middle</xsl:text></xsl:if>
        <xsl:if test="starts-with(.,'{') or starts-with(.,'}')"><xsl:text> cell_bracket table_halign_center</xsl:text></xsl:if>
      </xsl:attribute>
      <span class="cell_contents"><xsl:apply-templates/></span>
    </td>
  </xsl:template>
  
  <!-- paragraphs -->
  
  <xsl:template match="p">
    <xsl:choose>
      <xsl:when test="ancestor::p or child::table">
        <div>
          <xsl:attribute name="class">
            <xsl:if test="@rend"><xsl:value-of select="@rend"/><xsl:text> </xsl:text></xsl:if>
            <xsl:text>p</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when test="descendant::hi[@rend='center']"><div class="p contains_center"><xsl:apply-templates/></div></xsl:when>
      <xsl:when test="@n='info'"><!-- don't show, pull into alt tag --></xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:if test="@rend">
            <xsl:attribute name="class">
              <xsl:if test="@rend"><xsl:value-of select="@rend"/><xsl:text> </xsl:text></xsl:if>
              
            </xsl:attribute>
          </xsl:if>
          
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="format_for_attribute">
    <xsl:param name="input"/>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quot">"</xsl:variable>
    <xsl:value-of select="translate(translate($input, $apos, ''),$quot,'')"/>
  </xsl:template>
  
  <!-- ~~~~~~ figures ~~~~~~ -->
  
  <xsl:template match="figure/head">
    <h3 class="figure_head"><xsl:apply-templates/></h3>
  </xsl:template>
  
  <xsl:template name="figure_formatter">
    <xsl:param name="type"/>
    
    <xsl:choose>
      <xsl:when test="$type = 'audio' or $type = 'video'"></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="image_id">
          <xsl:value-of select="lower-case(@n)"/>
        </xsl:variable>
        
        <xsl:variable name="image_builder">
          <img>
            <xsl:attribute name="src">
              <xsl:value-of select="$file_location"/>
              <!-- When in the images section, pull full sized image. 
          When in book ("other") pull 300 px image-->
              <xsl:text>images/lewisandclark/</xsl:text>
              <xsl:choose>
                <xsl:when test="$type = 'other'">
                  <xsl:text>300/</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>700/</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$image_id"/>
              <xsl:choose>
                <xsl:when test="ends-with($image_id,'.jpg')"></xsl:when>
                <xsl:otherwise>.jpg</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="alt"><xsl:call-template name="format_for_attribute"><xsl:with-param name="input" select="p[@n='info']"/></xsl:call-template></xsl:attribute>
          </img>
        </xsl:variable>
        
        
        <div class="figure_image">
          <!-- When in the images section, do not link 
          When in book, link to larger image-->
          <xsl:choose>
            <xsl:when test="$type = 'other'">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$file_location"/>
                  <!-- When in the images section, pull full sized image. 
          When in book ("other") pull 300 px image-->
                  <xsl:text>images/lewisandclark/</xsl:text>
                  <xsl:text>full/</xsl:text>
                  <xsl:value-of select="$image_id"/>
                  <xsl:choose>
                    <xsl:when test="ends-with($image_id,'.jpg')"></xsl:when>
                    <xsl:otherwise>.jpg</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="data-toggle">lightbox</xsl:attribute>
                <xsl:attribute name="data-gallery">LC</xsl:attribute>
                <xsl:attribute name="data-title"><xsl:call-template name="format_for_attribute"><xsl:with-param name="input" select="p[@n='info']"/></xsl:call-template></xsl:attribute>
                <xsl:copy-of select="$image_builder"/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$image_builder"/>
              
              <div class="full_sized_image_link">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="$file_location"/>
                    <xsl:text>images/lewisandclark/</xsl:text>
                    <xsl:text>full/</xsl:text>
                    <xsl:value-of select="$image_id"/>
                    <xsl:choose>
                      <xsl:when test="ends-with($image_id,'.jpg')"></xsl:when>
                      <xsl:otherwise>.jpg</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:text>Full Sized Image</xsl:text>
                </a>
              </div>
            </xsl:otherwise>
          </xsl:choose>
          
          
        </div>
      </xsl:otherwise>
    </xsl:choose>
    
    
    

  </xsl:template>
  
  <xsl:template match="figure">

    
    <div class="tei_figure">
       <xsl:choose>
         <xsl:when test="//keywords[@n='category']/term[1] = 'Images'">
           <xsl:call-template name="figure_formatter">
             <xsl:with-param name="type">image</xsl:with-param>
           </xsl:call-template>
         </xsl:when>
         <xsl:when test="media/@mimeType='audio/mp3'">
           <xsl:call-template name="figure_formatter">
             <xsl:with-param name="type">audio</xsl:with-param>
           </xsl:call-template>
         </xsl:when>
         <xsl:when test="media/@mimeType='video/mp4'">
           <xsl:call-template name="figure_formatter">
             <xsl:with-param name="type">video</xsl:with-param>
           </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
           <xsl:call-template name="figure_formatter">
             <xsl:with-param name="type">other</xsl:with-param>
           </xsl:call-template>
         </xsl:otherwise>
       </xsl:choose>
      <xsl:apply-templates/>
    </div>

  </xsl:template>
  
  <!-- ~~~~~~~ audio and video ~~~~~~~ -->
  
 
  
  <xsl:template match="media[@mimeType='audio/mp3']">
    <div class="audio_player">
      <audio controls="controls">
        <source src="{$file_location}audio/lewisandclark/mp3/{@url}"/>
        <source src="{$file_location}audio/lewisandclark/ogg/{substring-before(@url,'.mp3')}.ogg"/>
        <p>Your browser does not support HTML5 audio or our codecs, please download the <a href="{$file_location}audio/lewisandclark/mp3/{@url}">MP3 file (medium quality)</a> or the <a href="{$file_location}audio/lewisandclark/ogg/{substring-before(@url,'.mp3')}.ogg">OGG file (high quality)</a>.</p>
        
        
      </audio>
    </div>
    
  </xsl:template>
  
  <xsl:template match="media[@mimeType='video/mp4']">
    <div class="wdn-responsive-embed wdn-aspect16x9 videoembed">
      <iframe src="{@url}?format=iframe&amp;autoplay=0" title="{parent::*/parent::*/parent::*/head}" allowfullscreen='true'>&#160;</iframe>
    </div>
  </xsl:template>
  
  <!-- ~~~~~~~ references ~~~~~~~ -->
  
  <xsl:template match="speaker//ref"><!-- do nothing, called by mode --></xsl:template>
  
  <xsl:template match="speaker//ref" mode="display">
    <xsl:apply-templates/><xsl:text> </xsl:text>
    <a>
      <xsl:attribute name="href">#<xsl:value-of select="@target"/></xsl:attribute>
      <xsl:attribute name="id">l<xsl:value-of select="@target"/></xsl:attribute>
      <xsl:attribute name="class">ref_link</xsl:attribute>
      <sup>[<xsl:value-of select="@n"/>]</sup>
    </a>
  </xsl:template>
  
  <xsl:template match="ref">
    <xsl:choose>
      <xsl:when test="@type='email'">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="starts-with(@target,'http')">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:apply-templates></xsl:apply-templates>
        </a>
      </xsl:when>
      <xsl:when test="@type='editorial' and @target">
        <a>
          <xsl:attribute name="href">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@type='editorial'">
        <a>
          <xsl:attribute name="href">
            <xsl:text></xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text></xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      
      <xsl:when test="@type='related'">
        <a>
          <xsl:attribute name="href">
            <xsl:text></xsl:text>
            <xsl:choose>
              <xsl:when test="@target"><xsl:value-of select="@target"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="@n"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text></xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      
      <xsl:when test="@type='internal'">
        <a>
          <xsl:attribute name="href">
            <!--<xsl:text>../</xsl:text>-->
            <xsl:choose>
              <xsl:when test="@target"><xsl:value-of select="@target"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="@n"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text></xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:apply-templates/><xsl:text> </xsl:text>
        <a>
          <xsl:attribute name="href">#<xsl:value-of select="@target"/></xsl:attribute>
          <xsl:attribute name="id">l<xsl:value-of select="@target"/></xsl:attribute>
          <xsl:attribute name="class">ref_link</xsl:attribute>
          <sup>[<xsl:value-of select="@n"/>]</sup>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ~~~~~~ Notes Section ~~~~~~ -->
  <xsl:template match="/TEI//back/div[@type='notes']">
    <div class="footnotes">
      <h4>Footnotes</h4>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- ~~~~~~ Notes ~~~~~~ -->
  <xsl:template match="div[@type='notes']//note">
 
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

  <!-- don't show file references, handle them in /text rule or use solr -->
  <xsl:template match="div[@type='file_references']" priority="2"></xsl:template>
  
  <!-- add classes to divs for styling -->

  <xsl:template match="div" priority="1">
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="@type"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text> tei_div</xsl:text>
      </xsl:attribute>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id">
          <xsl:value-of select="@xml:id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>  
  
  <!-- Speaker -->
  
  <xsl:template match="div[@type='entry']//sp//speaker">
    <h4 class="entry_author">
      <xsl:text>[</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>]</xsl:text>
      <xsl:if test="descendant::ref">
        <xsl:apply-templates select="ref" mode="display"></xsl:apply-templates>
      </xsl:if>
    </h4>
  </xsl:template> 
<!--  
  <xsl:template match="div[@type='entry']//sp//speaker/name">
    <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
  </xsl:template>-->
  
  <xsl:template match="div[@type='entry']//sp//ab//date">
    <xsl:if test="normalize-space(.) != ''">
      <div class="entry_date">
        <xsl:apply-templates/>
      </div>
    </xsl:if>
    
    <div class="clear_return">&#160;</div>
  </xsl:template> 
  
  <!-- names/places/tribes -->
  <!-- currently search?=Rocky Mountains -->
  <!-- should be search?qfield=places&qtext=Rocky+Mountains -->
  
  <!-- comment out for link check -->
  <xsl:template match="name">
    <xsl:choose>
      <!-- Can't have a link inside a link, investigate if this is a problem -kmd -->
      <xsl:when test="ancestor::ref">
        <xsl:apply-templates/>
      </xsl:when>
      <!-- Only show when journals for now -->
      <xsl:when test="normalize-space(//keywords[@n='category']/term[1]/text()) = 'Journals' ">
        <a>
          <xsl:attribute name="class">regularization</xsl:attribute>
          <xsl:attribute name="title"><xsl:value-of select="@key"/></xsl:attribute>
          <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
          <xsl:attribute name="data-placement">top</xsl:attribute>
          <xsl:attribute name="href">
            <xsl:text>../search?</xsl:text>
            <xsl:choose>
              <xsl:when test="@type = 'place'">places</xsl:when>
              <xsl:when test="@type = 'person'">people</xsl:when>
              <xsl:when test="@type = 'native_nation'">lc_native_nation_ss</xsl:when>
            </xsl:choose>
            <xsl:text>=</xsl:text>
            <xsl:value-of select="encode-for-uri(@key)"/>
            <xsl:text></xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="tei_name"><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  

</xsl:stylesheet>