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
private class RsvrApexLexicalParserInputTest {
    @isTest(SeeAllData=false)
    static void test01() {
        final String apexClassText = '@isTest(SeeAllData=false)\n'
            + 'private class RsvrApexLexicalParserTest11 {\n'
            + '    // SOQL および SOSL クエリ\n'
            + '    @isTest(SeeAllData=false)\n'
            + '    static void test01() {\n'
            + '        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = \'Acme\'];\n'
            + '    }';
        final RsvrApexLexicalParserInput input = new RsvrApexLexicalParserInput(apexClassText);
        input.mark();
        input.reset();
        input.move(0);
        input.pos();
        input.readChar();
        input.getRemainingtext(false);
    }
}