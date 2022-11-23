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
public class RsvrApexLexicalParserInput {
    private String apexClassText;
    private Integer currentPos = -1;
    private Integer markPos = -1;

    public RsvrApexLexicalParserInput(String apexClassText) {
        this.apexClassText = apexClassText;
    }

    public Integer readChar() {
        currentPos++;
        if (apexClassText.length() <= currentPos) {
            // end of string.
            return -1;
        }

        return apexClassText.charAt(currentPos);
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
        if (apexClassText.length() <= (pos)) {
            return '';
        }
        return apexClassText.substring(pos);
    }
}