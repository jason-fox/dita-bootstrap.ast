<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  version="3.0"
>

  <xsl:template
    match="*[contains(@class, ' topic/simpletable ')]
                        [not(*[contains(@class, ' topic/strow ') or contains(@class, ' topic/sthead ')])]"
    priority="10"
  />

  <xsl:template match="*[contains(@class, ' topic/simpletable ')]">
    <ast:node type="table">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/sthead ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/strow ')]"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/sthead ')]">
    <ast:node type="thead">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <ast:node type="tr">
        <ast:props/>
        <xsl:apply-templates select="*[contains(@class, ' topic/stentry ')]">
          <xsl:with-param name="header" select="true()" tunnel="yes"/>
        </xsl:apply-templates>
      </ast:node>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/strow ')]">
    <ast:node type="tr">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/stentry ')]"/>
    </ast:node>
  </xsl:template>

  <!-- th vs td conveys "header" directly via the tag, so no separate prop is needed -->
  <xsl:template match="*[contains(@class, ' topic/stentry ')]">
    <xsl:param name="header" as="xs:boolean?" tunnel="yes"/>
    <ast:node type="{if ($header) then 'th' else 'td'}">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
