<!--
- SPDX-License-Identifier: Apache-2.0
- Copyright (C) 2025 Jayesh Badwaik <j.badwaik@fz-juelich.de>
-->

# EBNf Specification of Korml Language

We present here the EBNF specification of the Korml language. We separate the
specification of the Korml language into two parts:

1. The lexical structure
2. The syntactical structure

and we write grammars for each part separately. This separation allows us to use the common logic
and code for lexical analysis for both the DOM and SAX parsers for Korml.



