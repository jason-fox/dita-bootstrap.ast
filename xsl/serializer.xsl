<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="xs ast"
  version="3.0"
>

  <!-- [type, props?, ...children]; props omitted when empty (children are never plain objects, so item[1] is unambiguous) -->
  <xsl:template match="ast:node" mode="to-fn-json">
    <fn:array>
      <fn:string><xsl:value-of select="@type"/></fn:string>
      <xsl:if test="ast:props/(ast:prop | ast:prop-array)">
        <fn:map>
          <xsl:apply-templates select="ast:props/(ast:prop | ast:prop-array)" mode="to-fn-json-prop"/>
        </fn:map>
      </xsl:if>
      <xsl:apply-templates select="(ast:node | ast:text)" mode="to-fn-json"/>
    </fn:array>
  </xsl:template>

  <!-- one ast:text -> a bare fn:string (no wrapper) -->
  <xsl:template match="ast:text" mode="to-fn-json">
    <fn:string><xsl:value-of select="."/></fn:string>
  </xsl:template>

  <!-- one ast:prop -> one fn:string|number|boolean|null, coerced by @type -->
  <xsl:template match="ast:prop" mode="to-fn-json-prop">
    <xsl:variable name="type" select="(@type, 'string')[1]"/>
    <xsl:choose>
      <xsl:when test="$type = 'boolean'">
        <fn:boolean key="{@name}"><xsl:value-of select="@value = 'true'"/></fn:boolean>
      </xsl:when>
      <xsl:when test="$type = 'number'">
        <fn:number key="{@name}"><xsl:value-of select="xs:double(@value)"/></fn:number>
      </xsl:when>
      <xsl:when test="$type = 'null'">
        <fn:null key="{@name}"/>
      </xsl:when>
      <xsl:otherwise>
        <fn:string key="{@name}"><xsl:value-of select="@value"/></fn:string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- one ast:prop-array -> one fn:array, for props like Accordion's defaultActiveKey (scalar
       items, via ast:item/@value) or breadcrumbs (object items, via nested ast:prop children) -->
  <xsl:template match="ast:prop-array" mode="to-fn-json-prop">
    <fn:array key="{@name}">
      <xsl:for-each select="ast:item">
        <xsl:choose>
          <xsl:when test="@value">
            <fn:string><xsl:value-of select="@value"/></fn:string>
          </xsl:when>
          <xsl:otherwise>
            <fn:map>
              <xsl:apply-templates select="ast:prop" mode="to-fn-json-prop"/>
            </fn:map>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </fn:array>
  </xsl:template>

  <!-- per-topic document envelope: {"meta": {...}, "content": [tuples], "scrollspy"?: [tuples]} -->
  <xsl:function name="ast:serialize-document" as="xs:string">
    <xsl:param name="meta" as="element(ast:meta)?"/>
    <xsl:param name="content" as="element(ast:node)*"/>
    <xsl:param name="scrollspy" as="element(ast:node)*"/>
    <xsl:variable name="tree" as="element(fn:map)">
      <fn:map>
        <fn:map key="meta">
          <xsl:apply-templates select="$meta/(ast:prop | ast:prop-array)" mode="to-fn-json-prop"/>
        </fn:map>
        <fn:array key="content">
          <xsl:apply-templates select="$content" mode="to-fn-json"/>
        </fn:array>
        <!-- omitted (not an empty array) when there's nothing to scroll-spy, so the frontend's
             three-panel layout switch can key off "scrollspy" in doc rather than a length check -->
        <xsl:if test="exists($scrollspy)">
          <fn:array key="scrollspy">
            <xsl:apply-templates select="$scrollspy" mode="to-fn-json"/>
          </fn:array>
        </xsl:if>
      </fn:map>
    </xsl:variable>
    <xsl:sequence select="xml-to-json($tree)"/>
  </xsl:function>

  <!-- merged TOC document envelope: {"toc": [tuples], "title": "...", "navToc": "...", "scrollspyToc": "..."} -->
  <xsl:function name="ast:serialize-toc" as="xs:string">
    <xsl:param name="entries" as="element(ast:node)*"/>
    <xsl:param name="title" as="xs:string"/>
    <xsl:param name="nav-toc" as="xs:string"/>
    <xsl:param name="scrollspy-toc" as="xs:string"/>
    <xsl:variable name="tree" as="element(fn:map)">
      <fn:map>
        <fn:array key="toc">
          <xsl:apply-templates select="$entries" mode="to-fn-json"/>
        </fn:array>
        <xsl:if test="normalize-space($title)">
          <fn:string key="title"><xsl:value-of select="$title"/></fn:string>
        </xsl:if>
        <fn:string key="navToc"><xsl:value-of select="$nav-toc"/></fn:string>
        <fn:string key="scrollspyToc"><xsl:value-of select="$scrollspy-toc"/></fn:string>
      </fn:map>
    </xsl:variable>
    <xsl:sequence select="xml-to-json($tree)"/>
  </xsl:function>

</xsl:stylesheet>
