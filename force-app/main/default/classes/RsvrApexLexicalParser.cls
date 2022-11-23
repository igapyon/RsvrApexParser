/*
 * Copyright 2022 Reservoir Consulting - Toshiki Iga
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class RsvrApexLexicalParser {
    private static final Boolean IS_DEBUG = false;

    public abstract class LexicalToken {
        public String type {get; set;}
        public String target {get; set;}
        public String original {get; set;}
    }

    public class KeywordToken extends LexicalToken {
    }

    public class LiteralToken extends LexicalToken {
    }

    public class SeparatorToken extends LexicalToken {
    }

    public class OperatorToken extends LexicalToken {
    }

    public class WhitespaceToken extends LexicalToken {
    }

    public class CommentToken extends LexicalToken {
    }

    public class IdentifierToken extends LexicalToken {
    }

    public class AtsignToken extends LexicalToken {
    }

    public class PanicToken extends LexicalToken {
        public String message {get; set;}
        public String remainingtext {get; set;}
    }

    private String apexClassText;
    private List<LexicalToken> tokenList = new List<LexicalToken>();
    private Integer currentPos = -1;
    private Integer markPos = -1;

    private Integer readChar() {
        currentPos++;
        if (apexClassText.length() <= currentPos) {
            // end of string.
            return -1;
        }

        return apexClassText.charAt(currentPos);
    }

    private Integer mark() {
        markPos = currentPos;
        return markPos;
    }

    private void move(Integer pos) {
        currentPos = pos;
    }

    private Integer pos() {
        return currentPos;
    }

    private void reset() {
        currentPos = markPos;
    }

    ////////////////////////////////
    // Mail process.

    public List<LexicalToken> parse(String apexClassText) {
        this.apexClassText = apexClassText;
        tokenList = new List<LexicalToken>();
        currentPos = -1;
        markPos = -1;

        for (;;) {
            if (IS_DEBUG) System.debug('TRACE: Current remaining text: ' + getRemainingtext(true));
            {
                // Check End of file.
                mark();
                if (readChar() == -1) {
                    if (IS_DEBUG) System.debug('TRACE: check EOF: ');
                    // End of file
                    break;
                }
                reset();
            }

            {
                if (IS_DEBUG) System.debug('TRACE: parseKeyword: ');
                KeywordToken tok = parseKeyword();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseIdentifier: ');
                IdentifierToken tok = parseIdentifier();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseSeparator: ');
                SeparatorToken tok = parseSeparator();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseOperator: ');
                OperatorToken tok = parseOperator();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseAtsign: ');
                AtsignToken tok = parseAtsign();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }

            ////////////////////////
            // Literals

            {
                if (IS_DEBUG) System.debug('TRACE: parseStringLiteral: ');
                LiteralToken tok = parseStringLiteral();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }

            ////////////////////////
            // Whitespace and comments.

            {
                if (IS_DEBUG) System.debug('TRACE: parseWS: ');
                WhitespaceToken tok = parseWS();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseDocComment: ');
                CommentToken tok = parseDocComment();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseComment: ');
                CommentToken tok = parseComment();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseLineComment: ');
                CommentToken tok = parseLineComment();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }

            // Can't here.
            {
                System.debug('TRACE: PANIC: Unexpected error. Process stopped.: ' + getRemainingtext(true));
                PanicToken tok = new PanicToken();
                tok.type = 'PANIC';
                tok.message = 'Unexpected error. Process stopped.';
                tok.remainingtext = getRemainingtext(false);
                tokenList.add(tok);
                break;
            }        
        }
        
        return tokenList;
    }

    ///////////////////////////////////////
    // Parse

    private KeywordToken parseKeyword() {
        KeywordToken result = new KeywordToken();
        result.type = 'Keyword';

        mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    reset();
                    return null;
                }

                move(pos() - 1);
                if (RsvrApexLexicalParserUtil.isKeyword(result.target)) {
                    // Hit
                    mark();
                    result.original = result.target;
                    return result;
                } else {
                    break;
                }
            }
        }

        reset();
        return null;
    }

    // 
    // channels {
    // WHITESPACE_CHANNEL,
    // COMMENT_CHANNEL
    // }

    // SOQL Date literal
    // DateLiteral: Digit Digit Digit Digit '-' Digit Digit '-' Digit Digit;
    // DateTimeLiteral: DateLiteral 't' Digit Digit ':' Digit Digit ':' Digit Digit ('z' | (('+' | '-') Digit+ ( ':' Digit+)? ));

    // SOQL Currency literal
    // (NOTE: this is also a valid Identifier)
    // IntegralCurrencyLiteral: [a-z] [a-z] [a-z] Digit+;


    // FindLiteral
    // :   '[' WS? 'find' WS '\'' FindCharacters? '\''
    // ;

    // fragment
    // FindCharacters
    //     :   FindCharacter+
    //     ;

    // fragment
    // FindCharacter
    //     :   ~['\\]
    //     |   FindEscapeSequence
    //     ;
    // FindLiteralAlt
    //     :   '[' WS? 'find' WS '{' FindCharactersAlt? '}'
    //     ;
    // fragment
    // FindCharactersAlt
    //     :   FindCharacterAlt+
    //     ;
    // fragment
    // FindCharacterAlt
    //     :   ~[}\\]
    //     |   FindEscapeSequence
    //     ;
    // fragment
    // FindEscapeSequence
    //     :   '\\' [+\-&|!(){}^"~*?:'\\]
    //     ;

    // // §3.10.1 Integer Literals
    // 
    // IntegerLiteral
    //     :   Digit Digit*
    //     ;
    // 

    // LongLiteral
    //     : Digit Digit* [lL]
    //     ;

    // NumberLiteral
    //     :   Digit* '.' Digit Digit* [dD]?
    //     ;

    // fragment
    // HexCharacter
    //     :   Digit | 'a' | 'b' | 'c' | 'd' | 'e' | 'f'
    //     ;

    // fragment
    // Digit
    //     :   [0-9]
    //     ;

    // // §3.10.3 Boolean Literals

    // BooleanLiteral
    //     :   'true'
    //     |   'false'
    //     ;

    // // §3.10.5 String Literals
    private LiteralToken parseStringLiteral() {
        LiteralToken result = new LiteralToken();
        result.type = 'StringLiteral';

        mark();

        // canma should be first.
        Integer first = readChar();
        if (first != '\''.charAt(0)) {
            reset();
            return null;
        }

        // start string literal.
        result.original = RsvrApexLexicalParserUtil.int2string(first);
        result.target = '';
        for (;;) {
            Integer next = readChar();
            if (next == -1) {
                // End of file.
                // Unexpected.
                reset();
                return result;
            }
            if (next == '\''.charAt(0)) {
                // end of string literal.
                mark();
                result.original = result.original + result.target + RsvrApexLexicalParserUtil.int2string(next);
                return result;
            }

            // TODO エスケープシーケンス
            // TODO Unicode
        
            result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
        }

        reset();
        return null;
    }

    // StringLiteral
    //     :   '\'' StringCharacters? '\''
    //     ;



    // fragment
    // StringCharacters
    //     :   StringCharacter+
    //     ;

    // fragment
    // StringCharacter
    //     :   ~['\\]
    //     |   EscapeSequence
    //     ;
    // // §3.10.6 Escape Sequences for Character and String Literals
    // fragment
    // EscapeSequence
    //     :   '\\' [btnfr"'\\]
    //     |   '\\u' HexCharacter HexCharacter HexCharacter HexCharacter
    //     ;

    // // §3.10.7 The Null Literal

    // NullLiteral
    //     :   NULL
    //     ;

    /**
     * Parse separator.
     * 
     * Must be one char.
     */
    private SeparatorToken parseSeparator() {
        SeparatorToken result = new SeparatorToken();
        result.type = 'Separator';

        mark();
        result.target = '';
        for (;;) {
            Integer next = readChar();
            if (RsvrApexLexicalParserUtil.isSeparator(RsvrApexLexicalParserUtil.int2string(next))) {
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                result.original = result.target;
                return result;
            } else {
                break;
            }
        }

        reset();
        return null;
    }

    // // §3.12 Operators

    private OperatorToken parseOperator() {
        OperatorToken result = new OperatorToken();
        result.type = 'Operator';

        mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (RsvrApexLexicalParserUtil.isOperatorLetter(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    reset();
                    return null;
                }

                move(pos() - 1);
                if (RsvrApexLexicalParserUtil.isOperator(result.target)) {
                    // Hit
                    mark();
                    result.original = result.target;
                    return result;
                } else {
                    break;
                }
            }
        }

        reset();
        return null;
    }

    //
    // Additional symbols not defined in the lexical specification
    //

    // ATSIGN : '@';
    private AtsignToken parseAtsign() {
        AtsignToken result = new AtsignToken();
        result.type = 'Atsign';

        mark();
        result.target = '';

        Integer next = readChar();
        if (next == '@'.charAt(0)) {
            result.target = RsvrApexLexicalParserUtil.int2string(next);
            result.original = result.target;
            return result;
        }

        reset();
        return null;
    }

    // // §3.8 Identifiers (must appear after all keywords in the grammar)

    // Identifier
    //     :   JavaLetter JavaLetterOrDigit*
    //     ;
    private IdentifierToken parseIdentifier() {
        IdentifierToken result = new IdentifierToken();
        result.type = 'Identifier';

        mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (RsvrApexLexicalParserUtil.isJavaLetterOrDigit(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    reset();
                    return null;
                }

                move(pos() - 1);

                // Hit
                mark();
                result.original = result.target;
                return result;
            }
        }

        reset();
        return null;
    }

    // //
    // // Whitespace and comments
    // //

    // WS  :  [ \t\r\n\u000C]+ -> channel(WHITESPACE_CHANNEL)
    //     ;
    private WhitespaceToken parseWS() {
        WhitespaceToken result = new WhitespaceToken();
        result.type = 'Whitespace';

        mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (next == -1) {
                // end of file.
                mark();
                break;
            }

            if (next == ' '.charAt(0)
            || next == '\t'.charAt(0)
            || next == '\r'.charAt(0)
            || next == '\n'.charAt(0)
            || next == '\u000C'.charAt(0)) {
                isExist = true;
                mark();
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            }
            // Other.
            reset();
            break;
        }

        if (isExist == false) {
            reset();
            return null;
        }

        result.original = result.target;
        return result;
    }

    // DOC_COMMENT
    //     :   '/**' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseDocComment() {
        CommentToken result = new CommentToken();
        result.type = 'DocComment';

        mark();
        Integer first = readChar();
        if (first != '/'.charAt(0)) {
            reset();
            return null;
        }
        Integer second = readChar();
        if (second != '*'.charAt(0)) {
            reset();
            return null;
        }
        Integer third = readChar();
        if (third != '*'.charAt(0)) {
            reset();
            return null;
        }

        // hit line comment
        result.original = RsvrApexLexicalParserUtil.int2string(first) + RsvrApexLexicalParserUtil.int2string(second) + RsvrApexLexicalParserUtil.int2string(third);
        result.target = '';
        for (;;) {
            Integer next = readChar();
            if (next == '*'.charAt(0)) {
                mark();
                Integer next2 = readChar();
                if (next2 == '/'.charAt(0)) {
                    // End of comment.
                    mark();
                    result.original = result.original + result.target + RsvrApexLexicalParserUtil.int2string(next) + RsvrApexLexicalParserUtil.int2string(next2);
                    return result;
                }
                reset();
            }

            mark();
            result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
        }

        return result;
    }

    // COMMENT
    //     :   '/*' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseComment() {
        CommentToken result = new CommentToken();
        result.type = 'Comment';

        mark();
        Integer first = readChar();
        if (first != '/'.charAt(0)) {
            reset();
            return null;
        }
        Integer second = readChar();
        if (second != '*'.charAt(0)) {
            reset();
            return null;
        }

        // hit line comment
        result.original = RsvrApexLexicalParserUtil.int2string(first) + RsvrApexLexicalParserUtil.int2string(second);
        result.target = '';
        for (;;) {
            Integer next = readChar();
            if (next == '*'.charAt(0)) {
                mark();
                Integer next2 = readChar();
                if (next2 == '/'.charAt(0)) {
                    // End of comment.
                    mark();
                    result.original = result.original + result.target + RsvrApexLexicalParserUtil.int2string(next) + RsvrApexLexicalParserUtil.int2string(next2);
                    return result;
                }
                reset();
            }

            mark();
            result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
        }

        return result;
    }

    // LINE_COMMENT
    //     :   '//' ~[\r\n]* -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseLineComment() {
        CommentToken result = new CommentToken();
        result.type = 'LineComment';

        mark();
        Integer first = readChar();
        if (first != '/'.charAt(0)) {
            reset();
            return null;
        }
        Integer second = readChar();
        if (second != '/'.charAt(0)) {
            reset();
            return null;
        }

        // hit line comment
        result.original = RsvrApexLexicalParserUtil.int2string(first) + RsvrApexLexicalParserUtil.int2string(second);
        result.target = '';
        for (;;) {
            Integer next = readChar();
            if (next == '\r'.charAt(0)
            || next == '\n'.charAt(0)
            || next == -1) {
                reset();
                result.original = result.original + result.target;
                break;
            }

            mark();
            result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
        }

        return result;
    }

    public String getRemainingtext(Boolean isNext) {
        Integer pos = currentPos;
        if (isNext) {
            pos++;
        }
        if (pos < 0) {
            pos = 0;
        }
        if (apexClassText.length() <= (pos)) {
            return '';
        }
        return apexClassText.substring(pos);
    }
}
