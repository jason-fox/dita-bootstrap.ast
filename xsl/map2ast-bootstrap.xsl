<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="dita-ot ast"
  version="3.0"
>

  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
  <!-- dita-utilities.xsl already includes functions.xsl; don't import it separately -->
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/topic2textonly.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/serializer.xsl"/>
  <!-- get-navtitle / toc-href: shared with the per-topic pipeline's breadcrumb generation -->
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/nav.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="OUTEXT" select="'.json'"/>
  <xsl:param name="DEFAULTLANG" select="'en'"/>
  <!-- same param names/defaults as dita-bootstrap's html5-bootstrap transtype (plugin.xml);
       passed through to toc.json as-is, not interpreted here -->
  <xsl:param name="nav-toc" select="'collapsible'"/>
  <xsl:param name="scrollspy-toc" select="'none'"/>

  <xsl:template match="/">
    <xsl:variable name="map" select="*[contains(@class, ' map/map ')]"/>
    <xsl:variable name="entries" as="element(ast:node)*">
      <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="toc"/>
    </xsl:variable>
    <!-- same title cascade as dita-bootstrap's Customization/xsl/nav.xsl default-sidebar-header -->
    <xsl:variable name="doc-title" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:choose>
        <!-- [1] must wrap the whole // result, not chain onto the last step - unparenthesized it
             means "first title-class child per ancestor," yielding multiple nodes and breaking fn:string() -->
        <xsl:when test="($map//*[contains(@class, ' topic/title ')])[1]">
          <xsl:value-of select="string(($map//*[contains(@class, ' topic/title ')])[1])"/>
        </xsl:when>
        <xsl:when test="($map//*[contains(@class, ' bookmap/mainbooktitle ')])[1]">
          <xsl:value-of select="string(($map//*[contains(@class, ' bookmap/mainbooktitle ')])[1])"/>
        </xsl:when>
        <xsl:when test="$map/@title">
          <xsl:value-of select="$map/@title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
            select="string($map/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')][1])"
          />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="map-lang" select="($map/@xml:lang)[1]"/>
    <xsl:variable
      name="effective-lang"
      select="if (normalize-space($map-lang)) then string($map-lang) else $DEFAULTLANG"
    />
    <xsl:value-of
      select="ast:serialize-toc($entries, normalize-space($doc-title), $nav-toc, $scrollspy-toc, $effective-lang)"
    />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template
    match="*[contains(@class, ' map/topicref ')]
                        [not(@toc = 'no')]
                        [not(@processing-role = 'resource-only')]"
    mode="toc"
  >
    <xsl:variable name="title" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:variable name="navtitle-rtf">
        <xsl:apply-templates select="." mode="get-navtitle"/>
      </xsl:variable>
      <xsl:sequence select="string($navtitle-rtf)"/>
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:call-template name="toc-href"/>
    </xsl:variable>
    <xsl:variable name="children" as="element(ast:node)*">
      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc"/>
    </xsl:variable>
    <!-- mirrors dita-bootstrap's Customization/xsl/nav.xsl nav-icon template -->
    <xsl:variable
      name="icon-content"
      select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/othermeta ') and @name = 'icon']/@content"
    />
    <xsl:variable
      name="icon-style-content"
      select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/othermeta ') and @name = 'icon-style']/@content"
    />
    <xsl:if test="normalize-space($title) or $children">
      <ast:node type="TocEntry">
        <ast:props>
          <ast:prop name="title" value="{normalize-space($title)}"/>
          <xsl:if test="normalize-space($href)">
            <ast:prop name="href" value="{$href}"/>
          </xsl:if>
          <xsl:if test="normalize-space($icon-content)">
            <ast:prop name="icon" value="{normalize-space(concat('me-2 ', $icon-content))}"/>
            <xsl:if test="normalize-space($icon-style-content)">
              <ast:prop name="iconStyle" value="{$icon-style-content}"/>
            </xsl:if>
          </xsl:if>
        </ast:props>
        <xsl:sequence select="$children"/>
      </ast:node>
    </xsl:if>
  </xsl:template>

  <!-- if toc=no but a child has toc=yes, that child bubbles up -->
  <xsl:template
    match="*[contains(@class, ' map/topicref ')]
                        [@toc = 'no']
                        [not(@processing-role = 'resource-only')]"
    mode="toc"
  >
    <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc"/>
  </xsl:template>

  <xsl:template match="*" mode="toc" priority="-1"/>

</xsl:stylesheet>
