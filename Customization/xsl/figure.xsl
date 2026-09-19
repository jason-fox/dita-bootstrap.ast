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

  <!-- syntaxdiagram also carries topic/fig; excluded here so pr-d.xsl's own template wins (a
       syntax diagram isn't a figure). ut-d/imagemap gets the same real-plugin exception but stays unexcluded - no AST imagemap renderer exists yet, and excluding it would just drop its content. -->
  <xsl:template match="*[contains(@class, ' topic/fig ') and not(contains(@class, ' pr-d/syntaxdiagram '))]">
    <xsl:variable name="title" select="*[contains(@class, ' topic/title ')]"/>
    <xsl:variable name="desc" select="*[contains(@class, ' topic/desc ')]"/>
    <ast:node type="figure">
      <ast:props>
        <xsl:if test="@frame">
          <ast:prop name="data-frame" value="{@frame}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'figure w-100 mw-100 p-3'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="node() except ($title | $desc)"/>
      <xsl:if test="$title">
        <ast:node type="figcaption">
          <ast:props>
            <ast:prop name="className" value="figure-caption"/>
          </ast:props>
          <ast:text><xsl:call-template name="getVariable"><xsl:with-param
                name="id"
                select="'Figure'"
              /></xsl:call-template><xsl:text> </xsl:text><xsl:value-of
              select="count(preceding::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')]) + 1"
            /><xsl:text>. </xsl:text></ast:text>
          <xsl:apply-templates select="$title/(*|text())"/>
          <xsl:if test="$desc">
            <ast:text>. </ast:text>
            <ast:node type="span">
              <ast:props>
                <ast:prop name="className" value="figdesc"/>
              </ast:props>
              <xsl:apply-templates select="$desc/(*|text())"/>
            </ast:node>
          </xsl:if>
        </ast:node>
      </xsl:if>
    </ast:node>
  </xsl:template>

  <!-- images inside a fig get Bootstrap's figure-img treatment, not a plain img -->
  <xsl:template match="*[contains(@class, ' topic/image ')][ancestor::*[contains(@class, ' topic/fig ')]]">
    <ast:node type="img">
      <ast:props>
        <ast:prop name="src" value="{@href}"/>
        <xsl:variable name="alt" select="(*[contains(@class, ' topic/alt ')], @alt)[1]"/>
        <xsl:if test="$alt">
          <ast:prop name="alt" value="{normalize-space(string($alt))}"/>
        </xsl:if>
        <xsl:if test="@width">
          <ast:prop name="width" value="{@width}"/>
        </xsl:if>
        <xsl:if test="@height">
          <ast:prop name="height" value="{@height}"/>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@loading">
            <ast:prop name="loading" value="{@loading}"/>
          </xsl:when>
          <xsl:when test="contains(@otherprops, 'loading(')">
            <ast:prop name="loading" value="{substring-before(substring-after(@otherprops, 'loading('), ')')}"/>
          </xsl:when>
        </xsl:choose>
        <xsl:variable name="figImageClasses" as="xs:string*" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <xsl:text>image</xsl:text>
          <xsl:if test="contains(@class, ' bootstrap-d/thumbnail ')">
            <xsl:text>thumbnail</xsl:text>
          </xsl:if>
          <xsl:text>figure-img img-fluid border rounded</xsl:text>
        </xsl:variable>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="string-join($figImageClasses, ' ')"/>
        </xsl:call-template>
      </ast:props>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
