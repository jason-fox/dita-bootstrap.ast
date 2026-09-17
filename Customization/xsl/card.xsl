<?xml version="1.0" encoding="UTF-8"?>
<!-- bootstrap-d/card, or topic/section[outputclass~=card] -> Card + flat CardHeader/CardImg/CardBody/CardFooter children -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="xs"
  version="3.0"
>

  <xsl:template
    match="*[contains(@class, ' bootstrap-d/card ')]
                        | *[contains(@class, ' topic/section ')][ast:has-outputclass-token(., 'card')]"
  >
    <xsl:variable
      name="header"
      select="*[contains(@class, ' bootstrap-d/card-header ')
                                           or (contains(@class, ' topic/div ') and ast:has-outputclass-token(., 'card-header'))]"
    />
    <xsl:variable
      name="footer"
      select="*[contains(@class, ' bootstrap-d/card-footer ')
                                           or (contains(@class, ' topic/div ') and ast:has-outputclass-token(., 'card-footer'))]"
    />
    <xsl:variable name="images" select="*[contains(@class, ' topic/image ')]"/>
    <!-- "the first image within a card places an image to the top" - no outputclass required; an explicit
         card-img-bottom token overrides, matching plugins/dita-bootstrap.specialization/sample/card.dita -->
    <xsl:variable
      name="explicit-bottom"
      select="$images[contains(concat(' ', @outputclass, ' '), ' card-img-bottom ')]"
    />
    <xsl:variable name="explicit-top" select="$images[contains(concat(' ', @outputclass, ' '), ' card-img-top ')]"/>
    <xsl:variable name="top-image" select="($explicit-top, $images[not(. is $explicit-bottom[1])])[1]"/>
    <xsl:variable name="bottom-image" select="$explicit-bottom[not(. is $top-image)][1]"/>
    <xsl:variable name="title" select="*[contains(@class, ' topic/title ')]"/>
    <xsl:variable
      name="body"
      select="*[not(. is $header) and not(. is $footer)
                                        and not(. is $top-image) and not(. is $bottom-image)
                                        and not(. is $title)]
                                       | text()"
    />
    <xsl:variable name="color" select="ast:resolve-color(., ())"/>
    <!-- cards default to a fixed width unless the author already sized it themselves -->
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable name="width-class" select="if (@width or exists($tokens[starts-with(., 'w-')])) then () else 'w-50'"/>
    <ast:node type="Card">
      <ast:props>
        <xsl:if test="@bordercolor">
          <ast:prop name="border" value="{@bordercolor}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <!-- @color is a literal "alert alert-{color}" treatment here, not react-bootstrap's Card
               bg prop (a solid text-bg-{color} fill) - matches dita-bootstrap's own pastel card look -->
          <xsl:with-param
            name="defaultClass"
            select="string-join(($width-class, if ($color) then concat('alert p-0 alert-', $color) else ()), ' ')"
          />
          <xsl:with-param name="stripOutputclass" select="'card'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:if test="$header">
        <ast:node type="CardHeader">
          <ast:props>
            <xsl:for-each select="$header">
              <xsl:call-template name="common-props">
                <xsl:with-param name="stripOutputclass" select="'card-header'"/>
              </xsl:call-template>
            </xsl:for-each>
          </ast:props>
          <xsl:apply-templates select="$header/(*|text())"/>
        </ast:node>
      </xsl:if>
      <xsl:if test="$top-image">
        <xsl:apply-templates select="$top-image[1]" mode="card-img">
          <xsl:with-param name="variant" select="'top'"/>
        </xsl:apply-templates>
      </xsl:if>
      <ast:node type="CardBody">
        <ast:props/>
        <xsl:if test="$title">
          <ast:node type="CardTitle">
            <ast:props/>
            <xsl:apply-templates select="$title/(*|text())"/>
          </ast:node>
        </xsl:if>
        <xsl:apply-templates select="$body"/>
      </ast:node>
      <xsl:if test="$bottom-image">
        <xsl:apply-templates select="$bottom-image[1]" mode="card-img">
          <xsl:with-param name="variant" select="'bottom'"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$footer">
        <ast:node type="CardFooter">
          <ast:props>
            <xsl:for-each select="$footer">
              <xsl:call-template name="common-props">
                <xsl:with-param name="stripOutputclass" select="'card-footer'"/>
              </xsl:call-template>
            </xsl:for-each>
          </ast:props>
          <xsl:apply-templates select="$footer/(*|text())"/>
        </ast:node>
      </xsl:if>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/image ')]" mode="card-img">
    <xsl:param name="variant" as="xs:string"/>
    <ast:node type="CardImg">
      <ast:props>
        <ast:prop name="variant" value="{$variant}"/>
        <ast:prop name="src" value="{@href}"/>
        <xsl:if test="@alt">
          <ast:prop name="alt" value="{@alt}"/>
        </xsl:if>
      </ast:props>
    </ast:node>
  </xsl:template>

  <!-- xref outputclass="card-link" -> Card.Link; only an outputclass convention exists (no specialized element) -->
  <xsl:template match="*[contains(@class, ' topic/xref ')][ast:has-outputclass-token(., 'card-link')]">
    <xsl:variable name="resolved-href">
      <xsl:call-template name="href"/>
    </xsl:variable>
    <xsl:variable name="is-external" as="xs:boolean">
      <xsl:call-template name="is-external-link"/>
    </xsl:variable>
    <ast:node type="CardLink">
      <ast:props>
        <xsl:if test="$resolved-href != ''">
          <ast:prop name="href" value="{$resolved-href}"/>
        </xsl:if>
        <xsl:call-template name="link-target-props">
          <xsl:with-param name="external" select="$is-external"/>
        </xsl:call-template>
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="'card-link'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
