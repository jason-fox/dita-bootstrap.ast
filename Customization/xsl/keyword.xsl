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

  <!-- pr-d elements specializing topic/keyword directly: class="keyword {name}" -->
  <xsl:template match="*[contains(@class, ' pr-d/option ')]">
    <xsl:call-template name="ast:keyword-span"><xsl:with-param name="name" select="'option'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/parmname ')]">
    <xsl:call-template name="ast:keyword-span"><xsl:with-param name="name" select="'parmname'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/apiname ')]">
    <xsl:call-template name="ast:keyword-span"><xsl:with-param name="name" select="'apiname'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/kwd ')]">
    <xsl:call-template name="ast:keyword-span"><xsl:with-param name="name" select="'kwd'"/></xsl:call-template>
  </xsl:template>
  <!-- cmdname is software domain (sw-d), not pr-d, but is still topic/keyword-based -->
  <xsl:template match="*[contains(@class, ' sw-d/cmdname ')]">
    <xsl:call-template name="ast:keyword-span"><xsl:with-param name="name" select="'cmdname'"/></xsl:call-template>
  </xsl:template>

  <xsl:template name="ast:keyword-span">
    <xsl:param name="name" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <ast:node type="span">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="concat('keyword ', $name)"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- these pr-d elements specialize topic/ph, not topic/keyword: class="ph {name}" -->
  <xsl:template match="*[contains(@class, ' pr-d/var ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'var'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/synph ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'synph'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/oper ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'oper'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/delim ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'delim'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/sep ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'sep'"/></xsl:call-template>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/repsep ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'repsep'"/></xsl:call-template>
  </xsl:template>
  <!-- filepath is software domain (sw-d), not pr-d, but is still topic/ph-based -->
  <xsl:template match="*[contains(@class, ' sw-d/filepath ')]">
    <xsl:call-template name="ast:ph-span"><xsl:with-param name="name" select="'filepath'"/></xsl:call-template>
  </xsl:template>

  <xsl:template name="ast:ph-span">
    <xsl:param name="name" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
    <ast:node type="span">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="concat('ph ', $name)"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- pr-d/codeph overrides the base xsl/pr-d.xsl <code> template, only to add the "ph codeph" class -->
  <xsl:template match="*[contains(@class,' pr-d/codeph ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'ph codeph'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- Overrides pr-d.xsl's flattened <pre><code>: routes children through their own templates
       (mode="codeblock-content") instead of string(.), keeping nested markup and raw whitespace. -->
  <xsl:template match="*[contains(@class, ' pr-d/codeblock ')]">
    <ast:node type="pre">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="if (@color) then concat('alert alert-', @color) else 'alert alert-secondary'"
          />
        </xsl:call-template>
      </ast:props>
      <ast:node type="code">
        <ast:props/>
        <xsl:apply-templates select="(*|text())" mode="codeblock-content"/>
      </ast:node>
    </ast:node>
  </xsl:template>

  <xsl:template match="text()" mode="codeblock-content">
    <ast:text><xsl:value-of select="."/></ast:text>
  </xsl:template>

  <xsl:template match="*" mode="codeblock-content">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <!-- topic/term is a base DITA element (not a domain specialization), so its ancestry is just "term" -->
  <xsl:template match="*[contains(@class, ' topic/term ')]">
    <ast:node type="dfn">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'term'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- xml-d elements all specialize markup-d/markupname (itself a topic/keyword specialization):
       class="keyword markupname {name}", each with its own literal punctuation wrapping -->
  <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'keyword markupname xmlatt'"/>
        </xsl:call-template>
      </ast:props>
      <ast:text>@</ast:text>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <!-- plain <markupname> or <xmlelement> (the other xml-d specializations below have their own templates) -->
  <xsl:template
    match="*[contains(@class, ' markup-d/markupname ')]
                        [not(contains(@class, ' xml-d/xmlatt ') or contains(@class, ' xml-d/xmlpi ')
                             or contains(@class, ' xml-d/xmlnsname ') or contains(@class, ' xml-d/textentity ')
                             or contains(@class, ' xml-d/parameterentity ') or contains(@class, ' xml-d/numcharref '))]"
  >
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param
            name="defaultClass"
            select="concat('keyword markupname', if (contains(@class, ' xml-d/xmlelement ')) then ' xmlelement' else '')"
          />
        </xsl:call-template>
      </ast:props>
      <ast:text>&lt;</ast:text>
      <xsl:apply-templates select="(*|text())"/>
      <ast:text>&gt;</ast:text>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/xmlnsname ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'keyword markupname xmlnsname'"/>
        </xsl:call-template>
      </ast:props>
      <xsl:apply-templates select="(*|text())"/>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'keyword markupname xmlpi'"/>
        </xsl:call-template>
      </ast:props>
      <ast:text>&lt;?</ast:text>
      <xsl:apply-templates select="(*|text())"/>
      <ast:text>?&gt;</ast:text>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/textentity ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'keyword markupname textentity'"/>
        </xsl:call-template>
      </ast:props>
      <ast:text>&amp;</ast:text>
      <xsl:apply-templates select="(*|text())"/>
      <ast:text>;</ast:text>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'keyword markupname parameterentity'"/>
        </xsl:call-template>
      </ast:props>
      <ast:text>%</ast:text>
      <xsl:apply-templates select="(*|text())"/>
      <ast:text>;</ast:text>
    </ast:node>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]">
    <ast:node type="code">
      <ast:props>
        <xsl:call-template name="common-props">
          <xsl:with-param name="defaultClass" select="'keyword markupname numcharref'"/>
        </xsl:call-template>
      </ast:props>
      <ast:text>&amp;#</ast:text>
      <xsl:apply-templates select="(*|text())"/>
      <ast:text>;</ast:text>
    </ast:node>
  </xsl:template>

</xsl:stylesheet>
