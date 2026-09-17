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

  <xsl:template
    match="*[contains(@class, ' bootstrap-d/accordion ')]
                        | *[contains(@class, ' topic/bodydiv ')][tokenize(string(@outputclass), '\s+') = ('accordion', 'accordion-flush', 'accordion-open')]"
  >
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/accordion ')"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable name="always-open" select="if ($is-specialized) then @open = 'yes' else 'accordion-open' = $tokens"/>
    <!-- outputclass path: each direct topic/section child is one item; "show" token signals it starts open -->
    <xsl:variable
      name="items"
      select="if ($is-specialized)
                                        then *[contains(@class, ' bootstrap-d/accordion-item ')]
                                        else *[contains(@class, ' topic/section ')]"
    />
    <xsl:variable
      name="open-items"
      select="if ($is-specialized)
                                             then $items[@open = 'yes']
                                             else $items[tokenize(string(@outputclass), '\s+') = 'show']"
    />
    <ast:node type="Accordion">
      <ast:props>
        <xsl:if test="if ($is-specialized) then @flush = 'yes' else 'accordion-flush' = $tokens">
          <ast:prop name="flush" type="boolean" value="true"/>
        </xsl:if>
        <xsl:if test="$always-open">
          <ast:prop name="alwaysOpen" type="boolean" value="true"/>
        </xsl:if>
        <xsl:if test="$open-items">
          <xsl:choose>
            <xsl:when test="$always-open">
              <ast:prop-array name="defaultActiveKey">
                <xsl:for-each select="$open-items">
                  <ast:item value="{(@id, concat('item-', count($items[. &lt;&lt; current()])))[1]}"/>
                </xsl:for-each>
              </ast:prop-array>
            </xsl:when>
            <xsl:otherwise>
              <ast:prop
                name="defaultActiveKey"
                value="{($open-items[1]/@id, concat('item-', count($items[. &lt;&lt; $open-items[1]])))[1]}"
              />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="stripOutputclass"
            select="if ($is-specialized) then 'accordion' else $tokens[. = ('accordion', 'accordion-flush', 'accordion-open')]"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="$items" mode="accordion-item">
        <xsl:with-param name="items" select="$items" tunnel="yes"/>
      </xsl:apply-templates>
    </ast:node>
  </xsl:template>

  <xsl:template
    match="*[contains(@class, ' bootstrap-d/accordion-item ')] | *[contains(@class, ' topic/section ')]"
    mode="accordion-item"
  >
    <xsl:param name="items" tunnel="yes"/>
    <xsl:variable name="is-specialized" select="contains(@class, ' bootstrap-d/accordion-item ')"/>
    <xsl:variable name="event-key" select="(@id, concat('item-', count($items[. &lt;&lt; current()])))[1]"/>
    <ast:node type="AccordionItem">
      <ast:props>
        <ast:prop name="eventKey" value="{$event-key}"/>
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="if ($is-specialized) then 'accordion-item' else 'show'"/>
        </xsl:call-template>
      </ast:props>
      <ast:node type="AccordionHeader">
        <ast:props/>
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]/(*|text())"/>
      </ast:node>
      <ast:node type="AccordionBody">
        <ast:props/>
        <xsl:apply-templates select="(*[not(contains(@class, ' topic/title '))] | text())"/>
      </ast:node>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
