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

  <xsl:template match="*[ast:is-alert(.)]">
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable name="color-token" select="$tokens[starts-with(., 'alert-')][1]"/>
    <xsl:variable
      name="variant"
      select="(@color, if ($color-token) then substring-after($color-token, 'alert-') else ())[1]"
    />
    <xsl:variable name="title" select="*[contains(@class, ' topic/title ')]"/>
    <ast:node type="Alert">
      <ast:props>
        <ast:prop name="variant" value="{$variant}"/>
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="('alert', $color-token)"/>
        </xsl:call-template>
      </ast:props>
      <xsl:if test="$title">
        <ast:node type="AlertHeading">
          <ast:props/>
          <xsl:apply-templates select="$title/(*|text())"/>
        </ast:node>
      </xsl:if>
      <xsl:apply-templates select="(*[not(. is $title)] | text())"/>
    </ast:node>
  </xsl:template>

  <!-- links inside an alert are react-bootstrap's Alert.Link component, not a plain <a> -->
  <xsl:template
    match="(*[contains(@class, ' topic/xref ')] | *[contains(@class, ' topic/link ')])
                        [ancestor::*[ast:is-alert(.)]]"
  >
    <xsl:variable name="resolved-href">
      <xsl:call-template name="href"/>
    </xsl:variable>
    <xsl:variable name="is-external" as="xs:boolean">
      <xsl:call-template name="is-external-link"/>
    </xsl:variable>
    <ast:node type="AlertLink">
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
