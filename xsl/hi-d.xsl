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

  <xsl:template match="*[contains(@class, ' hi-d/b ')]">
    <ast:node type="strong">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' hi-d/i ')]">
    <ast:node type="em">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' hi-d/u ')]">
    <ast:node type="u">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
