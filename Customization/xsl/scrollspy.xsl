<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="xs ast"
  version="3.0"
>
  <!-- AST counterpart to dita-bootstrap's scrollspy.xsl: an "on this page" nav built from the
       current topic's own structure, reusing the TocEntry shape so the frontend shares code with toc.json. -->

  <xsl:param name="scrollspy-toc" select="'none'"/>

  <!-- root call: applied to the whole topic from xsl/topic.xsl's mode="json-document" template -->
  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="scrollspy">
    <xsl:if test="$scrollspy-toc != 'none'">
      <xsl:apply-templates select="*[contains(@class, ' topic/body ')]" mode="scrollspy"/>
      <xsl:for-each select="*[contains(@class, ' topic/topic ')]">
        <xsl:variable name="title" select="*[contains(@class, ' topic/title ')]"/>
        <xsl:variable name="children" as="element(ast:node)*">
          <xsl:apply-templates select="." mode="scrollspy"/>
        </xsl:variable>
        <ast:node type="TocEntry">
          <ast:props>
            <ast:prop name="title" value="{normalize-space(string($title))}"/>
            <ast:prop name="href" value="{concat('#', ast:scrollspy-title-id($title))}"/>
          </ast:props>
          <xsl:sequence select="$children"/>
        </ast:node>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- only direct children of body: matches scrollspy.xsl's own body-level scope, not sections
       nested inside other sections -->
  <xsl:template match="*[contains(@class, ' topic/body ')]" mode="scrollspy">
    <xsl:for-each
      select="*[@id and *[contains(@class, ' topic/title ')]
                        and (contains(@class, ' topic/section ') or contains(@class, ' topic/example '))]"
    >
      <ast:node type="TocEntry">
        <ast:props>
          <ast:prop name="title" value="{normalize-space(string(*[contains(@class, ' topic/title ')]))}"/>
          <ast:prop name="href" value="{concat('#', ast:element-id(.))}"/>
        </ast:props>
      </ast:node>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
