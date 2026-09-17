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

  <!-- matches org.dita.html5's actual <pre><code>...</code></pre> nesting -->
  <xsl:template match="*[contains(@class, ' pr-d/codeblock ')]">
    <ast:node type="pre">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="if (@color) then concat('alert alert-', @color) else 'alert alert-secondary'"
          />
        </xsl:call-template>
      </ast:props>
      <ast:node type="code">
        <ast:props/>
        <ast:text><xsl:value-of select="string(.)"/></ast:text>
      </ast:node>
    </ast:node>
  </xsl:template>

  <!-- codeph also carries topic/ph in @class; wins over the generic span fallback via import order -->
  <xsl:template match="*[contains(@class, ' pr-d/codeph ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- pr-d/syntaxdiagram also matches topic/fig; Customization/xsl/figure.xsl excludes it, so this
       plain div wins - but it still gets figure/w-100/mw-100/p-3 since bootstrap-class applies those to any topic/fig element regardless of wrapper. -->
  <xsl:template match="*[contains(@class, ' pr-d/syntaxdiagram ')]">
    <ast:node type="div">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'figure w-100 mw-100 p-3'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="node()"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' pr-d/syntaxdiagram ')]/*[contains(@class, ' topic/title ')]">
    <ast:node type="h3">
      <ast:props/>
      <ast:text><xsl:value-of select="."/></ast:text>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
