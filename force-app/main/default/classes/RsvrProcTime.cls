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
 * Trace Process time.
 */
 public class RsvrProcTime {
    private final Map<String,Integer> procCountMap = new Map<String,Integer>();
    private final Map<String,Long> procTimeMap = new Map<String,Long>();

    private String currentProcName = 'Noname';
    private Long currentProcEnterTime = Datetime.now().getTime();

    public RsvrProcTime() {
        enter('Noname');
    }

    public void enter(String procName) {
        if (procCountMap.get(procName) == null) {
            procCountMap.put(procName, 0);
        }
        if (procTimeMap.get(procName) == null) {
            procTimeMap.put(procName, 0);
        }

        Long enterTime = Datetime.now().getTime();
        cal(enterTime);

        // 与えられた新しい処理名を記憶
        currentProcName = procName;
        currentProcEnterTime = enterTime;
    }

    private void cal(Long enterTime) {
        // 処理中だった時刻計測を実施
        procCountMap.put(currentProcName, procCountMap.get(currentProcName) + 1);
        Long oldEnterTime = procTimeMap.get(currentProcName);
        Long procCostTime = enterTime - currentProcEnterTime;
        procTimeMap.put(currentProcName, oldEnterTime + procCostTime);
        System.debug('RsvrProcTime: ' + currentProcName + ': count:' + procCountMap.get(currentProcName) + ', time:' + procCostTime + ', totaltime: ' + procTimeMap.get(currentProcName));
    }

    public void close() {
        // 処理中だった時刻計測を実施
        Long enterTime = Datetime.now().getTime();
        cal(enterTime);

        dump();
    }

    public void dump() {
        String message = '\n\nRsvrProcTime:\n';
        for (String key : procCountMap.keySet()) {
            message += ('    ' + key + ': count:' + procCountMap.get(key) + ', totaltime: ' + procTimeMap.get(key) + '\n');
        }
        message += '\n';
        System.debug(message);
    }
}
