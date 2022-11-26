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
 * This class provide Apex test.
 * 
 * @since 2022-11-23
 */
@isTest(SeeAllData=false)
private class RsvrApexLexicalParserTest12 {
    // Literals

    /**
     * 文字列リテラルのエスケープに関する簡単な確認。
     */

    @isTest(SeeAllData=false)
    static void test01() {
        Integer val1 = 123;
        Long val2 = 123L;
        Double val3 = 123.456;
        Boolean val4 = true;
        Boolean val5 = false;
        String val6 = null;
    }

    @isTest(SeeAllData=false)
    static void test02() {
        String val1 = 'ABC';
        String val2 = 'A\'C';
        String val3 = 'A\\C';
        String val4 = 'A\nC';
    }

    @isTest(SeeAllData=false)
    static void test03() {
        String val1 = 'A\'C';
        List<Integer> myList = val1.getChars();
    }
}