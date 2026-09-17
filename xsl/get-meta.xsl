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

  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="json-meta">
    <xsl:variable name="shortdesc-text" as="xs:string?" xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' topic/shortdesc ')]">
          <xsl:sequence select="string(*[contains(@class, ' topic/shortdesc ')][1])"/>
        </xsl:when>
        <xsl:when test="*[contains(@class, ' topic/abstract ')]/*[contains(@class, ' topic/shortdesc ')]">
          <xsl:sequence
            select="string(*[contains(@class, ' topic/abstract ')][1]/*[contains(@class, ' topic/shortdesc ')][1])"
          />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <ast:meta>
      <ast:prop name="title" value="{string(*[contains(@class, ' topic/title ')][1])}"/>
      <xsl:if test="$shortdesc-text">
        <ast:prop name="shortdesc" value="{$shortdesc-text}"/>
      </xsl:if>
      <xsl:call-template name="common-props"/>
    </ast:meta>
  </xsl:template>

</xsl:stylesheet>
