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

    public static final Integer KEY_ABSTRACT = 0;
    public static final Integer KEY_AFTER = 1;
    public static final Integer KEY_BEFORE = 2;
    public static final Integer KEY_BREAK = 3;
    public static final Integer KEY_CATCH = 4;
    public static final Integer KEY_CLASS = 5;
    public static final Integer KEY_CONTINUE = 6;
    public static final Integer KEY_DELETE = 7;
    public static final Integer KEY_DO = 8;
    public static final Integer KEY_ELSE = 9;
    public static final Integer KEY_ENUM = 10;
    public static final Integer KEY_EXTENDS = 11;
    public static final Integer KEY_FINAL = 12;
    public static final Integer KEY_FINALLY = 13;
    public static final Integer KEY_FOR = 14;
    public static final Integer KEY_GET = 15;
    public static final Integer KEY_GLOBAL = 16;
    public static final Integer KEY_IF = 17;
    public static final Integer KEY_IMPLEMENTS = 18;
    public static final Integer KEY_INHERITED = 19;
    public static final Integer KEY_INSERT = 20;
    public static final Integer KEY_INSTANCEOF = 21;
    public static final Integer KEY_INTERFACE = 22;
    public static final Integer KEY_MERGE = 23;
    public static final Integer KEY_NEW = 24;
    public static final Integer KEY_NULL = 25;
    public static final Integer KEY_ON = 26;
    public static final Integer KEY_OVERRIDE = 27;
    public static final Integer KEY_PRIVATE = 28;
    public static final Integer KEY_PROTECTED = 29;
    public static final Integer KEY_PUBLIC = 30;
    public static final Integer KEY_RETURN = 31;
    public static final Integer KEY_SYSTEMRUNAS = 31;
    public static final Integer KEY_SET = 32;
    public static final Integer KEY_SHARING = 33;
    public static final Integer KEY_STATIC = 34;
    public static final Integer KEY_SUPER = 35;
    public static final Integer KEY_SWITCH = 36;
    public static final Integer KEY_TESTMETHOD = 37;
    public static final Integer KEY_THIS = 38;
    public static final Integer KEY_THROW = 39;
    public static final Integer KEY_TRANSIENT = 40;
    public static final Integer KEY_TRIGGER = 41;
    public static final Integer KEY_TRY = 42;
    public static final Integer KEY_UNDELETE = 43;
    public static final Integer KEY_UPDATE = 44;
    public static final Integer KEY_UPSERT = 45;
    public static final Integer KEY_VIRTUAL = 46;
    public static final Integer KEY_VOID = 47;
    public static final Integer KEY_WEBSERVICE = 48;
    public static final Integer KEY_WHEN = 49;
    public static final Integer KEY_WHILE = 50;
    public static final Integer KEY_WITH = 51;
    public static final Integer KEY_WITHOUT = 52;
    // Apex generic types, Set is defined above for properties
    public static final Integer KEY_LIST = 53;
    public static final Integer KEY_MAP = 54;
    // Soql specific keywords
    public static final Integer KEY_SELECT = 55;
    public static final Integer KEY_COUNT = 56;
    public static final Integer KEY_FROM = 57;
    public static final Integer KEY_AS = 58;
    public static final Integer KEY_USING = 59;
    public static final Integer KEY_SCOPE = 60;
    public static final Integer KEY_WHERE = 61;
    public static final Integer KEY_ORDER = 62;
    public static final Integer KEY_BY = 63;
    public static final Integer KEY_LIMIT = 64;
    public static final Integer KEY_SOQLAND = 65;
    public static final Integer KEY_SOQLOR = 66;
    public static final Integer KEY_NOT = 67;
    public static final Integer KEY_AVG = 68;
    public static final Integer KEY_COUNT_DISTINCT = 69;
    public static final Integer KEY_MIN = 70;
    public static final Integer KEY_MAX = 71;
    public static final Integer KEY_SUM = 72;
    public static final Integer KEY_TYPEOF = 73;
    public static final Integer KEY_END = 74;
    public static final Integer KEY_THEN = 75;
    public static final Integer KEY_LIKE = 76;
    public static final Integer KEY_IN = 77;
    public static final Integer KEY_INCLUDES = 78;
    public static final Integer KEY_EXCLUDES = 79;
    public static final Integer KEY_ASC = 80;
    public static final Integer KEY_DESC = 81;
    public static final Integer KEY_NULLS = 82;
    public static final Integer KEY_FIRST = 83;
    public static final Integer KEY_LAST = 84;
    public static final Integer KEY_GROUP = 85;
    public static final Integer KEY_ALL = 86;
    public static final Integer KEY_ROWS = 87;
    public static final Integer KEY_VIEW = 88;
    public static final Integer KEY_HAVING = 89;
    public static final Integer KEY_ROLLUP = 90;
    public static final Integer KEY_TOLABEL = 91;
    public static final Integer KEY_OFFSET = 92;
    public static final Integer KEY_DATA = 93;
    public static final Integer KEY_CATEGORY = 94;
    public static final Integer KEY_AT = 95;
    public static final Integer KEY_ABOVE = 96;
    public static final Integer KEY_BELOW = 97;
    public static final Integer KEY_ABOVE_OR_BELOW = 98;
    public static final Integer KEY_SECURITY_ENFORCED = 99;
    public static final Integer KEY_REFERENCE = 100;
    public static final Integer KEY_CUBE = 101;
    public static final Integer KEY_FORMAT = 102;
    public static final Integer KEY_TRACKING = 103;
    public static final Integer KEY_VIEWSTAT = 104;
    public static final Integer KEY_CUSTOM = 105;
    public static final Integer KEY_STANDARD = 106;
    public static final Integer KEY_DISTANCE = 107;
    public static final Integer KEY_GEOLOCATION = 108;
    // SOQL Date functions
    public static final Integer KEY_CALENDAR_MONTH = 109;
    public static final Integer KEY_CALENDAR_QUARTER = 110;
    public static final Integer KEY_CALENDAR_YEAR = 111;
    public static final Integer KEY_DAY_IN_MONTH = 112;
    public static final Integer KEY_DAY_IN_WEEK = 113;
    public static final Integer KEY_DAY_IN_YEAR = 114;
    public static final Integer KEY_DAY_ONLY = 115;
    public static final Integer KEY_FISCAL_MONTH = 116;
    public static final Integer KEY_FISCAL_QUARTER = 117;
    public static final Integer KEY_FISCAL_YEAR = 118;
    public static final Integer KEY_HOUR_IN_DAY = 119;
    public static final Integer KEY_WEEK_IN_MONTH = 120;
    public static final Integer KEY_WEEK_IN_YEAR = 121;
    public static final Integer KEY_CONVERT_TIMEZONE = 122;
    // SOQL Date formulas
    public static final Integer KEY_YESTERDAY = 123;
    public static final Integer KEY_TODAY = 124;
    public static final Integer KEY_TOMORROW = 125;
    public static final Integer KEY_LAST_WEEK = 126;
    public static final Integer KEY_THIS_WEEK = 127;
    public static final Integer KEY_NEXT_WEEK = 128;
    public static final Integer KEY_LAST_MONTH = 129;
    public static final Integer KEY_THIS_MONTH = 130;
    public static final Integer KEY_NEXT_MONTH = 131;
    public static final Integer KEY_LAST_90_DAYS = 132;
    public static final Integer KEY_NEXT_90_DAYS = 133;
    public static final Integer KEY_LAST_N_DAYS_N = 134;
    public static final Integer KEY_NEXT_N_DAYS_N = 135;
    public static final Integer KEY_NEXT_N_WEEKS_N = 136;
    public static final Integer KEY_LAST_N_WEEKS_N = 137;
    public static final Integer KEY_NEXT_N_MONTHS_N = 138;
    public static final Integer KEY_LAST_N_MONTHS_N = 139;
    public static final Integer KEY_THIS_QUARTER = 140;
    public static final Integer KEY_LAST_QUARTER = 141;
    public static final Integer KEY_NEXT_QUARTER = 142;
    public static final Integer KEY_NEXT_N_QUARTERS_N = 143;
    public static final Integer KEY_LAST_N_QUARTERS_N = 144;
    public static final Integer KEY_THIS_YEAR = 145;
    public static final Integer KEY_LAST_YEAR = 146;
    public static final Integer KEY_NEXT_YEAR = 147;
    public static final Integer KEY_NEXT_N_YEARS_N = 148;
    public static final Integer KEY_LAST_N_YEARS_N = 149;
    public static final Integer KEY_THIS_FISCAL_QUARTER = 150;
    public static final Integer KEY_LAST_FISCAL_QUARTER = 151;
    public static final Integer KEY_NEXT_FISCAL_QUARTER = 152;
    public static final Integer KEY_NEXT_N_FISCAL_QUARTERS_N = 153;
    public static final Integer KEY_LAST_N_FISCAL_QUARTERS_N = 154;
    public static final Integer KEY_THIS_FISCAL_YEAR = 155;
    public static final Integer KEY_LAST_FISCAL_YEAR = 156;
    public static final Integer KEY_NEXT_FISCAL_YEAR = 157;
    public static final Integer KEY_NEXT_N_FISCAL_YEARS_N = 158;
    public static final Integer KEY_LAST_N_FISCAL_YEARS_N = 159;
    // SOSL Keywords
    public static final Integer KEY_FIND = 160;
    public static final Integer KEY_EMAIL = 161;
    public static final Integer KEY_NAME = 162;
    public static final Integer KEY_PHONE = 163;
    public static final Integer KEY_SIDEBAR = 164;
    public static final Integer KEY_FIELDS = 165;
    public static final Integer KEY_METADATA = 166;
    public static final Integer KEY_PRICEBOOKID = 167;
    public static final Integer KEY_NETWORK = 168;
    public static final Integer KEY_SNIPPET = 169;
    public static final Integer KEY_TARGET_LENGTH = 170;
    public static final Integer KEY_DIVISION = 171;
    public static final Integer KEY_RETURNING = 172;
    public static final Integer KEY_LISTVIEW = 173;
    
    public static final String[] KEYWORDS = new String[]{
        'abstract',
        'after',
        'before',
        'break',
        'catch',
        'class',
        'continue',
        'delete',
        'do',
        'else',
        'enum',
        'extends',
        'final',
        'finally',
        'for',
        'get',
        'global',
        'if',
        'implements',
        'inherited',
        'insert',
        'instanceof',
        'interface',
        'merge',
        'new',
        'null',
        'on',
        'override',
        'private',
        'protected',
        'public',
        'return',
        'system.runas',
        'set',
        'sharing',
        'static',
        'super',
        'switch',
        'testmethod',
        'this',
        'throw',
        'transient',
        'trigger',
        'try',
        'undelete',
        'update',
        'upsert',
        'virtual',
        'void',
        'webservice',
        'when',
        'while',
        'with',
        'without',
        // Apex generic types, Set is defined above for properties
        'list',
        'map',
        // Soql specific keywords
        'select',
        'count',
        'from',
        'as',
        'using',
        'scope',
        'where',
        'order',
        'by',
        'limit',
        'and',
        'or',
        'not',
        'avg',
        'count_distinct',
        'min',
        'max',
        'sum',
        'typeof',
        'end',
        'then',
        'like',
        'in',
        'includes',
        'excludes',
        'asc',
        'desc',
        'nulls',
        'first',
        'last',
        'group',
        'all',
        'rows',
        'view',
        'having',
        'rollup',
        'tolabel',
        'offset',
        'data',
        'category',
        'at',
        'above',
        'below',
        'above_or_below',
        'security_enforced',
        'reference',
        'cube',
        'format',
        'tracking',
        'viewstat',
        'custom',
        'standard',
        'distance',
        'geolocation',
        // SOQL Date functions
        'calendar_month',
        'calendar_quarter',
        'calendar_year',
        'day_in_month',
        'day_in_week',
        'day_in_year',
        'day_only',
        'fiscal_month',
        'fiscal_quarter',
        'fiscal_year',
        'hour_in_day',
        'week_in_month',
        'week_in_year',
        'converttimezone',
        // SOQL Date formulas
        'yesterday',
        'today',
        'tomorrow',
        'last_week',
        'this_week',
        'next_week',
        'last_month',
        'this_month',
        'next_month',
        'last_90_days',
        'next_90_days',
        'last_n_days',
        'next_n_days',
        'next_n_weeks',
        'last_n_weeks',
        'next_n_months',
        'last_n_months',
        'this_quarter',
        'last_quarter',
        'next_quarter',
        'next_n_quarters',
        'last_n_quarters',
        'this_year',
        'last_year',
        'next_year',
        'next_n_years',
        'last_n_years',
        'this_fiscal_quarter',
        'last_fiscal_quarter',
        'next_fiscal_quarter',
        'next_n_fiscal_quarters',
        'last_n_fiscal_quarters',
        'this_fiscal_year',
        'last_fiscal_year',
        'next_fiscal_year',
        'next_n_fiscal_years',
        'last_n_fiscal_years',
        // SOSL Keywords
        'find',
        'email',
        'name',
        'phone',
        'sidebar',
        'fields',
        'metadata',
        'pricebookid',
        'network',
        'snippet',
        'target_length',
        'division',
        'returning',
        'listview'
    };

    public abstract class LexicalToken {
        public String original {get; set;}
        public String type {get; set;}
    }

    public class KeywordToken extends LexicalToken {
        public String keyword {get; set;}
    }

    public class LiteralToken extends LexicalToken {
    }

    public class SeparatorToken extends LexicalToken {
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
                if (IS_DEBUG) System.debug('TRACE: parseKEYWORD: ' + apexClassText.substring(currentPos + 1));
                KeywordToken tok = parseKEYWORD();
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
                tok.remainingtext = 'PANIC. Unexpected error. Process stopped.' + apexClassText.substring(currentPos);
                tokenList.add(tok);
                break;
            }        
        }
        
        return tokenList;
    }

    ///////////////////////////////////////
    // Parse

    private KeywordToken parseKEYWORD() {
        KeywordToken result = new KeywordToken();
        result.type = 'KEYWORD';

        mark();
        result.keyword = '';
        boolean isExist = false;
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


    // §3.11 Separators

    // LPAREN          : '(';
    // RPAREN          : ')';
    // LBRACE          : '{';
    // RBRACE          : '}';
    // LBRACK          : '[';
    // RBRACK          : ']';
    // SEMI            : ';';
    // COMMA           : ',';
    // DOT             : '.';

    // // §3.12 Operators

    // ASSIGN          : '=';
    // GT              : '>';
    // LT              : '<';
    // BANG            : '!';
    // TILDE           : '~';
    // QUESTIONDOT     : '?.';
    // QUESTION        : '?';
    // COLON           : ':';
    // EQUAL           : '==';
    // TRIPLEEQUAL     : '===';
    // NOTEQUAL        : '!=';
    // LESSANDGREATER  : '<>';
    // TRIPLENOTEQUAL  : '!==';
    // AND             : '&&';
    // OR              : '||';
    // INC             : '++';
    // DEC             : '--';
    // ADD             : '+';
    // SUB             : '-';
    // MUL             : '*';
    // DIV             : '/';
    // BITAND          : '&';
    // BITOR           : '|';
    // CARET           : '^';
    // MAPTO           : '=>';

    // ADD_ASSIGN      : '+=';
    // SUB_ASSIGN      : '-=';
    // MUL_ASSIGN      : '*=';
    // DIV_ASSIGN      : '/=';
    // AND_ASSIGN      : '&=';
    // OR_ASSIGN       : '|=';
    // XOR_ASSIGN      : '^=';
    // LSHIFT_ASSIGN   : '<<=';
    // RSHIFT_ASSIGN   : '>>=';
    // URSHIFT_ASSIGN  : '>>>=';

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
        boolean isExist = false;
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
    private static boolean isJavaLetter(Integer val) {
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
    private static boolean isJavaLetterOrDigit(Integer val) {
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



    private boolean isKeyword(String val) {
        for (String look : KEYWORDS) {
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
        boolean isExist = false;
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
