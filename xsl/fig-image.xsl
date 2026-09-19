<?xml version="1.0" encoding="UTF-8"?>
<!-- fig -> figure, image -> img -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
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

  <!-- Process a list of images as a single HTML5 Picture element. -->
  <xsl:template
    match="*[contains(@class, ' bootstrap-d/picture ') or (contains(@class, ' topic/div ') and contains(@outputclass, 'd-picture'))]"
  >
    <ast:node type="picture">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="if (contains(@class, ' bootstrap-d/picture ')) then 'div picture' else 'picture'"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:for-each select="*[contains(@class, ' topic/image ')]">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:apply-templates select="."/>
          </xsl:when>
          <xsl:otherwise>
            <ast:node type="source">
              <ast:props>
                <ast:prop name="srcset" value="{@href}"/>
                <xsl:choose>
                  <xsl:when test="@media">
                    <ast:prop name="media" value="{concat('(', @media, ')')}"/>
                  </xsl:when>
                  <xsl:when test="contains(@otherprops, 'media(')">
                    <xsl:variable name="m" select="substring-before(substring-after(@otherprops, 'media('), ')')"/>
                    <ast:prop name="media" value="{concat('(', $m, ')')}"/>
                  </xsl:when>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="@type">
                    <ast:prop name="type" value="{@type}"/>
                  </xsl:when>
                  <xsl:when test="contains(@otherprops, 'type(')">
                    <xsl:variable name="t" select="substring-before(substring-after(@otherprops, 'type('), ')')"/>
                    <ast:prop name="type" value="{$t}"/>
                  </xsl:when>
                </xsl:choose>
              </ast:props>
            </ast:node>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
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
        <xsl:choose>
          <xsl:when test="@loading">
            <ast:prop name="loading" value="{@loading}"/>
          </xsl:when>
          <xsl:when test="contains(@otherprops, 'loading(')">
            <ast:prop name="loading" value="{substring-before(substring-after(@otherprops, 'loading('), ')')}"/>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="@placement">
          <ast:prop name="data-placement" value="{@placement}"/>
        </xsl:if>
        <xsl:if test="@align">
          <ast:prop name="align" value="{@align}"/>
        </xsl:if>
        <xsl:variable name="imageClasses" as="xs:string*">
          <xsl:text>image</xsl:text>
          <xsl:if test="contains(@class, ' bootstrap-d/thumbnail ')">
            <xsl:text>thumbnail</xsl:text>
          </xsl:if>
          <xsl:if test="@scalefit = 'yes'">
            <xsl:text>img-fluid</xsl:text>
          </xsl:if>
          <xsl:if test="@placement = 'break'">
            <xsl:choose>
              <xsl:when test="@align = 'left'">imageleft</xsl:when>
              <xsl:when test="@align = 'right'">imageright</xsl:when>
              <xsl:when test="@align = 'center'">imagecenter</xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:variable>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="string-join($imageClasses, ' ')"/>
        </xsl:call-template>
      </ast:props>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
