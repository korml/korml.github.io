<!--
- SPDX-License-Identifier: Apache-2.0
- Copyright (C) 2025 Jayesh Badwaik <j.badwaik@fz-juelich.de>
-->

# Korml - Kosha's Reduced Markup Language


**korml** is a markup language inspired from YAML designed to be simple predictable to read and
write for humans, while also being straightforward to parse and process by machines. It removes some
of the difficult to handle features of YAML in favor of more easy-to-understand constructs. It also
prioritizes ease of round-tripping data through multiple tools without loss of information or
unexpected transformations. A straightforward object model of korml means that the tooling used to
parse and manipulate korml data can expose clean APIs and rich debugging information to the users.

In comparison to YAML, korml omits features that complicate parsing and tooling such as:

1. Complex key types
2. Aliases and anchors
3. Implicit typing and tag resolution
4. Chomping and indentation indicators in block scalars

On the other hand, in order to provide the functionality needed for expressing strings, it add a new
functionality of triple-quoted strings similar to Python's `"""..."""` syntax. This allows for easy
inclusion of multiline text blocks without having to reason about special rules around chomping or
indentation.



