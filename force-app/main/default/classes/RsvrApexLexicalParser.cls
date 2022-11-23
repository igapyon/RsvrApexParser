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
        'list',
        'map',
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
}

/** 
// Keywords
ABSTRACT      : 'abstract';
AFTER         : 'after';
BEFORE        : 'before';
BREAK         : 'break';
CATCH         : 'catch';
CLASS         : 'class';
CONTINUE      : 'continue';
DELETE        : 'delete';
DO            : 'do';
ELSE          : 'else';
ENUM          : 'enum';
EXTENDS       : 'extends';
FINAL         : 'final';
FINALLY       : 'finally';
FOR           : 'for';
GET           : 'get';
GLOBAL	      : 'global';
IF            : 'if';
IMPLEMENTS    : 'implements';
INHERITED     : 'inherited';
INSERT        : 'insert';
INSTANCEOF    : 'instanceof';
INTERFACE     : 'interface';
MERGE         : 'merge';
NEW           : 'new';
NULL          : 'null';
ON            : 'on';
OVERRIDE      : 'override';
PRIVATE       : 'private';
PROTECTED     : 'protected';
PUBLIC        : 'public';
RETURN        : 'return';
SYSTEMRUNAS   : 'system.runas';
SET           : 'set';
SHARING       : 'sharing';
STATIC        : 'static';
SUPER         : 'super';
SWITCH        : 'switch';
TESTMETHOD    : 'testmethod';
THIS          : 'this';
THROW         : 'throw';
TRANSIENT     : 'transient';
TRIGGER       : 'trigger';
TRY           : 'try';
UNDELETE      : 'undelete';
UPDATE        : 'update';
UPSERT        : 'upsert';
VIRTUAL       : 'virtual';
VOID          : 'void';
WEBSERVICE    : 'webservice';
WHEN          : 'when';
WHILE         : 'while';
WITH          : 'with';
WITHOUT       : 'without';

// Apex generic types, Set is defined above for properties
LIST          : 'list';
MAP           : 'map';

// Soql specific keywords
SELECT          : 'select';
COUNT           : 'count';
FROM            : 'from';
AS              : 'as';
USING           : 'using';
SCOPE           : 'scope';
WHERE           : 'where';
ORDER           : 'order';
BY              : 'by';
LIMIT           : 'limit';
SOQLAND         : 'and';
SOQLOR          : 'or';
NOT             : 'not';
AVG             : 'avg';
COUNT_DISTINCT  : 'count_distinct';
MIN             : 'min';
MAX             : 'max';
SUM             : 'sum';
TYPEOF          : 'typeof';
END             : 'end';
THEN            : 'then';
LIKE            : 'like';
IN              : 'in';
INCLUDES        : 'includes';
EXCLUDES        : 'excludes';
ASC             : 'asc';
DESC            : 'desc';
NULLS           : 'nulls';
FIRST           : 'first';
LAST            : 'last';
GROUP           : 'group';
ALL             : 'all';
ROWS            : 'rows';
VIEW            : 'view';
HAVING          : 'having';
ROLLUP          : 'rollup';
TOLABEL         : 'tolabel';
OFFSET          : 'offset';
DATA            : 'data';
CATEGORY        : 'category';
AT              : 'at';
ABOVE           : 'above';
BELOW           : 'below';
ABOVE_OR_BELOW  : 'above_or_below';
SECURITY_ENFORCED : 'security_enforced';
REFERENCE       : 'reference';
CUBE            : 'cube';
FORMAT          : 'format';
TRACKING        : 'tracking';
VIEWSTAT        : 'viewstat';
CUSTOM          : 'custom';
STANDARD        : 'standard';
DISTANCE        : 'distance';
GEOLOCATION     : 'geolocation';

// SOQL Date functions
CALENDAR_MONTH      : 'calendar_month';
CALENDAR_QUARTER    : 'calendar_quarter';
CALENDAR_YEAR       : 'calendar_year';
DAY_IN_MONTH        : 'day_in_month';
DAY_IN_WEEK         : 'day_in_week';
DAY_IN_YEAR         : 'day_in_year';
DAY_ONLY            : 'day_only';
FISCAL_MONTH        : 'fiscal_month';
FISCAL_QUARTER      : 'fiscal_quarter';
FISCAL_YEAR         : 'fiscal_year';
HOUR_IN_DAY         : 'hour_in_day';
WEEK_IN_MONTH       : 'week_in_month';
WEEK_IN_YEAR        : 'week_in_year';
CONVERT_TIMEZONE    : 'converttimezone';

// SOQL Date formulas
YESTERDAY                 : 'yesterday';
TODAY                     : 'today';
TOMORROW                  : 'tomorrow';
LAST_WEEK                 : 'last_week';
THIS_WEEK                 : 'this_week';
NEXT_WEEK                 : 'next_week';
LAST_MONTH                : 'last_month';
THIS_MONTH                : 'this_month';
NEXT_MONTH                : 'next_month';
LAST_90_DAYS              : 'last_90_days';
NEXT_90_DAYS              : 'next_90_days';
LAST_N_DAYS_N             : 'last_n_days';
NEXT_N_DAYS_N             : 'next_n_days';
NEXT_N_WEEKS_N            : 'next_n_weeks';
LAST_N_WEEKS_N            : 'last_n_weeks';
NEXT_N_MONTHS_N           : 'next_n_months';
LAST_N_MONTHS_N           : 'last_n_months';
THIS_QUARTER              : 'this_quarter';
LAST_QUARTER              : 'last_quarter';
NEXT_QUARTER              : 'next_quarter';
NEXT_N_QUARTERS_N         : 'next_n_quarters';
LAST_N_QUARTERS_N         : 'last_n_quarters';
THIS_YEAR                 : 'this_year';
LAST_YEAR                 : 'last_year';
NEXT_YEAR                 : 'next_year';
NEXT_N_YEARS_N            : 'next_n_years';
LAST_N_YEARS_N            : 'last_n_years';
THIS_FISCAL_QUARTER       : 'this_fiscal_quarter';
LAST_FISCAL_QUARTER       : 'last_fiscal_quarter';
NEXT_FISCAL_QUARTER       : 'next_fiscal_quarter';
NEXT_N_FISCAL_QUARTERS_N  : 'next_n_fiscal_quarters';
LAST_N_FISCAL_QUARTERS_N  : 'last_n_fiscal_quarters';
THIS_FISCAL_YEAR          : 'this_fiscal_year';
LAST_FISCAL_YEAR          : 'last_fiscal_year';
NEXT_FISCAL_YEAR          : 'next_fiscal_year';
NEXT_N_FISCAL_YEARS_N     : 'next_n_fiscal_years';
LAST_N_FISCAL_YEARS_N     : 'last_n_fiscal_years';

// SOSL Keywords
FIND                      : 'find';
EMAIL                     : 'email';
NAME                      : 'name';
PHONE                     : 'phone';
SIDEBAR                   : 'sidebar';
FIELDS                    : 'fields';
METADATA                  : 'metadata';
PRICEBOOKID               : 'pricebookid';
NETWORK                   : 'network';
SNIPPET                   : 'snippet';
TARGET_LENGTH             : 'target_length';
DIVISION                  : 'division';
RETURNING                 : 'returning';
LISTVIEW                  : 'listview';
*/


