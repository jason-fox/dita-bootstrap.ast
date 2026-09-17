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

  <xsl:template
    match="*[contains(@class, ' bootstrap-d/pagination ')]
                        | *[contains(@class, ' topic/section ') and ast:has-outputclass-token(., 'pagination')]"
  >
    <xsl:variable name="title" select="*[contains(@class, ' topic/title ')]"/>
    <xsl:variable name="list" select="*[contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ')]"/>
    <ast:node type="nav">
      <ast:props>
        <xsl:if test="$title">
          <ast:prop name="aria-label" value="{normalize-space(string($title))}"/>
        </xsl:if>
      </ast:props>
      <xsl:apply-templates select="$list"/>
    </ast:node>
  </xsl:template>

  <xsl:template
    match="*[(contains(@class, ' topic/ol ') or contains(@class, ' topic/ul '))
                         and (parent::*[contains(@class, ' bootstrap-d/pagination ')]
                              or parent::*[contains(@class, ' topic/section ') and ast:has-outputclass-token(., 'pagination')]
                              or ast:has-outputclass-token(., 'pagination'))]"
  >
    <xsl:variable name="is-specialized" select="parent::*[contains(@class, ' bootstrap-d/pagination ')]"/>
    <xsl:variable
      name="size"
      select="if ($is-specialized) then (if (../@size = 'small') then 'sm' else if (../@size = 'large') then 'lg' else ())
                                       else ()"
    />
    <!-- the specialized <pagination> wrapper's own outputclass (e.g. alignment utilities) has nowhere
         else to land, since it's consumed into the <nav> wrapper above with no class of its own -->
    <xsl:variable name="wrapper-class" select="if ($is-specialized) then string(../@outputclass) else ()"/>
    <ast:node type="Pagination">
      <ast:props>
        <xsl:if test="$size">
          <ast:prop name="size" value="{$size}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="$wrapper-class"/>
          <xsl:with-param
            name="stripOutputclass"
            select="if (ast:has-outputclass-token(., 'pagination')) then 'pagination' else ()"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/li ')]" mode="pagination-item"/>
    </ast:node>
  </xsl:template>

  <!-- a bare <ol outputclass="pagination"> with no wrapping <pagination>/section needs its own <nav> -->
  <xsl:template
    match="*[(contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ')) and ast:has-outputclass-token(., 'pagination')]
                        [not(parent::*[contains(@class, ' bootstrap-d/pagination ')])]
                        [not(parent::*[contains(@class, ' topic/section ') and ast:has-outputclass-token(., 'pagination')])]"
    priority="1"
  >
    <ast:node type="nav">
      <ast:props/>
      <xsl:next-match/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/li ')]" mode="pagination-item">
    <xsl:variable name="xref" select="*[contains(@class, ' topic/xref ')][1]"/>
    <xsl:variable name="resolved-href">
      <xsl:if test="$xref">
        <xsl:for-each select="$xref">
          <xsl:call-template name="href"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <ast:node type="PaginationItem">
      <ast:props>
        <xsl:if test="$resolved-href != ''">
          <ast:prop name="href" value="{$resolved-href}"/>
        </xsl:if>
        <xsl:if test="ast:has-outputclass-token(., 'active')">
          <ast:prop name="active" type="boolean" value="true"/>
        </xsl:if>
        <xsl:if test="ast:has-outputclass-token(., 'disabled')">
          <ast:prop name="disabled" type="boolean" value="true"/>
        </xsl:if>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="$xref/(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
