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

    private RsvrApexLexicalParserInput input = null;
    private List<RsvrApexLexicalParser.LexicalToken> tokenList = new List<RsvrApexLexicalParser.LexicalToken>();

    ////////////////////////////////
    // Mail process loop.

    public List<LexicalToken> parse(String apexClassText) {
        input = new RsvrApexLexicalParserInput(apexClassText);

        for (;;) {
            if (IS_DEBUG) System.debug('TRACE: Current remaining text: ' + input.getRemainingtext(true));

            ////////////////////////////////
            // Check End of file.
            input.mark();
            if (input.readChar() == -1) {
                if (IS_DEBUG) System.debug('TRACE: check EOF: ');
                // End of file
                break;
            }
            input.reset();

            if (IS_DEBUG) System.debug('TRACE: parseKeyword: ');
            LexicalToken tok = null;
            tok = parseKeyword();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseIdentifier: ');
            tok = parseIdentifier();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseSeparator: ');
            tok = parseSeparator();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseOperator: ');
            tok = parseOperator();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseAtsign: ');
            tok = parseAtsign();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            ////////////////////////
            // Literals

            if (IS_DEBUG) System.debug('TRACE: parseStringLiteral: ');
            tok = parseStringLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            ////////////////////////
            // Whitespace and comments.

            if (IS_DEBUG) System.debug('TRACE: parseWS: ');
            tok = parseWS();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseDocComment: ');
            tok = parseDocComment();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseComment: ');
            tok = parseComment();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseLineComment: ');
            tok = parseLineComment();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            // Do NOT enter here..
            {
                System.debug('TRACE: PANIC: Unexpected error. Process stopped.: ' + input.getRemainingtext(true));
                PanicToken panic = new PanicToken();
                panic.type = 'PANIC';
                panic.message = 'Unexpected error. Process stopped.';
                panic.remainingtext = input.getRemainingtext(false);
                tokenList.add(panic);
                break;
            }        
        }
        
        return tokenList;
    }

    // Mail process loop.
    ////////////////////////////////

    ///////////////////////////////////////
    // Parse

    private KeywordToken parseKeyword() {
        KeywordToken result = new KeywordToken();
        result.type = 'Keyword';

        input.mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    input.reset();
                    return null;
                }

                input.move(input.pos() - 1);
                if (RsvrApexLexicalParserUtil.isKeyword(result.target)) {
                    // Hit
                    input.mark();
                    result.original = result.target;
                    return result;
                } else {
                    break;
                }
            }
        }

        input.reset();
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

    // // §3.10.3 Boolean Literals

    // BooleanLiteral
    //     :   'true'
    //     |   'false'
    //     ;

    // // §3.10.5 String Literals

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

    private LiteralToken parseStringLiteral() {
        LiteralToken result = new LiteralToken();
        result.type = 'StringLiteral';

        input.mark();

        // canma should be first.
        Integer first = input.readChar();
        if (first != '\''.charAt(0)) {
            input.reset();
            return null;
        }

        // start string literal.
        result.original = RsvrApexLexicalParserUtil.int2string(first);
        result.target = '';
        for (;;) {
            Integer next = input.readChar();
            if (next == -1) {
                // End of file.
                // Unexpected.
                input.reset();
                return result;
            }
            if (next == '\''.charAt(0)) {
                // end of string literal.
                input.mark();
                result.original = result.original + RsvrApexLexicalParserUtil.int2string(next);
                return result;
            }

            // TODO エスケープシーケンス
            // TODO Unicode

            //     :   '\\' [btnfr"'\\]
            if (next == '\\'.charAt(0)) {
                // Escape begin.
                result.original = result.original + RsvrApexLexicalParserUtil.int2string(next);

                Integer next2 = input.readChar();
                result.original = result.original + RsvrApexLexicalParserUtil.int2string(next2);
                if (next2 == 'b'.charAt(0)) {
                    result.target = result.target + '\b';
                    continue;
                }
                if (next2 == 't'.charAt(0)) {
                    result.target = result.target + '\t';
                    continue;
                }
                if (next2 == 'n'.charAt(0)) {
                    result.target = result.target + '\n';
                    continue;
                }
                if (next2 == 'f'.charAt(0)) {
                    result.target = result.target + '\f';
                    continue;
                }
                if (next2 == 'r'.charAt(0)) {
                    result.target = result.target + '\r';
                    continue;
                }
                if (next2 == '"'.charAt(0)
                || next2 == '\''.charAt(0)
                || next2 == '\\'.charAt(0)) {
                    result.target = result.target + RsvrApexLexicalParserUtil.int2string(next2);
                    continue;
                }
                // '\\u' HexCharacter HexCharacter HexCharacter HexCharacter
                if (next2 == 'u'.charAt(0)) {
                    Integer hex1 = input.readChar();
                    if (RsvrApexLexicalParserUtil.isHexCharacter(hex1) == false) {
                        input.reset();
                        break;
                    }
                    Integer hex2 = input.readChar();
                    if (RsvrApexLexicalParserUtil.isHexCharacter(hex2) == false) {
                        input.reset();
                        break;
                    }
                    Integer hex3 = input.readChar();
                    if (RsvrApexLexicalParserUtil.isHexCharacter(hex3) == false) {
                        input.reset();
                        break;
                    }
                    Integer hex4 = input.readChar();
                    if (RsvrApexLexicalParserUtil.isHexCharacter(hex4) == false) {
                        input.reset();
                        break;
                    }
                    String hexTarget = RsvrApexLexicalParserUtil.int2string(hex1) + RsvrApexLexicalParserUtil.int2string(hex2) + RsvrApexLexicalParserUtil.int2string(hex3) + RsvrApexLexicalParserUtil.int2string(hex4);
                    result.original = result.original + hexTarget;
                    // Hex錬成
                    Blob blobHexTarget = EncodingUtil.convertFromHex(hexTarget);
                    result.target = result.target + blobHexTarget;
                    continue;
                }
                // エスケープ中の想定外のコース。ここに入ってはダメ。
                break;
            }

            result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
            result.original = result.original + RsvrApexLexicalParserUtil.int2string(next);
        }

        input.reset();
        return null;
    }

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

        input.mark();
        result.target = '';
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isSeparator(RsvrApexLexicalParserUtil.int2string(next))) {
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                result.original = result.target;
                return result;
            } else {
                break;
            }
        }

        input.reset();
        return null;
    }

    // // §3.12 Operators

    private OperatorToken parseOperator() {
        OperatorToken result = new OperatorToken();
        result.type = 'Operator';

        input.mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isOperatorLetter(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    input.reset();
                    return null;
                }

                input.move(input.pos() - 1);
                if (RsvrApexLexicalParserUtil.isOperator(result.target)) {
                    // Hit
                    input.mark();
                    result.original = result.target;
                    return result;
                } else {
                    break;
                }
            }
        }

        input.reset();
        return null;
    }

    //
    // Additional symbols not defined in the lexical specification
    //

    // ATSIGN : '@';
    private AtsignToken parseAtsign() {
        AtsignToken result = new AtsignToken();
        result.type = 'Atsign';

        input.mark();
        result.target = '';

        Integer next = input.readChar();
        if (next == '@'.charAt(0)) {
            result.target = RsvrApexLexicalParserUtil.int2string(next);
            result.original = result.target;
            return result;
        }

        input.reset();
        return null;
    }

    // // §3.8 Identifiers (must appear after all keywords in the grammar)

    // Identifier
    //     :   JavaLetter JavaLetterOrDigit*
    //     ;
    private IdentifierToken parseIdentifier() {
        IdentifierToken result = new IdentifierToken();
        result.type = 'Identifier';

        input.mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isJavaLetterOrDigit(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    input.reset();
                    return null;
                }

                input.move(input.pos() - 1);

                // Hit
                input.mark();
                result.original = result.target;
                return result;
            }
        }

        input.reset();
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

        input.mark();
        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (next == -1) {
                // end of file.
                input.mark();
                break;
            }

            if (next == ' '.charAt(0)
            || next == '\t'.charAt(0)
            || next == '\r'.charAt(0)
            || next == '\n'.charAt(0)
            || next == '\u000C'.charAt(0)) {
                isExist = true;
                input.mark();
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            }
            // Other.
            input.reset();
            break;
        }

        if (isExist == false) {
            input.reset();
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

        input.mark();
        Integer first = input.readChar();
        if (first != '/'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != '*'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer third = input.readChar();
        if (third != '*'.charAt(0)) {
            input.reset();
            return null;
        }

        // hit line comment
        result.original = RsvrApexLexicalParserUtil.int2string(first) + RsvrApexLexicalParserUtil.int2string(second) + RsvrApexLexicalParserUtil.int2string(third);
        result.target = '';
        for (;;) {
            Integer next = input.readChar();
            if (next == '*'.charAt(0)) {
                input.mark();
                Integer next2 = input.readChar();
                if (next2 == '/'.charAt(0)) {
                    // End of comment.
                    input.mark();
                    result.original = result.original + result.target + RsvrApexLexicalParserUtil.int2string(next) + RsvrApexLexicalParserUtil.int2string(next2);
                    return result;
                }
                input.reset();
            }

            input.mark();
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

        input.mark();
        Integer first = input.readChar();
        if (first != '/'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != '*'.charAt(0)) {
            input.reset();
            return null;
        }

        // hit line comment
        result.original = RsvrApexLexicalParserUtil.int2string(first) + RsvrApexLexicalParserUtil.int2string(second);
        result.target = '';
        for (;;) {
            Integer next = input.readChar();
            if (next == '*'.charAt(0)) {
                input.mark();
                Integer next2 = input.readChar();
                if (next2 == '/'.charAt(0)) {
                    // End of comment.
                    input.mark();
                    result.original = result.original + result.target + RsvrApexLexicalParserUtil.int2string(next) + RsvrApexLexicalParserUtil.int2string(next2);
                    return result;
                }
                input.reset();
            }

            input.mark();
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

        input.mark();
        Integer first = input.readChar();
        if (first != '/'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != '/'.charAt(0)) {
            input.reset();
            return null;
        }

        // hit line comment
        result.original = RsvrApexLexicalParserUtil.int2string(first) + RsvrApexLexicalParserUtil.int2string(second);
        result.target = '';
        for (;;) {
            Integer next = input.readChar();
            if (next == '\r'.charAt(0)
            || next == '\n'.charAt(0)
            || next == -1) {
                input.reset();
                result.original = result.original + result.target;
                break;
            }

            input.mark();
            result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
        }

        return result;
    }
}
