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

/**
 * Reservoir Apex Language Parser.
 * 
 * This class provide Lexical Parser for Apex Language.
 * 
 * @since 2022-11-23
 */
public class RsvrApexLexicalParser {
    private static final Boolean IS_DEBUG = false;

    private static final RsvrProcTime procTime = new RsvrProcTime('RsvrApexLexicalParser');

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

    /**
     * Parse given Apex Class text.
     * 
     * @param apexClassText Apex Class Text.
     * @return List of LexicalToken.
     */
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

            // Parse.
            LexicalToken tok = null;

            ////////////////////////
            // Whitespace and comments.

            if (IS_DEBUG) System.debug('TRACE: parseWhitespace: ');
            tok = parseWhitespace();
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

            //////////////////////////////////////////////////////////

            if (IS_DEBUG) System.debug('TRACE: parseKeyword: ');
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

            // parseDateLiteral より先にparseDateTimeLiteralを実施。
            if (IS_DEBUG) System.debug('TRACE: parseDateTimeLiteral: ');
            tok = parseDateTimeLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseDateLiteral: ');
            tok = parseDateLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }            

            if (IS_DEBUG) System.debug('TRACE: parseStringLiteral: ');
            tok = parseStringLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            // NumberのパースはLongより先に実施。
            if (IS_DEBUG) System.debug('TRACE: parseNumberLiteral: ');
            tok = parseNumberLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            // LongのパースはIntegerより先に実施。
            if (IS_DEBUG) System.debug('TRACE: parseLongLiteral: ');
            tok = parseLongLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }

            if (IS_DEBUG) System.debug('TRACE: parseIntegerLiteral: ');
            tok = parseIntegerLiteral();
            if (tok != null) {
                tokenList.add(tok);
                continue;
            }
                        
            // Do NOT enter here..
            {
                System.debug('TRACE: PANIC: Unexpected error. Process stopped.: [' + input.getRemainingtext(true) + ']');
                PanicToken panic = new PanicToken();
                panic.type = 'PANIC';
                panic.message = 'Unexpected error. Process stopped.';
                panic.remainingtext = input.getRemainingtext(false);
                tokenList.add(panic);
                break;
            }        
        }

        procTime.close();
        return tokenList;
    }

    // Mail process loop.
    ////////////////////////////////

    ///////////////////////////////////////
    // Parse

    private LexicalToken parseKeyword() {
        procTime.enter('parseKeyword');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
                isExist = true;
                if (targetList == null) {
                    targetList = new List<Integer>();
                }
                targetList.add(next);
                continue;
            } else {
                if (isExist == false) {
                    input.reset();
                    return null;
                }

                input.move(input.pos() - 1);

                String target = String.fromCharArray(targetList);
                if (target.toLowerCase() == 'null') {
                    // Hit
                    input.mark();
                    LiteralToken result = new LiteralToken();
                    result.type = 'NullLiteral';
                    result.target = target;
                    result.original = result.target;
                    return result;
                }
                if (RsvrApexLexicalParserUtil.isKeyword(target)) {
                    // Hit
                    input.mark();
                    KeywordToken result = new KeywordToken();
                    result.type = 'Keyword';
                    result.target = target;
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
    private LiteralToken parseDateLiteral() {
        procTime.enter('parseDateLiteral');
        input.mark();

        Integer val1 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val1) == false) {
            input.reset();
            return null;
        }
        Integer val2 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val2) == false) {
            input.reset();
            return null;
        }
        Integer val3 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val3) == false) {
            input.reset();
            return null;
        }
        Integer val4 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val4) == false) {
            input.reset();
            return null;
        }
        Integer val5 = input.readChar();
        if (val5 != 45 /* [-] */) {
            input.reset();
            return null;
        }
        Integer val6 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val6) == false) {
            input.reset();
            return null;
        }
        Integer val7 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val7) == false) {
            input.reset();
            return null;
        }
        Integer val8 = input.readChar();
        if (val8 != 45 /* [-] */) {
            input.reset();
            return null;
        }
        Integer val9 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val9) == false) {
            input.reset();
            return null;
        }
        Integer val10 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val10) == false) {
            input.reset();
            return null;
        }

        LiteralToken result = new LiteralToken();
        result.type = 'DateLiteral';
        result.target = '';

        // この時点でDateリテラルとする。
        result.target = RsvrApexLexicalParserUtil.int2string(val1) + RsvrApexLexicalParserUtil.int2string(val2) + RsvrApexLexicalParserUtil.int2string(val3) + RsvrApexLexicalParserUtil.int2string(val4) + RsvrApexLexicalParserUtil.int2string(val5) + RsvrApexLexicalParserUtil.int2string(val6) + RsvrApexLexicalParserUtil.int2string(val7) + RsvrApexLexicalParserUtil.int2string(val8) + RsvrApexLexicalParserUtil.int2string(val9) + RsvrApexLexicalParserUtil.int2string(val10);
        result.original = result.target;
        input.mark();

        return result;
    }    

    // DateTimeLiteral: DateLiteral 't' Digit Digit ':' Digit Digit ':' Digit Digit ('z' | (('+' | '-') Digit+ ( ':' Digit+)? ));
    private LiteralToken parseDateTimeLiteral() {
        procTime.enter('parseDateTimeLiteral');
        input.mark();

        Integer val1 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val1) == false) {
            input.reset();
            return null;
        }
        Integer val2 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val2) == false) {
            input.reset();
            return null;
        }
        Integer val3 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val3) == false) {
            input.reset();
            return null;
        }
        Integer val4 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val4) == false) {
            input.reset();
            return null;
        }
        Integer val5 = input.readChar();
        if (val5 != 45 /* [-] */) {
            input.reset();
            return null;
        }
        Integer val6 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val6) == false) {
            input.reset();
            return null;
        }
        Integer val7 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val7) == false) {
            input.reset();
            return null;
        }
        Integer val8 = input.readChar();
        if (val8 != 45 /* [-] */) {
            input.reset();
            return null;
        }
        Integer val9 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val9) == false) {
            input.reset();
            return null;
        }
        Integer val10 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val10) == false) {
            input.reset();
            return null;
        }

        // t
        Integer val11 = input.readChar();
        if (val11 != 't'.charAt(0) && val11 != 'T'.charAt(0)) {
            input.reset();
            return null;
        }

        // Digit Digit ':' Digit Digit ':' Digit Digit
        Integer val12 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val12) == false) {
            input.reset();
            return null;
        }
        Integer val13 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val13) == false) {
            input.reset();
            return null;
        }
        Integer val14 = input.readChar();
        if (val14 != ':'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer val15 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val15) == false) {
            input.reset();
            return null;
        }
        Integer val16 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val16) == false) {
            input.reset();
            return null;
        }
        Integer val17 = input.readChar();
        if (val17 != ':'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer val18 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val18) == false) {
            input.reset();
            return null;
        }
        Integer val19 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val19) == false) {
            input.reset();
            return null;
        }

        LiteralToken result = new LiteralToken();
        result.type = 'DateTimeLiteral';
        result.target = '';

        // ('z' | (('+' | '-') Digit+ ( ':' Digit+)? ))
        Integer val20 = input.readChar();
        if (val20 == 'z'.charAt(0) || val20 == 'Z'.charAt(0)) {
            // hit
            result.target = RsvrApexLexicalParserUtil.int2string(val1) + RsvrApexLexicalParserUtil.int2string(val2) + RsvrApexLexicalParserUtil.int2string(val3) + RsvrApexLexicalParserUtil.int2string(val4) + RsvrApexLexicalParserUtil.int2string(val5) + RsvrApexLexicalParserUtil.int2string(val6) + RsvrApexLexicalParserUtil.int2string(val7) + RsvrApexLexicalParserUtil.int2string(val8) + RsvrApexLexicalParserUtil.int2string(val9) + RsvrApexLexicalParserUtil.int2string(val10)
                + RsvrApexLexicalParserUtil.int2string(val11) + RsvrApexLexicalParserUtil.int2string(val12) + RsvrApexLexicalParserUtil.int2string(val13) + RsvrApexLexicalParserUtil.int2string(val14) + RsvrApexLexicalParserUtil.int2string(val15) + RsvrApexLexicalParserUtil.int2string(val16) + RsvrApexLexicalParserUtil.int2string(val17) + RsvrApexLexicalParserUtil.int2string(val18) + RsvrApexLexicalParserUtil.int2string(val19) + RsvrApexLexicalParserUtil.int2string(val20);
            result.original = result.target;
            input.mark();
            return result;
        }
        if (val20 != '+'.charAt(0) && val20 != '-'.charAt(0)) {
            input.reset();
            return null;
        }
        Integer val21 = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(val21) == false) {
            input.reset();
            return null;
        }

        // この時点でDateTimeリテラル確定。
        result.target = RsvrApexLexicalParserUtil.int2string(val1) + RsvrApexLexicalParserUtil.int2string(val2) + RsvrApexLexicalParserUtil.int2string(val3) + RsvrApexLexicalParserUtil.int2string(val4) + RsvrApexLexicalParserUtil.int2string(val5) + RsvrApexLexicalParserUtil.int2string(val6) + RsvrApexLexicalParserUtil.int2string(val7) + RsvrApexLexicalParserUtil.int2string(val8) + RsvrApexLexicalParserUtil.int2string(val9) + RsvrApexLexicalParserUtil.int2string(val10)
            + RsvrApexLexicalParserUtil.int2string(val11) + RsvrApexLexicalParserUtil.int2string(val12) + RsvrApexLexicalParserUtil.int2string(val13) + RsvrApexLexicalParserUtil.int2string(val14) + RsvrApexLexicalParserUtil.int2string(val15) + RsvrApexLexicalParserUtil.int2string(val16) + RsvrApexLexicalParserUtil.int2string(val17) + RsvrApexLexicalParserUtil.int2string(val18) + RsvrApexLexicalParserUtil.int2string(val19) + RsvrApexLexicalParserUtil.int2string(val20)
            + RsvrApexLexicalParserUtil.int2string(val21);
        input.mark();

        // Digit+ ( ':' Digit+)? )
        for (;;) {
            Integer valX = input.readChar();
            if (RsvrApexLexicalParserUtil.isDigit(valX) || ':'.charAt(0) == valX) {
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(valX);
                input.mark();
                continue;
            }
            input.reset();
            break;
        }
        result.original = result.target;
        input.reset();
        return result;
    }

    // TODO SOQL Currency literal は一旦未着手のまま放置。

    // SOQL Currency literal
    // (NOTE: this is also a valid Identifier)
    // IntegralCurrencyLiteral: [a-z] [a-z] [a-z] Digit+;

    // TODO FIND 系は一旦未着手のまま放置。

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

    private LiteralToken parseIntegerLiteral() {
        procTime.enter('parseIntegerLiteral');
        input.mark();

        LiteralToken result = new LiteralToken();
        result.type = 'IntegerLiteral';

        result.target = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isDigit(next)) {
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    input.reset();
                    return null;
                }

                // アルファベットなら違うもの。
                if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
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

    // LongLiteral
    //     : Digit Digit* [lL]
    //     ;

    private LiteralToken parseLongLiteral() {
        procTime.enter('parseLongLiteral');
        input.mark();

        LiteralToken result = new LiteralToken();
        result.type = 'LongLiteral';

        result.target = '';
        Boolean isFirst = true;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isDigit(next)) {
                isFirst = false;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            }
            if (isFirst == false && (next == 105 /* [l] */ || next == 76 /* [L] */)) {
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);

                // Hit
                input.mark();
                result.original = result.target;
                return result;
            }
            input.reset();
            return null;
        }

        input.reset();
        return null;
    }

    // NumberLiteral
    //     :   Digit* '.' Digit Digit* [dD]?
    //     ;
    private LiteralToken parseNumberLiteral() {
        procTime.enter('parseNumberLiteral');
        input.mark();

        LiteralToken result = new LiteralToken();
        result.type = 'NumberLiteral';

        result.target = '';
        Boolean isFirst = true;
        Boolean isExist = false;
        Boolean isDotExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isDigit(next)) {
                isFirst = false;
                isExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            }
            if (isFirst == false && isDotExist == false && next == 46 /* [.] */) {
                isDotExist = true;
                result.target = result.target + RsvrApexLexicalParserUtil.int2string(next);
                continue;
            }
            if (isExist == false || isDotExist == false) {
                input.reset();
                return null;
            }

            // アルファベットなら違うもの。
            if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
                input.reset();
                return null;
            }
            
            input.move(input.pos() - 1);

            // Hit
            input.mark();
            result.original = result.target;
            return result;
        }

        input.reset();
        return null;
    }

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
        procTime.enter('parseStringLiteral');

        input.mark();
        final Boolean IS_LOCAL_DEBUG = false;

        // canma should be first.
        Integer first = input.readChar();
        if (first != 39 /* ['] */) {
            input.reset();
            return null;
        }
        if (IS_LOCAL_DEBUG) System.debug('TRACE: Start of string literal.');

        final List<Integer> targetList = new List<Integer>();
        final List<Integer> targetOriginalList = new List<Integer>();

        // start string literal.
        targetOriginalList.add(first);
        for (;;) {
            final Integer next = input.readChar();
            if (IS_LOCAL_DEBUG) System.debug('TRACE: Next char[' + RsvrApexLexicalParserUtil.int2string(next) + ']');
            if (IS_LOCAL_DEBUG) System.debug('TRACE: Remainingtext [' + input.getRemainingtext(false) + ']');
            if (next == -1) {
                if (IS_LOCAL_DEBUG) System.debug('TRACE: End of file.');
                // End of file.
                // Unexpected.
                input.mark();
                LiteralToken result = new LiteralToken();
                result.type = 'StringLiteral';
                result.target = String.fromCharArray(targetList);
                result.original = String.fromCharArray(targetOriginalList);
                return result;
            }
            if (next == 39 /* [Camma] */) {
                if (IS_LOCAL_DEBUG) System.debug('TRACE: End of string literal.');

                // end of string literal.
                input.mark();
                targetOriginalList.add(next);
                LiteralToken result = new LiteralToken();
                result.type = 'StringLiteral';
                result.target = String.fromCharArray(targetList);
                result.original = String.fromCharArray(targetOriginalList);
                return result;
            }

            //     :   bs [btnfr"cammabs]
            if (next == RsvrUnicodeConstants.LETTER_Backslash) {
                if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape began.');
                // Escape begin.
                targetOriginalList.add(next);

                Integer next2 = input.readChar();
                targetOriginalList.add(next2);
                if (next2 == 98 /* [b] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + b');
                    targetList.add(8 /* [b] */);
                    continue;
                }
                if (next2 == 116 /* [t] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + t');
                    targetList.add(9 /* [t] */);
                    continue;
                }
                if (next2 == 110 /* [n] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + n');
                    targetList.add(10 /* [n] */);
                    continue;
                }
                if (next2 == 102 /* [f] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + f');
                    targetList.add(12 /* [f] */);
                    continue;
                }
                if (next2 == 114 /* [r] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + r');
                    targetList.add(13 /* [r] */);
                    continue;
                }
                if (next2 == 34 /* ["] */
                || next2 == 39 /* [Camma] */
                || next2 == 92 /* [backslash] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + double/kanma,backslash');
                    targetList.add(next2);
                    continue;
                }
                // 'u' HexCharacter HexCharacter HexCharacter HexCharacter
                if (next2 == 117 /* [u] */) {
                    if (IS_LOCAL_DEBUG) System.debug('TRACE: Escape + u');
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
                    targetOriginalList.add(hex1);
                    targetOriginalList.add(hex2);
                    targetOriginalList.add(hex3);
                    targetOriginalList.add(hex4);
                    // Hex錬成
                    Blob blobHexTarget = EncodingUtil.convertFromHex(hexTarget);
                    // TODO FIXME 多分バグっている
                    targetList.add(blobHexTarget.toString().charAt(0));
                    continue;
                }
                // エスケープ中の想定外のコース。ここに入ってはダメ。
                System.debug('Fatal: Skipped char: ' + RsvrApexLexicalParserUtil.int2string(next2));
                break;
            }

            targetOriginalList.add(next);
            targetList.add(next);
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
        procTime.enter('parseSeparator');

        input.mark();

        final Integer next = input.readChar();
        if (RsvrApexLexicalParserUtil.isSeparator(next)) {
            final SeparatorToken result = new SeparatorToken();
            result.type = 'Separator';
            result.target = RsvrApexLexicalParserUtil.int2string(next);
            result.original = result.target;
            return result;
        }

        input.reset();
        return null;
    }

    // // §3.12 Operators

    private OperatorToken parseOperator() {
        procTime.enter('parseOperator');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (RsvrApexLexicalParserUtil.isOperatorLetter(next)) {
                isExist = true;
                if (targetList == null) {
                    targetList = new List<Integer>();
                }
                targetList.add(next);
                continue;
            } else {
                if (isExist == false) {
                    input.reset();
                    return null;
                }

                input.move(input.pos() - 1);
                String target = String.fromCharArray(targetList);
                // System.debug('TRACE: Operator candidate: [' + target + ']');
                if (RsvrApexLexicalParserUtil.isOperator(target)) {
                    // Hit
                    input.mark();
                    OperatorToken result = new OperatorToken();
                    result.type = 'Operator';
                    result.target = target;
                    result.original = result.target;
                    // System.debug('TRACE: Operator: [' + result.target + ']');
                    return result;
                } else {
                    // System.debug('TRACE: Non Operator: [' + target + ']');
                    if (targetList.get(0) == 62 /* [>] */) {
                        // 特殊処理
                        input.reset();
                        Integer retry = input.readChar();

                        OperatorToken result = new OperatorToken();
                        result.type = 'Operator';
                        result.target = RsvrApexLexicalParserUtil.int2string(retry);
                        result.original = result.target;
                        input.mark();
                        return result;
                    }

                    // in case // or /* pass here.
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
        procTime.enter('parseAtsign');

        input.mark();

        AtsignToken result = new AtsignToken();
        result.type = 'Atsign';

        result.target = '';

        Integer next = input.readChar();
        if (next == 64 /* [@] */) {
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
    private LexicalToken parseIdentifier() {
        procTime.enter('parseIdentifier');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        Boolean isFirst = true;
        for (;;) {
            Integer next = input.readChar();
            if (isFirst) {
                isFirst = false;
                if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
                    isExist = true;
                    if (targetList == null) {
                        targetList = new List<Integer>();
                    }
                    targetList.add(next);
                    continue;
                }
            } else {
                if (RsvrApexLexicalParserUtil.isJavaLetterOrDigit(next)) {
                    isExist = true;
                    if (targetList == null) {
                        targetList = new List<Integer>();
                    }
                    targetList.add(next);
                    continue;
                }
            }
            if (isExist == false) {
                input.reset();
                return null;
            }

            // 読み過ぎた部分を廃棄。
            input.move(input.pos() - 1);

            // Hit
            input.mark();

            final String target = String.fromCharArray(targetList);

            if (target.toLowerCase() == 'true'
            || target.toLowerCase() == 'false') {
                LiteralToken result = new LiteralToken();
                result.type = 'BooleanLiteral';
                result.target = target;
                result.original = result.target;
                return result;
            }

            IdentifierToken result = new IdentifierToken();
            result.type = 'Identifier';
            result.target = target;
            result.original = result.target;
            return result;
        }

        input.reset();
        return null;
    }

    // //
    // // Whitespace and comments
    // //

    // WS  :  [ trnu000C]+ -> channel(WHITESPACE_CHANNEL)
    //     ;
    private WhitespaceToken parseWhitespace() {
        procTime.enter('parseWhitespace');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        for (;;) {
            Integer next = input.readChar();
            if (next == -1) {
                // end of file.
                input.mark();
                break;
            }

            if (next == 32 /* [' '] */
            || next == 9 /* [t] */
            || next == 12 /* [r] */
            || next == 10 /* [n] */
            || next == 12 /* [u000C] */) {
                isExist = true;
                input.mark();
                if (targetList == null) {
                    targetList = new List<Integer>();
                }

                targetList.add(next);
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

        WhitespaceToken result = new WhitespaceToken();
        result.type = 'Whitespace';
        result.target = String.fromCharArray(targetList);
        result.original = result.target;
        return result;
    }

    // DOC_COMMENT
    //     :   /** .*? */ -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseDocComment() {
        procTime.enter('parseDocComment');

        input.mark();

        Integer first = input.readChar();
        if (first != 47 /* [/] */) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != 42 /* [*] */) {
            input.reset();
            return null;
        }
        Integer third = input.readChar();
        if (third != 42 /* [*] */) {
            input.reset();
            return null;
        }

        List<Integer> targetList = new List<Integer>();

        // hit line comment
        for (;;) {
            Integer next = input.readChar();
            if (next == 42 /* [*] */) {
                input.mark();
                Integer next2 = input.readChar();
                if (next2 == 47 /* [/] */) {
                    // End of comment.
                    input.mark();
                    CommentToken result = new CommentToken();
                    result.type = 'DocComment';
                    result.target = String.fromCharArray(targetList);
                    result.original = '/**' + result.target + '*/';
                    return result;
                }
                input.reset();
            }

            input.mark();
            targetList.add(next);
        }

        CommentToken result = new CommentToken();
        result.type = 'DocComment';
        result.target = String.fromCharArray(targetList);
        result.original = '/**' + result.target;

        return result;
    }

    // COMMENT
    //     :   '/*' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseComment() {
        procTime.enter('parseComment');

        input.mark();
        Integer first = input.readChar();
        if (first != 47 /* [/] */) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != 42 /* [*] */) {
            input.reset();
            return null;
        }

        List<Integer> targetList = new List<Integer>();

        // hit line comment
        for (;;) {
            Integer next = input.readChar();
            if (next == 42 /* [*] */) {
                input.mark();
                Integer next2 = input.readChar();
                if (next2 == 47 /* [/] */) {
                    // End of comment.
                    input.mark();

                    CommentToken result = new CommentToken();
                    result.type = 'Comment';
                    result.target = String.fromCharArray(targetList);
                    result.original = '/*' + result.target + '*/';
                    return result;
                }
                input.reset();
            }

            input.mark();
            targetList.add(next);
        }

        CommentToken result = new CommentToken();
        result.type = 'Comment';
        result.target = String.fromCharArray(targetList);
        result.original = '/*' + result.target;
        return result;
    }

    // LINE_COMMENT
    //     :   // ~[rn]* -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseLineComment() {
        procTime.enter('parseLineComment');

        input.mark();

        Integer first = input.readChar();
        if (first != 47 /* [/] */) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != 47 /* [/] */) {
            input.reset();
            return null;
        }

        List<Integer> targetList = new List<Integer>();

        // hit line comment
        for (;;) {
            Integer next = input.readChar();
            if (next == 13 /* [r] */
            || next == 10 /* [n] */
            || next == -1) {
                input.move(input.pos() - 1);
                input.mark();
                break;
            }

            targetList.add(next);
        }

        CommentToken result = new CommentToken();
        result.type = 'LineComment';
        result.target = String.fromCharArray(targetList);
        result.original = '//' + result.target;
        return result;
    }
}
