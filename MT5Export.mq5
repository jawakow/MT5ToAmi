//+------------------------------------------------------------------+
//|                                                     MT5ToAmi.mq5 |
//|                                                          jawakow |
//|                                       https://jawakow.github.io/ |
//+------------------------------------------------------------------+
#property copyright "jawakow"
#property link      "https://jawakow.github.io/"
#property version   "1.00"
#property strict
#property indicator_chart_window

#import "shell32.dll"
int ShellExecuteW(int hWnd,string Verb,string File,string Parameter,string Path,int ShowCommand);
#import
string YMD,MDY,TimeHHMM;
string D,M,Sym,Sym1;
int handle,handle1,cnt,cnts;
datetime LastDate;
int barsToImport;
int selectedSymbolPos;
extern bool realTimeEnabled=true;
float lastClose=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   EventSetTimer(1);
//scanCustom(20*1440);
   FileDelete("lock");

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   scanCustom(2,"intraday_data.txt");
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_KEYDOWN)
     {

     }
   if(lparam==82)
     {
      scanCustom(100000,"historical_data.txt");

     }
  }
//+------------------------------------------------------------------+

void scanCustom(int bars,string filename)
  {

   barsToImport=bars;
   handle=FileOpen(filename,FILE_WRITE|FILE_ANSI,',');

   for(selectedSymbolPos=0;selectedSymbolPos<SymbolsTotal(true);selectedSymbolPos++)
     {

      Sym=SymbolName(selectedSymbolPos,true);
      //Sym=Symbol();
      //Export(PERIOD_D1);
      //Export(PERIOD_H1);
      Export(PERIOD_M1);
     }
   FileClose(handle);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Export(string Per)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,true);

   int sizeOfCopyRates=CopyRates(Symbol(),Period(),0,barsToImport,rates);
//int HistBars=ArraySize(rates);
//Print(sizeOfCopyRates);
//int HistBars=Bars(Symbol(), PERIOD_M1) - 1;
   for(cnt=0;cnt<sizeOfCopyRates;cnt++)
     {
      TimeHHMM=TimeToString(rates[cnt].time,TIME_MINUTES);
      D=TimeDayMQL4(rates[cnt].time);
      if(TimeDayMQL4(rates[cnt].time)<10) D=("0"+TimeDayMQL4(rates[cnt].time));
      M=TimeMonthMQL4(rates[cnt].time);
      if(TimeMonthMQL4(rates[cnt].time)<10) M=("0"+TimeMonthMQL4(rates[cnt].time));

      YMD = (TimeYearMQL4(rates[cnt].time)+""+M+""+D);
      MDY = (M+""+D+""+TimeYearMQL4(rates[cnt].time));
      Sym1=Sym;
      StringReplace(Sym1,"#","_");
      FileWrite(handle,Sym1,YMD,TimeHHMM,rates[cnt].open,rates[cnt].high,rates[cnt].low,rates[cnt].close,rates[cnt].tick_volume);
      //if (isIntra) FileWrite(handle,Sym1,(long)rates[cnt].time,rates[cnt].open,rates[cnt].high,rates[cnt].low,rates[cnt].close,rates[cnt].tick_volume); 

      //cnts = cnt;        
     }
//LastDate = rates[cnts].time;
//Print(LastDate);
  }
//+------------------------------------------------------------------+

int TimeDayMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMonthMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.mon);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeYearMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.year);
  }
//+------------------------------------------------------------------+
