CSVtoArray(ByRef ToProcess)
{
  Index = 1
  TempArray := Object()
  Loop, Parse, ToProcess, `,
  {
    Test := TempArray.Insert(A_LoopField)
    If (!Test)
      MsgBox, Fail
    Index := Index + 1
  }
  return TempArray
}


ConvertSecondstoMinSec(Seconds)
{
  MinSec := ""
  Minutes := 0
  Loop
  {
    If (Seconds < 60)
    {
      If (Minutes != 0)
      {
        MinSec := Minutes . " minute"
        If (Minutes > 1)
        {
          MinSec := MinSec . "s"
        }
        If (Seconds > 0)
        {
          MinSec := MinSec . " and "
        }
      }
      If (Seconds > 0)
      {
        MinSec := MinSec . Seconds . " second"
        If (Seconds > 1)
        {
          MinSec := MinSec . "s"
        }
      }
      break
    }
    Seconds := Seconds - 60
    Minutes := Minutes + 1
  }
  return MinSec
}


ParseRestartTimes(Times)
{
  Global ServerStartTime
  LongTimes := ""
  Loop, Parse, Times, `,,%A_Space%
  {
    FoundMatch = 0
    D := "-/:._,\\"
    DelimiterPattern := "-!@#%&=_:;',/``~\Q$^*()+{}[]\|?<>.\E"
    If ((RegExMatch(A_LoopField, "ix)^(?P<Year>\d{4})[" . D . "]?(?P<Month>(0\d|0?[1-9]|1[012]))[" . D . "]?(?P<Day>(0?[1-9]|[1-2]\d|3[01]))\s(?P<Hour>[012]?\d)[" . D . "]?(?P<Minute>[0-5]\d)?[" . D . "]?(?P<Second>[0-5]\d)?(?P<AP>[ap]m)?$", Time)) and (!FoundMatch))
    {
      If (StrLen(TimeMonth) = 1)
      {
        TimeMonth := "0" . TimeMonth
      }
      If (StrLen(TimeDay) = 1)
      {
        TimeDay := "0" . TimeDay
      }
      If ((TimeAP = "pm") and (TimeHour < 12))
      {
        TimeHour := TimeHour + 12
        If (TimeHour = 24)
        {
          TimeHour = "00"
        }
      }
      If (TimeHour = "")
      {
        TimeHour := "00"
      }
      If (TimeMinute = "")
      {
        TimeMinute := "00"
      }
      If (TimeSecond = "")
      {
        TimeSecond := "00"
      }
      If (StrLen(TimeHour) = 1)
      {
        TimeHour := "0" . TimeHour
      }
      If (StrLen(TimeMinute) = 1)
      {
        TimeMinute := "0" . TimeMinute
      }
      If (StrLen(TimeSecond) = 1)
      {
        TimeSecond := "0" . TimeSecond
      }
      LongTimes := LongTimes . TimeYear . TimeMonth . TimeDay . TimeHour . TimeMinute . TimeSecond . ","
      FoundMatch = 1
    }
    If ((RegExMatch(A_LoopField, "ix)^(?P<Year>\d{2})[" . D . "]?(?P<Month>(0\d|0?[1-9]|1[012]))[" . D . "]?(?P<Day>(0?[1-9]|[1-2]\d|3[01]))\s(?P<Hour>[012]?\d)[" . D . "]?(?P<Minute>[0-5]\d)?[" . D . "]?(?P<Second>[0-5]\d)?\s?(?P<AP>[ap]m)?$", Time)) and (!FoundMatch))
    {
      TimeYear := SubStr(A_YYYY, 1, 2) . TimeYear
      If (StrLen(TimeMonth) = 1)
      {
        TimeMonth := "0" . TimeMonth
      }
      If (StrLen(TimeDay) = 1)
      {
        TimeDay := "0" . TimeDay
      }
      If ((TimeAP = "pm") and (TimeHour < 12))
      {
        TimeHour := TimeHour + 12
        If (TimeHour = 24)
        {
          TimeHour = "00"
        }
      }
      If (TimeHour = "")
      {
        TimeHour := "00"
      }
      If (TimeMinute = "")
      {
        TimeMinute := "00"
      }
      If (TimeSecond = "")
      {
        TimeSecond := "00"
      }
      If (StrLen(TimeHour) = 1)
      {
        TimeHour := "0" . TimeHour
      }
      If (StrLen(TimeMinute) = 1)
      {
        TimeMinute := "0" . TimeMinute
      }
      If (StrLen(TimeSecond) = 1)
      {
        TimeSecond := "0" . TimeSecond
      }
      LongTimes := LongTimes . TimeYear . TimeMonth . TimeDay . TimeHour . TimeMinute . TimeSecond . ","
      FoundMatch = 1
    }
    if ((RegExMatch(A_LoopField, "ix)^(?P<Hour>[012]?\d)[" . D . "]?(?P<Minute>[0-5]\d)?[" . D . "]?(?P<Second>[0-5]\d)?\s?(?P<AP>[ap]m)?$", Time)) and (!FoundMatch))
    {
      If ((TimeAP = "pm") and (TimeHour < 12))
      {
        TimeHour := TimeHour + 12
        If (TimeHour = 24)
        {
          TimeHour = "00"
        }
      }
      If (TimeHour = "")
      {
        TimeHour := "00"
      }
      If (TimeMinute = "")
      {
        TimeMinute := "00"
      }
      If (TimeSecond = "")
      {
        TimeSecond := "00"
      }
      If (StrLen(TimeHour) = 1)
      {
        TimeHour := "0" . TimeHour
      }
      If (StrLen(TimeMinute) = 1)
      {
        TimeMinute := "0" . TimeMinute
      }
      If (StrLen(TimeSecond) = 1)
      {
        TimeSecond := "0" . TimeSecond
      }
      LongTimes := LongTimes . A_YYYY . A_MM . A_DD . TimeHour . TimeMinute . TimeSecond . ","
      FoundMatch = 1
    }
    If ((RegExMatch(A_LoopField, "^((?P<Day>\d{1,2})\s?(d|day|days))?\s?((?P<Hour>\d{1,2})\s?(h|hr|hrs|hour|hours))?\s?((?P<Minute>\d{1,2})\s?(m|min|mins|minutes))?\s?((?P<Second>\d{1,2})\s?(s|sec|secs|seconds))?$", Time)) and (!FoundMatch))
    {
      TimeMonth = 0
      TimeYear = 0
      If (TimeDay = "")
      {
        TimeDay := 0
      }
      If (TimeHour = "")
      {
        TimeHour := 0
      }
      If (TimeMinute = "")
      {
        TimeMinute := 0
      }
      If (TimeSecond = "")
      {
        TimeSecond := 0
      }
      
      TimeSecond := SubStr(ServerStartTime, 13, 2) + TimeSecond
      Loop
      {
        If (TimeSecond < 60)
        {
          break
        }
        TimeSecond := TimeSecond - 60
        TimeMinute := TimeMinute + 1
      }
      TimeMinute := SubStr(ServerStartTime, 11, 2) + TimeMinute
      Loop
      {
        If (TimeMinute < 60)
        {
          break
        }
        TimeMinute := TimeMinute - 60
        TimeHour := TimeHour + 1
      }
      TimeHour := SubStr(ServerStartTime, 9, 2) + TimeHour
      Loop
      {
        If (TimeHour < 24)
        {
          break
        }
        TimeHour := TimeHour - 24
        TimeDay := TimeDay + 1
      }
      TimeDay := SubStr(ServerStartTime, 7, 2) + TimeDay
      Loop
      {
        If ((RegExMatch(SubStr(ServerStartTime, 5, 2), "(01|03|05|07|08|10|12)")) and (TimeDay <= 31))
        {
          break
        }
        If ((RegExMatch(SubStr(ServerStartTime, 5, 2), "(04|06|09|11)")) and (TimeDay <= 30))
        {
          break
        }
        LeapYear = 0
        TempYear := SubStr(ServerStartTime, 1, 4)
        If (!InStr((TempYear / 4), "."))
        {
          LeapYear = 1
          If (!InStr((TempYear / 100), "."))
          {
            LeapYear = 0
            If (!InStr((TempYear / 400), "."))
            {
              LeapYear = 1
            }
          }
        }
        If ((SubStr(ServerStartTime, 5, 2) = "02") and (LeapYear) and (TimeDay <= 29))
        {
          break
        }
        If ((SubStr(ServerStartTime, 5, 2) = "02") and (!LeapYear) and (TimeDay <= 28))
        {
          break
        }
        If (RegExMatch(SubStr(ServerStartTime, 5, 2), "(01|03|05|07|08|10|12)"))
        {
          TimeDay := TimeDay - 31
        }
        If (RegExMatch(SubStr(ServerStartTime, 5, 2), "(04|06|09|11)"))
        {
          TimeDay := TimeDay - 31
        }
        If ((SubStr(ServerStartTime, 5, 2) = "02") and (LeapYear))
        {
          TimeDay := TimeDay - 29
        }
        If ((SubStr(ServerStartTime, 5, 2) = "02") and (!LeapYear))
        {
          TimeDay := TimeDay - 28
        }
        TimeMonth := TimeMonth + 1
      }
      TimeMonth := SubStr(ServerStartTime, 5, 2) + TimeMonth
      FoundMatch = 1
      Loop
      {
        If (TimeMonth < 12)
        {
          Break
        }
        TimeMonth := TimeMonth - 12
        TimeYear := TimeYear + 1
      }
      If (StrLen(TimeMonth) = 1)
      {
        TimeMonth := "0" + TimeMonth
      }
      If (StrLen(TimeDay) = 1)
      {
        TimeDay := "0" + TimeDay
      }
      If (StrLen(TimeHour) = 1)
      {
        TimeHour := "0" + TimeHour
      }
      If (StrLen(TimeMinute) = 1)
      {
        TimeMinute := "0" + TimeMinute
      }
      If (StrLen(TimeSecond) = 1)
      {
        TimeSecond := "0" + TimeSecond
      }
      TimeYear := SubStr(ServerStartTime, 1, 4) + TimeYear
      LongTimes := Longtimes . TimeYear . TimeMonth . TimeDay . TimeHour . TimeMinute . TimeSecond . ","
    }
  }
  Return LongTimes
}