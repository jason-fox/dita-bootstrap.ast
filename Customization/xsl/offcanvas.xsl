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

  <xsl:template match="*[ast:is-offcanvas(.)]">
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/offcanvas ')"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable
      name="placement-token"
      select="$tokens[starts-with(., 'offcanvas-')][substring-after(., 'offcanvas-') = ('start', 'end', 'top', 'bottom')][1]"
    />
    <xsl:variable
      name="placement"
      select="(if ($is-specialized) then @position else ()),
                                            (if ($placement-token) then substring-after($placement-token, 'offcanvas-') else ())[1]"
    />
    <xsl:variable name="id" select="(@id, generate-id(.))[1]"/>
    <xsl:variable name="title" select="*[contains(@class, ' topic/title ')]"/>
    <ast:node type="Offcanvas">
      <ast:props>
        <!-- common-props already emits @id when present; only cover the no-@id fallback here -->
        <xsl:if test="not(@id)">
          <ast:prop name="id" value="{$id}"/>
        </xsl:if>
        <xsl:if test="$placement">
          <ast:prop name="placement" value="{$placement}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="stripOutputclass"
            select="if ($is-specialized) then () else $tokens[starts-with(., 'offcanvas')]"
          />
        </xsl:call-template>
      </ast:props>
      <ast:node type="OffcanvasHeader">
        <ast:props>
          <ast:prop name="closeButton" type="boolean" value="true"/>
        </ast:props>
        <xsl:if test="$title">
          <ast:node type="OffcanvasTitle">
            <ast:props/>
            <xsl:apply-templates select="$title/(*|text())"/>
          </ast:node>
        </xsl:if>
      </ast:node>
      <ast:node type="OffcanvasBody">
        <ast:props/>
        <xsl:apply-templates select="(*[not(contains(@class, ' topic/title '))] | text())"/>
      </ast:node>
    </ast:node>
  </xsl:template>

  <!-- a button/xref wired to toggle an offcanvas, instead of navigating or submitting -->
  <xsl:template
    match="*[(contains(@class, ' bootstrap-d/button ') or contains(@class, ' topic/xref ')) and ast:has-props-token(., 'offcanvas-toggle')]"
  >
    <xsl:call-template name="ast:render-toggle-button">
      <xsl:with-param name="target" select="substring-after(@href, '#')"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
