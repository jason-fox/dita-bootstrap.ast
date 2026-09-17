<?xml version="1.0" encoding="UTF-8"?>
<!-- fig -> figure, image -> img -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  version="3.0"
>

  <xsl:template match="*[contains(@class, ' topic/fig ')]">
    <ast:node type="figure">
      <ast:props>
        <xsl:if test="@frame">
          <ast:prop name="data-frame" value="{@frame}"/>
        </xsl:if>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
      <xsl:apply-templates
        select="node() except *[contains(@class, ' topic/title ') or contains(@class, ' topic/desc ')]"
      />
    </ast:node>
  </xsl:template>

  <!-- block and inline placement both render as a plain img; "placement" prop preserves the distinction -->
  <xsl:template match="*[contains(@class, ' topic/image ')]">
    <ast:node type="img">
      <ast:props>
        <ast:prop name="src" value="{@href}"/>
        <xsl:variable name="alt" as="xs:string?" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <xsl:choose>
            <xsl:when test="*[contains(@class, ' topic/alt ')]">
              <xsl:sequence select="normalize-space(string(*[contains(@class, ' topic/alt ')][1]))"/>
            </xsl:when>
            <xsl:when test="@alt">
              <xsl:sequence select="@alt"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$alt">
          <ast:prop name="alt" value="{$alt}"/>
        </xsl:if>
        <!-- width/height are DITA NMTOKEN, not necessarily numeric (e.g. "50%"); passed through as-is, matching org.dita.html5 -->
        <xsl:if test="@width">
          <ast:prop name="width" value="{@width}"/>
        </xsl:if>
        <xsl:if test="@height">
          <ast:prop name="height" value="{@height}"/>
        </xsl:if>
        <xsl:if test="@placement">
          <ast:prop name="data-placement" value="{@placement}"/>
        </xsl:if>
        <xsl:if test="@align">
          <ast:prop name="align" value="{@align}"/>
        </xsl:if>
        <xsl:call-template name="common-props"/>
      </ast:props>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
