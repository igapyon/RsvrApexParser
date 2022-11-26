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
 * This class provide Utilities for Lexical Parser.
 * 
 * @since 2022-11-23
 */
public class RsvrApexLexicalParserUtil {
    private static final Map<Integer, String> int2stringMap = new Map<Integer, String>();

    public static String int2string(final Integer val) {
        if (int2stringMap.get(val) == null) {
            List<Integer> nextOne = new List<Integer>();
            nextOne.add(val);
            String strVal = String.fromCharArray(nextOne);
            int2stringMap.put(val, strVal);
        }
        return int2stringMap.get(val);
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
    public static Boolean isJavaLetter(final Integer val) {
        // [a-zA-Z$_] // these are the "java letters" below 0xFF
        if (97 /*[a]*/ <= val && val <= 122 /*[z]*/) {
            return true;
        }
        if (65 /*[A]*/ <= val && val <= 90 /*[Z]*/) {
            return true;
        }
        if (36 /*[$]*/ == val) {
            return true;
        }
        if (95 /*[_]*/ == val) {
            return true;
        }
        // ~[\u0000-\u00FF\uD800-\uDBFF]
        if (0 /*'\u0000'*/ <= val && val <= 255 /*'\u00FF'*/) {
            return false;
        }
        if (55296 /*'\uD800'*/ <= val && val <= 56319 /*'\uDBFF'*/) {
            return false;
        }
        if (val == -1) {
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
    public static Boolean isJavaLetterOrDigit(final Integer val) {
        // [a-zA-Z$_] // these are the "java letters" below 0xFF
        if (97 /*[a]*/ <= val && val <= 122 /*[z]*/) {
            return true;
        }
        if (65 /*[A]*/ <= val && val <= 90 /*[Z]*/) {
            return true;
        }
        if (48 /*[0]*/ <= val && val <= 57 /*[9]*/) {
            return true;
        }
        if (36 /*[$]*/ == val) {
            return true;
        }
        if (95 /*[_]*/ == val) {
            return true;
        }
        // ~[\u0000-\u00FF\uD800-\uDBFF]
        if (0 /*'\u0000'*/ <= val && val <= 255 /*'\u00FF'*/) {
            return false;
        }
        if (55296 /*'\uD800'*/ <= val && val <= 56319 /*'\uDBFF'*/) {
            return false;
        }
        if (val == -1) {
            return false;
        }
        return true;
    }

    private static Map<String,String> keywordMap = null;

    public static Boolean isKeyword(final String val) {
        if (keywordMap == null) {
            keywordMap = new Map<String,String>();
            for (String look : RsvrApexConstants.KEYWORDS) {
                keywordMap.put(look.toLowerCase(), look);
            }
        }
        return (keywordMap.get(val.toLowerCase()) != null);
    }

    private static Map<Integer,String> separatorMap = null;

    public static Boolean isSeparator(final Integer val) {
        if (separatorMap == null) {
            separatorMap = new Map<Integer,String>();
            for (String look : RsvrApexConstants.SEPARATORS) {
                separatorMap.put(look.charAt(0),look);
            }
        }
        return (separatorMap.get(val) != null);
    }

    private static Map<String,String> operatorMap = null;

    public static Boolean isOperator(final String val) {
        if (operatorMap == null) {
            operatorMap = new Map<String,String>();
            for (String look : RsvrApexConstants.OPERATORS) {
                operatorMap.put(look.toLowerCase(),look);
            }
        }
        return (operatorMap.get(val.toLowerCase()) != null);
    }

    public static Boolean isOperatorLetter(final Integer val) {
        if (val == RsvrUnicodeConstants.LETTER_Equal
        || val == RsvrUnicodeConstants.LETTER_Greater_Than
        || val == RsvrUnicodeConstants.LETTER_Less_Than
        || val == RsvrUnicodeConstants.LETTER_Tilde
        || val == RsvrUnicodeConstants.LETTER_Question
        || val == RsvrUnicodeConstants.LETTER_Full_Stop
        || val == RsvrUnicodeConstants.LETTER_Colon
        || val == RsvrUnicodeConstants.LETTER_Equal
        || val == RsvrUnicodeConstants.LETTER_Exclamation
        || val == RsvrUnicodeConstants.LETTER_Ampersand
        || val == RsvrUnicodeConstants.LETTER_Vertical_Bar
        || val == RsvrUnicodeConstants.LETTER_Plus
        || val == RsvrUnicodeConstants.LETTER_Hyphen_Minus
        || val == RsvrUnicodeConstants.LETTER_Asterisk
        || val == RsvrUnicodeConstants.LETTER_Slash
        || val == RsvrUnicodeConstants.LETTER_Circumflex_Accent) {
            return true;
        }
        return false;
    }

    // fragment
    // Digit
    //     :   [0-9]
    //     ;
    public static Boolean isDigit(Integer val) {
        if (val == RsvrUnicodeConstants.LETTER_Digit_Zero
        || val == RsvrUnicodeConstants.LETTER_Digit_One
        || val == RsvrUnicodeConstants.LETTER_Digit_Two
        || val == RsvrUnicodeConstants.LETTER_Digit_Three
        || val == RsvrUnicodeConstants.LETTER_Digit_Four
        || val == RsvrUnicodeConstants.LETTER_Digit_Five
        || val == RsvrUnicodeConstants.LETTER_Digit_Six
        || val == RsvrUnicodeConstants.LETTER_Digit_Seven
        || val == RsvrUnicodeConstants.LETTER_Digit_Eight
        || val == RsvrUnicodeConstants.LETTER_Digit_Nine) {
            return true;
        }
        return false;
    }

    // fragment
    // HexCharacter
    //     :   Digit | 'a' | 'b' | 'c' | 'd' | 'e' | 'f'
    //     ;
    public static Boolean isHexCharacter(Integer val) {
        if (isDigit(val)) {
            return true;
        }
        if ('a'.charAt(0) == val || 'A'.charAt(0) == val
        || 'b'.charAt(0) == val || 'B'.charAt(0) == val
        || 'c'.charAt(0) == val || 'C'.charAt(0) == val
        || 'd'.charAt(0) == val || 'D'.charAt(0) == val
        || 'e'.charAt(0) == val || 'E'.charAt(0) == val
        || 'f'.charAt(0) == val || 'F'.charAt(0) == val) {
            return true;
        }
        return false;
    }

    //////////////////////////////////////
    //

    public static String readApexClassBody(String apexClassName) {
        try {
            ApexClass apc = [SELECT Name, Body, NamespacePrefix
                FROM ApexClass
                WHERE Status = 'Active'
                AND Name = :apexClassName
                LIMIT 1];
            if (apc == null) {
                return null;
            }
            return apc.Body;
        } catch (System.QueryException ex) {
            return null;
        }
    }

    public static void validateLexicalParser(String apexClassNameWithoutExt, Boolean isDumpMode) {
        String apexClassBody = RsvrApexLexicalParserUtil.readApexClassBody(apexClassNameWithoutExt);
        // System.debug('TRACE: body[' + apexClassBody + ']');
        RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> result = parser.parse(apexClassBody);

        String parsedInput = '';
        for (RsvrApexLexicalParser.LexicalToken look : result) {
            parsedInput += look.original;
        }

        if (isDumpMode) {
            String dump = '';
            for (RsvrApexLexicalParser.LexicalToken look : result) {
                dump += (look.toString() + '\n');
            }
            System.debug('Dump:\n' + dump+ '\n\n');
        }

        // Fukugen check.
        System.assertEquals(apexClassBody, parsedInput);
    }
}