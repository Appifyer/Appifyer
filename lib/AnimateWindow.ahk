/* AnimateWindow(hwnd,time,options){
    local H:=0x10000, A:=0x20000,C:=0x10, B:= 0x80000,S:=0x40000,R:= 0x1, L:=0x2, D:=0x4, U:=0x8,O:="HACBSLURD",opt:="",format:=""
    format:= A_FormatInteger
    SetFormat, integerfast, Hex
    opt := 0x0 + 0
    Loop,parse,Options
        If InStr(O,A_LoopField)
            opt |= %A_LoopField%
    If opt
        DllCall("AnimateWindow", "UInt", hwnd, "Int", time, "UInt", opt)
    SetFormat, integerfast,%format%
}
 */
 
AnimateWindow(HWND, Options, t=200){ ; By Nimda
o := 0, op := {Activate : 0x00020000, Fade : 0x00080000, Center : 0x00000010, Hide : 0x00010000, LR : 0x00000001, RL : 0x00000002, Slide : 0x00040000, TB : 0x00000004, BT : 0x00000008}
For k in op
If InStr(Options, k, false)
o |= op[k]
return DllCall("AnimateWindow", "UPtr", HWND, "Int", t, "UInt", o)
}