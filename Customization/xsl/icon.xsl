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

  <xsl:template match="*[contains(@class, ' bootstrap-d/icon ')]">
    <xsl:variable name="icon-class" select="(@icon, @outputclass)[1]"/>
    <ast:node type="i">
      <ast:props>
        <xsl:if test="$icon-class">
          <ast:prop name="className" value="{normalize-space(concat('pe-2 ', $icon-class))}"/>
        </xsl:if>
        <xsl:if test="@style">
          <ast:prop name="style" value="{@style}"/>
        </xsl:if>
      </ast:props>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
