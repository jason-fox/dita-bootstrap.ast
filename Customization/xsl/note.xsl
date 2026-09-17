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

  <!-- type->color default table, from dita-bootstrap's own bootstrap-note logic -->
  <xsl:function name="ast:note-default-color" as="xs:string">
    <xsl:param name="type" as="xs:string?"/>
    <xsl:sequence
      select="if ($type = ('tip', 'fastpath', 'remember')) then 'success'
                           else if ($type = ('restriction', 'important', 'attention', 'caution', 'warning', 'trouble')) then 'warning'
                           else if ($type = 'danger') then 'danger'
                           else if ($type = 'notice') then 'info'
                           else if ($type = 'other') then 'dark'
                           else if ($type = 'note' or empty($type)) then 'primary'
                           else 'info'"
    />
  </xsl:function>

  <!-- @icon wins over an @otherprops "icon(...)" token, which wins over the @type default -->
  <xsl:function name="ast:note-icon-class" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:sequence
      select="if ($node/@icon) then string($node/@icon)
                           else (ast:otherprops-token($node, 'icon'), ast:note-default-icon($node/@type))[1]"
    />
  </xsl:function>

  <!-- @style wins over an @otherprops "style(...)" token -->
  <xsl:function name="ast:note-icon-style" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:sequence select="if ($node/@style) then string($node/@style) else ast:otherprops-token($node, 'style')"/>
  </xsl:function>

  <xsl:template match="*[contains(@class, ' topic/note ')]">
    <xsl:variable name="icon-class" select="ast:note-icon-class(.)"/>
    <xsl:variable name="icon-style" select="ast:note-icon-style(.)"/>
    <!-- @type="other" keeps its label from @othertype; every other type's label comes from the message bundle -->
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="@type = 'other' and @othertype">
          <xsl:value-of select="@othertype"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="type" select="(@type, 'note')[1]"/>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="concat(upper-case(substring($type, 1, 1)), substring($type, 2))"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="color-token" select="tokenize(string(@outputclass), '\s+')[starts-with(., 'alert-')][1]"/>
    <ast:node type="Alert">
      <ast:props>
        <ast:prop name="variant" value="{(ast:resolve-color(., 'alert-'), ast:note-default-color(@type))[1]}"/>
        <!-- "note" is a marker class (not a Bootstrap one): common-bootstrap.css keys its left border off it -->
        <xsl:call-template name="common-props">
          <xsl:with-param name="stripOutputclass" select="$color-token"/>
          <xsl:with-param name="defaultClass" select="'note'"/>
        </xsl:call-template>
      </ast:props>
      <!-- mirrors the real plugin's span.note__title: icon + label + colon, not a heading -->
      <ast:node type="span">
        <ast:props>
          <ast:prop name="className" value="note__title"/>
        </ast:props>
        <xsl:if test="$icon-class">
          <ast:node type="i">
            <ast:props>
              <ast:prop name="className" value="{concat('pe-2 ', $icon-class)}"/>
              <xsl:if test="$icon-style">
                <ast:prop name="style" value="{$icon-style}"/>
              </xsl:if>
            </ast:props>
          </ast:node>
        </xsl:if>
        <ast:text><xsl:value-of select="$label"/><xsl:call-template name="getVariable"><xsl:with-param
              name="id"
              select="'ColonSymbol'"
            /></xsl:call-template></ast:text>
      </ast:node>
      <!-- xsl:text, not a literal space: whitespace-only literal text is stripped when the stylesheet is parsed -->
      <ast:text><xsl:text> </xsl:text></ast:text>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- links inside an Alert are react-bootstrap's Alert.Link component, not InlineLink -->
  <xsl:template
    match="(*[contains(@class, ' topic/xref ')] | *[contains(@class, ' topic/link ')])
                        [ancestor::*[contains(@class, ' topic/note ')]]"
  >
    <xsl:variable name="resolved-href">
      <xsl:call-template name="href"/>
    </xsl:variable>
    <xsl:variable name="is-external" as="xs:boolean" xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:call-template name="is-external-link"/>
    </xsl:variable>
    <ast:node type="AlertLink">
      <ast:props>
        <xsl:if test="$resolved-href != ''">
          <ast:prop name="href" value="{$resolved-href}"/>
        </xsl:if>
        <xsl:call-template name="link-target-props">
          <xsl:with-param name="external" select="$is-external"/>
        </xsl:call-template>
        <xsl:call-template name="common-props"/>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
