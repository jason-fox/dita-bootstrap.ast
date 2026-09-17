<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ast="http://dita-ot.sourceforge.net/dita-bootstrap-ast"
  version="3.0"
>

  <xsl:function name="ast:resolve-color" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="prefix" as="xs:string?"/>
    <xsl:variable
      name="token"
      as="xs:string?"
      select="if ($prefix and $node/@outputclass)
                          then tokenize($node/@outputclass, '\s+')[starts-with(., $prefix)][1]
                          else ()"
    />
    <xsl:sequence
      select="($node/@color,
                           if ($token) then substring-after($token, $prefix) else ())[1]"
    />
  </xsl:function>

  <!-- exact whitespace-delimited outputclass token match, e.g. 'card' does not match 'card-header' -->
  <xsl:function name="ast:has-outputclass-token" as="xs:boolean">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="token" as="xs:string"/>
    <xsl:sequence select="boolean($node/@outputclass) and ($token = tokenize(string($node/@outputclass), '\s+'))"/>
  </xsl:function>

  <!-- exact whitespace-delimited @props token match, e.g. props="offcanvas-toggle" -->
  <xsl:function name="ast:has-props-token" as="xs:boolean">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="token" as="xs:string"/>
    <xsl:sequence select="boolean($node/@props) and ($token = tokenize(string($node/@props), '\s+'))"/>
  </xsl:function>

  <!-- shared with offcanvas.xsl's toggle button, which needs the same variant as a plain bootstrap-d/button -->
  <xsl:function name="ast:button-variant" as="xs:string">
    <xsl:param name="node" as="element()"/>
    <xsl:variable name="is-specialized" select="contains($node/@class, ' bootstrap-d/button ')"/>
    <xsl:variable name="tokens" select="tokenize(string($node/@outputclass), '\s+')"/>
    <xsl:variable name="variant-token" select="$tokens[starts-with(., 'btn-')][not(. = ('btn-sm', 'btn-lg'))][1]"/>
    <xsl:sequence
      select="if ($is-specialized)
                           then concat(if ($node/@outline = 'yes') then 'outline-' else '', (ast:resolve-color($node, ()), 'primary')[1])
                           else substring-after($variant-token, 'btn-')"
    />
  </xsl:function>

  <xsl:function name="ast:button-size" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:variable name="is-specialized" select="contains($node/@class, ' bootstrap-d/button ')"/>
    <xsl:variable name="tokens" select="tokenize(string($node/@outputclass), '\s+')"/>
    <xsl:variable name="size-token" select="$tokens[. = ('btn-sm', 'btn-lg')][1]"/>
    <xsl:sequence
      select="if ($is-specialized)
                           then (if ($node/@size = 'small') then 'sm' else if ($node/@size = 'large') then 'lg' else ())
                           else if ($size-token) then substring-after($size-token, 'btn-') else ()"
    />
  </xsl:function>

  <!-- closest @color/outputclass "table-*" token, checking entry -> row -> thead/tbody/tfoot -> table in turn -->
  <xsl:function name="ast:table-color" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:variable
      name="chain"
      select="reverse($node/ancestor-or-self::*[contains(@class, ' topic/entry ')
                                                                          or contains(@class, ' topic/row ')
                                                                          or contains(@class, ' topic/thead ')
                                                                          or contains(@class, ' topic/tbody ')
                                                                          or contains(@class, ' topic/tfoot ')
                                                                          or contains(@class, ' topic/table ')])"
    />
    <xsl:sequence select="(for $n in $chain return ast:resolve-color($n, 'table-'))[1]"/>
  </xsl:function>

  <!-- a button/xref that toggles a target elsewhere on the page (an Offcanvas or a Collapse), keyed by
       id through the frontend's shared ToggleContext rather than Bootstrap's data-bs-toggle JS -->
  <xsl:template name="ast:render-toggle-button">
    <xsl:param name="target" as="xs:string"/>
    <ast:node type="ToggleButton">
      <ast:props>
        <ast:prop name="target" value="{$target}"/>
        <ast:prop name="variant" value="{ast:button-variant(.)}"/>
        <xsl:variable name="size" select="ast:button-size(.)"/>
        <xsl:if test="$size">
          <ast:prop name="size" value="{$size}"/>
        </xsl:if>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="stripOutputclass"
            select="if (contains(@class, ' bootstrap-d/button ')) then 'btn' else ()"
          />
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- true for the specialized <alert>, or a plain section styled via outputclass="alert-{color}" -->
  <xsl:function name="ast:is-alert" as="xs:boolean">
    <xsl:param name="node" as="element()"/>
    <xsl:sequence
      select="contains($node/@class, ' bootstrap-d/alert ')
                           or (contains($node/@class, ' topic/section ')
                               and exists(tokenize(string($node/@outputclass), '\s+')[starts-with(., 'alert-')]))"
    />
  </xsl:function>

  <!-- true for the specialized <tabbed-dialog>, or a bodydiv styled via outputclass="nav-tabs"/"nav-pills" -->
  <xsl:function name="ast:is-tabbed-dialog" as="xs:boolean">
    <xsl:param name="node" as="element()"/>
    <xsl:sequence
      select="contains($node/@class, ' bootstrap-d/tabbed-dialog ')
                           or (contains($node/@class, ' topic/bodydiv ')
                               and (contains(string($node/@outputclass), 'nav-tabs')
                                    or contains(string($node/@outputclass), 'nav-pills')))"
    />
  </xsl:function>

  <!-- true for the specialized <offcanvas>, or a section styled via outputclass="offcanvas-{placement}" -->
  <xsl:function name="ast:is-offcanvas" as="xs:boolean">
    <xsl:param name="node" as="element()"/>
    <xsl:sequence
      select="contains($node/@class, ' bootstrap-d/offcanvas ')
                           or (contains($node/@class, ' topic/section ') and contains(string($node/@outputclass), 'offcanvas-'))"
    />
  </xsl:function>

  <!-- pull one name(value) token out of @otherprops, e.g. otherprops="icon(bi-search), style(color: red;)" -->
  <xsl:function name="ast:otherprops-token" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:variable name="marker" select="concat($name, '(')"/>
    <xsl:variable
      name="after"
      select="if ($node/@otherprops and contains(string($node/@otherprops), $marker))
                                        then substring-after(string($node/@otherprops), $marker)
                                        else ()"
    />
    <xsl:sequence select="if ($after) then normalize-space(substring-before($after, ')')) else ()"/>
  </xsl:function>

  <!-- bi-* icon class for a note's default @type, mirroring dita-bootstrap's own bootstrap-icon table -->
  <xsl:function name="ast:note-default-icon" as="xs:string?">
    <xsl:param name="type" as="xs:string?"/>
    <xsl:sequence
      select="if ($type = 'tip') then 'bi bi-lightbulb'
                           else if ($type = 'fastpath') then 'bi bi-shield-check'
                           else if ($type = 'remember') then 'bi bi-clipboard-check'
                           else if ($type = 'restriction') then 'bi bi-slash-circle'
                           else if ($type = 'important') then 'bi bi-exclamation-circle-fill'
                           else if ($type = ('attention', 'caution', 'warning', 'trouble', 'danger')) then 'bi bi-exclamation-triangle'
                           else if ($type = 'notice') then 'bi bi-info-circle-fill'
                           else if ($type = 'note' or empty($type)) then 'bi bi-pencil'
                           else ()"
    />
  </xsl:function>

  <!-- one @margin/@padding token (e.g. 't3', 'x-2', 'auto') -> its Bootstrap utility class -->
  <xsl:function name="ast:spacing-token-class" as="xs:string?">
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:param name="token" as="xs:string"/>
    <xsl:sequence
      select="if (matches($token, '^[etbsxy](-?\d+|auto)$'))
                           then concat($prefix, substring($token, 1, 1), '-', translate(substring($token, 2), '-', 'n'))
                           else if (contains($token, '-')) then $token
                           else concat($prefix, '-', $token)"
    />
  </xsl:function>

  <!-- @color -> a utility class, only for elements that don't turn it into a semantic prop
       themselves (Alert's variant, Badge's bg, ...); mirrors dita-bootstrap's get-output-class. -->
  <xsl:function name="ast:color-class" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:variable name="class" select="string($node/@class)"/>
    <xsl:variable
      name="is-btn-outputclass"
      select="exists(tokenize(string($node/@outputclass), '\s+')[starts-with(., 'btn-')])"
    />
    <xsl:choose>
      <xsl:when test="not($node/@color)"/>
      <xsl:when
        test="(contains($class, ' topic/xref ') or contains($class, ' topic/link '))
                       and not(contains($class, ' bootstrap-d/button ')) and not($is-btn-outputclass)"
      >
        <xsl:sequence select="concat('link-', $node/@color)"/>
      </xsl:when>
      <xsl:when
        test="contains($class, ' topic/note ') or contains($class, ' topic/pre ')
                       or contains($class, ' topic/xref ') or contains($class, ' topic/link ')
                       or contains($class, ' bootstrap-d/card ') or contains($class, ' bootstrap-d/alert ')
                       or contains($class, ' bootstrap-d/badge ') or contains($class, ' bootstrap-d/list-group ')
                       or contains($class, ' bootstrap-d/carousel ') or contains($class, ' bootstrap-d/button ')
                       or contains($class, ' topic/table ') or contains($class, ' topic/thead ')
                       or contains($class, ' topic/tbody ') or contains($class, ' topic/tfoot ')
                       or contains($class, ' topic/row ') or contains($class, ' topic/entry ')"
      />
      <xsl:otherwise>
        <xsl:sequence select="concat('text-bg-', $node/@color)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- @margin/@padding/@shadow -> spacing/shadow utility classes, mirroring dita-bootstrap's decoration
       template. @padding is skipped on note/pre/card/alert, which use it for other purposes. -->
  <xsl:function name="ast:decoration-classes" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:variable name="margin-classes" as="xs:string*">
      <xsl:for-each select="tokenize(normalize-space(string($node/@margin)), '\s+')[. != '']">
        <xsl:sequence select="ast:spacing-token-class('m', .)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="padding-classes" as="xs:string*">
      <xsl:if
        test="$node/@padding and not(contains($node/@class, ' topic/note ')
                                            or contains($node/@class, ' topic/pre ')
                                            or contains($node/@class, ' bootstrap-d/card ')
                                            or contains($node/@class, ' bootstrap-d/alert '))"
      >
        <xsl:for-each select="tokenize(normalize-space(string($node/@padding)), '\s+')[. != '']">
          <xsl:sequence select="ast:spacing-token-class('p', .)"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <xsl:variable
      name="shadow-class"
      select="if ($node/@shadow = 'yes') then 'shadow'
                                               else if ($node/@shadow = ('no', 'none')) then 'shadow-none'
                                               else if ($node/@shadow) then concat('shadow-', $node/@shadow)
                                               else ()"
    />
    <xsl:variable name="color-class" select="ast:color-class($node)"/>
    <xsl:sequence
      select="if (exists($margin-classes) or exists($padding-classes) or exists($shadow-class) or exists($color-class))
                           then string-join(($margin-classes, $padding-classes, $shadow-class, $color-class), ' ')
                           else ()"
    />
  </xsl:function>

</xsl:stylesheet>
