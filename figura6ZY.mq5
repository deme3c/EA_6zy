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

C_Configuracion      config(phi0, phi6, isBuy, costeFigura);
C_TradeManager       tradeManager;
C_EstrategiaManager  estrategia(&config, &tradeManager);


int OnInit()
{

   estrategia.Inicializar();
   estrategia.ColocarPrimeraOperacion();
   
   return(INIT_SUCCEEDED);
}


void OnTick()
{
   estrategia.ComprobarEstadoPrimeraOperacion();
   
   switch(estrategia.GetState())
   {
      case ESTADO_ESPERANDO_PRIMERA_OP:
         
         break;
      
      case ESTADO_PRIMERA_OP_EN_CURSO:
         
         break;
      
      case ESTADO_PRIMERA_OP_CERRADA:
      
         break;
         
      case ESTADO_SEGUNDO_TRAMO_EN_CURSO:
      
         break;
         
      case ESTADO_TERMINADA:
      
         break;
                  
   }  
   
}

void OnDeinit(const int reason)
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

