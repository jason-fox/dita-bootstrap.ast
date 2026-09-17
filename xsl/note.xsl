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

  <xsl:template match="*[contains(@class, ' topic/note ')]">
    <ast:node type="div">
      <ast:props>
        <!-- data- prefix: not a real div attribute, kept forwardable without a React DOM warning -->
        <ast:prop
          name="data-note-type"
          value="{if (@type = 'other' and @othertype) then @othertype else (@type, 'note')[1]}"
        />
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
