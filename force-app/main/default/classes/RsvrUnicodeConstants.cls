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
 * Unicode Constants for Apex.
 */
public class RsvrUnicodeConstants {
    public static final Integer NUL = 0; // Null character [U+0000]
    public static final Integer SOH = 1; // Start of Heading [U+0001]
    public static final Integer STX = 2; // Start of Text [U+0002]
    public static final Integer ETX = 3; // End-of-text character [U+0003]
    public static final Integer EOT = 4; // End-of-transmission character [U+0004]
    public static final Integer ENQ = 5; // Enquiry character [U+0005]
    public static final Integer ACK = 6; // Acknowledge character [U+0006]
    public static final Integer BEL = 7; // Bell character [U+0007]
    public static final Integer BS  = 8; // Backspace [U+0008]
    public static final Integer HT  = 9; // Horizontal tab [U+0009]
    public static final Integer LF  = 10; // Line feed [U+000A]
    public static final Integer VT  = 11; // Vertical tab [U+000B]
    public static final Integer FF  = 12; // Form feed [U+000C]
    public static final Integer CR  = 13; // Carriage return [U+000D]
    public static final Integer SO  = 14; // Shift Out [U+000E]
    public static final Integer SI  = 15; // Shift In [U+000F]
    public static final Integer DLE = 16; // Data Link Escape [U+0010]
    public static final Integer DC1 = 17; // Device Control 1 [U+0011]
    public static final Integer DC2 = 18; // Device Control 2 [U+0012]
    public static final Integer DC3 = 19; // Device Control 3 [U+0013]
    public static final Integer DC4 = 20; // Device Control 4 [U+0014]
    public static final Integer NAK = 21; // Negative-acknowledge character [U+0015]
    public static final Integer SYN = 22; // Synchronous Idle [U+0016]
    public static final Integer ETB = 23; // End of Transmission Block [U+0017]
    public static final Integer CAN = 24; // Cancel character [U+0018]
    public static final Integer EM  = 25; // End of Medium [U+0019]
    public static final Integer SUB = 26; // Substitute character [U+001A]
    public static final Integer ESC = 27; // Escape character [U+001B]
    public static final Integer FS  = 28; // File Separator [U+001C]
    public static final Integer GS  = 29; // Group Separator [U+001D]
    public static final Integer RS  = 30; // Record Separator [U+001E]
    public static final Integer US  = 31; // Unit Separator [U+001F]

    public static final Integer LETTER_Space       = 32; // SPACE
    public static final Integer LETTER_Exclamation = 33; // !
    public static final Integer LETTER_Quotation   = 34; // "
    public static final Integer LETTER_Sharp       = 35; // #
    public static final Integer LETTER_Dollar      = 36; // $
    public static final Integer LETTER_Percent     = 37; // %
    public static final Integer LETTER_Ampersand   = 38; // &
    public static final Integer LETTER_Apostrophe  = 39; // '
    public static final Integer LETTER_Left_Parenthesis = 40; // (
    public static final Integer LETTER_Right_Parenthesis = 41; // )
    public static final Integer LETTER_Asterisk    = 42; // *
    public static final Integer LETTER_Plus        = 43; // +
    public static final Integer LETTER_Comma       = 44; // ,
    public static final Integer LETTER_Hyphen_Minus= 45; // -
    public static final Integer LETTER_Full_Stop   = 46; // .
    public static final Integer LETTER_Slash       = 47; // /
    public static final Integer LETTER_Digit_Zero  = 48; // 0
    public static final Integer LETTER_Digit_One   = 49; // 1
    public static final Integer LETTER_Digit_Two   = 50; // 2
    public static final Integer LETTER_Digit_Three = 51; // 3
    public static final Integer LETTER_Digit_Four  = 52; // 4
    public static final Integer LETTER_Digit_Five  = 53; // 5
    public static final Integer LETTER_Digit_Six   = 54; // 6
    public static final Integer LETTER_Digit_Seven = 55; // 7
    public static final Integer LETTER_Digit_Eight = 56; // 8
    public static final Integer LETTER_Digit_Nine  = 57; // 9
    public static final Integer LETTER_Colon       = 58; // :
    public static final Integer LETTER_Semicolon   = 59; // ;
    public static final Integer LETTER_Less_Than   = 60; // <
    public static final Integer LETTER_Equal       = 61; // =
    public static final Integer LETTER_Greater_Than= 62; // >
    public static final Integer LETTER_Question    = 63; // ?
    public static final Integer LETTER_At          = 64; // @
    public static final Integer LETTER_Latin_Capital_Letter_A = 65; // A
    public static final Integer LETTER_Latin_Capital_Letter_B = 66; // B
    public static final Integer LETTER_Latin_Capital_Letter_C = 67; // C
    public static final Integer LETTER_Latin_Capital_Letter_D = 68; // D
    public static final Integer LETTER_Latin_Capital_Letter_E = 69; // E
    public static final Integer LETTER_Latin_Capital_Letter_F = 70; // F
    public static final Integer LETTER_Latin_Capital_Letter_G = 71; // G
    public static final Integer LETTER_Latin_Capital_Letter_H = 72; // H
    public static final Integer LETTER_Latin_Capital_Letter_I = 73; // I
    public static final Integer LETTER_Latin_Capital_Letter_J = 74; // J
    public static final Integer LETTER_Latin_Capital_Letter_K = 75; // K
    public static final Integer LETTER_Latin_Capital_Letter_L = 76; // L
    public static final Integer LETTER_Latin_Capital_Letter_M = 77; // M
    public static final Integer LETTER_Latin_Capital_Letter_N = 78; // N
    public static final Integer LETTER_Latin_Capital_Letter_O = 79; // O
    public static final Integer LETTER_Latin_Capital_Letter_P = 80; // P
    public static final Integer LETTER_Latin_Capital_Letter_Q = 81; // Q
    public static final Integer LETTER_Latin_Capital_Letter_R = 82; // R
    public static final Integer LETTER_Latin_Capital_Letter_S = 83; // S
    public static final Integer LETTER_Latin_Capital_Letter_T = 84; // T
    public static final Integer LETTER_Latin_Capital_Letter_U = 85; // U
    public static final Integer LETTER_Latin_Capital_Letter_V = 86; // V
    public static final Integer LETTER_Latin_Capital_Letter_W = 87; // W
    public static final Integer LETTER_Latin_Capital_Letter_X = 88; // X
    public static final Integer LETTER_Latin_Capital_Letter_Y = 89; // Y
    public static final Integer LETTER_Latin_Capital_Letter_Z = 90; // Z
    public static final Integer LETTER_Left_Square_Bracket  = 91; // [
    public static final Integer LETTER_Backslash            = 92; // \
    public static final Integer LETTER_Right_Square_Bracket	= 93; // ]
    public static final Integer LETTER_Circumflex_Accent    = 94; // ^
    public static final Integer LETTER_Low_Line             = 95; // _
    public static final Integer LETTER_Grave_Accent	        = 96; // `
    public static final Integer LETTER_Latin_Small_Letter_A	= 97; // a
    public static final Integer LETTER_Latin_Small_Letter_B	= 98; // b
    public static final Integer LETTER_Latin_Small_Letter_C	= 99; // c
    public static final Integer LETTER_Latin_Small_Letter_D	= 100; // d
    public static final Integer LETTER_Latin_Small_Letter_E	= 101; // e
    public static final Integer LETTER_Latin_Small_Letter_F	= 102; // f
    public static final Integer LETTER_Latin_Small_Letter_G	= 103; // g
    public static final Integer LETTER_Latin_Small_Letter_H	= 104; // h
    public static final Integer LETTER_Latin_Small_Letter_I	= 105; // i
    public static final Integer LETTER_Latin_Small_Letter_J	= 106; // j
    public static final Integer LETTER_Latin_Small_Letter_K	= 107; // k
    public static final Integer LETTER_Latin_Small_Letter_L	= 108; // l
    public static final Integer LETTER_Latin_Small_Letter_M	= 109; // m
    public static final Integer LETTER_Latin_Small_Letter_N	= 110; // n
    public static final Integer LETTER_Latin_Small_Letter_O	= 111; // o
    public static final Integer LETTER_Latin_Small_Letter_P	= 112; // p
    public static final Integer LETTER_Latin_Small_Letter_Q	= 113; // q
    public static final Integer LETTER_Latin_Small_Letter_R	= 114; // r
    public static final Integer LETTER_Latin_Small_Letter_S	= 115; // s
    public static final Integer LETTER_Latin_Small_Letter_T	= 116; // t
    public static final Integer LETTER_Latin_Small_Letter_U	= 117; // u
    public static final Integer LETTER_Latin_Small_Letter_V	= 118; // v
    public static final Integer LETTER_Latin_Small_Letter_W	= 119; // w
    public static final Integer LETTER_Latin_Small_Letter_X	= 120; // x
    public static final Integer LETTER_Latin_Small_Letter_Y	= 121; // y
    public static final Integer LETTER_Latin_Small_Letter_Z	= 122; // z
    public static final Integer LETTER_Left_Curly_Bracket = 123; // {
    public static final Integer LETTER_Vertical_Bar	= 124; // |
    public static final Integer LETTER_Right_Curly_Bracket = 125; // }
    public static final Integer LETTER_Tilde = 126; // ~

    public static final Integer DEL = 127; // Delete [U+007F]
    public static final Integer PAD = 128; // Padding Character [U+0080]
    public static final Integer HOP = 129; // High Octet Preset [U+0081]
    public static final Integer BPH = 130; // Break Permitted Here [U+0082]
    public static final Integer NBH = 131; // No Break Here [U+0083]
    public static final Integer IND = 132; // Index [U+0084]
    public static final Integer NEL = 133; // Next Line [U+0085]
    public static final Integer SSA = 134; // Start of Selected Area [U+0086]
    public static final Integer ESA = 135; // End of Selected Area [U+0087]
    public static final Integer HTS = 136; // Character Tabulation Set [U+0088]
    public static final Integer HTJ = 137; // Character Tabulation with Justification [U+0089]
    public static final Integer VTS = 138; // Line Tabulation Set [U+008A]
    public static final Integer PLD = 139; // Partial Line Forward [U+008B]
    public static final Integer PLU = 140; // Partial Line Backward [U+008C]
    public static final Integer RI  = 141; // Reverse Line Feed [U+008D]
    public static final Integer SS2 = 142; // Single-Shift Two [U+008E]
    public static final Integer SS3 = 143; // Single-Shift Three [U+008F]
    public static final Integer DCS = 144; // Device Control String [U+0090]
    public static final Integer PU1 = 145; // Private Use 1 [U+0091]
    public static final Integer PU2 = 146; // Private Use 2 [U+0092]
    public static final Integer STS = 147; // Set Transmit State [U+0093]
    public static final Integer CCH = 148; // Cancel character [U+0094]
    public static final Integer MW  = 149; // Message Waiting [U+0095]
    public static final Integer SPA = 150; // Start of Protected Area [U+0096]
    public static final Integer EPA = 151; // End of Protected Area [U+0097]
    public static final Integer SOS = 152; // Start of String [U+0098]
    public static final Integer SGCI= 153; // Single Graphic Character Introducer [U+0099]
    public static final Integer SCI = 154; // Single Character Intro Introducer [U+009A]
    public static final Integer CSI = 155; // Control Sequence Introducer [U+009B]
    public static final Integer ST  = 156; // String Terminator [U+009C]
    public static final Integer OSC = 157; // Operating System Command [U+009D]
    public static final Integer PM  = 158; // Private Message [U+009E]
    public static final Integer APC = 159; // Application Program Command [U+009F]
}