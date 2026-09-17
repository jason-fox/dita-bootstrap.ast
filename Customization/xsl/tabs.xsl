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
    match="*[ast:is-tabbed-dialog(.) and not(@style = 'vertical-pills') and not(contains(string(@outputclass), 'nav-pills-vertical'))]"
  >
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <!-- specialized <tabbed-dialog> signals pills via @style; the outputclass path via a 'nav-pills' token -->
    <xsl:variable
      name="nav-variant"
      select="if (@style = 'pills' or contains(string(@outputclass), 'nav-pills')) then 'pills' else 'tabs'"
    />
    <xsl:variable name="items" select="*[contains(@class, ' topic/section ')]"/>
    <ast:node type="TabContainer">
      <ast:props>
        <ast:prop name="defaultActiveKey" value="{($items[1]/@id, 'tab-0')[1]}"/>
      </ast:props>
      <ast:node type="Nav">
        <ast:props>
          <ast:prop name="variant" value="{$nav-variant}"/>
          <!-- Tab.Container (the parent node) renders no DOM element, so id/className/margin
               classes belong here on Nav - it's what actually renders role="tablist" -->
          <xsl:call-template name="common-props">
            <xsl:with-param name="stripOutputclass" select="$tokens[. = ('nav-tabs', 'nav-pills')]"/>
            <xsl:with-param name="defaultClass" select="'tabbed-dialog'"/>
          </xsl:call-template>
        </ast:props>
        <xsl:apply-templates select="$items" mode="tab-nav-item">
          <xsl:with-param name="items" select="$items" tunnel="yes"/>
        </xsl:apply-templates>
      </ast:node>
      <ast:node type="TabContent">
        <ast:props/>
        <xsl:apply-templates select="$items" mode="tab-pane">
          <xsl:with-param name="items" select="$items" tunnel="yes"/>
        </xsl:apply-templates>
      </ast:node>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/section ')]" mode="tab-nav-item">
    <xsl:param name="items" tunnel="yes"/>
    <xsl:variable name="event-key" select="(@id, concat('tab-', count($items[. &lt;&lt; current()])))[1]"/>
    <ast:node type="NavItem">
      <ast:props/>
      <ast:node type="NavLink">
        <ast:props>
          <ast:prop name="eventKey" value="{$event-key}"/>
        </ast:props>
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]/(*|text())"/>
      </ast:node>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/section ')]" mode="tab-pane">
    <xsl:param name="items" tunnel="yes"/>
    <xsl:variable name="event-key" select="(@id, concat('tab-', count($items[. &lt;&lt; current()])))[1]"/>
    <ast:node type="TabPane">
      <ast:props>
        <ast:prop name="eventKey" value="{$event-key}"/>
      </ast:props>
      <xsl:apply-templates select="(*[not(contains(@class, ' topic/title '))] | text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
