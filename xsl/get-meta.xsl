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

  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="json-meta">
    <xsl:variable name="shortdesc-text" as="xs:string?" xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' topic/shortdesc ')]">
          <xsl:sequence select="string(*[contains(@class, ' topic/shortdesc ')][1])"/>
        </xsl:when>
        <xsl:when test="*[contains(@class, ' topic/abstract ')]/*[contains(@class, ' topic/shortdesc ')]">
          <xsl:sequence
            select="string(*[contains(@class, ' topic/abstract ')][1]/*[contains(@class, ' topic/shortdesc ')][1])"
          />
        </xsl:when>
        <xsl:when test="*[contains(@class, ' glossentry/glossdef ')]">
          <xsl:sequence select="string(*[contains(@class, ' glossentry/glossdef ')][1])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- search-only synonyms; never rendered, so this is the AST's only representation of them -->
    <xsl:variable
      name="indexterms"
      as="element()*"
      select="*[contains(@class, ' topic/prolog ')]/*[contains(@class, ' topic/metadata ')]
                            /*[contains(@class, ' topic/keywords ')]//*[contains(@class, ' topic/indexterm ')]"
    />
    <!-- DITA @xml:lang attribute cascading, falling back to DEFAULTLANG parameter -->
    <xsl:variable name="doc-lang" select="(ancestor-or-self::*[@xml:lang])[last()]/@xml:lang"/>
    <xsl:variable
      name="effective-lang"
      select="if (normalize-space($doc-lang)) then string($doc-lang) else (if (/*/@xml:lang) then string(/*/@xml:lang) else $DEFAULTLANG)"
    />
    <ast:meta>
      <ast:prop name="title" value="{string(*[contains(@class, ' topic/title ')][1])}"/>
      <ast:prop name="lang" value="{$effective-lang}"/>
      <xsl:if test="$shortdesc-text">
        <ast:prop name="shortdesc" value="{$shortdesc-text}"/>
      </xsl:if>
      <xsl:if test="$indexterms">
        <ast:prop-array name="keywords">
          <xsl:for-each select="$indexterms">
            <ast:item value="{normalize-space(.)}"/>
          </xsl:for-each>
        </ast:prop-array>
      </xsl:if>
      <!-- defined in Customization/xsl/breadcrumb.xsl; no-op unless args.breadcrumbs is set -->
      <xsl:call-template name="breadcrumb-props"/>
      <xsl:call-template name="common-props">
        <xsl:with-param name="skipLang" select="true()"/>
      </xsl:call-template>
    </ast:meta>
  </xsl:template>

</xsl:stylesheet>
