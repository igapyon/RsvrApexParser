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
public class RsvrApexLexicalParserUtil {
    public static String int2string(Integer val) {
        List<Integer> nextOne = new List<Integer>();
        nextOne.add(val);
        return String.fromCharArray(nextOne);
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
    public static Boolean isJavaLetter(Integer val) {
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
    public static Boolean isJavaLetterOrDigit(Integer val) {
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

    public static Boolean isKeyword(String val) {
        for (String look : RsvrApexConstants.KEYWORDS) {
            if (look.toLowerCase() == val.toLowerCase()) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isSeparator(String val) {
        for (String look : RsvrApexConstants.SEPARATORS) {
            if (look.toLowerCase() == val.toLowerCase()) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isOperator(String val) {
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

    // fragment
    // Digit
    //     :   [0-9]
    //     ;

    public static Boolean isDigit(Integer val) {
        if ('0'.charAt(0) == val
        || '1'.charAt(0) == val
        || '2'.charAt(0) == val
        || '3'.charAt(0) == val
        || '4'.charAt(0) == val
        || '5'.charAt(0) == val
        || '6'.charAt(0) == val
        || '7'.charAt(0) == val
        || '8'.charAt(0) == val
        || '9'.charAt(0) == val) {
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
        if ('a'.charAt(0) == val
        || 'b'.charAt(0) == val
        || 'c'.charAt(0) == val
        || 'd'.charAt(0) == val
        || 'e'.charAt(0) == val
        || 'f'.charAt(0) == val) {
            return true;
        }
        return false;
    }

    //////////////////////////////////////
    //

    public static String readApexClassBody(String apexClassName) {
        ApexClass apc = [SELECT Name, Body, NamespacePrefix
            FROM ApexClass
            WHERE Status = 'Active'
            AND Name = :apexClassName
            LIMIT 1];

        if (apc == null) {
            return null;
        }
        return apc.Body;
    }

    public static void validateLexicalParser(String apexClassNameWithoutExt, Boolean isDumpMode) {
        String apexClassBody = RsvrApexLexicalParserUtil.readApexClassBody(apexClassNameWithoutExt);
        RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> result = parser.parse(apexClassBody);

        String parsedInput = '';
        for (RsvrApexLexicalParser.LexicalToken look : result) {
            parsedInput += look.original;
        }
        // Fukugen check.
        System.assertEquals(apexClassBody, parsedInput);

        if (isDumpMode) {
            String dump = '';
            for (RsvrApexLexicalParser.LexicalToken look : result) {
                dump += (look.toString() + '\n');
            }
            System.debug('Dump:\n' + dump+ '\n\n');
        }
    }
}