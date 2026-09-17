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

  <xsl:template name="common-props">
    <!-- element's own DTD-default/marker outputclass token(s) (e.g. 'card', or 'btn-primary btn-lg' for the outputclass-driven path); react-bootstrap applies these via bsPrefix/props, so strip them here -->
    <xsl:param name="stripOutputclass" as="xs:string*" select="()" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <!-- a caller-supplied base class (e.g. codeblock's 'alert alert-secondary'), mirroring dita-bootstrap's own default-output-class param -->
    <xsl:param name="defaultClass" as="xs:string?" select="()" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <xsl:if test="@id">
      <ast:prop name="id" value="{@id}"/>
    </xsl:if>
    <xsl:variable
      name="own-classes"
      select="if (exists($stripOutputclass))
                                              then string-join(tokenize(string(@outputclass), '\s+')[not(. = $stripOutputclass)], ' ')
                                              else string(@outputclass)"
    />
    <!-- @margin/@padding/@shadow (e.g. margin="t3") aren't outputclass tokens but expand to the same utility classes -->
    <xsl:variable
      name="classes"
      select="normalize-space(string-join(($defaultClass, $own-classes, ast:decoration-classes(.)), ' '))"
    />
    <xsl:if test="$classes != ''">
      <ast:prop name="className" value="{$classes}"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
