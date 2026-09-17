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

  <xsl:template match="*[contains(@class, ' topic/table ')]">
    <xsl:variable
      name="frame-class"
      select="if (@frame = 'sides') then 'border-start border-end pt-3 px-3'
                                              else if (@frame = 'top') then 'border-top pt-3'
                                              else if (@frame = 'bottom') then 'border-bottom pt-3 px-3'
                                              else if (@frame = 'topbot') then 'border-top border-bottom pt-3 px-3'
                                              else if (@frame = 'all') then 'border pt-3 px-3'
                                              else if (@frame = 'none') then 'border-0 pt-3 px-3'
                                              else ()"
    />
    <xsl:variable name="color" select="ast:table-color(.)"/>
    <xsl:variable name="tokens" select="tokenize(string(@outputclass), '\s+')"/>
    <xsl:variable
      name="border-class"
      select="if (@colsep = '1' and @rowsep = '1') then 'table-bordered'
                                               else if (@colsep = '0' and @rowsep = '0') then 'table-borderless'
                                               else ()"
    />
    <ast:node type="div">
      <ast:props>
        <xsl:if test="$frame-class">
          <ast:prop name="className" value="{$frame-class}"/>
        </xsl:if>
      </ast:props>
      <ast:node type="Table">
        <ast:props>
          <xsl:if test="@striped = 'yes'">
            <ast:prop name="striped" type="boolean" value="true"/>
          </xsl:if>
          <xsl:if test="@striped-columns = 'yes'">
            <ast:prop name="striped" value="columns"/>
          </xsl:if>
          <xsl:if test="@compact = 'yes'">
            <ast:prop name="size" value="sm"/>
          </xsl:if>
          <xsl:if test="$color">
            <ast:prop name="variant" value="{$color}"/>
          </xsl:if>
          <xsl:call-template name="common-props">
            <xsl:with-param name="defaultClass" select="$border-class"/>
            <xsl:with-param
              name="stripOutputclass"
              select="if ($color) then $tokens[starts-with(., 'table-')] else ()"
            />
          </xsl:call-template>
        </ast:props>
        <xsl:apply-templates select=".//*[contains(@class, ' topic/thead ')]"/>
        <xsl:apply-templates select=".//*[contains(@class, ' topic/tbody ')]"/>
      </ast:node>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/thead ')]">
    <xsl:variable name="color" select="ast:table-color(.)"/>
    <ast:node type="thead">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="if ($color) then concat('table-', $color) else ()"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/row ')]">
        <xsl:with-param name="header" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/tbody ')]">
    <xsl:variable name="color" select="ast:table-color(.)"/>
    <xsl:variable name="table" select="ancestor::*[contains(@class, ' topic/table ')][1]"/>
    <ast:node type="tbody">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="string-join((if ($table/@divider = 'yes') then 'table-group-divider' else (),
                                                                    if ($color) then concat('table-', $color) else ()), ' ')"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/row ')]"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/row ')]">
    <xsl:param name="header" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="color" select="ast:table-color(.)"/>
    <!-- Bootstrap's tables reset the legacy HTML valign-on-<tr> cascade, so it needs a real utility class here
         (entry/<td> keeps its own @valign attribute below - that one still renders fine as-is) -->
    <xsl:variable name="valign-class" select="if (@valign) then concat('align-', @valign) else ()"/>
    <ast:node type="tr">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="string-join(($valign-class, if ($color) then concat('table-', $color) else ()), ' ')"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="*[contains(@class, ' topic/entry ')]">
        <xsl:with-param name="header" select="$header" tunnel="yes"/>
      </xsl:apply-templates>
    </ast:node>
  </xsl:template>

  <!-- th vs td conveys "header" directly via the tag, so no separate prop is needed -->
  <xsl:template match="*[contains(@class, ' topic/entry ')]">
    <xsl:param name="header" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="color" select="ast:table-color(.)"/>
    <ast:node type="{if ($header) then 'th' else 'td'}">
      <ast:props>
        <xsl:if test="@morerows">
          <ast:prop name="rowSpan" type="number" value="{xs:integer(@morerows) + 1}"/>
        </xsl:if>
        <!-- align: own value only; tgroup/colspec cascade not implemented (TODO) -->
        <xsl:if test="@align">
          <ast:prop name="align" value="{@align}"/>
        </xsl:if>
        <xsl:variable
          name="valign"
          select="(@valign,
                                              ../@valign,
                                              ancestor::*[contains(@class, ' topic/tbody ') or contains(@class, ' topic/thead ')][1]/@valign)[1]"
        />
        <xsl:if test="$valign">
          <ast:prop name="valign" value="{$valign}"/>
        </xsl:if>
        <xsl:if test="@rotate">
          <ast:prop name="data-rotate" type="boolean" value="{if (@rotate = 'yes') then 'true' else 'false'}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="if ($color) then concat('table-', $color) else ()"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
