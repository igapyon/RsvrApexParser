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
 * Input parser for Lexical parse.
 */
public class RsvrApexLexicalParserInput {
    private List<Integer> apexClassCharList;
    private Integer currentPos = -1;
    private Integer markPos = -1;

    public RsvrApexLexicalParserInput(String apexClassText) {
        // これだとバックスラッシュが消失する。
        // this.apexClassCharList = apexClassText.getChars();

        // これだとCPUタイムで圧倒的に不利。
        //List<Integer> result = new List<Integer>();
        //Integer len = apexClassText.length();
        //for (Integer i = 0; i < len; i++) {
        //    result.add(apexClassText.charAt(i));
        //}
        //this.apexClassCharList = result;

        // ワークアラウンド。バックスラッシュは増やしてしまえば良い。（自信はないがぱっとみ動作する）
        this.apexClassCharList = apexClassText.replace('\\','\\\\').getChars();
    }

    public Integer readChar() {
        currentPos++;
        if (apexClassCharList.size() <= currentPos) {
            // end of string.
            return -1;
        }

        return apexClassCharList.get(currentPos);
    }

    public Integer mark() {
        markPos = currentPos;
        return markPos;
    }

    public void move(Integer pos) {
        currentPos = pos;
    }

    public Integer pos() {
        return currentPos;
    }

    public void reset() {
        currentPos = markPos;
    }

    public String getRemainingtext(Boolean isNext) {
        Integer pos = currentPos;
        if (isNext) {
            pos++;
        }
        if (pos < 0) {
            pos = 0;
        }
        if (apexClassCharList.size() <= (pos)) {
            return '';
        }
        final String apexClassText = String.fromCharArray(apexClassCharList);
        return apexClassText.substring(pos);
    }
}