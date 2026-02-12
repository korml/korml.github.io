<!--
- SPDX-License-Identifier: Apache-2.0
- Copyright (C) 2025 Jayesh Badwaik <j.badwaik@fz-juelich.de>
-->

# Syntax of Korml Language

!!! note

    This page always presents the syntax of the **latest released version** of the korml
    specification. For historical or version-specific syntax, see the [old versions
    page](/syntax/old/). For now, there are no old versions, as the only released version is 1.0,
    but the page will be updated in future.

    Current Version: 1.0 <br>
    Release Date: 2026-02-28

!!! note

    The page describes the syntax of the korml language, as specified in the [Specification
    document](/spec) in a more expository form. It is intended as a reference for users and implementers
    to understand how korml documents are structured and how to write them correctly. Due to the nature
    expository nature of the page, it is not a formal specification, and in case of any discrepancies,
    the formal grammar in the specification document takes precedence.





The syntax for korml is line-oriented and indentation-sensitive. Structural relationships are
determined by indentation, explicit delimiters, and the syntax of mappings, sequences, flow
collections, and scalars. Whitespace, comments, and line endings follow the rules described in the
corresponding subsections. Examples are provided to demonstrate valid forms and invalid forms. As
specified above, they are explanatory and do not replace the formal grammar.

## Overview

A typical korml file looks like show below. One will notice that it is extremely similar to YAML in
its overall structure with some minor differences. Please refer to the [Comparison of Korml and
YAML](#comparison-of-korml-and-yaml) section for a quick overview of the differences.


```yaml
%!korml version 1.0 # mandatory version directive
--- # mandatory document start marker
# Simple key-value mapping
key: value

# Sequence  of items
list:
    - item1
    - item2

# Mapping
object:
    name: "Example"
    count: 42

# Folded block scalar
# This becomes a single line equivalent to:
# folded_block_scalar: "This is a folded block scalar that becomes a single line."
folded_block_scalar: >
    This is a folded
    block scalar that
    becomes a single line.

# Literal block scalar
literal_block: |
    This is a literal
    block scalar that
    preserves line breaks.

# Triple-quoted scalar
# The content inside is taken literally, including newlines and indentation
# and there are no escape sequences except for the delimiter itself.
triple_quoted:
    """
    This is a triple-quoted string. It can span multiple lines and has no special escaping rules.
    It allows for the parser to be much simpler.
    """

... # mandatory document end marker

--- # optional second document
# Another document can follow
... # document end marker
```

A korml file consists of one or more **documents**. A document is composed of nodes of the following
types. Each node has at most one parent, except the root node of a document. The model forms a
finite tree. There are no references between nodes, no shared subtrees, and no cycles. Documents are
independent of each other in multi-document files. There are only three kinds of nodes in the
document model:


- **Scalar Node**
    Represents a single atomic value representing one of the fundamental scalar types:
    - String,
    - Integer
    - Float
    - Boolean
    - Null

    These types are determined by the syntax layer when parsing a scalar literal. Scalar nodes have
    no children and never contain nested structure.

- **Sequence Node**
  Represents an ordered list of nodes. Each list element is itself a node of one of the defined node
  types. The order of elements is preserved exactly as parsed.

- **Mapping Node**
  Represents a collection of key–value pairs. Keys are strings obtained from scalar syntax in key
  position. Values are nodes. The order of entries is preserved. Duplicate keys are invalid unless
  explicitly permitted by an implementation.

These three kinds are the entire data model of Korml. Korml allows two different ways to *write*
sequences and mappings:

- **Block form** — uses indentation (YAML-style)
- **Flow form** — uses brackets (`[...]`, `{...}`) (YAML-style)

The different ways to write sequences and mapping affects only the **syntax**, not the underlying
data. No matter how a value is written, it still represents one of the three node kinds. We will
describe the syntax for each kind of node in both block and flow forms in more detail in the
following sections.


## Version Directive

All korml documents, irrespective of which version of the specification they conform to, must begin
with a version directive of the following form:

```
%!korml x.y
```

Here, `x` and `y` are non-negative integers representing the major and minor version numbers of the
specification, respectively. The version directive must be the very first line of the document, and
must be followed by a newline character. The version directive is mandatory for all korml documents
and serves to indicate which version of the specification the document conforms to.

In conformance with semantic versioning, the major version number (x) indicates breaking changes to
the specification, while the minor version number (y) indicates non-breaking additions. The semantic
versioning rules imply the following compatibility guarantee:

For a fixed major version x, the set of valid KORML documents defined by specification version x.y
is a subset of the set defined by version x.z for all z ≥ y. Therefore, a parser that supports
version x.z can correctly parse documents conforming to version x.y.


## Document Markers

Documents are delimited using explicit markers. Each document contains exactly one root node as
described in the Document Model. A document may optionally begin with a **version directive**, which
identifies the intended korml language version for that document.

1. Version Directive

    A document may begin with a version directive of the form:

    ```yaml
    %!korml <version>
    ```

    The directive applies only to the document that follows it. It must appear before any document
    start marker or document content. The directive is not part of the document’s node tree and has
    no effect on the document’s structure beyond declaring its version. If present in a
    multi-document file, each document must provide its own directive independently. The directive
    is optional; documents without a directive are interpreted according to implementation-defined
    default version rules.

2. Document Start Marker

    A document may begin with the three-dash marker `---`. This marker is required when a file
    contains more than one document. If the marker is omitted, the file is treated as containing a
    single document whose content begins at the first non-empty, non-comment line.

3. Document End Marker

    Every document ends with the three-dot marker `...`. The document end marker is mandatory for
    all documents, including single-document files. After an end marker, the next non-whitespace,
    non-comment content must be either a new `---` start marker or the end of the file. Any other
    content is invalid.

4. Inter-Document Whitespace

    Any number of blank lines and comments may appear:

    - before a version directive
    - before a document start marker
    - after a document end marker

    Such whitespace has no effect on document boundaries. There can not be any other content between
    documents besides comments and blank lines.

### Examples of a Documents



=== "Single Document"

    ```yaml
    %!korml 1.0
    ---
    key: value
    ...
    ```

=== "Two Documents"


    ```yaml
    %!korml 1.0 # All documents use version 1.0
    ---
    key1: value1
    ...
    # Any comment can go here between documents
    # Blank lines are also allowed

    ---
    key2: value2
    ...
    ```


## Scalars

A **Scalar** is the simplest kind of node in a Korml document. It holds a single, indivisible value
with no children and no internal structure. After parsing, each scalar is interpreted as one of the
fundamental scalar types defined in the document model: **String**, **Integer**, **Float**,
**Boolean**, or **Null**. The type assigned to a scalar depends on the concrete syntax used to write
it.

Korml provides several syntactic forms for writing scalar values:

1. **Plain scalars**
2. **Single-quoted scalars**
3. **Double-quoted scalars**
4. **Triple-quoted scalars** (`""" ... """`)
5. **Block scalars** (`|` and `>`)

Except for triple-quoted and block scalars, all scalar syntaxes appear on a single logical line.
Although each form has its own rules and use cases, they all produce the same kind of node in the
document model: a scalar node carrying exactly one fundamental value.

### Plain scalars

Plain scalars are unquoted textual forms. They are the most compact representation and are parsed
according to their spelling. If a plain scalar matches the syntax of an integer, float, boolean, or
null literal, it is interpreted as that type; otherwise it becomes a string. Plain scalars cannot
contain certain characters and cannot span multiple lines.

=== "Valid Plain Scalars"

    ```yaml
    hello          # string (does not match any numeric/boolean/null form)
    true           # boolean
    false          # boolean
    123            # integer (arbitrary length allowed, limited only by implementation)
    -42            # integer
    3.14           # float
    1.0e+6         # float (scientific notation, `e±` with float on one side and int on other)
    1.0e-6         # float (special support for scientific notation)
    "1.0e+6"        # string (quoted, so not a number)
    null           # null
    file_name      # string
    value123       # string (not a number because letters included)
    123abc         # string (not a number because letters included)
    ```

=== "Invalid Plain Scalars (with Valid Alternatives)"

    ```yaml
    hello world         # invalid: plain scalars may not contain spaces; use quotes instead
    "hello world"       # valid: quoted scalar

    ⌴leading-space      # invalid: plain scalars cannot start with a space
    "⌴leading-space"    # valid: quoted scalar

    trailing-space⌴     # invalid: plain scalars cannot end with a space
    "trailing-space⌴"   # valid: quoted scalar

    a:b                 # invalid: ':' not allowed in plain scalars; must use quotes
    "a:b"               # valid: quoted scalar

    item#1              # valid, but probably not intended: '#' starts a comment; use quotes
    "item#1"            # valid: quoted scalar

    [abc]               # invalid: '[' and ']' are reserved characters
    "[abc]"             # valid: quoted scalar

    {key}               # invalid: '{' and '}' are reserved characters
    "{key}"             # valid: quoted scalar

    "unbalanced         # invalid: quote must be closed or removed
    'also-bad           # invalid: same reason

    multi
    line                # invalid: plain scalars cannot span multiple lines
    ```

#### Scalar Semantics

The type of a plain scalar is determined by its syntax:

- An integer is a sequence of digits, optionally preceded by a `-` for negative numbers. There is no
  limit on the number of digits. Leading zeros are not allowed unless the number is exactly `0`. The
  range of integers is unbounded, limited only by implementation constraints.

- A float is a number that includes a decimal point or an exponent. The syntax for floats includes:
  - A sequence of digits with a decimal point (e.g., `3.14`, `0.001`, `-0.5`)
  - A number in scientific notation using `e` or `E` (e.g., `1.0e+6`, `2.5E-3`) Floats must have at
  least one digit before or after the decimal point, and the exponent must be an integer.

- A boolean is either `true` or `false` (case-sensitive).

- A null value is represented by the literal `NULL` (case-sensitive).

- Any plain scalar that does not match the syntax of an integer, float, boolean, or null is interpreted as a
  string. This includes any scalar containing characters that are not valid in the other types, such
  as letters, punctuation (other than `-` and `.`), or reserved characters.

### Quoted scalars

Korml provides three quoted forms for writing string values: **single-quoted**, **double-quoted**, and
**triple-quoted** scalars. Quoted scalars give precise control over how characters appear in the
resulting string and avoid the limitations of plain scalars. Regardless of their contents, every
quoted scalar is interpreted as a value of type **String**.

Quoted forms differ in how they represent characters, how they handle escape sequences, and whether
they permit multiple lines of text. All quoted forms treat the content as strings, even if the
content looks like a number or boolean.


#### Single-quoted scalars

Single-quoted scalars use `'...'` to enclose literal text. They do not interpret escape sequences:
every character between the quotes is taken exactly as written, with the sole exception that two
single quotes in a row represent a literal `'` inside the value. Newlines are not permitted.

Examples:

```yaml
'hello'
'path/to/file'
'It''s correct' # single quote inside the string is represented by two single quotes
```

Single quotes are useful when the intended value contains characters that would otherwise have
syntactic meaning, such as `:`, `#`, or `{`, and when no escape processing is desired.


#### Double-quoted scalars

Double-quoted scalars use `"..."` and allow a small set of escape sequences for common characters.
They do not permit literal newlines; all multi-line content must be encoded using escapes.

Supported escapes:

- `\"` for a literal double quote
- `\\` for a backslash
- `\n` for a newline
- `\t` for a tab character

Examples:

```yaml
"hello"
"Line 1\nLine 2"
"She said \"hi\""
"Tab:\tindent"
```

Double quotes are appropriate when a value needs precise control over special characters or when the
string contains characters that would otherwise need escaping.

#### Triple-quoted scalars


A triple-quoted scalar begins with a line containing only `"""` and ends with another line
containing only `"""`. Both delimiters must appear at the **same indentation level**. Everything
between these two lines is the content of the scalar.

The indentation of the content is determined by the indentation of the opening delimiter. If the
opening `"""` is indented, that indentation establishes a baseline: all content lines have their
leading spaces up to that baseline removed. This allows triple-quoted scalars to be indented within a
mapping or sequence without introducing unwanted leading spaces in the resulting string.

Example (with indentation trimming):

```yaml
key:
  """
  This line begins at column 3 in the source,
  but because the opening delimiter is also at
  column 3, these leading spaces are removed.
    Indentation beyond that baseline is kept.
  """
```

The result is the string:

```
This line begins at column 3 in the source,
but because the opening delimiter is also at
column 3, these leading spaces are removed.
  Indentation beyond that baseline is kept.
```

Triple-quoted scalars treat all characters literally and do not interpret escape sequences, with
**exactly one** exception used to embed the delimiter itself: `\"""` inserts the literal sequence
`"""` without terminating the scalar.

All other backslashes are literal. Example including the delimiter:

```korml
"""
Example: \"""
"""
```

Triple-quoted scalars are intended for text where readability and faithful preservation of formatting
are important, such as embedded documentation, configuration templates, or code blocks.



### Block scalars

Block scalars provide an indentation-based way to write multi-line string values. They come in two
forms:

- `|` for **literal** block scalars, which preserve line breaks
- `>` for **folded** block scalars, which replace line breaks with spaces

Both forms always produce a **String** value.

A block scalar begins with `|` or `>` on its own line (apart from surrounding whitespace), followed
by one or more content lines. Blank lines are **not** allowed inside block scalars. If blank lines
are needed, a triple-quoted scalar must be used instead.


#### Indentation and trimming

The indentation of the indicator line (the line containing `|` or `>`) defines the **block level**.
Every content line must be indented **strictly more** than this level. If any content line is
indented less than or equal to the indicator, the block scalar is invalid.

Block scalars use a single trimming rule:

1. Measure the indentation of the indicator line — call this *I* spaces.
2. Require every content line to have indentation > *I*.
3. On each content line, remove exactly *I* leading spaces.
4. Preserve any remaining indentation exactly as written.

This means block scalars are visually aligned with the document but normalized so that the
indentation of the indicator is *not* part of the resulting text.

**Example:**

```yaml
note:
  |
      Line one
      Line two
        More indentation
```

Here:

* The `|` is indented by 4 spaces, so *I* = 4
* All content lines must be indented at least 5 spaces (which they are)
* Each line loses exactly 4 leading spaces

Result:

```
    Line one
    Line two
      More indentation
```

This preserves relative indentation inside the block while removing structural indentation.


#### Literal block scalars (`|`)

Literal block scalars preserve the structure of the lines exactly:

* each content line becomes one line in the result
* line breaks are preserved as written
* blank lines are not allowed

Example:

```yaml
message: |
  alpha
  beta
  gamma
```

Result:

```
alpha
beta
gamma
```

Literal blocks are best for line-oriented text.

#### Folded block scalars (`>`)

Folded block scalars join multiple content lines into a single line of text. Each newline separating
two content lines becomes a single space in the resulting string.

Because blank lines are not allowed, folded scalars never produce paragraph breaks.

Example:

```yaml
summary: >
  This text is folded.
  It becomes one line.
  Folding is predictable.
```

Result:

```
This text is folded. It becomes one line. Folding is predictable.
```

Folded scalars are useful for long logical lines that are wrapped in the source for readability but
should appear as a single line in the resulting string. Block scalars provide a simple, predictable
mechanism for writing multi-line text without blank lines. When blank lines or arbitrary indentation
are required, triple-quoted scalars should be used instead.



## Sequence nodes

A **Sequence Node** represents an ordered list of nodes. Each element may be any kind of node—
scalar, mapping, or another sequence—and the order of elements is preserved exactly as written.

Korml provides two syntactic forms for sequences:

- **Block sequences**, written using `-` as a list marker
- **Flow sequences**, written using `[ ... ]` with comma-separated elements

Both forms produce the same sequence node in the document model.

---

### Block sequences

Block sequences use indentation to express structure. Each item begins with a `-` at the sequence’s
indentation level. A value may follow the `-` on the same line, or the value may appear on the
following lines as an indented node. Block sequences are well suited for multi-line or nested
structures where readability is more important than compact notation.

Example:

```yaml
items:
  - 10
  - "hello"
  - [nested, list]
  - key: value
```

This creates a sequence of four elements: an integer, a string, a sequence, and a mapping.

!!! note
    A list item may also appear with the `-` on its own line:

    ```korml
    -
      - nested
      - list
    ```
    This form is valid and supported by the grammar, and is useful for deeply nested structures. However,
    it is rarely needed in typical documents, where placing the value on the same line as `-` is usually
    clearer.


---

### Flow sequences

Flow sequences provide a compact inline representation using square brackets. Elements are separated
by commas and may span multiple lines if indentation rules are followed.

Example:

```korml
items: [10, "hello", [nested, list], {key: value}]
```

Flow sequences behave exactly like block sequences, but are typically used when the structure is
simple or when an inline notation is preferred.

---

### Sequence semantics

A sequence node:

* preserves the order of elements
* may contain any number of items
* may mix node types freely
* does not allow empty (blank) items

Once parsed, there is no distinction at the document model level between block and flow forms: both
produce the same node type in the document model.


## Mapping nodes

A **Mapping Node** represents a collection of key–value pairs. Keys are always strings (scalar nodes
of type **String**) and values may be any kind of node. Mappings preserve the order in which entries
appear in the document.

Korml provides two syntactic forms for mappings:

- **Block mappings**, written using indentation
- **Flow mappings**, written using `{ ... }` with comma-separated pairs

Both forms construct the same mapping node in the document model.

---

### Block mappings

Block mappings use indentation to express structure. Each entry consists of a key, followed by a `:`,
optionally followed by a value on the same line. If the value does not appear on that line, or if it
is a complex node, it appears on the following lines as an indented block.

Example:

```korml
person:
  name: "Alice"
  age: 30
  address:
    street: "Main St"
    number: 42
```

Keys must be valid scalar literals. Quoted keys are supported and interpreted as strings:

```yaml
"strange key": value
'other key': 10
```

A mapping entry with no value on the same line is allowed, but the value must follow on indented
lines:

```yaml
config:
  settings:
    feature:
      enabled: true
  metadata:
    kind: test
```

Most mappings will use the standard `key: value` style. Indented values are typically used for
multi-line or nested structures. Duplicate keys are invalid unless explicitly permitted by the
implementation. If allowed, the behavior (for example, last-one-wins) must be defined by that
implementation.

---

### Flow mappings

Flow mappings provide a compact inline form using curly braces. Entries are separated by commas, and
each entry consists of `key: value`.

Example:

```yaml
config: {name: "Alice", age: 30, active: true}
```

Flow mappings may span multiple lines, as long as indentation rules for flow collections are
followed:

```yaml
config: {
  name: "Alice",
  age: 30,
  active: true
}
```

Flow mappings behave exactly like block mappings, but are typically used for short or simple
structures.

---

### Mapping semantics

A mapping node:

* preserves the order of entries as written
* uses **String** keys (regardless of whether they were written plain or quoted)
* allows values of any node type
* rejects duplicate keys unless an implementation defines a policy

Once parsed, the representation in the document model is identical regardless of whether the mapping
was written in block or flow form.

## Comments

Comments allow annotations for humans without affecting the meaning of a document. Korml uses a
single, simple comment form inspired by YAML and many line-oriented configuration languages.

### Line Comments

A comment begins with the `#` character and continues until the end of the line. The `#` may appear
after optional whitespace or after any syntactic element. The comment itself is not part of the data
model and is ignored by the document model. However, for the purpose of round-tripping and
preserving human readability, comments are retained by parsers and emitters. See the


Examples:

```yaml
# A full-line comment

key: value        # Comment after content
list: [1, 2, 3]   # Inline comment

message: |
  Line one        # This is part of the block scalar content, not a comment
  Line two
```

### Comments Inside Scalars

Comments **do not apply inside quoted, triple-quoted, or block scalars**. Inside such constructs,
the `#` character is treated as a literal character and has no special meaning.

Examples:

```yaml
'not a comment # inside quotes'
"also literal # still not a comment"

"""
This # is part of the text.
"""

text: |
  This # is also literal
  because block scalars take the text exactly.
```

### Comment Placement Rules

* Comments **may appear anywhere** a line break is permitted:

  * before or after document markers
  * before or after any node
  * between items of a sequence or mapping
  * as standalone lines for readability

* A comment is syntactically equivalent to an empty line.

* Comments **cannot** appear in the middle of multi-line constructs such as:

  * plain scalars (which cannot span lines),
  * a single-quoted or double-quoted scalar (same-line only),
  * the interior of a triple-quoted scalar,
  * the interior of a block scalar.

* Comments **end the current line** immediately; no further tokens may appear after a `#` outside a scalar.

Example (trailing content after comment):

```yaml
# key2: value is just a part of the comment
key: value # comment here key2: value
```

Valid example:

```yaml
key: value # comment here
```

### Blank Lines

A line consisting only of whitespace and/or a comment is treated as a **blank line**. Blank lines do
not terminate sequences, mappings, or scalars (except block scalars, where blank *content* lines are
not allowed).

## Comparison of Korml and YAML
