#ifndef __TRADEMANAGER_MQH__
#define __TRADEMANAGER_MQH__

#include <Trade/Trade.mqh>

class C_TradeManager
{
private:
   CTrade trade;

public:
   C_TradeManager() {}
   
   bool OpenBuy(double lote, double sl, double tp, string comentario)
   {
      bool ok = trade.Buy(lote, _Symbol, 0.0, sl, tp, comentario);
      if(!ok) Print("Error al abrir buy a mercado (",comentario, " ):", GetLastError());
      return ok;  
   }
   
   bool OpenBuyLimit(double lote,double px, double sl, double tp, string comentario)
   {
      bool ok = trade.BuyLimit(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir buyLimit (",comentario, "): ", GetLastError());
      return ok;
   }
   
   bool OpenBuyStop(double lote, double px, double sl, double tp, string comentario)
   {
      bool ok = trade.BuyStop(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir buyStop (", comentario, "): ", GetLastError());
      return ok;
   }

   bool OpenSell(double lote, double sl, double tp, string comentario)
   {
      bool ok = trade.Sell(lote, _Symbol, 0.0, sl, tp, comentario);
      if(!ok) Print("Error al abrir sell a mercado (", comentario, "): ", GetLastError());
      return ok;
   }

   bool OpenSellLimit(double lote, double px, double sl, double tp, string comentario)
   {
      bool ok = trade.SellLimit(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir sellLimit (", comentario, "): ", GetLastError());
      return ok;
   }

   bool OpenSellStop(double lote, double px, double sl, double tp, string comentario)
   {
      bool ok = trade.SellStop(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir sellStop (", comentario, "): ", GetLastError());
      return ok;
   }
   
   // Devuelve el dealId de la ultima operacion ejecutada
   ulong GetResultDeal()
   {
      return trade.ResultDeal();
   }

};

#endif 