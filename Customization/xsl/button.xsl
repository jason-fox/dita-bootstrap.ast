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

  <!-- a "toggle" button/xref (offcanvas-toggle, collapse-toggle) is handled by its own component's Customization file instead -->
  <xsl:template
    match="*[contains(@class, ' bootstrap-d/button ')][not(ast:has-props-token(., 'offcanvas-toggle') or ast:has-props-token(., 'collapse-toggle'))]
                        | *[contains(@class, ' topic/xref ')][exists(tokenize(string(@outputclass), '\s+')[starts-with(., 'btn-')])][not(ast:has-props-token(., 'offcanvas-toggle') or ast:has-props-token(., 'collapse-toggle'))]"
  >
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/button ')"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <!-- the variant token is whichever btn-* token isn't the sm/lg size marker -->
    <xsl:variable name="variant-token" select="$tokens[starts-with(., 'btn-')][not(. = ('btn-sm', 'btn-lg'))][1]"/>
    <xsl:variable name="size-token" select="$tokens[. = ('btn-sm', 'btn-lg')][1]"/>
    <xsl:variable name="variant" select="ast:button-variant(.)"/>
    <xsl:variable name="size" select="ast:button-size(.)"/>
    <xsl:variable name="resolved-href">
      <xsl:call-template name="href"/>
    </xsl:variable>
    <xsl:variable name="is-external" as="xs:boolean">
      <xsl:call-template name="is-external-link"/>
    </xsl:variable>
    <ast:node type="Button">
      <ast:props>
        <ast:prop name="variant" value="{$variant}"/>
        <xsl:if test="$size">
          <ast:prop name="size" value="{$size}"/>
        </xsl:if>
        <xsl:if test="$resolved-href != ''">
          <ast:prop name="href" value="{$resolved-href}"/>
        </xsl:if>
        <xsl:call-template name="link-target-props">
          <xsl:with-param name="external" select="$is-external"/>
        </xsl:call-template>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="stripOutputclass"
            select="if ($is-specialized) then 'btn' else ($variant-token, $size-token)"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
