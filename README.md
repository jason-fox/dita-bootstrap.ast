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
     --output=out
```

This produces one JSON file per topic plus a merged `toc.json`, which a React app can fetch and
render - see [DITA Bootstrap AST Harness](https://github.com/jason-fox/dita-bootstrap.react) for a working example.

## License

[Apache 2.0](LICENSE) © 2026 Jason Fox
