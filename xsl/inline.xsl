<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  version="3.0"
>

  <xsl:template match="*[contains(@class, ' topic/ph ')]">
    <ast:node type="span">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- phase 1: plain text only, no glossary/keyref resolution -->
  <xsl:template match="*[contains(@class, ' topic/term ')]">
    <ast:node type="dfn">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- collapse whitespace runs; a whitespace-only run is dropped between block siblings (a stray
       text node would break react-bootstrap's flex/grid layouts) but kept as one space between
       inline ones, e.g. a run of buttons, matching how a browser would render the same source -->
  <xsl:template match="text()">
    <xsl:variable name="collapsed" select="replace(., '\s+', ' ')"/>
    <xsl:if test="normalize-space($collapsed) != '' or not(../*[ast:is-block(.)])">
      <ast:text><xsl:value-of select="$collapsed"/></ast:text>
    </xsl:if>
  </xsl:template>

  <!-- topic/keyword and its specializations (cmdname, varname, msgnum, ...) -->
  <xsl:template match="*[contains(@class, ' topic/keyword ')]">
    <ast:node type="span">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- phase 1: no auto trademark-symbol insertion -->
  <xsl:template match="*[contains(@class, ' topic/tm ')]">
    <ast:node type="span">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/cite ')]">
    <ast:node type="cite">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/q ')]">
    <ast:node type="q">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/boolean ')]">
    <ast:text><xsl:value-of select="concat(name(), ': ', @state)"/></ast:text>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/state ')]">
    <ast:text><xsl:value-of select="concat(name(), ': ', @name, '=', @value)"/></ast:text>
  </xsl:template>

  <!-- passthrough wrapper, no node of its own -->
  <xsl:template match="*[contains(@class, ' topic/text ')]">
    <xsl:apply-templates select="(*|text())"/>
  </xsl:template>

</xsl:stylesheet>
