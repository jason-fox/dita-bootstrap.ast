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
    match="*[contains(@class, ' bootstrap-d/carousel ')]
                        | *[(contains(@class, ' topic/ul ') or contains(@class, ' topic/ol '))
                            and ast:has-outputclass-token(., 'carousel')]"
  >
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/carousel ')"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable name="is-fade" select="if ($is-specialized) then @fade = 'yes' else 'carousel-fade' = $tokens"/>
    <xsl:variable
      name="autoplay-off"
      select="if ($is-specialized) then @autoplay = 'no' else ast:otherprops-token(., 'autoplay') = 'false'"
    />
    <xsl:variable
      name="touch-off"
      select="if ($is-specialized) then @touch = 'no' else ast:otherprops-token(., 'touch') = 'false'"
    />
    <xsl:variable
      name="indicators-on"
      select="if ($is-specialized) then @indicators = 'yes' else ast:otherprops-token(., 'indicators') = 'true'"
    />
    <xsl:variable
      name="interval"
      select="if ($is-specialized) then @interval else ast:otherprops-token(., 'interval')"
    />
    <xsl:variable name="items" select="*[contains(@class, ' topic/li ')]"/>
    <ast:node type="Carousel">
      <ast:props>
        <xsl:if test="$is-fade">
          <ast:prop name="fade" type="boolean" value="true"/>
        </xsl:if>
        <ast:prop name="indicators" type="boolean" value="{if ($indicators-on) then 'true' else 'false'}"/>
        <xsl:choose>
          <xsl:when test="$autoplay-off">
            <ast:prop name="interval" type="null"/>
          </xsl:when>
          <xsl:when test="$interval">
            <ast:prop name="interval" type="number" value="{$interval}"/>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="$touch-off">
          <ast:prop name="touch" type="boolean" value="false"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="if ($is-specialized) then () else 'carousel'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="$items" mode="carousel-item"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/li ')]" mode="carousel-item">
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/carousel-item ')"/>
    <xsl:variable
      name="item-interval"
      select="if ($is-specialized) then @interval else ast:otherprops-token(., 'interval')"
    />
    <xsl:variable name="images" select="*[contains(@class, ' topic/image ')]"/>
    <xsl:variable name="figs" select="*[contains(@class, ' topic/fig ')]"/>
    <ast:node type="CarouselItem">
      <ast:props>
        <xsl:if test="$item-interval">
          <ast:prop name="interval" type="number" value="{$item-interval}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="if ($is-specialized) then () else 'carousel-item'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:choose>
        <!-- fig-wrapped image: caption comes from the fig's title, not the image itself -->
        <xsl:when test="$figs">
          <xsl:for-each select="$figs">
            <xsl:call-template name="carousel-image">
              <xsl:with-param name="image" select="*[contains(@class, ' topic/image ')][1]"/>
            </xsl:call-template>
            <xsl:if test="*[contains(@class, ' topic/title ')]">
              <ast:node type="CarouselCaption">
                <ast:props/>
                <ast:node type="p">
                  <ast:props/>
                  <xsl:apply-templates select="*[contains(@class, ' topic/title ')]/(*|text())"/>
                </ast:node>
              </ast:node>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="count($images) = 1">
          <xsl:call-template name="carousel-image">
            <xsl:with-param name="image" select="$images[1]"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="count($images) > 1">
          <ast:node type="div">
            <ast:props>
              <ast:prop name="className" value="row"/>
            </ast:props>
            <xsl:variable
              name="col-class"
              select="if (count($images) = 2) then 'col-6'
                                                    else if (count($images) = 3) then 'col-4'
                                                    else 'col-3'"
            />
            <xsl:for-each select="$images">
              <ast:node type="div">
                <ast:props>
                  <ast:prop name="className" value="{$col-class}"/>
                </ast:props>
                <xsl:call-template name="carousel-image">
                  <xsl:with-param name="image" select="."/>
                </xsl:call-template>
              </ast:node>
            </xsl:for-each>
          </ast:node>
        </xsl:when>
      </xsl:choose>
      <!-- non-image content (e.g. a grid-row of caption text) renders alongside the image(s) as usual -->
      <xsl:apply-templates select="(* except ($images | $figs))[not(contains(@class, ' topic/title '))]"/>
    </ast:node>
  </xsl:template>

  <!-- react-bootstrap's own carousel images always carry 'd-block w-100', unlike a plain inline/block image -->
  <xsl:template name="carousel-image">
    <xsl:param name="image" as="element()?"/>
    <xsl:if test="$image">
      <ast:node type="img">
        <ast:props>
          <ast:prop name="src" value="{$image/@href}"/>
          <xsl:variable name="alt" select="($image/*[contains(@class, ' topic/alt ')], $image/@alt)[1]"/>
          <xsl:if test="$alt">
            <ast:prop name="alt" value="{normalize-space(string($alt))}"/>
          </xsl:if>
          <xsl:for-each select="$image">
            <xsl:call-template name="common-props">
              <xsl:with-param name="defaultClass" select="'d-block w-100'"/>
            </xsl:call-template>
          </xsl:for-each>
        </ast:props>
      </ast:node>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
