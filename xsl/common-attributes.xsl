<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0"
>

  <xsl:function name="dita-ot:generate-id" as="xs:string">
    <xsl:param name="topic" as="xs:string?"/>
    <xsl:param name="element" as="xs:string?"/>
    <xsl:sequence select="string-join(($topic, $element), '__')"/>
  </xsl:function>

  <xsl:function name="dita-ot:normalize-href" as="xs:string?">
    <xsl:param name="href" as="xs:string"/>
    <xsl:sequence select="replace(translate($href, '\', '/'), ' ', '%20')"/>
  </xsl:function>

  <xsl:function name="ast:element-id" as="xs:string">
    <xsl:param name="element" as="element()"/>
    <xsl:choose>
      <xsl:when test="contains($element/@class, ' topic/topic ')">
        <xsl:sequence select="string($element/@id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="dita-ot:generate-id($element/ancestor::*[contains(@class, ' topic/topic ')][1]/@id, $element/@id)"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="ast:scrollspy-title-id" as="xs:string">
    <xsl:param name="title" as="element()"/>
    <xsl:choose>
      <xsl:when test="$title/@id">
        <xsl:sequence select="dita-ot:generate-id($title/parent::*/@id, $title/@id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="n" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <xsl:number
            select="$title"
            count="*[contains(@class, ' topic/title ')][parent::*[contains(@class, ' topic/topic ')]]"
            level="any"
          />
        </xsl:variable>
        <xsl:sequence select="concat('ariaid-title', $n)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="common-props">
    <xsl:param name="stripOutputclass" as="xs:string*" select="()" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <xsl:param name="defaultClass" as="xs:string?" select="()" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <xsl:param name="skipLang" as="xs:boolean" select="false()" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <xsl:if test="@id">
      <ast:prop name="id" value="{ast:element-id(.)}"/>
    </xsl:if>
    <xsl:if test="@dir">
      <ast:prop name="dir" value="{@dir}"/>
    </xsl:if>
    <xsl:if test="@xml:lang and not($skipLang)">
      <ast:prop name="lang" value="{@xml:lang}"/>
    </xsl:if>
    <xsl:variable
      name="own-classes"
      select="if (exists($stripOutputclass))
                                              then string-join(tokenize(string(@outputclass), '\s+')[not(. = $stripOutputclass)], ' ')
                                              else string(@outputclass)"
    />
    <xsl:variable
      name="classes"
      select="normalize-space(string-join(($defaultClass, $own-classes, ast:decoration-classes(.)), ' '))"
    />
    <xsl:if test="$classes != ''">
      <ast:prop name="className" value="{$classes}"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
