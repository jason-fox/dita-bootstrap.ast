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

  <xsl:template
    match="*[contains(@class, ' topic/table ')][contains(@otherprops, 'search') or contains(@otherprops, 'sortable') or contains(@otherprops, 'pagination') or contains(@otherprops, 'export') or contains(@otherprops, 'column-toggle') or contains(@otherprops, 'sticky-header')]"
    priority="5"
  >
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
      <ast:node type="InteractiveTable">
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

          <!-- Interactivity flags -->
          <xsl:if test="contains(@otherprops, 'search')">
            <ast:prop name="searchable" type="boolean" value="true"/>
          </xsl:if>
          <xsl:if test="contains(@otherprops, 'sortable')">
            <ast:prop name="sortable" type="boolean" value="true"/>
          </xsl:if>
          <xsl:if test="contains(@otherprops, 'pagination')">
            <ast:prop name="paginated" type="boolean" value="true"/>
            <xsl:variable
              name="pageSize"
              select="if (contains(@otherprops, 'pagination-100')) then '100'
                      else if (contains(@otherprops, 'pagination-50')) then '50'
                      else if (contains(@otherprops, 'pagination-25')) then '25'
                      else if (contains(@otherprops, 'pagination-10')) then '10'
                      else '10'"
            />
            <ast:prop name="pageSize" type="number" value="{$pageSize}"/>
          </xsl:if>
          <xsl:if test="contains(@otherprops, 'export') or contains(@otherprops, 'export-csv')">
            <ast:prop name="exportable" type="boolean" value="true"/>
          </xsl:if>
          <xsl:if test="contains(@otherprops, 'column-toggle') or contains(@otherprops, 'col-vis')">
            <ast:prop name="columnToggle" type="boolean" value="true"/>
          </xsl:if>
          <xsl:if test="contains(@otherprops, 'sticky-header')">
            <ast:prop name="stickyHeader" type="boolean" value="true"/>
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

</xsl:stylesheet>
