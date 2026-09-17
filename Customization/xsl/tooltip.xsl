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
    match="*[contains(@class, ' bootstrap-d/tooltip ')]
                        | *[contains(@class, ' topic/xref ') and contains(string(@outputclass), 'tooltip-')]"
  >
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/tooltip ')"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable name="desc" select="*[contains(@class, ' topic/desc ')][1]"/>
    <xsl:variable
      name="placement"
      select="(if ($is-specialized) then @position else ()),
                                            (if ($tokens[. = 'tooltip-left']) then 'left'
                                             else if ($tokens[. = 'tooltip-right']) then 'right'
                                             else if ($tokens[. = 'tooltip-bottom']) then 'bottom'
                                             else if ($tokens[. = 'tooltip-top']) then 'top'
                                             else ())[1]"
    />
    <xsl:variable name="resolved-href">
      <xsl:call-template name="href"/>
    </xsl:variable>
    <ast:node type="TooltipTrigger">
      <ast:props>
        <ast:prop name="text" value="{normalize-space(string($desc))}"/>
        <xsl:if test="$placement">
          <ast:prop name="placement" value="{$placement}"/>
        </xsl:if>
        <xsl:if test="$resolved-href != ''">
          <ast:prop name="href" value="{$resolved-href}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <!-- an outputclass="btn-*" trigger needs the literal "btn" base class too - it isn't rendered
               through the real Button component here, so react-bootstrap can't add it automatically -->
          <xsl:with-param name="defaultClass" select="if (exists($tokens[starts-with(., 'btn-')])) then 'btn' else ()"/>
          <xsl:with-param name="stripOutputclass" select="$tokens[starts-with(., 'tooltip')]"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*[not(contains(@class, ' topic/desc '))] | text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
