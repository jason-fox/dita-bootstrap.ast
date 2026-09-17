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

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="OUTEXT" select="'.json'"/>

  <xsl:template match="*" mode="get-navtitle">
    <xsl:choose>
      <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]">
        <xsl:apply-templates
          select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"
          mode="dita-ot:text-only"
        />
      </xsl:when>
      <xsl:when test="@navtitle">
        <xsl:value-of select="@navtitle"/>
      </xsl:when>
      <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[dita-ot:matches-linktext-class(@class)]">
        <xsl:apply-templates
          select="*[contains(@class, ' map/topicmeta ')]/*[dita-ot:matches-linktext-class(@class)]"
          mode="dita-ot:text-only"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
    <xsl:variable name="entries" as="element(ast:node)*">
      <xsl:apply-templates select="*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicref ')]" mode="toc"/>
    </xsl:variable>
    <xsl:value-of select="ast:serialize-toc($entries)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="toc-href" as="xs:string?" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:choose>
      <xsl:when test="not(normalize-space(@href))"/>
      <xsl:when
        test="@copy-to and not(contains(@chunk, 'to-content'))
                      and (not(@format) or @format = ('dita', 'ditamap'))"
      >
        <xsl:call-template name="replace-extension">
          <xsl:with-param name="filename" select="@copy-to"/>
          <xsl:with-param name="extension" select="$OUTEXT"/>
        </xsl:call-template>
        <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
          <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="not(@scope = 'external') and (not(@format) or @format = ('dita', 'ditamap'))">
        <xsl:call-template name="replace-extension">
          <xsl:with-param name="filename" select="@href"/>
          <xsl:with-param name="extension" select="$OUTEXT"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@href"/>
      </xsl:otherwise>
    </xsl:choose>
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
