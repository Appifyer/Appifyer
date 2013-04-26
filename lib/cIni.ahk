/*
Author	: zzzooo10
Link	: http://www.autohotkey.com/forum/viewtopic.php?p=462061#462061

Thanks to Tuncay for the idea: http://www.autohotkey.com/forum/viewtopic.php?t=74496

Licence	:
	Use in source, library and binary form is permitted.
	Redistribution and modification must meet the following condition:
	- My nickname (zzzooo10) and the origin (link) must be reproduced by binaries, or attached in the documentation.
	ALL MY SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESSED OR IMPLIED WARRANTIES.
*/

cIni(File, Default = "") {
    global Ini
	Return (Ini := new Ini(File, Default))
}

class Ini
{
        ; Loads ini file.
    __New(File, Default = "") {
        If (FileExist(File)) and (RegExMatch(File, "\.ini$"))
            FileRead, Info, % File
        Else
            Info := File
        Loop, Parse, Info, `n, `r
        {
            If (!A_LoopField)
                Continue
            If (SubStr(A_LoopField, 1, 1) = ";")
            {
                Comment .= A_LoopField . "`n"
                Continue
            }
            RegExMatch(A_LoopField, "(?:^\[(.+?)\]$|(.+?)=(.*))", Info) ; Info1 = Seciton, Info2 = Key, Info3 = Value\
            If (Info1)
                Saved_Section := Trim(Info1), this[Saved_Section] := { }, this[Saved_Section].__Comments := Comment, Comment := ""
            Info3 := (Info3) ? Info3 : Default
            If (Info2) and (Saved_Section)
                this[Saved_Section].Insert(Trim(Info2), Info3) ; Set the section name withs its keys and values.
        }
    }
    
    __Get(Section) {
        If (Section != "__Section")
            this[Section] := new this.__Section()
    }
    
    class __Section
    { 
        __Set(Key, Value) {
            If (Key = "__Comment")
            {
                Loop, Parse, Value, `n
                {
                    If (SubStr(A_LoopField, 1, 1) != ";")
                    {
                        NewValue .= "; " . A_LoopField . "`n"
                        Continue
                    }
                    NewValue .= A_LoopField . "`n"
                }
                this.__Comments := NewValue
                Return NewValue
            }
        }
        
        __Get(Name) {
            If (Name = "__Comment")
                Return this.__Comments
        }
    
    }
    
    ; Renames an entire section or just an individual key.
    Rename(Section, NewName, KeyName = "") { ; If KeyName is omited, rename the seciton, else rename key.
        Sections := this.Sections(",")
        If Section not in %Sections%
            Return 1
        else if ((this.HasKey(NewName)) and (!KeyName)) ; If the new section already exists.
            Return 1
        else if ((this[Section].HasKey(NewName)) and (KeyName)) ; If the section already contains the new key name.
            Return 1
        else if (!this[Section].HasKey(KeyName) and (KeyName)) ; If the section doesn't have the key to rename.
            Return 1
        else If (!KeyName)
        {
            this[NewName] := { }
            for key, value in this[Section]
                this[NewName].Insert(Key, Value)
            this[NewName].__Comment := this[Section].__Comment
            this.Remove(Section)
        }
        Else
        {
            KeyValue := this[Section][KeyName]
            this[Section].Insert(NewName, KeyValue)
            this[Section].Remove(KeyName)
        }
        Return 0
    }
    
    ; Delete a whole section or just a specific key within a section.
    Delete(Section, Key = "") { ; Omit "Key" to delete the whole section.
        If (Key)
            this[Section].Remove(Key)
        Else
            this.Remove(Section)
    }
    
    ; Returns a list of sections in the ini.
    Sections(Delimiter = "`n") {
        for Section, in this
            List .= (this.Keys(Section)) ? Section . Delimiter : ""
        Return SubStr(List, 1, -1)
    }
    
    ; Get all of the keys in the entire ini or just one section.
    Keys(Section = "") { ; Leave blank to retrieve all keys or specify a seciton to retrieve all of its keys.
        Sections := Section ? Section : this.Sections()
        Loop, Parse, Sections, `n
            for key, in this[A_LoopField]
                keys .= (key = "__Comments" or key = "__Comment") ? "" : key . "`n"
        Return SubStr(keys, 1, -1)
    }
     
    ; Saves everything to a file.
    Save(File) { 
        Sections := this.Sections()
        loop, Parse, Sections, `n
        {
            NewIni .= (this[A_LoopField].__Comments)
            NewIni .= (A_LoopField) ? ("[" . A_LoopField . "]`n") : ""
            For key, value in this[A_LoopField]
                NewIni .= (key = "__Comments" or key = "__Comment") ? "" : key . "=" . value . "`n"
            NewIni .= "`n"
        }
        FileDelete, % File
        FileAppend, % SubStr(NewIni, 1, -1), % File
    }
    
}