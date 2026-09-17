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
  exclude-result-prefixes="xs dita-ot"
  version="3.0"
>

  <xsl:param name="OUTEXT" select="'.json'"/>

  <!-- copied, not imported, from plugin:org.dita.html5:xsl/rel-links.xsl:322-355: importing it would pull in
       its mode="ditamsg:unknown-extension" call, whose template isn't in this pipeline's import chain -->
  <xsl:template name="href">
    <xsl:apply-templates select="." mode="determine-final-href"/>
  </xsl:template>
  <xsl:template match="*" mode="determine-final-href">
    <xsl:choose>
      <xsl:when test="not(normalize-space(@href)) or empty(@href)"/>
      <xsl:when test="(empty(@format) and @scope = 'external') or (@format and not(@format = 'dita'))">
        <xsl:value-of select="@href"/>
      </xsl:when>
      <xsl:when test="starts-with(@href, '#')">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="dita-ot:generate-id(dita-ot:get-topic-id(@href), dita-ot:get-element-id(@href))"/>
      </xsl:when>
      <xsl:when test="(empty(@scope) or @scope = ('local', 'peer')) and (empty(@format) or @format = 'dita')">
        <xsl:call-template name="replace-extension">
          <xsl:with-param name="filename" select="@href"/>
          <xsl:with-param name="extension" select="$OUTEXT"/>
          <xsl:with-param name="ignore-fragment" select="true()"/>
        </xsl:call-template>
        <xsl:if test="contains(@href, '#')">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="dita-ot:generate-id(dita-ot:get-topic-id(@href), dita-ot:get-element-id(@href))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="is-external-link" as="xs:boolean">
    <xsl:sequence
      select="@scope = 'external'
                           or @type = 'external'
                           or (lower-case((@format, '')[1]) = 'pdf' and not(@scope = 'local'))"
    />
  </xsl:template>

  <!-- real anchor attributes for an external link, matching org.dita.html5's own target="_blank" rel="external noopener" -->
  <xsl:template name="link-target-props">
    <xsl:param name="external" as="xs:boolean"/>
    <xsl:if test="$external">
      <ast:prop name="target" value="_blank"/>
      <ast:prop name="rel" value="external noopener"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/xref ')] | *[contains(@class, ' topic/link ')]">
    <xsl:variable name="resolved-href">
      <xsl:call-template name="href"/>
    </xsl:variable>
    <xsl:variable name="is-external" as="xs:boolean">
      <xsl:call-template name="is-external-link"/>
    </xsl:variable>
    <ast:node type="a">
      <ast:props>
        <xsl:if test="$resolved-href != ''">
          <ast:prop name="href" value="{$resolved-href}"/>
        </xsl:if>
        <xsl:call-template name="link-target-props">
          <xsl:with-param name="external" select="$is-external"/>
        </xsl:call-template>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
