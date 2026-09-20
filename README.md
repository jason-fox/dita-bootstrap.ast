# DITA Bootstrap AST

_DITA Bootstrap AST_ is a [DITA Open Toolkit plug-in](https://www.dita-ot.org/plugins) that walks the same preprocessed topic/map tree as the [DITA Bootstrap](https://dita-bootstrap.github.io) HTML5 transtype, but instead of emitting HTML it serializes each topic (plus a merged TOC) as `[type, props?, ...children]` JSON tuples, shaped so a React app can render them with real `react-bootstrap` components instead of raw HTML.

Adopting a structured JSON AST (Abstract Syntax Tree) with a React rendering harness shift the documentation generation towards an application-centric model. The advantage of an AST + React Approach include a complete decoupling the presentation layer from the
documentation semantic and because the React harness uses components like react-bootstrap, the documentation automatically inherits the exact web application styling, typography, and theme tokens without CSS overrides.

The AST format is recursive and would allow the injection of complex, stateful components into the document hierarchy. Furthermore, structured DITA JSON AST can be combined with MCP-UI (Model Context Protocol UI / MCP Apps standard) to bridge the gap between static technical documentation and AI-driven context delivery.

<!-- MarkdownTOC levels="2,3" -->

- [Installation](#installation)
  - [Installing DITA-OT](#installing-dita-ot)
  - [Installing the Plug-in](#installing-the-plug-in)
- [Using](#using)
- [Parameters](#parameters)
  - [Navigation Menus](#navigation-menus)
  - [Menubar TOC](#menubar-toc)
  - [Running Header and Footer](#running-header-and-footer)
  - [Scrollspy navigation](#scrollspy-navigation)
  - [Breadcrumbs](#breadcrumbs)
  - [Table of Contents Filename](#table-of-contents-filename)
- [License](#license)

<!-- /MarkdownTOC -->

## Installation

The _DITA Bootstrap AST_ plug-in has been tested with [DITA-OT 4.x](https://www.dita-ot.org/download). Use the latest version for best results.

### Installing DITA-OT

1.  Download the latest distribution package from the project website at
    [dita-ot.org/download](https://www.dita-ot.org/download).
2.  Extract the contents of the package to the directory where you want to install DITA-OT.
3.  **Optional**: Add the absolute path for the `bin` directory to the _PATH_ system variable.

    This defines the necessary environment variable to run the `dita` command from the command line.

See the [DITA-OT documentation](https://www.dita-ot.org/dev/topics/installing-client.html) for detailed installation instructions.

### Installing the Plug-in

- Run the plug-in installation commands:

```console
dita install org.dita-bootstrap.ast
```

## Using

Specify the `ast-bootstrap` format when building output with the `dita` command:

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --args.hdr=includes/hdr.navbar.default.xsl \
     --args.ftr=includes/ftr.content.example.xml \
     --menubar-toc.include=yes \
     --output=out
```

This produces one JSON file per topic plus a merged `toc.json`, which a React app can fetch and
render - see [DITA Bootstrap AST Harness](https://github.com/jason-fox/dita-bootstrap.react) for a working example.

## Parameters

Unlike [DITA Bootstrap](https://dita-bootstrap.github.io)'s HTML5 transtype, this plug-in doesn't render any of the
variants below itself - it serializes the DITA-OT input parameter value through to the JSON output as-is, and it's
up to the consuming React app to decide how to render it.

### Navigation Menus

As with `html5-bootstrap`, the standard HTML5 [`--nav-toc`](https://www.dita-ot.org/dev/parameters/parameters-html5.html#html5__nav-toc)
parameter selects the shape of the table of contents. The value is written to `toc.json`'s `navToc` field:

- `none` – No TOC
- `partial` – Partial TOC that shows the current topic, its parents, siblings and children
- `full` – Full TOC for the entire map
- `list-group-partial` – Partial TOC styled as a Bootstrap list group
- `list-group-full` – Full TOC styled as a Bootstrap list group
- `nav-pill-partial` – Partial TOC styled as Bootstrap nav-pills
- `nav-pill-full` – Full TOC styled as Bootstrap nav-pills
- `collapsible` – Full TOC with collapsible list elements (the default)

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --nav-toc=list-group-partial
```

### Menubar TOC

The `--menubar-toc.include` parameter specifies whether top-level menubar navigation is enabled. When set to `yes`, `"menubar": true` is emitted in `toc.json` for the renderer to display top-level menubar links and perform partial sidebar TOC filtering:

- `no` – Menubar is disabled (the default)
- `yes` – Menubar is enabled and `"menubar": true` is serialized in `toc.json`

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --menubar-toc.include=yes
```

### Running Header and Footer

The `--args.hdr` and `--args.ftr` parameters specify XML/XSL files containing header and footer templates. Their AST trees are serialized into `header` and `footer` fields in `toc.json`:

- `--args.hdr` – Specifies an XML file for running header content
- `--args.ftr` – Specifies an XML file for running footer content

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --args.hdr=path/to/header.xml \
     --args.ftr=path/to/footer.xml
```

### Scrollspy navigation

The `--scrollspy-toc` parameter enables an "on this page" navigation entry, built from the current topic's own
nested subtopics and sections. The value is written to `toc.json`'s `scrollspyToc` field, and
each topic that has anything to link to gets its own `scrollspy` array in its JSON:

- `none` – No scrollspy navigation (the default)
- `list` – Plain nested list
- `list-group` – Styled as a Bootstrap list group
- `nav-pill` – Styled as Bootstrap nav-pills

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --scrollspy-toc=list
```

### Breadcrumbs

The `--args.breadcrumbs` parameter, adds a topic breadcrumb trail. Set it to `yes` to
include a `meta.breadcrumbs` array of `{title, href}` entries in each topic's JSON:

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --args.breadcrumbs=yes
```

### Table of Contents Filename

By default, the merged table of contents is written to `toc.json`. Set `--args.ast.toc` to change the base filename
no extension is required.

```console
dita --input=path/to/your.ditamap \
     --format=ast-bootstrap \
     --args.ast.toc=nav
```

## License

[Apache 2.0](LICENSE) © 2026 Jason Fox
