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
  <!-- AST counterpart to dita-bootstrap's own Customization/xsl/breadcrumb.xsl: same
       args.breadcrumbs/BREADCRUMBS param, same ancestor-topicref walk via the input map, but
       emitted as meta.breadcrumbs (title/href pairs) instead of a rendered <nav> -->

  <xsl:param name="BREADCRUMBS" select="'no'"/>
  <xsl:param name="input.map.url" as="xs:string?"/>
  <xsl:param name="FILEDIR" as="xs:string?"/>
  <xsl:param name="FILENAME" as="xs:string?"/>

  <xsl:variable name="breadcrumb-input-map" as="document-node()?">
    <xsl:if test="$BREADCRUMBS = 'yes' and normalize-space($input.map.url)">
      <xsl:sequence select="document($input.map.url)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable
    name="breadcrumb-current-file"
    as="xs:string?"
    select="if ($FILEDIR = '.') then $FILENAME else concat($FILEDIR, '/', $FILENAME)"
  />

  <xsl:variable
    name="breadcrumb-current-topicref"
    as="element()?"
    select="($breadcrumb-input-map//*[contains(@class, ' map/topicref ')]
              [dita-ot:normalize-href(substring-before(concat(@href, '#'), '#')) = $breadcrumb-current-file])[1]"
  />

  <!-- called from get-meta.xsl; a no-op unless $BREADCRUMBS = 'yes' and the current topic is
       reachable from the input map (e.g. resource-only or unreferenced topics have no trail) -->
  <xsl:template name="breadcrumb-props">
    <xsl:if test="$BREADCRUMBS = 'yes' and $breadcrumb-current-topicref">
      <ast:prop-array name="breadcrumbs">
        <xsl:for-each select="$breadcrumb-current-topicref/ancestor-or-self::*[contains(@class, ' map/topicref ')]">
          <xsl:variable name="title" as="xs:string">
            <xsl:variable name="navtitle-rtf">
              <xsl:apply-templates select="." mode="get-navtitle"/>
            </xsl:variable>
            <xsl:sequence select="normalize-space(string($navtitle-rtf))"/>
          </xsl:variable>
          <xsl:if test="$title != ''">
            <xsl:variable name="href" as="xs:string?">
              <xsl:call-template name="toc-href"/>
            </xsl:variable>
            <ast:item>
              <ast:prop name="title" value="{$title}"/>
              <!-- the active/current crumb carries no href, matching dita-bootstrap's own
                   breadcrumb-item.active (aria-current="page") span-not-anchor treatment -->
              <xsl:if test="normalize-space($href) and not(. is $breadcrumb-current-topicref)">
                <ast:prop name="href" value="{$href}"/>
              </xsl:if>
            </ast:item>
          </xsl:if>
        </xsl:for-each>
      </ast:prop-array>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
