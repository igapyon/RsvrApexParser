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
        public String original {get; set;}
        public String type {get; set;}
    }

    public class KeywordToken extends LexicalToken {
        public String keyword {get; set;}
    }

    public class LiteralToken extends LexicalToken {
        public String literal {get; set;}
    }

    public class SeparatorToken extends LexicalToken {
        public String separator {get; set;}
    }

    public class OperatorToken extends LexicalToken {
        public String operator {get; set;}
    }

    public class WhitespaceToken extends LexicalToken {
        public String whitespace {get; set;}
    }

    public class CommentToken extends LexicalToken {
        public String comment {get; set;}
    }

    public class IdentifierToken extends LexicalToken {
        public String identifier {get; set;}
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
            currentPos--;
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
            {
                if (IS_DEBUG) System.debug('TRACE: parseKeyword: ' + apexClassText.substring(currentPos + 1));
                KeywordToken tok = parseKeyword();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseIdentifier: ' + apexClassText.substring(currentPos + 1));
                IdentifierToken tok = parseIdentifier();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseSeparator: ' + apexClassText.substring(currentPos + 1));
                SeparatorToken tok = parseSeparator();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseOperator: ' + apexClassText.substring(currentPos + 1));
                OperatorToken tok = parseOperator();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseWS: ' + apexClassText.substring(currentPos + 1));
                WhitespaceToken tok = parseWS();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                if (IS_DEBUG) System.debug('TRACE: parseLINE_COMMENT: ' + apexClassText.substring(currentPos + 1));
                CommentToken tok = parseLINE_COMMENT();
                if (tok != null) {
                    tokenList.add(tok);
                    continue;
                }
            }
            {
                mark();
                if (readChar() == -1) {
                    // End of file
                    break;
                }
                reset();
            }

            // Can't here.
            {
                PanicToken tok = new PanicToken();
                tok.type = 'PANIC';
                tok.message = 'Unexpected error. Process stopped.';
                tok.remainingtext = apexClassText.substring(currentPos);
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
        result.type = 'KEYWORD';

        mark();
        result.keyword = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (isJavaLetter(next)) {
                isExist = true;
                result.keyword = result.keyword + int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    reset();
                    return null;
                }

                move(pos() - 1);
                if (isKeyword(result.keyword)) {
                    // Hit
                    mark();
                    result.original = result.keyword;
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

    private static Boolean isSeparator(String val) {
        for (String look : RsvrApexConstants.SEPARATORS) {
            if (look.toLowerCase() == val.toLowerCase()) {
                return true;
            }
        }
        return false;
    }

    /**
     * Parse separator.
     * 
     * Must be one char.
     */
    private SeparatorToken parseSeparator() {
        SeparatorToken result = new SeparatorToken();
        result.type = 'SEPARATOR';

        mark();
        result.separator = '';
        for (;;) {
            Integer next = readChar();
            if (isSeparator(int2string(next))) {
                result.separator = result.separator + int2string(next);
                result.original = result.separator;
                return result;
            } else {
                break;
            }
        }

        reset();
        return null;
    }

    // // §3.12 Operators

    private static Boolean isOperator(String val) {
        for (String look : RsvrApexConstants.OPERATORS) {
            if (look.toLowerCase() == val.toLowerCase()) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isOperatorLetter(Integer val) {
        if ('='.charAt(0) == val
        || '>'.charAt(0) == val
        || '<'.charAt(0) == val
        || '~'.charAt(0) == val
        || '?'.charAt(0) == val
        || '.'.charAt(0) == val
        || ':'.charAt(0) == val
        || '='.charAt(0) == val
        || '!'.charAt(0) == val
        || '&'.charAt(0) == val
        || '|'.charAt(0) == val
        || '+'.charAt(0) == val
        || '-'.charAt(0) == val
        || '*'.charAt(0) == val
        || '/'.charAt(0) == val
        || '&'.charAt(0) == val
        || '^'.charAt(0) == val) {
                return true;
        }
        return false;
    }

    private OperatorToken parseOperator() {
        OperatorToken result = new OperatorToken();
        result.type = 'OPERATOR';

        mark();
        result.operator = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (isOperatorLetter(next)) {
                isExist = true;
                result.operator = result.operator + int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    reset();
                    return null;
                }

                move(pos() - 1);
                if (isOperator(result.operator)) {
                    // Hit
                    mark();
                    result.original = result.operator;
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


    // // §3.8 Identifiers (must appear after all keywords in the grammar)

    // Identifier
    //     :   JavaLetter JavaLetterOrDigit*
    //     ;
    private IdentifierToken parseIdentifier() {
        IdentifierToken result = new IdentifierToken();
        result.type = 'Identifier';

        mark();
        result.identifier = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (isJavaLetterOrDigit(next)) {
                isExist = true;
                result.identifier = result.identifier + int2string(next);
                continue;
            } else {
                if (isExist == false) {
                    reset();
                    return null;
                }

                move(pos() - 1);

                // Hit
                mark();
                result.original = result.identifier;
                return result;
            }
        }

        reset();
        return null;
    }

    // // Apex identifiers don't support non-ascii but we maintain Java rules here and post-validate
    // // so we can give better error messages
    // fragment
    // JavaLetter
    //     :   [a-zA-Z$_] // these are the "java letters" below 0xFF
    //     |   // covers all characters above 0xFF which are not a surrogate
    //         ~[\u0000-\u00FF\uD800-\uDBFF]
    //     |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
    //         [\uD800-\uDBFF] [\uDC00-\uDFFF]
    //     ;
    private static Boolean isJavaLetter(Integer val) {
        // [a-zA-Z$_] // these are the "java letters" below 0xFF
        if ('a'.charAt(0) <= val && val <= 'z'.charAt(0)) {
            return true;
        }
        if ('A'.charAt(0) <= val && val <= 'Z'.charAt(0)) {
            return true;
        }
        if ('$'.charAt(0) == val) {
            return true;
        }
        if ('_'.charAt(0) == val) {
            return true;
        }
        // ~[\u0000-\u00FF\uD800-\uDBFF]
        if ('\u0000'.charAt(0) <= val && val <= '\u00FF'.charAt(0)) {
            return false;
        }
        if ('\uD800'.charAt(0) <= val && val <= '\uDBFF'.charAt(0)) {
            return false;
        }
        return true;
    }

    // fragment
    // JavaLetterOrDigit
    //     :   [a-zA-Z0-9$_] // these are the "java letters or digits" below 0xFF
    //     |   // covers all characters above 0xFF which are not a surrogate
    //         ~[\u0000-\u00FF\uD800-\uDBFF]
    //     |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
    //         [\uD800-\uDBFF] [\uDC00-\uDFFF]
    //     ;
    private static Boolean isJavaLetterOrDigit(Integer val) {
        // [a-zA-Z$_] // these are the "java letters" below 0xFF
        if ('a'.charAt(0) <= val && val <= 'z'.charAt(0)) {
            return true;
        }
        if ('A'.charAt(0) <= val && val <= 'Z'.charAt(0)) {
            return true;
        }
        if ('0'.charAt(0) <= val && val <= '9'.charAt(0)) {
            return true;
        }
        if ('$'.charAt(0) == val) {
            return true;
        }
        if ('_'.charAt(0) == val) {
            return true;
        }
        // ~[\u0000-\u00FF\uD800-\uDBFF]
        if ('\u0000'.charAt(0) <= val && val <= '\u00FF'.charAt(0)) {
            return false;
        }
        if ('\uD800'.charAt(0) <= val && val <= '\uDBFF'.charAt(0)) {
            return false;
        }
        return true;
    }

    private static Boolean isKeyword(String val) {
        for (String look : RsvrApexConstants.KEYWORDS) {
            if (look.toLowerCase() == val.toLowerCase()) {
                return true;
            }
        }
        return false;
    }


    // //
    // // Whitespace and comments
    // //

    // WS  :  [ \t\r\n\u000C]+ -> channel(WHITESPACE_CHANNEL)
    //     ;
    private WhitespaceToken parseWS() {
        WhitespaceToken result = new WhitespaceToken();
        result.type = 'WHITESPACE';

        mark();
        result.whitespace = '';
        Boolean isExist = false;
        for (;;) {
            Integer next = readChar();
            if (next == ' '.charAt(0)
            || next == '\t'.charAt(0)
            || next == '\r'.charAt(0)
            || next == '\n'.charAt(0)
            || next == '\u000C'.charAt(0)) {
                isExist = true;
                mark();
                result.whitespace = result.whitespace + int2string(next);
                continue;
            }
            reset();
            break;
        }

        if (isExist == false) {
            return null;
        }

        result.original = result.whitespace;
        return result;
    }

    // DOC_COMMENT
    //     :   '/**' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;
    private WhitespaceToken parseDOC_COMMENT() {
        return null;
    }

    // COMMENT
    //     :   '/*' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;
    private WhitespaceToken parseCOMMENT() {
        return null;
    }

    // LINE_COMMENT
    //     :   '//' ~[\r\n]* -> channel(COMMENT_CHANNEL)
    //     ;
    private CommentToken parseLINE_COMMENT() {
        CommentToken result = new CommentToken();
        result.type = 'LINE_COMMENT';

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
        result.original = int2string(first) + int2string(second);
        result.comment = '';
        for (;;) {
            Integer next = readChar();
            if (next == '\r'.charAt(0)
            || next == '\n'.charAt(0)
            || next == -1) {
                reset();
                result.original = result.original + result.comment;
                break;
            }

            mark();
            result.comment = result.comment + int2string(next);
        }

        return result;
    }

    public static String int2string(Integer val) {
        List<Integer> nextOne = new List<Integer>();
        nextOne.add(val);
        return String.fromCharArray(nextOne);
    }
}
