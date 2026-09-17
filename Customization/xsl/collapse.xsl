<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="xs"
  version="3.0"
>

  <xsl:template match="*[contains(@class, ' bootstrap-d/collapse ')]">
    <xsl:variable name="id" select="(@id, generate-id(.))[1]"/>
    <xsl:variable name="is-horizontal" select="ast:has-outputclass-token(., 'collapse-horizontal')"/>
    <xsl:variable name="style" select="ast:otherprops-token(., 'style')"/>
    <ast:node type="Collapse">
      <ast:props>
        <xsl:if test="not(@id)">
          <ast:prop name="id" value="{$id}"/>
        </xsl:if>
        <xsl:if test="$is-horizontal">
          <ast:prop name="horizontal" type="boolean" value="true"/>
        </xsl:if>
        <xsl:if test="$style">
          <ast:prop name="style" value="{$style}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="('collapse', 'collapse-horizontal')"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- a button/xref wired to toggle a collapse, instead of navigating or submitting -->
  <xsl:template
    match="*[(contains(@class, ' bootstrap-d/button ') or contains(@class, ' topic/xref ')) and ast:has-props-token(., 'collapse-toggle')]"
  >
    <xsl:call-template name="ast:render-toggle-button">
      <xsl:with-param name="target" select="substring-after(@href, '#')"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
