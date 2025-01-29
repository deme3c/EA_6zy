#ifndef __ESTRATEGIAMANAGER6ZY_MQH__
#define __ESTRATEGIAMANAGER6ZY_MQH__

#include "Configuracion6ZY.mqh"
#include "TradeManager.mqh"

class C_EstrategiaManager
{
private:
   C_Configuracion*      config;
   C_TradeManager*       tradeManager;
   E_Estados6ZY         state;
   ulong                dealIds[28];

public: 
   C_EstrategiaManager(C_Configuracion *_config, C_TradeManager *_tradeMan)
   {
      config = _config;            
      tradeManager = _tradeMan;
      state = ESTADO_ESPERANDO_PRIMERA_OP;
      ArrayInitialize(dealIds, 0); 
   }    
   
   void Inicializar()
   {
      if(!config.ValidarParametros())
      {
         Print("Parametros no validos");
         return;
      }
      
      config.CalcularNiveles();

   }
   
   void ColocarPrimeraOperacion()
   {
      if(state != ESTADO_ESPERANDO_PRIMERA_OP)
      {
         Print("No se puede colocar la primera operación. Estado actual: ", state);
         return;
      }
  
      double precioActualBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double precioActualAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      if(config.GetIsBuy())
      {
         double m_phi0 =config.GetPhi(0);
         double sl = config.GetSlBuy();
         double tp = config.GetPhi(6);
         
         double loteInicial = config.CalcularLoteSimple(config.GetCosteFigura(), m_phi0, sl);
         
         if(phi0 < precioActualAsk)
         {
            if(tradeManager.OpenBuyLimit(loteInicial, phi0, sl, tp, "Primer ninja a la carrera"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden BuyLimit colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else if(phi0 > precioActualAsk)
         {
            if(tradeManager.OpenBuyStop(loteInicial, m_phi0, sl, tp, "Primer ninja a la carrera"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden BuyStop colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else
         {
            if(tradeManager.OpenBuy(loteInicial, sl, tp, "Primer ninja a la carrera phi0 -> phi6"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden Buy a mercado colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
      }
      
      else
      {
         double m_phi6 = config.GetPhi(6);
         double sl   = config.GetSlSell();
         double tp   = config.GetPhi(0);
         
         double loteInicial = config.CalcularLoteSimple(config.GetCosteFigura(), m_phi6, sl);
         
         
         if(phi6 < precioActualBid)
         {
            if(tradeManager.OpenSellStop(loteInicial, m_phi6, sl, tp, "Primer ninja a la carrera phi6 -> phi0"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden SellStop colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else if(phi6 > precioActualBid)
         {
            if(tradeManager.OpenSellLimit(loteInicial, m_phi6, sl, tp, "Primer ninja a la carrera phi6 -> phi0"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden SellLimit colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else
         {
            if(tradeManager.OpenSell(loteInicial, sl, tp, "Primer ninja a la carrera phi6 -> phi0"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden Sell a mercado colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
      } 
   }
   
   void ComprobarEstadoPrimeraOperacion()
   {
      if(state != ESTADO_PRIMERA_OP_EN_CURSO) return;
   
      ulong ticket = dealIds[0];
      bool posicionCerrada = true;
      
      ulong posicionID = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      
      if(PositionSelectByTicket(posicionID)) posicionCerrada = false;
      
      if(posicionCerrada)
      {
         HistorySelectByPosition(posicionID);
         
         for(int i=HistoryDealsTotal() - 1; i>=0; i--){
            ulong dealTicket = HistoryDealGetTicket(i);
            
            if(HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID) == posicionID &&
               HistoryDealGetInteger(dealTicket, DEAL_ENTRY) == DEAL_ENTRY_OUT) 
            {
               ENUM_DEAL_REASON motivo = (ENUM_DEAL_REASON)HistoryDealGetInteger(dealTicket, DEAL_REASON);
               
               if(motivo == DEAL_REASON_TP)
               {
                  state = ESTADO_PRIMERA_OP_CERRADA;
                  Print("Ninja cerrado por TP");
                  break;
               }
               else if(motivo == DEAL_REASON_SL)
               {
                  state = ESTADO_TERMINADA;
                  Print("Ninja eliminado, fin de la figura");
                  break;
               }      
                  
            }
         }
         
      }      
      
      
   }
   
   
   
   E_Estados6ZY GetState() const { return state; }
   
   
   void SetDealId(int index, ulong dealId)
   {
      if (index >= 0 && index < 28) dealIds[index] = dealId;
   }
   
   ulong GetDealId(int index) const
   {
      if (index >= 0 && index < 28) return dealIds[index];
      return 0; 
   }
   
   
};


#endif 