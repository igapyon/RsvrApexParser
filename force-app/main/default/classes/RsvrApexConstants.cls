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
 * This class provide Constants of Apex Language.
 * 
 * @since 2022-11-23
 */
public class RsvrApexConstants {
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
    public static final Integer KEY_SYSTEMRUNAS = 32;
    public static final Integer KEY_SET = 33;
    public static final Integer KEY_SHARING = 34;
    public static final Integer KEY_STATIC = 35;
    public static final Integer KEY_SUPER = 36;
    public static final Integer KEY_SWITCH = 37;
    public static final Integer KEY_TESTMETHOD = 38;
    public static final Integer KEY_THIS = 39;
    public static final Integer KEY_THROW = 40;
    public static final Integer KEY_TRANSIENT = 41;
    public static final Integer KEY_TRIGGER = 42;
    public static final Integer KEY_TRY = 43;
    public static final Integer KEY_UNDELETE = 44;
    public static final Integer KEY_UPDATE = 45;
    public static final Integer KEY_UPSERT = 46;
    public static final Integer KEY_VIRTUAL = 47;
    public static final Integer KEY_VOID = 48;
    public static final Integer KEY_WEBSERVICE = 49;
    public static final Integer KEY_WHEN = 50;
    public static final Integer KEY_WHILE = 51;
    public static final Integer KEY_WITH = 52;
    public static final Integer KEY_WITHOUT = 53;
    // Apex generic types, Set is defined above for properties
    public static final Integer KEY_LIST = 54;
    public static final Integer KEY_MAP = 55;
    // Soql specific keywords
    public static final Integer KEY_SELECT = 56;
    public static final Integer KEY_COUNT = 57;
    public static final Integer KEY_FROM = 58;
    public static final Integer KEY_AS = 59;
    public static final Integer KEY_USING = 60;
    public static final Integer KEY_SCOPE = 61;
    public static final Integer KEY_WHERE = 62;
    public static final Integer KEY_ORDER = 63;
    public static final Integer KEY_BY = 64;
    public static final Integer KEY_LIMIT = 65;
    public static final Integer KEY_SOQLAND = 66;
    public static final Integer KEY_SOQLOR = 67;
    public static final Integer KEY_NOT = 68;
    public static final Integer KEY_AVG = 69;
    public static final Integer KEY_COUNT_DISTINCT = 70;
    public static final Integer KEY_MIN = 71;
    public static final Integer KEY_MAX = 72;
    public static final Integer KEY_SUM = 73;
    public static final Integer KEY_TYPEOF = 74;
    public static final Integer KEY_END = 75;
    public static final Integer KEY_THEN = 76;
    public static final Integer KEY_LIKE = 77;
    public static final Integer KEY_IN = 78;
    public static final Integer KEY_INCLUDES = 79;
    public static final Integer KEY_EXCLUDES = 80;
    public static final Integer KEY_ASC = 81;
    public static final Integer KEY_DESC = 82;
    public static final Integer KEY_NULLS = 83;
    public static final Integer KEY_FIRST = 84;
    public static final Integer KEY_LAST = 85;
    public static final Integer KEY_GROUP = 86;
    public static final Integer KEY_ALL = 87;
    public static final Integer KEY_ROWS = 88;
    public static final Integer KEY_VIEW = 89;
    public static final Integer KEY_HAVING = 90;
    public static final Integer KEY_ROLLUP = 91;
    public static final Integer KEY_TOLABEL = 92;
    public static final Integer KEY_OFFSET = 93;
    public static final Integer KEY_DATA = 94;
    public static final Integer KEY_CATEGORY = 95;
    public static final Integer KEY_AT = 96;
    public static final Integer KEY_ABOVE = 97;
    public static final Integer KEY_BELOW = 98;
    public static final Integer KEY_ABOVE_OR_BELOW = 99;
    public static final Integer KEY_SECURITY_ENFORCED = 100;
    public static final Integer KEY_REFERENCE = 101;
    public static final Integer KEY_CUBE = 102;
    public static final Integer KEY_FORMAT = 103;
    public static final Integer KEY_TRACKING = 104;
    public static final Integer KEY_VIEWSTAT = 105;
    public static final Integer KEY_CUSTOM = 106;
    public static final Integer KEY_STANDARD = 107;
    public static final Integer KEY_DISTANCE = 108;
    public static final Integer KEY_GEOLOCATION = 109;
    // SOQL Date functions
    public static final Integer KEY_CALENDAR_MONTH = 110;
    public static final Integer KEY_CALENDAR_QUARTER = 111;
    public static final Integer KEY_CALENDAR_YEAR = 112;
    public static final Integer KEY_DAY_IN_MONTH = 113;
    public static final Integer KEY_DAY_IN_WEEK = 114;
    public static final Integer KEY_DAY_IN_YEAR = 115;
    public static final Integer KEY_DAY_ONLY = 116;
    public static final Integer KEY_FISCAL_MONTH = 117;
    public static final Integer KEY_FISCAL_QUARTER = 118;
    public static final Integer KEY_FISCAL_YEAR = 119;
    public static final Integer KEY_HOUR_IN_DAY = 120;
    public static final Integer KEY_WEEK_IN_MONTH = 121;
    public static final Integer KEY_WEEK_IN_YEAR = 122;
    public static final Integer KEY_CONVERT_TIMEZONE = 123;
    // SOQL Date formulas
    public static final Integer KEY_YESTERDAY = 124;
    public static final Integer KEY_TODAY = 125;
    public static final Integer KEY_TOMORROW = 126;
    public static final Integer KEY_LAST_WEEK = 127;
    public static final Integer KEY_THIS_WEEK = 128;
    public static final Integer KEY_NEXT_WEEK = 129;
    public static final Integer KEY_LAST_MONTH = 130;
    public static final Integer KEY_THIS_MONTH = 131;
    public static final Integer KEY_NEXT_MONTH = 132;
    public static final Integer KEY_LAST_90_DAYS = 133;
    public static final Integer KEY_NEXT_90_DAYS = 134;
    public static final Integer KEY_LAST_N_DAYS_N = 135;
    public static final Integer KEY_NEXT_N_DAYS_N = 136;
    public static final Integer KEY_NEXT_N_WEEKS_N = 137;
    public static final Integer KEY_LAST_N_WEEKS_N = 138;
    public static final Integer KEY_NEXT_N_MONTHS_N = 139;
    public static final Integer KEY_LAST_N_MONTHS_N = 140;
    public static final Integer KEY_THIS_QUARTER = 141;
    public static final Integer KEY_LAST_QUARTER = 142;
    public static final Integer KEY_NEXT_QUARTER = 143;
    public static final Integer KEY_NEXT_N_QUARTERS_N = 144;
    public static final Integer KEY_LAST_N_QUARTERS_N = 145;
    public static final Integer KEY_THIS_YEAR = 146;
    public static final Integer KEY_LAST_YEAR = 147;
    public static final Integer KEY_NEXT_YEAR = 148;
    public static final Integer KEY_NEXT_N_YEARS_N = 148;
    public static final Integer KEY_LAST_N_YEARS_N = 150;
    public static final Integer KEY_THIS_FISCAL_QUARTER = 151;
    public static final Integer KEY_LAST_FISCAL_QUARTER = 152;
    public static final Integer KEY_NEXT_FISCAL_QUARTER = 153;
    public static final Integer KEY_NEXT_N_FISCAL_QUARTERS_N = 154;
    public static final Integer KEY_LAST_N_FISCAL_QUARTERS_N = 155;
    public static final Integer KEY_THIS_FISCAL_YEAR = 156;
    public static final Integer KEY_LAST_FISCAL_YEAR = 157;
    public static final Integer KEY_NEXT_FISCAL_YEAR = 158;
    public static final Integer KEY_NEXT_N_FISCAL_YEARS_N = 159;
    public static final Integer KEY_LAST_N_FISCAL_YEARS_N = 160;
    // SOSL Keywords
    public static final Integer KEY_FIND = 161;
    public static final Integer KEY_EMAIL = 162;
    public static final Integer KEY_NAME = 163;
    public static final Integer KEY_PHONE = 164;
    public static final Integer KEY_SIDEBAR = 165;
    public static final Integer KEY_FIELDS = 166;
    public static final Integer KEY_METADATA = 167;
    public static final Integer KEY_PRICEBOOKID = 168;
    public static final Integer KEY_NETWORK = 169;
    public static final Integer KEY_SNIPPET = 170;
    public static final Integer KEY_TARGET_LENGTH = 171;
    public static final Integer KEY_DIVISION = 172;
    public static final Integer KEY_RETURNING = 173;
    public static final Integer KEY_LISTVIEW = 174;
    
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

    // ??3.11 Separators
    public static final Integer SEP_LPAREN = 0; // '('
    public static final Integer SEP_RPAREN = 1; // ')'
    public static final Integer SEP_LBRACE = 2; // '{'
    public static final Integer SEP_RBRACE = 3; // '}'
    public static final Integer SEP_LBRACK = 4; // '['
    public static final Integer SEP_RBRACK = 5; // ']'
    public static final Integer SEP_SEMI   = 6; // ';'
    public static final Integer SEP_COMMA  = 7; // ','
    public static final Integer SEP_DOT    = 8; // '.'
    
    public static final String[] SEPARATORS = new String[]{
        '(',
        ')',
        '{',
        '}',
        '[',
        ']',
        ';',
        ',',
        '.'
    };

    // // ??3.12 Operators

    public static final Integer OPE_ASSIGN          = 0; // '='
    public static final Integer OPE_GT              = 1; // '>'
    public static final Integer OPE_LT              = 2; // '<'
    public static final Integer OPE_BANG            = 3; // '!'
    public static final Integer OPE_TILDE           = 4; // '~'
    public static final Integer OPE_QUESTIONDOT     = 5; // '?.'
    public static final Integer OPE_QUESTION        = 6; // '?'
    public static final Integer OPE_COLON           = 7; // '= 1; //'
    public static final Integer OPE_EQUAL           = 8; // '=='
    public static final Integer OPE_TRIPLEEQUAL     = 9; // '==='
    public static final Integer OPE_NOTEQUAL        = 10; // '!='
    public static final Integer OPE_LESSANDGREATER  = 11; // '<>'
    public static final Integer OPE_TRIPLENOTEQUAL  = 12; // '!=='
    public static final Integer OPE_AND             = 13; // '&&'
    public static final Integer OPE_OR              = 14; // '||'
    public static final Integer OPE_INC             = 15; // '++'
    public static final Integer OPE_DEC             = 16; // '--'
    public static final Integer OPE_ADD             = 17; // '+'
    public static final Integer OPE_SUB             = 18; // '-'
    public static final Integer OPE_MUL             = 19; // '*'
    public static final Integer OPE_DIV             = 20; // '/'
    public static final Integer OPE_BITAND          = 21; // '&'
    public static final Integer OPE_BITOR           = 22; // '|'
    public static final Integer OPE_CARET           = 23; // '^'
    public static final Integer OPE_MAPTO           = 24; // '=>'
    public static final Integer OPE_ADD_ASSIGN      = 25; // '+='
    public static final Integer OPE_SUB_ASSIGN      = 26; // '-='
    public static final Integer OPE_MUL_ASSIGN      = 27; // '*='
    public static final Integer OPE_DIV_ASSIGN      = 28; // '/='
    public static final Integer OPE_AND_ASSIGN      = 29; // '&='
    public static final Integer OPE_OR_ASSIGN       = 30; // '|='
    public static final Integer OPE_XOR_ASSIGN      = 31; // '^='
    public static final Integer OPE_LSHIFT_ASSIGN   = 32; // '<<='
    public static final Integer OPE_RSHIFT_ASSIGN   = 33; // '>>='
    public static final Integer OPE_URSHIFT_ASSIGN  = 34; // '>>>='
    public static final Integer OPE_GE              = 35; // '>=' (iga added)
    public static final Integer OPE_LE              = 36; // '<=' (iga added)
    
    public static final String[] OPERATORS = new String[]{
        '=',
        '>',
        '<',
        '!',
        '~',
        '?.',
        '?',
        ':',
        '==',
        '===',
        '!=',
        '<>',
        '!==',
        '&&',
        '||',
        '++',
        '--',
        '+',
        '-',
        '*',
        '/',
        '&',
        '|',
        '^',
        '=>',
        '+=',
        '-=',
        '*=',
        '/=',
        '&=',
        '|=',
        '^=',
        '<<=',
        '>>=',
        '>>>=',
        '>=', // (iga added)
        '<=' // (iga added)
    };
}