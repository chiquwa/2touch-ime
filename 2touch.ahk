; テンキー2タッチ日本語入力システム (AutoHotkey v2対応)

; 特殊キー定数定義
;DIRECT_MODIFIER_DAKUTEN := "NumpadAdd"
;DIRECT_MODIFIER_HANDAKUTEN := "NumpadSub"
DIRECT_MODIFIER_CHONPU := "NumpadMult"
DIRECT_MODIFIER_SMALL_CONVERSION := "NumpadDiv"
DIRECT_MODIFIER_HYPHEN := "Numpad6_Numpad3"

; グローバル変数
lastPressedKeyCode := ""
lastOutputRomaji := ""
lastActionWasConversion := false

; 行定義（1タッチ目）
ROW_KEYS := Map(
    7, "A_ROW",    ; あ行
    8, "K_ROW",    ; か行
    9, "S_ROW",    ; さ行
    4, "T_ROW",    ; た行
    5, "N_ROW",    ; な行
    6, "H_ROW",    ; は行
    1, "M_ROW",    ; ま行
    2, "Y_ROW",    ; や行
    3, "R_ROW",    ; ら行
    0, "W_ROW"     ; わ行
)

; 段定義（2タッチ目）
COLUMN_KEYS := Map(
    7, 1,  ; あ段（1番目）
    8, 2,  ; い段（2番目）
    9, 3,  ; う段（3番目）
    4, 4,  ; え段（4番目）
    5, 5   ; お段（5番目）
)

; 直接出力キーマッピング
DIRECT_KEYS := Map()
;DIRECT_KEYS[DIRECT_MODIFIER_DAKUTEN] := "゛"
;DIRECT_KEYS[DIRECT_MODIFIER_HANDAKUTEN] := "゜"
DIRECT_KEYS[DIRECT_MODIFIER_CHONPU] := "ー"
DIRECT_KEYS[DIRECT_MODIFIER_HYPHEN] := "-"

; 2タッチ組み合わせマッピング
twoTouchCombineMap := Map(
    ; あ行 (7)
    "A_ROW_1", "a", "A_ROW_2", "i", "A_ROW_3", "u", "A_ROW_4", "e", "A_ROW_5", "o",
    ; か行 (8)
    "K_ROW_1", "ka", "K_ROW_2", "ki", "K_ROW_3", "ku", "K_ROW_4", "ke", "K_ROW_5", "ko",
    ; さ行 (9)
    "S_ROW_1", "sa", "S_ROW_2", "si", "S_ROW_3", "su", "S_ROW_4", "se", "S_ROW_5", "so",
    ; た行 (4)
    "T_ROW_1", "ta", "T_ROW_2", "ti", "T_ROW_3", "tu", "T_ROW_4", "te", "T_ROW_5", "to",
    ; な行 (5)
    "N_ROW_1", "na", "N_ROW_2", "ni", "N_ROW_3", "nu", "N_ROW_4", "ne", "N_ROW_5", "no",
    ; は行 (6)
    "H_ROW_1", "ha", "H_ROW_2", "hi", "H_ROW_3", "hu", "H_ROW_4", "he", "H_ROW_5", "ho",
    ; ま行 (1)
    "M_ROW_1", "ma", "M_ROW_2", "mi", "M_ROW_3", "mu", "M_ROW_4", "me", "M_ROW_5", "mo",
    ; や行 (2)
    "Y_ROW_1", "ya", "Y_ROW_2", "yi", "Y_ROW_3", "yu", "Y_ROW_4", "ye", "Y_ROW_5", "yo",
    ; ら行 (3)
    "R_ROW_1", "ra", "R_ROW_2", "ri", "R_ROW_3", "ru", "R_ROW_4", "re", "R_ROW_5", "ro",
    ; わ行 (0)
    "W_ROW_1", "wa", "W_ROW_2", "wi", "W_ROW_3", "wu", "W_ROW_4", "we", "W_ROW_5", "wo"
)

; 濁音化マッピング
dakutenMap := Map(
    "ka", "ga", "ki", "gi", "ku", "gu", "ke", "ge", "ko", "go",
    "sa", "za", "si", "zi", "su", "zu", "se", "ze", "so", "zo",
    "ta", "da", "ti", "di", "tu", "du", "te", "de", "to", "do",
    "ha", "ba", "hi", "bi", "hu", "bu", "he", "be", "ho", "bo"
)

; 半濁音化マッピング
handakutenMap := Map(
    "ha", "pa", "hi", "pi", "hu", "pu", "he", "pe", "ho", "po"
)

; 小文字化マッピング
smallKanaMap := Map(
    "a", "xa", "i", "xi", "u", "xu", "e", "xe", "o", "xo",
    "tu", "xtu", "ya", "xya", "yu", "xyu", "yo", "xyo",
    "wa", "xwa", "ka", "xka", "ke", "xke"
)

; 2タッチ特殊記号・数字マッピング
specialTwoTouchMap := Map(
    "61", "!",
    "62", "?",
    "28", "[",
    "24", "]",
    "-1", "1",
    "-2", "2",
    "-3", "3",
    "-4", "4",
    "-5", "5",
    "-6", "6",
    "-7", "7",
    "-8", "8",
    "-9", "9",
    "-0", "0"
)

; キーハンドラ関数
HandleKey(currentKeyCode) {
    global
    
    ; 1タッチ目が「-」の場合は、2タッチ目の数字でspecialKeyを生成
    if (lastPressedKeyCode = "-") {
        currentNum := StrReplace(currentKeyCode, "Numpad", "")
        if (currentNum != "") {
            specialKey := "-" . currentNum
            ; MsgBox("specialKey: " . specialKey)
            if (specialTwoTouchMap.Has(specialKey)) {
                Send(specialTwoTouchMap[specialKey])
                lastOutputRomaji := specialTwoTouchMap[specialKey]
                lastPressedKeyCode := ""
                lastActionWasConversion := false
                return
            }
            lastPressedKeyCode := ""
            return
        }
    }
    
    ; 小文字変換処理
    if (currentKeyCode = "NumpadDiv") {
        if (lastOutputRomaji != "" && smallKanaMap.Has(lastOutputRomaji)) {
            convertedRomaji := smallKanaMap[lastOutputRomaji]
            Send("{Backspace}")
            Send(convertedRomaji)
            lastOutputRomaji := convertedRomaji
            lastActionWasConversion := true
            return
        }
    }
    
    
    if (currentKeyCode = DIRECT_MODIFIER_CHONPU) {
        Send(DIRECT_KEYS[DIRECT_MODIFIER_CHONPU])
        lastOutputRomaji := ""
        return
    }
    
    ; 2タッチ組み合わせ処理
    if (lastPressedKeyCode != "") {
        ; 現在のキーコードから数字部分を抽出
        currentNum := StrReplace(currentKeyCode, "Numpad", "")
        if (currentNum = "") {
            lastPressedKeyCode := ""
            return
        }
        
        ; 追加: 2タッチ特殊記号・数字
        specialKey := lastPressedKeyCode . currentNum
        ; MsgBox("specialKey: " . specialKey)
        if (specialTwoTouchMap.Has(specialKey)) {
            if (specialKey = "61") {
                Send("{!}")
            } else {
                Send(specialTwoTouchMap[specialKey])
            }
            lastOutputRomaji := specialTwoTouchMap[specialKey]
            lastPressedKeyCode := ""
            lastActionWasConversion := false
            return
        }
        
        ; 特殊な組み合わせ: Numpad6 -> Numpad3 でハイフンを出力
        if (lastPressedKeyCode = "6" && currentNum = "3") {
            Send(DIRECT_KEYS[DIRECT_MODIFIER_HYPHEN])
            lastOutputRomaji := DIRECT_KEYS[DIRECT_MODIFIER_HYPHEN]
            lastPressedKeyCode := ""
            lastActionWasConversion := false
            return
        }
        
        ; 04で濁点、05で半濁点
        if (lastPressedKeyCode = "0") {
            if (currentNum = "4") { ; 濁点
                if (lastOutputRomaji != "" && dakutenMap.Has(lastOutputRomaji)) {
                    convertedRomaji := dakutenMap[lastOutputRomaji]
                    Send("{Backspace}")
                    Send(convertedRomaji)
                    lastOutputRomaji := convertedRomaji
                    lastActionWasConversion := true
                    lastPressedKeyCode := ""
                    return
                }
            } else if (currentNum = "5") { ; 半濁点
                if (lastOutputRomaji != "" && handakutenMap.Has(lastOutputRomaji)) {
                    convertedRomaji := handakutenMap[lastOutputRomaji]
                    Send("{Backspace}")
                    Send(convertedRomaji)
                    lastOutputRomaji := convertedRomaji
                    lastActionWasConversion := true
                    lastPressedKeyCode := ""
                    return
                }
            }
            ; 01で, 02で.
            if (currentNum = "1") { ; ,
                Send(",")
                lastOutputRomaji := ","
                lastPressedKeyCode := ""
                lastActionWasConversion := false
                return
            } else if (currentNum = "2") { ; .
                Send(".")
                lastOutputRomaji := "."
                lastPressedKeyCode := ""
                lastActionWasConversion := false
                return
            }
            ; 08でwo, 09でnn
            else if (currentNum = "8") { ; wo
                Send("wo")
                lastOutputRomaji := "wo"
                lastPressedKeyCode := ""
                lastActionWasConversion := false
                return
            } else if (currentNum = "9") { ; nn
                Send("nn")
                lastOutputRomaji := "nn"
                lastPressedKeyCode := ""
                lastActionWasConversion := false
                return
            }
        }
        
        try {
            currentNum := Integer(currentNum)
            lastNum := Integer(lastPressedKeyCode)
            
            if (ROW_KEYS.Has(lastNum) && COLUMN_KEYS.Has(currentNum)) {
                rowKey := ROW_KEYS[lastNum]
                columnNum := COLUMN_KEYS[currentNum]
                combineKey := rowKey . "_" . columnNum
                
                if (twoTouchCombineMap.Has(combineKey)) {
                    outputRomaji := twoTouchCombineMap[combineKey]
                    Send(outputRomaji)
                    lastOutputRomaji := outputRomaji
                    lastPressedKeyCode := ""
                    lastActionWasConversion := false
                    return
                }
            }
        } catch {
            ; エラーが発生した場合はリセット
        }
        ; 無効な組み合わせの場合はリセット
        lastPressedKeyCode := ""
    }
    
; 1タッチ目の処理
currentNum := StrReplace(currentKeyCode, "Numpad", "")
if (currentKeyCode = "NumpadSub") {
    lastPressedKeyCode := "-"
    lastActionWasConversion := false
    return
}
if (currentNum = "") {
    return
}



    ; ここで「lastPressedKeyCode = '-'」の場合は2タッチ目としてspecialKeyを生成する
    if (lastPressedKeyCode = "-") {
        specialKey := "-" . currentNum
        ; MsgBox("specialKey: " . specialKey)
        if (specialTwoTouchMap.Has(specialKey)) {
            Send(specialTwoTouchMap[specialKey])
            lastOutputRomaji := specialTwoTouchMap[specialKey]
            lastPressedKeyCode := ""
            lastActionWasConversion := false
            return
        }
        lastPressedKeyCode := ""
        return
    }
    
    try {
        currentNum := Integer(currentNum)
        if (ROW_KEYS.Has(currentNum)) {
            ; 行キー（1タッチ目） - 何も出力しない、次のキーを待つ
            lastPressedKeyCode := String(currentNum)
            lastActionWasConversion := false
        } else {
            ; 無効なキー
            lastPressedKeyCode := ""
        }
    } catch {
        lastPressedKeyCode := ""
    }
}

; リセット関数
ResetKey() {
    global
    lastPressedKeyCode := ""
    lastOutputRomaji := ""
    lastActionWasConversion := false
}

; ホットキー定義
Numpad0::HandleKey("Numpad0")
Numpad1::HandleKey("Numpad1")
Numpad2::HandleKey("Numpad2")
Numpad3::HandleKey("Numpad3")
Numpad4::HandleKey("Numpad4")
Numpad5::HandleKey("Numpad5")
Numpad6::HandleKey("Numpad6")
Numpad7::HandleKey("Numpad7")
Numpad8::HandleKey("Numpad8")
Numpad9::HandleKey("Numpad9")
;NumpadAdd::HandleKey("NumpadAdd")
NumpadSub::HandleKey("NumpadSub")
;NumpadMult::HandleKey("NumpadMult")
NumpadDiv::HandleKey("NumpadDiv")
;NumpadDot::HandleKey("NumpadDot")

; *キーでスペース
NumpadMult::Send("{Space}")

; .キーでスペース
NumpadDot::Send("{Space}")

; +キーでリセット
NumpadAdd::ResetKey()

; プログラム開始時の初期化
ResetKey()