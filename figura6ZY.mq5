#property copyright "David Martín Terrones (deme3c)"
#property link "https://github.com/deme3c"
#property version "1.00"

#include <Trade\Trade.mqh>


CTrade trade; 

input double phi6 = 10;
input double phi0 = 0;
input bool compra = true;
input double costeFigura = 10; // En euros

double u = 0.0;
double fibLevels[7] = {0, 23.6, 38.2, 50, 61.8, 76.4, 100};
double phi[];
double slbuy = 0.0, slsell = 0.0;
double loteInicial = 0.1;
double precioActual = 1.0007;

bool haTocadoSL = false;
bool haTocadoTp = false;

ulong primerNinja = 0;

int OnInit()
{
   if (phi6 <= phi0)
   {
      Print("Error: phi6 debe ser mayor que phi0");
      return INIT_FAILED;
   }

   ArrayResize(phi, ArraySize(fibLevels));
   calcularNiveles();
   colocarPrimeraOrden();

   if (compra)
   {
      Print("Figura compra colocada en ", phi0);
   }
   else
   {
      Print("Figura venta colocada en ", phi6);
   }

   return INIT_SUCCEEDED;
}

void OnTick()
{
   precioActual = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  
}

void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
   if (trans.type == TRADE_TRANSACTION_DEAL_ADD && trans.deal == primerNinja) 
   {
      double cierrePrecio;
      int motivoCierre;

      if (HistoryDealSelect(ticket))
      {
         motivoCierre = HistoryDealGetInteger(primerNinja, DEAL_REASON);
         cierrePrecio = HistoryDealGetDouble(primerNinja, DEAL_PRICE);

         if (motivoCierre == DEAL_REASON_SL) 
         {
            haTocadoSL = true;
            Print("Figura perdida -21PHI ;)", cierrePrecio);
         }
         else if (motivoCierre == DEAL_REASON_TP) 
         {
            haTocadoTp = true;
            
            // PROGRAMAR LAS 21 OPS RESTANTES 
         }
      }
}

void OnDeinit(const int reason)
{
   Print("EA finalizado");
}



//******************************************************             ****************************************************************



void calcularNiveles()
{
   for (int i = 0; i < ArraySize(fibLevels); i++)
   {
      phi[i] = phi0 - (phi0 - phi6) / 100.0 * fibLevels[i];
   }
   u = (phi6 - phi0) / 6.0;
   slbuy = phi0 - u;
   slsell = phi6 + u;
   loteInicial = (costeFigura / 21.0) / u;

   Print("Niveles calculados");
}

void colocarPrimeraOrden()
{
   
   if (compra)
   {
      if (trade.Buy(loteInicial, _Symbol, phi0, slbuy, phi6)) 
      {
         primerNinja = trade.ResultDeal();
         Print("Orden de compra phi0 -> phi6 ejecutada");
      }
      else
      {
         Print("Error al colocar la orden de compra: ", GetLastError());
      }
   }
   else
   {
      if (trade.Sell(loteInicial, _Symbol, phi6, slsell, phi0)) 
      {
         primerNinja = trade.ResultDeal();
         Print("Orden de venta phi6 -> phi0 ejecutada");
      }
      else
      {
         Print("Error al colocar la orden de venta: ", GetLastError());
      }
   }
}

void obtenerDatosSimbolo()
{
   double precioBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double precioAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double spread = precioAsk - precioBid; 

   PrintFormat("Bid: %.5f, Ask: %.5f, Spread: %.5f", precioBid, precioAsk, spread);
}


   
