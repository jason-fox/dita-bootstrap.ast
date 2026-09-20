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
  exclude-result-prefixes="xs fn ast"
  version="3.0"
>

  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/serializer.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="DOCS_PAGE_HDR" as="xs:string?"/>
  <xsl:param name="DOCS_PAGE_CARD" as="xs:string?"/>
  <xsl:param name="CHAT_BOT_HDR" as="xs:string?"/>
  <xsl:param name="CHAT_BOT_CARD" as="xs:string?"/>
  <xsl:param name="CHAT_BOT_FORM" as="xs:string?"/>
  <xsl:param name="FOOTER" as="xs:string?"/>

  <xsl:template match="/">
    <xsl:variable
      name="docs-title"
      select="if (normalize-space($DOCS_PAGE_CARD) and doc-available($DOCS_PAGE_CARD)) then normalize-space(doc($DOCS_PAGE_CARD)/*/title) else if (normalize-space($DOCS_PAGE_HDR) and doc-available($DOCS_PAGE_HDR)) then normalize-space(doc($DOCS_PAGE_HDR)/*/title) else ''"
    />
    <xsl:variable
      name="docs-desc"
      select="if (normalize-space($DOCS_PAGE_CARD) and doc-available($DOCS_PAGE_CARD)) then normalize-space(doc($DOCS_PAGE_CARD)/*/description) else if (normalize-space($DOCS_PAGE_HDR) and doc-available($DOCS_PAGE_HDR)) then normalize-space(doc($DOCS_PAGE_HDR)/*/description) else ''"
    />

    <xsl:variable
      name="chat-title"
      select="if (normalize-space($CHAT_BOT_CARD) and doc-available($CHAT_BOT_CARD)) then normalize-space(doc($CHAT_BOT_CARD)/*/title) else if (normalize-space($CHAT_BOT_HDR) and doc-available($CHAT_BOT_HDR)) then normalize-space(doc($CHAT_BOT_HDR)/*/title) else ''"
    />
    <xsl:variable
      name="chat-desc"
      select="if (normalize-space($CHAT_BOT_CARD) and doc-available($CHAT_BOT_CARD)) then normalize-space(doc($CHAT_BOT_CARD)/*/description) else if (normalize-space($CHAT_BOT_HDR) and doc-available($CHAT_BOT_HDR)) then normalize-space(doc($CHAT_BOT_HDR)/*/description) else ''"
    />

    <xsl:variable name="docs-hdr-ast" as="element(ast:node)?">
      <xsl:if test="normalize-space($DOCS_PAGE_HDR) and doc-available($DOCS_PAGE_HDR)">
        <xsl:apply-templates select="doc($DOCS_PAGE_HDR)/*" mode="hdr-ftr-ast"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="docs-card-ast" as="element(ast:node)*">
      <xsl:if test="normalize-space($DOCS_PAGE_CARD) and doc-available($DOCS_PAGE_CARD)">
        <xsl:variable name="doc-root" select="doc($DOCS_PAGE_CARD)/*"/>
        <xsl:choose>
          <xsl:when test="local-name($doc-root) = 'body'">
            <xsl:apply-templates select="$doc-root/*[not(self::title or self::description)]" mode="hdr-ftr-ast"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$doc-root" mode="hdr-ftr-ast"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="chat-hdr-ast" as="element(ast:node)?">
      <xsl:if test="normalize-space($CHAT_BOT_HDR) and doc-available($CHAT_BOT_HDR)">
        <xsl:apply-templates select="doc($CHAT_BOT_HDR)/*" mode="hdr-ftr-ast"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="chat-card-ast-all" as="element(ast:node)*">
      <xsl:if test="normalize-space($CHAT_BOT_CARD) and doc-available($CHAT_BOT_CARD)">
        <xsl:variable name="doc-root" select="doc($CHAT_BOT_CARD)/*"/>
        <xsl:choose>
          <xsl:when test="local-name($doc-root) = 'body'">
            <xsl:apply-templates select="$doc-root/*[not(self::title or self::description)]" mode="hdr-ftr-ast"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$doc-root" mode="hdr-ftr-ast"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="chat-card-ast" as="element(ast:node)?" select="$chat-card-ast-all[1]"/>

    <xsl:variable name="chat-form-ast" as="element(ast:node)?">
      <xsl:choose>
        <xsl:when test="normalize-space($CHAT_BOT_FORM) and doc-available($CHAT_BOT_FORM)">
          <xsl:variable name="doc-root" select="doc($CHAT_BOT_FORM)/*"/>
          <xsl:variable name="form-nodes" as="element(ast:node)*">
            <xsl:choose>
              <xsl:when test="local-name($doc-root) = 'body'">
                <xsl:apply-templates select="$doc-root/*[not(self::title or self::description)]" mode="hdr-ftr-ast"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$doc-root" mode="hdr-ftr-ast"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:sequence select="$form-nodes[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$chat-card-ast-all[2]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="footer-ast" as="element(ast:node)?">
      <xsl:if test="normalize-space($FOOTER) and doc-available($FOOTER)">
        <xsl:apply-templates select="doc($FOOTER)/*" mode="hdr-ftr-ast"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="tree" as="element(fn:map)">
      <fn:map>
        <fn:map key="docs-page">
          <xsl:if test="$docs-title != ''">
            <fn:string key="title"><xsl:value-of select="$docs-title"/></fn:string>
          </xsl:if>
          <xsl:if test="$docs-desc != ''">
            <fn:string key="description"><xsl:value-of select="$docs-desc"/></fn:string>
          </xsl:if>
          <xsl:if test="exists($docs-hdr-ast)">
            <xsl:apply-templates select="$docs-hdr-ast" mode="to-fn-json-key">
              <xsl:with-param name="keyName" select="'header'"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:if test="exists($docs-card-ast)">
            <xsl:choose>
              <xsl:when test="count($docs-card-ast) = 1">
                <xsl:apply-templates select="$docs-card-ast" mode="to-fn-json-key">
                  <xsl:with-param name="keyName" select="'card'"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <fn:array key="card">
                  <xsl:apply-templates select="$docs-card-ast" mode="to-fn-json"/>
                </fn:array>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </fn:map>

        <fn:map key="chat-bot">
          <xsl:if test="$chat-title != ''">
            <fn:string key="title"><xsl:value-of select="$chat-title"/></fn:string>
          </xsl:if>
          <xsl:if test="$chat-desc != ''">
            <fn:string key="description"><xsl:value-of select="$chat-desc"/></fn:string>
          </xsl:if>
          <xsl:if test="exists($chat-hdr-ast)">
            <xsl:apply-templates select="$chat-hdr-ast" mode="to-fn-json-key">
              <xsl:with-param name="keyName" select="'header'"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:if test="exists($chat-card-ast)">
            <xsl:apply-templates select="$chat-card-ast" mode="to-fn-json-key">
              <xsl:with-param name="keyName" select="'card'"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:if test="exists($chat-form-ast)">
            <xsl:apply-templates select="$chat-form-ast" mode="to-fn-json-key">
              <xsl:with-param name="keyName" select="'form'"/>
            </xsl:apply-templates>
          </xsl:if>
        </fn:map>

        <xsl:if test="exists($footer-ast)">
          <xsl:apply-templates select="$footer-ast" mode="to-fn-json-key">
            <xsl:with-param name="keyName" select="'footer'"/>
          </xsl:apply-templates>
        </xsl:if>
      </fn:map>
    </xsl:variable>

    <xsl:value-of select="xml-to-json($tree)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Mode to convert include XML templates into ast:node structures -->
  <xsl:template match="*[local-name() = 'title' or local-name() = 'description']" mode="hdr-ftr-ast"/>

  <xsl:template match="*[local-name() = 'document-title']" mode="hdr-ftr-ast">
    <ast:node type="span">
      <ast:text/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[local-name() = 'document-description']" mode="hdr-ftr-ast">
    <ast:node type="span">
      <ast:text/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[local-name() = 'favicon']" mode="hdr-ftr-ast">
    <ast:node type="Favicon">
      <xsl:if test="@*">
        <ast:props>
          <xsl:for-each select="@*">
            <ast:prop name="{name(.)}" value="{.}"/>
          </xsl:for-each>
        </ast:props>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="hdr-ftr-ast"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*" mode="hdr-ftr-ast">
    <ast:node type="{name(.)}">
      <xsl:if test="@*">
        <ast:props>
          <xsl:for-each select="@*">
            <ast:prop name="{name(.)}" value="{.}"/>
          </xsl:for-each>
        </ast:props>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="hdr-ftr-ast"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="text()" mode="hdr-ftr-ast">
    <xsl:if test="normalize-space(.) != ''">
      <ast:text><xsl:value-of select="."/></ast:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
