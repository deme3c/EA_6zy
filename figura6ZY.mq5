//+------------------------------------------------------------------+
//|                                                  figura6ZY.mq5   |
//|                                   David Martín Terrones (deme3c) |
//|                                        https://github.com/deme3c |
//+------------------------------------------------------------------+
#include "Configuracion6ZY.mqh"
#include "TradeManager.mqh"
#include "EstrategiaManager6ZY.mqh"

input double phi0 = 0.0;
input double phi6 = 0.0;
input bool   isBuy = true;  
input double costeFigura = 10.0; 

C_Configuracion g_config(phi0, phi6, isBuy, costeFigura);
C_TradeManager g_tradeManager;
C_EstrategiaManager *g_estrategia = nullptr;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{


   if(!g_config.ValidarParametros()) return INIT_FAILED;           
   
   g_estrategia = new C_EstrategiaManager(g_config, g_tradeManager);
   
   if(g_estrategia != nullptr)
   {
     Print("Estrategia inicializada correctamente.");
   }
     
     
     
     

   return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
  {

   
  }


void OnTick()
  {

   
  }


void OnTrade()
  {

   
  }


void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {

   
  }

