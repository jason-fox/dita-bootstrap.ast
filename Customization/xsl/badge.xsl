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

  <xsl:template
    match="*[contains(@class, ' bootstrap-d/badge ')]
                        | *[contains(@class, ' topic/ph ')][ast:has-outputclass-token(., 'badge')]"
  >
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/badge ')"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <!-- "text-bg-{color}" is the current convention; bare "bg-{color}" is still accepted -->
    <xsl:variable name="color-token" select="($tokens[starts-with(., 'text-bg-')], $tokens[starts-with(., 'bg-')])[1]"/>
    <xsl:variable name="color-prefix" select="if (starts-with($color-token, 'text-bg-')) then 'text-bg-' else 'bg-'"/>
    <xsl:variable
      name="bg"
      select="if ($is-specialized) then (ast:resolve-color(., ()), 'primary')[1]
                                     else if ($color-token) then substring-after($color-token, $color-prefix)
                                     else 'primary'"
    />
    <ast:node type="Badge">
      <ast:props>
        <ast:prop name="bg" value="{$bg}"/>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="stripOutputclass"
            select="if ($is-specialized) then 'badge' else ('badge', $color-token)"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
