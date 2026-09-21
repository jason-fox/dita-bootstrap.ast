<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA Bootstrap AST plug-in for DITA Open Toolkit.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">

  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
  <!-- dita-utilities.xsl already includes functions.xsl; don't import it separately -->
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>

  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/serializer.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/common-attributes.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/get-meta.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/nav.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/topic.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/note.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/lists.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/tables.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/simpletable.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/fig-image.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/rel-links.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/inline.xsl"/>

  <!-- must import after inline.xsl: hi-d/b|i|u also carry topic/ph in @class -->
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/hi-d.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:xsl/pr-d.xsl"/>

  <dita:extension
    id="dita.xsl.ast-bootstrap"
    behavior="org.dita.dost.platform.ImportXSLAction"
    xmlns:dita="http://dita-ot.sourceforge.net"
  />

  <!-- Bootstrap overrides, imported last so they win over the baseline templates above -->
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/breadcrumb.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/scrollspy.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/theme.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/icon.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/note.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/alert.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/badge.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/button.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/card.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/accordion.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/tabs.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/carousel.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/figure.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/offcanvas.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/collapse.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/pagination.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/tooltip.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/popover.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/table.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/interactiveTable.xsl"/>
  <xsl:import href="plugin:org.dita-bootstrap.ast:Customization/xsl/keyword.xsl"/>

</xsl:stylesheet>
