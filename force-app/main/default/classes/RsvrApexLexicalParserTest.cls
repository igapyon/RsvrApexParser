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
@isTest(SeeAllData=false)
public class RsvrApexLexicalParserTest {
    @isTest(SeeAllData=false)
    static void test01() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest', false);
    }

    @isTest(SeeAllData=false)
    static void test02() {
        System.assertEquals(39, '\''.charAt(0));
        System.assertEquals(92, '\\'.charAt(0));
        System.assertEquals(8, '\b'.charAt(0));
        System.assertEquals(9, '\t'.charAt(0));
        System.assertEquals(10, '\n'.charAt(0));
        System.assertEquals(12, '\f'.charAt(0));
        System.assertEquals(13, '\r'.charAt(0));
        System.assertEquals(34, '"'.charAt(0));
        System.assertEquals(12, '\u000C'.charAt(0));
    }
}
