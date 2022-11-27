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

    public class PanicToken extends LexicalToken {
        public String message {get; set;}
        public String remainingtext {get; set;}
    }

    private RsvrApexLexicalParserInput input = null;
    private List<RsvrApexLexicalParser.LexicalToken> tokenList = new List<RsvrApexLexicalParser.LexicalToken>();

    /////////////////////////////////////////////////////////////////
    // Main process loop.

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

    // Main process loop.
    /////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////
    // // Keywords

    public class KeywordToken extends LexicalToken {
        public Integer no {get; set;}
    }

    private LexicalToken parseKeyword() {
        procTime.enter('parseKeyword');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        for (Integer index = 0; index < 100/* for safety */; index++) {
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

                if (next != -1) {
                    input.move(input.pos() - 1);
                }

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
                    result.no = RsvrApexLexicalParserUtil.getKeywordNoMap().get(result.target);
                    return result;
                } else {
                    break;
                }
            }
        }

        input.reset();
        return null;
    }
    
    // ABSTRACT      : 'abstract';
    // AFTER         : 'after';
    // BEFORE        : 'before';
    // BREAK         : 'break';
    // CATCH         : 'catch';
    // CLASS         : 'class';
    // CONTINUE      : 'continue';
    // DELETE        : 'delete';
    // DO            : 'do';
    // ELSE          : 'else';
    // ENUM          : 'enum';
    // EXTENDS       : 'extends';
    // FINAL         : 'final';
    // FINALLY       : 'finally';
    // FOR           : 'for';
    // GET           : 'get';
    // GLOBAL	      : 'global';
    // IF            : 'if';
    // IMPLEMENTS    : 'implements';
    // INHERITED     : 'inherited';
    // INSERT        : 'insert';
    // INSTANCEOF    : 'instanceof';
    // INTERFACE     : 'interface';
    // MERGE         : 'merge';
    // NEW           : 'new';
    // NULL          : 'null';
    // ON            : 'on';
    // OVERRIDE      : 'override';
    // PRIVATE       : 'private';
    // PROTECTED     : 'protected';
    // PUBLIC        : 'public';
    // RETURN        : 'return';
    // SYSTEMRUNAS   : 'system.runas';
    // SET           : 'set';
    // SHARING       : 'sharing';
    // STATIC        : 'static';
    // SUPER         : 'super';
    // SWITCH        : 'switch';
    // TESTMETHOD    : 'testmethod';
    // THIS          : 'this';
    // THROW         : 'throw';
    // TRANSIENT     : 'transient';
    // TRIGGER       : 'trigger';
    // TRY           : 'try';
    // UNDELETE      : 'undelete';
    // UPDATE        : 'update';
    // UPSERT        : 'upsert';
    // VIRTUAL       : 'virtual';
    // VOID          : 'void';
    // WEBSERVICE    : 'webservice';
    // WHEN          : 'when';
    // WHILE         : 'while';
    // WITH          : 'with';
    // WITHOUT       : 'without';
    // 
    // // Apex generic types, Set is defined above for properties
    // LIST          : 'list';
    // MAP           : 'map';
    // 
    // // Soql specific keywords
    // SELECT          : 'select';
    // COUNT           : 'count';
    // FROM            : 'from';
    // AS              : 'as';
    // USING           : 'using';
    // SCOPE           : 'scope';
    // WHERE           : 'where';
    // ORDER           : 'order';
    // BY              : 'by';
    // LIMIT           : 'limit';
    // SOQLAND         : 'and';
    // SOQLOR          : 'or';
    // NOT             : 'not';
    // AVG             : 'avg';
    // COUNT_DISTINCT  : 'count_distinct';
    // MIN             : 'min';
    // MAX             : 'max';
    // SUM             : 'sum';
    // TYPEOF          : 'typeof';
    // END             : 'end';
    // THEN            : 'then';
    // LIKE            : 'like';
    // IN              : 'in';
    // INCLUDES        : 'includes';
    // EXCLUDES        : 'excludes';
    // ASC             : 'asc';
    // DESC            : 'desc';
    // NULLS           : 'nulls';
    // FIRST           : 'first';
    // LAST            : 'last';
    // GROUP           : 'group';
    // ALL             : 'all';
    // ROWS            : 'rows';
    // VIEW            : 'view';
    // HAVING          : 'having';
    // ROLLUP          : 'rollup';
    // TOLABEL         : 'tolabel';
    // OFFSET          : 'offset';
    // DATA            : 'data';
    // CATEGORY        : 'category';
    // AT              : 'at';
    // ABOVE           : 'above';
    // BELOW           : 'below';
    // ABOVE_OR_BELOW  : 'above_or_below';
    // SECURITY_ENFORCED : 'security_enforced';
    // REFERENCE       : 'reference';
    // CUBE            : 'cube';
    // FORMAT          : 'format';
    // TRACKING        : 'tracking';
    // VIEWSTAT        : 'viewstat';
    // CUSTOM          : 'custom';
    // STANDARD        : 'standard';
    // DISTANCE        : 'distance';
    // GEOLOCATION     : 'geolocation';
    // 
    // // SOQL Date functions
    // CALENDAR_MONTH      : 'calendar_month';
    // CALENDAR_QUARTER    : 'calendar_quarter';
    // CALENDAR_YEAR       : 'calendar_year';
    // DAY_IN_MONTH        : 'day_in_month';
    // DAY_IN_WEEK         : 'day_in_week';
    // DAY_IN_YEAR         : 'day_in_year';
    // DAY_ONLY            : 'day_only';
    // FISCAL_MONTH        : 'fiscal_month';
    // FISCAL_QUARTER      : 'fiscal_quarter';
    // FISCAL_YEAR         : 'fiscal_year';
    // HOUR_IN_DAY         : 'hour_in_day';
    // WEEK_IN_MONTH       : 'week_in_month';
    // WEEK_IN_YEAR        : 'week_in_year';
    // CONVERT_TIMEZONE    : 'converttimezone';
    // 
    // // SOQL Date formulas
    // YESTERDAY                 : 'yesterday';
    // TODAY                     : 'today';
    // TOMORROW                  : 'tomorrow';
    // LAST_WEEK                 : 'last_week';
    // THIS_WEEK                 : 'this_week';
    // NEXT_WEEK                 : 'next_week';
    // LAST_MONTH                : 'last_month';
    // THIS_MONTH                : 'this_month';
    // NEXT_MONTH                : 'next_month';
    // LAST_90_DAYS              : 'last_90_days';
    // NEXT_90_DAYS              : 'next_90_days';
    // LAST_N_DAYS_N             : 'last_n_days';
    // NEXT_N_DAYS_N             : 'next_n_days';
    // NEXT_N_WEEKS_N            : 'next_n_weeks';
    // LAST_N_WEEKS_N            : 'last_n_weeks';
    // NEXT_N_MONTHS_N           : 'next_n_months';
    // LAST_N_MONTHS_N           : 'last_n_months';
    // THIS_QUARTER              : 'this_quarter';
    // LAST_QUARTER              : 'last_quarter';
    // NEXT_QUARTER              : 'next_quarter';
    // NEXT_N_QUARTERS_N         : 'next_n_quarters';
    // LAST_N_QUARTERS_N         : 'last_n_quarters';
    // THIS_YEAR                 : 'this_year';
    // LAST_YEAR                 : 'last_year';
    // NEXT_YEAR                 : 'next_year';
    // NEXT_N_YEARS_N            : 'next_n_years';
    // LAST_N_YEARS_N            : 'last_n_years';
    // THIS_FISCAL_QUARTER       : 'this_fiscal_quarter';
    // LAST_FISCAL_QUARTER       : 'last_fiscal_quarter';
    // NEXT_FISCAL_QUARTER       : 'next_fiscal_quarter';
    // NEXT_N_FISCAL_QUARTERS_N  : 'next_n_fiscal_quarters';
    // LAST_N_FISCAL_QUARTERS_N  : 'last_n_fiscal_quarters';
    // THIS_FISCAL_YEAR          : 'this_fiscal_year';
    // LAST_FISCAL_YEAR          : 'last_fiscal_year';
    // NEXT_FISCAL_YEAR          : 'next_fiscal_year';
    // NEXT_N_FISCAL_YEARS_N     : 'next_n_fiscal_years';
    // LAST_N_FISCAL_YEARS_N     : 'last_n_fiscal_years';

    /////////////////////////////////////////////////////////////////
    // // SOQL Date literal
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

    /////////////////////////////////////////////////////////////////
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

    // // SOQL Currency literal
    // // (NOTE: this is also a valid Identifier)
    // IntegralCurrencyLiteral: [a-z] [a-z] [a-z] Digit+;

    // TODO SOQL Currency literal は一旦未着手のまま放置。

    // // SOSL Keywords
    // FIND                      : 'find';
    // EMAIL                     : 'email';
    // NAME                      : 'name';
    // PHONE                     : 'phone';
    // SIDEBAR                   : 'sidebar';
    // FIELDS                    : 'fields';
    // METADATA                  : 'metadata';
    // PRICEBOOKID               : 'pricebookid';
    // NETWORK                   : 'network';
    // SNIPPET                   : 'snippet';
    // TARGET_LENGTH             : 'target_length';
    // DIVISION                  : 'division';
    // RETURNING                 : 'returning';
    // LISTVIEW                  : 'listview';

    // FindLiteral
    //     :   '[' WS? 'find' WS '\'' FindCharacters? '\''
    //     ;

    // TODO FIND 系は一旦未着手のまま放置。

    // fragment
    // FindCharacters
    //     :   FindCharacter+
    //     ;
    // 
    // fragment
    // FindCharacter
    //     :   ~['\\]
    //     |   FindEscapeSequence
    //     ;
    // 
    // FindLiteralAlt
    //     :   '[' WS? 'find' WS '{' FindCharactersAlt? '}'
    //     ;
    // 
    // fragment
    // FindCharactersAlt
    //     :   FindCharacterAlt+
    //     ;
    // 
    // fragment
    // FindCharacterAlt
    //     :   ~[}\\]
    //     |   FindEscapeSequence
    //     ;
    // 
    // fragment
    // FindEscapeSequence
    //     :   '\\' [+\-&|!(){}    // "~*?:'\\]
    //     ;

    /////////////////////////////////////////////////////////////////
    //

    public class LiteralToken extends LexicalToken {
    }

    /////////////////////////////////////////////////////////////////
    // // §3.10.1 Integer Literals
    // 
    // IntegerLiteral
    //     :   Digit Digit*
    //     ;
    // 
    // LongLiteral
    //     : Digit Digit* [lL]
    //     ;
    // 
    // NumberLiteral
    //     :   Digit* '.' Digit Digit* [dD]?
    //     ;

    private LexicalToken parseNumberLiteral() {
        procTime.enter('parseNumberLiteral');
        input.mark();

        Integer first = input.readChar();
        if (RsvrApexLexicalParserUtil.isDigit(first) == false) {
            input.reset();
            return null;
        }

        // 数字が確定
        final List<Integer> targetList = new List<Integer>();
        final List<Integer> targetOriginalList = new List<Integer>();

        targetList.add(first);
        targetOriginalList.add(first);

        Boolean isDotExist = false;
        for (Integer index = 0; index < 100/* for safety */; index++) {
            Integer next = input.readChar();
            if (next == -1) {
                // end of file.
                input.mark();
                break;
            }

            if (next == RsvrUnicodeConstants.LETTER_Latin_Capital_Letter_D
              || next == RsvrUnicodeConstants.LETTER_Latin_Small_Letter_D) {
                // dD
                input.mark();
                targetOriginalList.add(next);
                LiteralToken result = new LiteralToken();
                result.type = 'NumberLiteral';
                result.target = String.fromCharArray(targetList);
                result.original = String.fromCharArray(targetOriginalList);
                return result;
            }
            if (next == RsvrUnicodeConstants.LETTER_Latin_Capital_Letter_L
              || next == RsvrUnicodeConstants.LETTER_Latin_Small_Letter_L) {
                // lL
                input.mark();
                targetOriginalList.add(next);
                LiteralToken result = new LiteralToken();
                result.type = 'LongLiteral';
                result.target = String.fromCharArray(targetList);
                result.original = String.fromCharArray(targetOriginalList);
                return result;
            }
            if (RsvrApexLexicalParserUtil.isDigit(next)) {
                targetOriginalList.add(next);
                targetList.add(next);
                continue;
            }
            if (next == RsvrUnicodeConstants.LETTER_Full_Stop) {
                isDotExist = true;
                targetOriginalList.add(next);
                targetList.add(next);
                continue;
            }

            // 廃棄
            input.move(input.pos() - 1);

            if (RsvrApexLexicalParserUtil.isJavaLetter(next)) {
                // DONT.
                input.reset();
                return null;
            }

            break;
        }

        // ここまできたら値確定
        input.mark();
        LiteralToken result = new LiteralToken();
        result.target = String.fromCharArray(targetList);
        result.original = String.fromCharArray(targetOriginalList);
        if (isDotExist) {
            result.type = 'NumberLiteral';
            return result;
        } else {
            result.type = 'IntegerLiteral';
            return result;
        }
    }

    // fragment
    // HexCharacter
    //     :   Digit | 'a' | 'b' | 'c' | 'd' | 'e' | 'f'
    //     ;
    // 
    // fragment
    // Digit
    //     :   [0-9]
    //     ;

    /////////////////////////////////////////////////////////////////
    // // §3.10.3 Boolean Literals
    // 
    // BooleanLiteral
    //     :   'true'
    //     |   'false'
    //     ;

    // Note: BooleanLiteral は parseIdentifier の内部で実現。

    /////////////////////////////////////////////////////////////////
    // // §3.10.5 String Literals
    // 
    // StringLiteral
    //     :   '\'' StringCharacters? '\''
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
        for (Integer index = 0; index < 10000/* for safety */; index++) {
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
                    targetOriginalList.add(hex1);
                    targetOriginalList.add(hex2);
                    targetOriginalList.add(hex3);
                    targetOriginalList.add(hex4);
                    // Hex錬成
                    if (hex1 == RsvrUnicodeConstants.LETTER_Digit_Zero && hex2 == RsvrUnicodeConstants.LETTER_Digit_Zero) {
                        String wrk = EncodingUtil.urlDecode('%' + RsvrApexLexicalParserUtil.int2string(hex3) + RsvrApexLexicalParserUtil.int2string(hex4), 'UTF-8');
                        targetList.add(wrk.charAt(0));
                    } else {
                        String wrk = EncodingUtil.urlDecode('%' + RsvrApexLexicalParserUtil.int2string(hex1) + RsvrApexLexicalParserUtil.int2string(hex2) + '%' + RsvrApexLexicalParserUtil.int2string(hex3) + RsvrApexLexicalParserUtil.int2string(hex4), 'UTF-8');
                        targetList.add(wrk.charAt(0));
                    }
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

    // fragment
    // StringCharacters
    //     :   StringCharacter+
    //     ;
    // 
    // fragment
    // StringCharacter
    //     :   ~['\\]
    //     |   EscapeSequence
    //     ;
    // 
    // // §3.10.6 Escape Sequences for Character and String Literals
    // 
    // fragment
    // EscapeSequence
    //     :   '\\' [btnfr"'\\]
    //     |   '\\u' HexCharacter HexCharacter HexCharacter HexCharacter
    //     ;

    /////////////////////////////////////////////////////////////////
    // // §3.10.7 The Null Literal
    // 
    // NullLiteral
    //     :   NULL
    //     ;

    // Note: NullLiteral は parseKeyword の内部で実現。

    /////////////////////////////////////////////////////////////////
    // // §3.11 Separators
    // 
    // LPAREN          : '(';
    // RPAREN          : ')';
    // LBRACE          : '{';
    // RBRACE          : '}';
    // LBRACK          : '[';
    // RBRACK          : ']';
    // SEMI            : ';';
    // COMMA           : ',';
    // DOT             : '.';

    public class SeparatorToken extends LexicalToken {
        public Integer no {get; set;}
    }

    private static Map<String,Integer> separatorNoMap = null;

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
            result.no = RsvrApexLexicalParserUtil.getSeparatorNoMap().get(result.target);
            return result;
        }

        input.reset();
        return null;
    }

    /////////////////////////////////////////////////////////////////
    // // §3.12 Operators
    // 
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
    // CARET           : '    // ';
    // MAPTO           : '=>';
    // 
    // ADD_ASSIGN      : '+=';
    // SUB_ASSIGN      : '-=';
    // MUL_ASSIGN      : '*=';
    // DIV_ASSIGN      : '/=';
    // AND_ASSIGN      : '&=';
    // OR_ASSIGN       : '|=';
    // XOR_ASSIGN      : '    // =';
    // LSHIFT_ASSIGN   : '<<=';
    // RSHIFT_ASSIGN   : '>>=';
    // URSHIFT_ASSIGN  : '>>>=';

    public class OperatorToken extends LexicalToken {
        public Integer no {get; set;}
    }

    private OperatorToken parseOperator() {
        procTime.enter('parseOperator');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        for (Integer index = 0; index < 100/* for safety */; index++) {
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
                    result.no = RsvrApexLexicalParserUtil.getOperatorNoMap().get(result.target);
                    // System.debug('TRACE: Operator: [' + result.target + ']');
                    return result;
                } else {
                    // 短くしながら確認
                    for (Integer len = target.length() - 1; len > 0; len--) {
                        input.move(input.pos() - 1);
                        final String subTarget = target.substring(0,len);
                        if (RsvrApexLexicalParserUtil.isOperator(subTarget)) {
                            // hit!
                            input.mark();
                            OperatorToken result = new OperatorToken();
                            result.type = 'Operator';
                            result.target = subTarget;
                            result.original = result.target;
                            result.no = RsvrApexLexicalParserUtil.getOperatorNoMap().get(result.target);
                            return result;
                        }
                    }

                    // in case // or /* pass here.
                    break;
                }
            }
        }

        input.reset();
        return null;
    }

    /////////////////////////////////////////////////////////////////
    // //
    // // Additional symbols not defined in the lexical specification
    // //
    // 
    // ATSIGN : '@';

    public class AtsignToken extends LexicalToken {
    }

    private AtsignToken parseAtsign() {
        procTime.enter('parseAtsign');

        input.mark();

        Integer next = input.readChar();
        if (next == 64 /* [@] */) {
            AtsignToken result = new AtsignToken();
            result.type = 'Atsign';
        
            result.target = RsvrApexLexicalParserUtil.int2string(next);
            result.original = result.target;
            return result;
        }

        input.reset();
        return null;
    }

    /////////////////////////////////////////////////////////////////
    // // §3.8 Identifiers (must appear after all keywords in the grammar)
    // 
    // Identifier
    //     :   JavaLetter JavaLetterOrDigit*
    //     ;

    public class IdentifierToken extends LexicalToken {
    }

    private LexicalToken parseIdentifier() {
        procTime.enter('parseIdentifier');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        Boolean isFirst = true;
        for (Integer index = 0; index < 10000/* for safety */; index++) {
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
    // 
    // fragment
    // JavaLetterOrDigit
    //     :   [a-zA-Z0-9$_] // these are the "java letters or digits" below 0xFF
    //     |   // covers all characters above 0xFF which are not a surrogate
    //         ~[\u0000-\u00FF\uD800-\uDBFF]
    //     |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
    //         [\uD800-\uDBFF] [\uDC00-\uDFFF]
    //     ;

    /////////////////////////////////////////////////////////////////
    // //
    // // Whitespace and comments
    // //
    // 
    // WS  :  [ \t\r\n\u000C]+ -> channel(WHITESPACE_CHANNEL)
    //     ;

    public class WhitespaceToken extends LexicalToken {
    }

    private WhitespaceToken parseWhitespace() {
        procTime.enter('parseWhitespace');

        input.mark();

        List<Integer> targetList = null;

        Boolean isExist = false;
        for (Integer index = 0; index < 10000/* for safety */; index++) {
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

    /////////////////////////////////////////////////////////////////
    // DOC_COMMENT
    //     :   '/**' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;
    // 
    // COMMENT
    //     :   '/*' .*? '*/' -> channel(COMMENT_CHANNEL)
    //     ;

    public class CommentToken extends LexicalToken {
    }

    private CommentToken parseComment() {
        procTime.enter('parseComment');

        input.mark();
        Integer first = input.readChar();
        if (first != RsvrUnicodeConstants.LETTER_Slash) {
            input.reset();
            return null;
        }
        Integer second = input.readChar();
        if (second != RsvrUnicodeConstants.LETTER_Asterisk) {
            input.reset();
            return null;
        }

        ////////////////////////////
        // コメント確定

        List<Integer> targetList = new List<Integer>();
        List<Integer> targetOriginalList = new List<Integer>();
        targetOriginalList.add(first);
        targetOriginalList.add(second);

        input.mark();
        Boolean isDocComment = false;
        Integer third = input.readChar();
        targetOriginalList.add(third);
        if (third == RsvrUnicodeConstants.LETTER_Asterisk) {
            isDocComment = true;
        } else {
            targetList.add(third);
        }

        // hit comment
        Boolean isPastAsterisk = false;
        for (Integer index = 0; index < 10000/* for safety */; index++) {
            Integer next = input.readChar();
            targetOriginalList.add(next);
            if (next == RsvrUnicodeConstants.LETTER_Asterisk) {
                isPastAsterisk = true;
            } else {
                if (isPastAsterisk && next == RsvrUnicodeConstants.LETTER_Slash
                || next == -1) {
                    // End of comment.
                    input.mark();

                    CommentToken result = new CommentToken();
                    if (isDocComment) {
                        result.type = 'DocComment';
                    } else {
                        result.type = 'Comment';
                    }
                    result.target = String.fromCharArray(targetList);
                    result.original = String.fromCharArray(targetOriginalList);
                    return result;
                }
                if (isPastAsterisk) {
                    isPastAsterisk = false;
                    targetList.add(RsvrUnicodeConstants.LETTER_Asterisk);
                }
                targetList.add(next);
            }
        }

        input.reset();
        return null;
    }
    
    /////////////////////////////////////////////////////////////////
    // LINE_COMMENT
    //     :   '//' ~[\r\n]* -> channel(COMMENT_CHANNEL)
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
        for (Integer index = 0; index < 10000/* for safety */; index++) {
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
