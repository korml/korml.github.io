<!--
- SPDX-License-Identifier: Apache-2.0
- Copyright (C) 2025 Jayesh Badwaik <j.badwaik@fz-juelich.de>
-->

# Specification of Korml Language

!!! note

    This page always presents the grammar of the **latest released version** of the korml
    specification. For historical or version-specific grammars, see the [old versions
    page](/spec/old/). For now, there are no old versions, as the only released version is 1.0, but
    the page will be updated in future.

    Current Version: 1.0 <br>
    Release Date: 2026-02-28



In this document, we define the syntax of the Korml language using an extended Backus-Naur Form
(EBNF) grammar. There are different variants of BNF and EBNF used in literature. In this document,
we use the following conventions:

- `{ ... }` denotes zero or more repetitions of the enclosed element.
- `? ... ?` denotes a text description which is not part of the grammar.
- `x*` dnotes one or more repetitions of `x`.

The grammar for the Korml language is divided into two main sections, the lexer grammar and the
high-level parser grammar. The separation allows us to make the round-trip functions either for
parser or lexer more easily.

## Lexer Grammar

The grammar for the lexical structure of Korml is almost $LL(0)$, except for

1. indentation-based tokens (INDENT, DEDENT) which are produced by the indentation stack logic in
   the lexer,

2. the `DASH_ITEM` token which is produced by a state-based rule in the lexer


```ebnf
(********************************************************************************)
(* 1. CHARACTER CLASSES (used only inside the lexer, not emitted as tokens)     *)
(********************************************************************************)

(* Set of digit characters *)
Digit              = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

(* Whitespace and newline characters *)
HSpace             = " " | "\t" ;
NEWLINE_CHAR       = "\n" ;
InnerSpace         = " " ;

(* Special characters used in korml syntax *)
SpecialChar        = ":" | "#" | "{" | "}" | "[" | "]" | "'" | '"' ;

NonSpecialChar     = ? any character except HSpace, NEWLINE_CHAR, SpecialChar ? ;


(********************************************************************************)
(* 2. LOW-LEVEL LEXER TOKENS: WHITESPACE, COMMENT, NEWLINE                      *)
(********************************************************************************)

WS                 = HSpace { HSpace } ;

CommentText        = { ? any character except NEWLINE_CHAR ? } ;

COMMENT            = "#" [CommentText] ;

NEWLINE            = NEWLINE_CHAR ;

EOF                = ? end of file ? ;


(********************************************************************************)
(* 3. INDENTATION TOKENS (Python-style)                                         *)
(*    (produced by indentation stack logic)                                     *)
(********************************************************************************)

LeadingWS          = [WS] ;

INDENT             = (* produced when indentation increases from previous line *) ;
DEDENT             = (* produced when indentation decreases from previous line *) ;


(********************************************************************************)
(* 4. SCALAR TOKENS                                                             *)
(********************************************************************************)

(* 4.1 Plain scalar *)
PlainChar          = NonSpecialChar | InnerSpace ;
PlainScalarText    = PlainChar { PlainChar } ;
PLAIN_SCALAR       = PlainScalarText ;

(* 4.2 Single-quoted scalar *)
SingleQuotedChar   =
      "''"
    | ? any character except "'" and NEWLINE_CHAR ? ;

SQ_SCALAR          = "'" SingleQuotedChar* "'" ;

(* 4.3 Double-quoted scalar *)
DoubleEscape       = '"' | "\\" | "n" | "t" ;

DoubleQuotedChar   =
      "\\" DoubleEscape
    | ? any character except '"' and NEWLINE_CHAR ? ;

DQ_SCALAR          = '"' DoubleQuotedChar* '"' ;

(* 4.4 Triple-quoted scalar *)
TripleQuote        = '"""' ;

TripleContentChar  = ? any character except end-of-file ? ;

TQ_SCALAR          =
    TripleQuote NEWLINE_CHAR
    { TripleContentChar NEWLINE_CHAR }*
    TripleQuote NEWLINE_CHAR ;

(* 4.5 Block scalar *)
BlockHeader        = ("|" | ">") HSpace* NEWLINE_CHAR ;
BlockScalarLine    = { ? any character except NEWLINE_CHAR ? } NEWLINE_CHAR ;

BLOCK_SCALAR       =
    BlockHeader
    { BlockScalarLine } ;


(********************************************************************************)
(* 5. PUNCTUATION, DIRECTIVES, DOCUMENT MARKERS                                 *)
(********************************************************************************)

LBRACE             = "{" ;
RBRACE             = "}" ;
LBRACKET           = "[" ;
RBRACKET           = "]" ;
COLON              = ":" ;
COMMA              = "," ;

VERSION_DIRECTIVE  =
    "%!korml" WS Digit { Digit | "." } NEWLINE_CHAR ;

DOC_START          = "---" HSpace* NEWLINE_CHAR ;
DOC_END            = "..." HSpace* NEWLINE_CHAR ;


(********************************************************************************)
(* 6. SEQUENCE DASH_ITEM TOKEN                                                   *)
(*    (state-based rule: dash at line-start indent = DASH_ITEM)                 *)
(********************************************************************************)

DASH_ITEM          = "-" ( HSpace | NEWLINE_CHAR ) ;


(********************************************************************************)
(* 7. LEXER START SYMBOLS (Only for documentation purposes)                     *)
(*    (These define the entry points for lexing; ordering/priority is impl.)    *)
(********************************************************************************)

(* One token (common “start” for tokenization) *)
Token =
    (*--- layout / trivia ---------------------------------------------------*)
      WS
    | COMMENT
    | NEWLINE

    (*--- indentation control (generated) -----------------------------------*)
    | INDENT
    | DEDENT

    (*--- document structure / directives -----------------------------------*)
    | VERSION_DIRECTIVE
    | DOC_START
    | DOC_END

    (*--- flow punctuation ---------------------------------------------------*)
    | LBRACE
    | RBRACE
    | LBRACKET
    | RBRACKET
    | COLON
    | COMMA

    (*--- block sequence control --------------------------------------------*)
    | DASH_ITEM

    (*--- scalar forms -------------------------------------------------------*)
    | TQ_SCALAR
    | BLOCK_SCALAR
    | SQ_SCALAR
    | DQ_SCALAR
    | PLAIN_SCALAR;

(* Whole file token stream *)
TokenStream = { Token } EOF ;
```

## High-Level Grammar

```ebnf
(********************************************************************************)
(* 1. PARSER HELPERS (WS, COMMENT, LINEEND, INTER-DOCUMENT WS, EMPTY)           *)
(********************************************************************************)

empty =
    ? empty production (no tokens) ? ;

WSOpt =
      WS { WS }
    | empty ;

COMMENTOpt =
      COMMENT
    | empty ;

LineEnd =
    WSOpt COMMENTOpt NEWLINE ;

InterDocumentWS =
    { WSOpt COMMENTOpt NEWLINE } ;

InterDocumentWSOpt =
      InterDocumentWS
    | empty ;


(********************************************************************************)
(* 2. TOP-LEVEL DOCUMENT STRUCTURE                                              *)
(********************************************************************************)

DocumentStream =
    ( InterDocumentWSOpt Document )
    { InterDocumentWS Document }
    InterDocumentWSOpt EOF ;

Document =
    VERSION_DIRECTIVE
    DOC_START
    Node
    DOC_END ;


(********************************************************************************)
(* 3. NODES AND BLOCK STRUCTURE                                                 *)
(********************************************************************************)

Node =
      Scalar
    | FlowMapping
    | FlowSequence
    | BlockNode ;

BlockNode =
    INDENT BlockNodeBody DEDENT ;

BlockNodeBody =
      MappingEntryPlus
    | SequenceItemPlus ;

MappingEntryPlus =
    MappingEntry { MappingEntry } ;

SequenceItemPlus =
    SequenceItem { SequenceItem } ;


(********************************************************************************)
(* 4. MAPPING ENTRIES                                                          *)
(********************************************************************************)

MappingEntry =
    Key WSOpt COLON MappingEntryTail ;

MappingEntryTail =
      WSOpt InlineValue LineEnd
      [NestedNode]

    | WSOpt LineEnd
      NestedNode ;

NestedNode =
    INDENT Node DEDENT ;

Key =
      PLAIN_SCALAR
    | SQ_SCALAR
    | DQ_SCALAR ;


(********************************************************************************)
(* 5. SEQUENCE ITEMS                                                           *)
(********************************************************************************)

SequenceItem =
    DASH_ITEM SequenceItemTail ;

SequenceItemTail =
      [InlineValue] LineEnd
      [NestedNode] ;

InlineValue =
      Scalar
    | FlowMapping
    | FlowSequence ;


(********************************************************************************)
(* 6. SCALAR NODES                                                             *)
(********************************************************************************)

Scalar =
      PLAIN_SCALAR
    | SQ_SCALAR
    | DQ_SCALAR
    | TQ_SCALAR
    | BLOCK_SCALAR ;


(********************************************************************************)
(* 7. FLOW COLLECTIONS                                                         *)
(********************************************************************************)

NodeListOpt =
      NodeList
    | empty ;

NodeList =
    Node { WSOpt COMMA WSOpt Node } ;

FlowPairListOpt =
      FlowPairList
    | empty ;

FlowPairList =
    FlowPair { WSOpt COMMA WSOpt FlowPair } ;

FlowSequence =
    LBRACKET WSOpt NodeListOpt WSOpt RBRACKET ;

FlowMapping =
    LBRACE WSOpt FlowPairListOpt WSOpt RBRACE ;

FlowPair =
    Key WSOpt COLON WSOpt Node ;


```
