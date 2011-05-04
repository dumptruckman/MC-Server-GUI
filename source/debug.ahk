If (DebugMode()) {
  SetTimer, DebugModeTimer, 250
}

DebugMode() {
  Global DebugMode
  If (DebugMode) {
    return 1
  }
  else {
    return 0
  }
}

Debug(var, val) {
  If (DebugMode()) {
    Global Debug
    If (Debug[var]) {
      LV_Modify(Debug[var], "", var, val)
    }
    else {
      Debug.Insert(var, LV_Add("", var, val))
    }
    LV_ModifyCol()  
  }
}