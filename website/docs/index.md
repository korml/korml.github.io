<!--
- SPDX-License-Identifier: Apache-2.0
- Copyright (C) 2025 Jayesh Badwaik <j.badwaik@fz-juelich.de>
-->

# Documentation


| FROM ↓ | TO KS  | TO LTS | TO AST | TO KDM |
|--------|--------|--------|--------|--------|
| **KS** | —      | lex    | parse  | loads  |
| **LTS**| unlex  | —      | —      | —      |
| **AST**| emit   | —      | —      | —      |
| **KDM**| dumps  | —      | —      | —      |

Full layer names:

- **KS**: Korml Source
- **LTS**: Lexical Token Stream
- **CST**: Concrete Syntax Tree
- **AST**: Abstract Syntax Tree
- **KDM**: Korml Data Model


Engines:

- **lexer**: Lexical Analyzer
- **parser**: Syntax Analyzer
- **builder**: AST builder
- **analyzer**: Korml Data Model Loader
