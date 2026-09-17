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

  <!-- shared by map2ast-bootstrap.xsl (TOC) and the per-topic pipeline (breadcrumbs);
       relies on the host stylesheet to declare $OUTEXT, as both hosts already do -->
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/topic2textonly.xsl"/>

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

</xsl:stylesheet>
