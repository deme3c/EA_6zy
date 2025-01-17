//+------------------------------------------------------------------+
//|                                                  figura6ZY.mq5   |
//|                                   David Martín Terrones (deme3c) |
//|                                        https://github.com/deme3c |
//+------------------------------------------------------------------+
#property copyright "David Martín Terrones (deme3c)"
#property link "https://github.com/deme3c"
#property version "1.00"

#include <Trade\Trade.mqh>
#include "Config.mqh"


CTrade trade; 



input double phi6 = 1.05850;
input double phi0 = 1.03450;
input bool compra = true;
input double costeFigura = 10; // En euros

double u = 0.0;
double fibLevels[7] = {0, 23.6, 38.2, 50, 61.8, 76.4, 100};
double phi[7] = {0,0,0,0,0,0,0};
double slbuy = 0.0, slsell = 0.0;

double loteInicial = 0.1;
double loteDos = 0.1;


double precioActual = 1.0007;

bool haTocadoSL = false;
bool haTocadoTp = false;

ulong primerNinja = 0;
ulong seisUno = 0;
ulong seisDos = 0;
ulong seisTres = 0;
ulong seisCuatro = 0;
ulong seisCinco = 0;
ulong seisSeis = 0;

double precioBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double precioAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
double spread = precioAsk - precioBid; 

int OnInit()
{
   if (phi6 <= phi0)
   {
      Print("Error: phi6 debe ser mayor que phi0");
      return INIT_FAILED;
   }

   //ArrayResize(phi, ArraySize(fibLevels));
   calcularNiveles();
   precioActual = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
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
      long motivoCierre;

      if (HistoryDealSelect(primerNinja))
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
            ninjasSeisGrupos();
            
         }
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
   //loteInicial = (costeFigura / 21.0) / u;

   Print("Niveles calculados");
}

void colocarPrimeraOrden()
{ 
   datetime expiracion = 0;
   if (compra)
   {
      if(phi0<precioActual)
      {
         if (trade.BuyLimit(loteInicial, phi0, _Symbol, slbuy, phi6, ORDER_TIME_GTC,expiracion)) 
         {
            primerNinja = trade.ResultDeal();
            Print("Orden de compra phi0 -> phi6 ejecutada");
         }
         else
         {
            Print("Error al colocar la orden de compra: ", GetLastError());
         }
      }
      else if(phi0>precioActual)
      {
         if (trade.BuyStop(loteInicial,phi0, _Symbol, slbuy, phi6,ORDER_TIME_GTC, expiracion)) 
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
         if (trade.BuyLimit(loteInicial, phi0, _Symbol, slbuy, phi6,ORDER_TIME_GTC ,expiracion)) 
         {
            primerNinja = trade.ResultDeal();
            Print("Orden de compra phi0 -> phi6 ejecutada");
         }
         else
         {
            Print("Error al colocar la orden de compra: ", GetLastError());
         }
      }
   } //if compra
   else
   {
      if(phi6<precioActual)
      {
         if (trade.SellStop(loteInicial,phi6, _Symbol,slsell, phi0, ORDER_TIME_SPECIFIED)) 
         {
            primerNinja = trade.ResultDeal();
            Print("Orden de venta phi6 -> phi0 ejecutada");
         }
         else
         {
            Print("Error al colocar la orden de venta: ", GetLastError());
         }
      }
      else if(phi6>precioActual)
      {
         if (trade.SellLimit(loteInicial, _Symbol, phi6, slsell, phi0)) 
         {
            primerNinja = trade.ResultDeal();
            Print("Orden de venta phi6 -> phi0 ejecutada");
         }
         else
         {
            Print("Error al colocar la orden de venta: ", GetLastError());
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
   } //else (venta)
}

void obtenerDatosSimbolo()
{
   precioBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   precioAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   spread = precioAsk - precioBid; 

}


void ninjasSeisGruposBucleada()
{
   if (loteInicial <= 0)
   {
      Print("Error: El lote inicial no puede ser menor o igual a cero.");
      return;
   }

   loteDos = loteInicial * 6;

   ulong operaciones[6]; 
   double preciosTp[6];    /

   if (!compra)
   {
      for (int i = 0; i < 6; i++)
      {
         precios[i] = phi[5 - i]; 
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

         if (trade.Sell(loteDos, _Symbol, bid, slsell, precios[i]))
         {
            operaciones[i] = trade.ResultDeal();
            Print("Operación ", i + 1, " ejecutada con éxito. Deal ID: ", operaciones[i]);
         }
         else
         {
            Print("Error en la operación ", i + 1, ". Código de error: ", GetLastError());
         }
      }
   }
   else
   {
      for (int i = 0; i < 6; i++)
      {
         precios[i] = phi[i]; 
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

         if (trade.Buy(loteDos, _Symbol, ask, slbuy, precios[i]))
         {
            operaciones[i] = trade.ResultDeal();
            Print("Operación ", i + 1, " ejecutada con éxito. Deal ID: ", operaciones[i]);
         }
         else
         {
            Print("Error en la operación ", i + 1, ". Código de error: ", GetLastError());
         }
      }
   }
}


