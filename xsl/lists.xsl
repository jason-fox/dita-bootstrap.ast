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

  <!-- empty-list guard -->
  <xsl:template
    match="*[(contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ') or contains(@class, ' topic/sl '))]
                        [not(*[contains(@class, ' topic/li ') or contains(@class, ' topic/sli ')])]"
    priority="10"
  />

  <xsl:template match="*[contains(@class, ' topic/ol ')]">
    <ast:node type="ol">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/li ')]"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/ul ')]">
    <ast:node type="ul">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/li ')]"/>
    </ast:node>
  </xsl:template>

  <!-- org.dita.html5 renders sl as <ul class="simple"> -->
  <xsl:template match="*[contains(@class, ' topic/sl ')]">
    <ast:node type="ul">
      <ast:props>
        <xsl:if test="@id">
          <ast:prop name="id" value="{@id}"/>
        </xsl:if>
        <ast:prop name="className" value="{string-join(('simple', @outputclass), ' ')}"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/sli ')]"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/li ')]">
    <ast:node type="li">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/sli ')]">
    <ast:node type="li">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
