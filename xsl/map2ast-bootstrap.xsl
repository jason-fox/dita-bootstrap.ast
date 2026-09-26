<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="xs dita-ot ast"
  version="3.0"
>

  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/serializer.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/nav.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="OUTEXT" select="'.json'"/>
  <xsl:param name="DEFAULTLANG" select="'en'"/>
  <xsl:param name="HDR" as="xs:string?"/>
  <xsl:param name="FTR" as="xs:string?"/>
  <xsl:param name="nav-toc" select="'collapsible'"/>
  <xsl:param name="scrollspy-toc" select="'none'"/>
  <xsl:param name="menubar-toc.include" select="'no'"/>

  <xsl:template match="/">
    <xsl:variable name="map" select="*[contains(@class, ' map/map ')]"/>
    <xsl:variable name="entries" as="element(ast:node)*">
      <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="toc"/>
    </xsl:variable>
    <xsl:variable name="doc-title" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:choose>
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
    <xsl:variable name="header-ast" as="element(ast:node)?">
      <xsl:if test="normalize-space($HDR) and doc-available($HDR)">
        <xsl:apply-templates select="doc($HDR)/*" mode="hdr-ftr-ast">
          <xsl:with-param name="doc-title" select="normalize-space($doc-title)" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="footer-ast" as="element(ast:node)?">
      <xsl:if test="normalize-space($FTR) and doc-available($FTR)">
        <xsl:apply-templates select="doc($FTR)/*" mode="hdr-ftr-ast">
          <xsl:with-param name="doc-title" select="normalize-space($doc-title)" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="skip-to-main-rtf">
      <xsl:call-template name="getVariable">
        <xsl:with-param name="id" select="'Skip to main content'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable
      name="skip-to-main"
      select="if (normalize-space(string($skip-to-main-rtf))) then string($skip-to-main-rtf) else 'Skip to main content'"
    />
    <xsl:variable name="skip-to-nav-rtf">
      <xsl:call-template name="getVariable">
        <xsl:with-param name="id" select="'Skip to docs navigation'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable
      name="skip-to-nav"
      select="if (normalize-space(string($skip-to-nav-rtf))) then string($skip-to-nav-rtf) else 'Skip to docs navigation'"
    />
    <xsl:value-of
      select="ast:serialize-toc($entries, normalize-space($doc-title), $nav-toc, $scrollspy-toc, $effective-lang, $header-ast, $footer-ast, $skip-to-main, $skip-to-nav, $menubar-toc.include = 'yes')"
    />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Mode to convert include XML (header/footer templates) into ast:node structures -->
  <xsl:template match="*[local-name() = 'document-title']" mode="hdr-ftr-ast">
    <xsl:param name="doc-title" as="xs:string" tunnel="yes"/>
    <ast:node type="span">
      <ast:text><xsl:value-of select="$doc-title"/></ast:text>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[local-name() = 'favicon']" mode="hdr-ftr-ast">
    <ast:node type="Favicon">
      <xsl:if test="@*">
        <ast:props>
          <xsl:for-each select="@*">
            <ast:prop name="{name(.)}" value="{.}"/>
          </xsl:for-each>
        </ast:props>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="hdr-ftr-ast"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*" mode="hdr-ftr-ast">
    <ast:node type="{name(.)}">
      <xsl:if test="@*">
        <ast:props>
          <xsl:for-each select="@*">
            <ast:prop name="{name(.)}" value="{.}"/>
          </xsl:for-each>
        </ast:props>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="hdr-ftr-ast"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="text()" mode="hdr-ftr-ast">
    <xsl:if test="normalize-space(.) != ''">
      <ast:text><xsl:value-of select="."/></ast:text>
    </xsl:if>
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
