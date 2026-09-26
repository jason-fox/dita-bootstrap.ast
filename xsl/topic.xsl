<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  exclude-result-prefixes="xs ast"
  version="3.0"
>

  <xsl:function name="ast:is-block" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:variable name="class" select="string($element/@class)"/>
    <xsl:sequence
      select="contains($class, ' topic/body ') or contains($class, ' topic/shortdesc ')
                           or contains($class, ' topic/abstract ') or contains($class, ' topic/title ')
                           or contains($class, ' topic/section ') or contains($class, ' task/info ')
                           or contains($class, ' topic/p ')
                           or (contains($class, ' topic/image ') and $element/@placement = 'break')
                           or contains($class, ' topic/pre ') or contains($class, ' topic/note ')
                           or contains($class, ' topic/fig ') or contains($class, ' topic/dl ')
                           or contains($class, ' topic/sl ') or contains($class, ' topic/ol ')
                           or contains($class, ' topic/ul ') or contains($class, ' topic/li ')
                           or contains($class, ' topic/sli ') or contains($class, ' topic/itemgroup ')
                           or contains($class, ' topic/table ') or contains($class, ' topic/entry ')
                           or contains($class, ' topic/simpletable ') or contains($class, ' topic/stentry ')
                           or contains($class, ' topic/example ')"
    />
  </xsl:function>

  <!-- ===== root document envelope ===== -->
  <xsl:template match="/" mode="json-document">
    <xsl:variable
      name="root-topic"
      select="(/dita/*[contains(@class, ' topic/topic ')] | /*[contains(@class, ' topic/topic ')])[1]"
    />
    <xsl:variable name="meta" as="element(ast:meta)?">
      <xsl:apply-templates select="$root-topic" mode="json-meta"/>
    </xsl:variable>
    <xsl:variable name="content" as="element(ast:node)*">
      <xsl:apply-templates
        select="$root-topic/*[contains(@class, ' glossentry/glossdef ') or contains(@class, ' topic/abstract ')]"
      />
      <xsl:apply-templates select="$root-topic/*[contains(@class, ' topic/body ')]/*"/>
      <!-- nested topics are siblings of body -->
      <xsl:apply-templates select="$root-topic/*[contains(@class, ' topic/topic ')]"/>
    </xsl:variable>
    <xsl:variable name="scrollspy" as="element(ast:node)*">
      <xsl:apply-templates select="$root-topic" mode="scrollspy"/>
    </xsl:variable>
    <xsl:value-of select="ast:serialize-document($meta, $content, $scrollspy)"/>
  </xsl:template>

  <!-- glossdef / abstract -> p (or div) -->
  <xsl:template match="*[contains(@class, ' glossentry/glossdef ') or contains(@class, ' topic/abstract ')]">
    <ast:node type="{if (descendant::*[ast:is-block(.)]) then 'div' else 'p'}">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- nested topic (e.g. task/concept substeps) -> article, matching org.dita.html5's child.topic -->
  <xsl:template match="*[contains(@class, ' topic/topic ')]">
    <ast:node type="article">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/body ')]/*"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"/>
    </ast:node>
  </xsl:template>

  <!-- section.cnt allows #PCDATA directly -->
  <xsl:template match="*[contains(@class, ' topic/section ')]">
    <ast:node type="section">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
      <xsl:apply-templates select="(*[not(contains(@class, ' topic/title '))] | text())"/>
    </ast:node>
  </xsl:template>

  <!-- title -> h{level} (only when rendered as a heading: section/example/fig/topic titles) -->
  <xsl:template match="*[contains(@class, ' topic/title ')]">
    <ast:node type="{concat('h', min((count(ancestor::*[contains(@class, ' topic/topic ')]) + 1, 6)))}">
      <ast:props>
        <!-- only topic titles are scrollspy targets; section/example get their id from @id via
             common-props, fig/dl titles need none -->
        <xsl:if test="parent::*[contains(@class, ' topic/topic ')]">
          <ast:prop name="id" value="{ast:scrollspy-title-id(.)}"/>
        </xsl:if>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- p -> div instead of p when it contains block-level descendants, matching org.dita.html5 -->
  <xsl:template match="*[contains(@class, ' topic/p ')]">
    <ast:node type="{if (descendant::*[ast:is-block(.)]) then 'div' else 'p'}">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- example.cnt allows #PCDATA directly, same as section above -->
  <xsl:template match="*[contains(@class, ' topic/example ')]">
    <ast:node type="div">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
      <xsl:apply-templates select="(*[not(contains(@class, ' topic/title '))] | text())"/>
    </ast:node>
  </xsl:template>

  <!-- div/bodydiv.cnt allow #PCDATA directly, generic grouping containers -->
  <xsl:template match="*[contains(@class, ' topic/div ')] | *[contains(@class, ' topic/bodydiv ')]">
    <ast:node type="div">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- dl -> flat dt/dd siblings (dthd/ddhd alike), matching literal HTML dl structure -->
  <xsl:template match="*[contains(@class, ' topic/dl ')]">
    <ast:node type="dl">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/dlhead ')]">
    <ast:node type="dt">
      <ast:props/>
      <xsl:apply-templates select="*[contains(@class, ' topic/dthd ')]/(*|text())"/>
    </ast:node>
    <ast:node type="dd">
      <ast:props/>
      <xsl:apply-templates select="*[contains(@class, ' topic/ddhd ')]/(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/dlentry ')]">
    <ast:node type="dt">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]/(*|text())"/>
    </ast:node>
    <ast:node type="dd">
      <ast:props/>
      <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]/(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- lq.cnt allows #PCDATA directly; org.dita.html5 renders lq as blockquote -->
  <xsl:template match="*[contains(@class, ' topic/lq ')]">
    <ast:node type="blockquote">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- fn.cnt allows #PCDATA directly; no literal tag fits (org.dita.html5 uses a
       complex numbered-marker + endnote-list system, out of scope) -->
  <xsl:template match="*[contains(@class, ' topic/fn ')]">
    <ast:node type="footnote">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- figgroup.cnt: generic multi-fig grouping, title falls through like fig -->
  <xsl:template match="*[contains(@class, ' topic/figgroup ')]">
    <ast:node type="div">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- whitespace is significant here: flatten to a raw, unnormalized ast:text leaf -->
  <xsl:template match="*[contains(@class, ' topic/lines ')]">
    <ast:node type="p">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <ast:text><xsl:value-of select="string(.)"/></ast:text>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/pre ')]">
    <ast:node type="pre">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="if (@color) then concat('alert alert-', @color) else 'alert alert-secondary'"
          />
        </xsl:call-template>
      </ast:props>
      <ast:text><xsl:value-of select="string(.)"/></ast:text>
    </ast:node>
  </xsl:template>

  <!-- non-DITA embedded content: flattened raw ast:text leaf, not normalized -->
  <xsl:template match="*[contains(@class, ' topic/foreign ')] | *[contains(@class, ' topic/unknown ')]">
    <ast:node type="div">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <ast:text><xsl:value-of select="string(.)"/></ast:text>
    </ast:node>
  </xsl:template>

  <!-- itemgroup.cnt allows #PCDATA directly -->
  <xsl:template match="*[contains(@class, ' topic/itemgroup ')]">
    <ast:node type="span">
      <ast:props>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- unhandled elements: drop rather than error -->
  <xsl:template match="*" priority="-1"/>

</xsl:stylesheet>
