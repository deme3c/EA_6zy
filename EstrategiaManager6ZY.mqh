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
   /**
    * @brief Constructor del gestor estratégico
    * @param _config Configuración inicializada
    * @param _tradeMan Manejador de operaciones
    * @note Inicializa en estado inicial y limpia array de operaciones
    */
   C_EstrategiaManager(C_Configuracion *_config, C_TradeManager *_tradeMan)
   {
      config = _config;            
      tradeManager = _tradeMan;
      state = ESTADO_ESPERANDO_PRIMERA_OP;
      ArrayInitialize(dealIds, 0); 
   }    
   
   /**
    * @brief Inicializa la estrategia
    * @details Realiza:
    *          - Validación de parámetros
    *          - Cálculo de niveles estratégicos
    * @warning Detiene inicialización si parámetros no son válidos
    */
   void Inicializar()
   {
      if(!config.ValidarParametros())
      {
         Print("Parametros no validos");
         return;
      }
      
      config.CalcularNiveles();

   }
   
   /**
    * @brief Coloca la operación inicial según configuración
    * @details Ejecuta órdenes limit/stop/market según relación entre:
    *          - Niveles phi0/phi6
    *          - Precio actual de mercado
    * @note Cambia estado a ESTADO_PRIMERA_OP_EN_CURSO si éxito
    */   
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
            if(tradeManager.OpenBuyLimit(loteInicial, phi0, sl, tp, "Primer ninja a la carrera, buylimit"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden BuyLimit colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else if(phi0 > precioActualAsk)
         {
            if(tradeManager.OpenBuyStop(loteInicial, m_phi0, sl, tp, "Primer ninja a la carrera, buystop"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden BuyStop colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else
         {
            if(tradeManager.OpenBuy(loteInicial, sl, tp, "Primer ninja a la carrera phi0 -> phi6, buy a mercado"))
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
            if(tradeManager.OpenSellStop(loteInicial, m_phi6, sl, tp, "Primer ninja a la carrera phi6 -> phi0, sellstop"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden SellStop colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else if(phi6 > precioActualBid)
         {
            if(tradeManager.OpenSellLimit(loteInicial, m_phi6, sl, tp, "Primer ninja a la carrera phi6 -> phi0, selllimit"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden SellLimit colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
         else
         {
            if(tradeManager.OpenSell(loteInicial, sl, tp, "Primer ninja a la carrera phi6 -> phi0, sell a mercado"))
            {
               dealIds[0] = tradeManager.GetResultDeal();
               Print("Orden Sell a mercado colocada correctamente. dealId=", dealIds[0]);
               state = ESTADO_PRIMERA_OP_EN_CURSO;
            }
         }
      } 
   }

   /**
    * @brief Verifica estado de la operación inicial
    * @details Detecta:
    *          - Cierre por Take Profit
    *          - Cierre por Stop Loss
    *          - Operación aún activa
    * @note Actualiza estado según resultado de la operación
    */  
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
   
   void colocarSegundoTramo()
   {
      if (state != ESTADO_PRIMERA_OP_CERRADA) 
      {
         Print("Error: Estado incorrecto para segundo tramo ", state);
         return;
      }
      
      double beneficioPrimeraOp = HistoryDealGetDouble(dealIds[0], DEAL_PROFIT) +
                                HistoryDealGetDouble(dealIds[0], DEAL_SWAP) +
                                HistoryDealGetDouble(dealIds[0], DEAL_COMMISSION);
                                
      if(beneficioPrimeraOp <= 0) 
      {
         Alert("Error: Beneficio no válido o operación perdedora ", beneficioPrimeraOp);
         return;
      }
      
      bool isBuy = config.GetIsBuy();
      double precioEntrada = isBuy ? config.GetPhi(6) : config.GetPhi(0);
    
      double PHI = beneficioPrimeraOp / 21.0;
      double precioActual = primeraOperacionCompra ? SymbolInfoDouble(simbolo, SYMBOL_BID) : SymbolInfoDouble(simbolo, SYMBOL_ASK);
      
      
      
      
      
      
      
      
      
      
      
    state = ESTADO_SEGUNDO_TRAMO_EN_CURSO;
    Print("Segundo tramo activado: 21 operaciones colocadas");
   }
   

   /**
    * @brief Obtiene estado actual de la estrategia
    * @return Estado actual del tipo E_Estados6ZY
    */
   E_Estados6ZY GetState() const { return state; }
   
   /**
    * @brief Registra ID de operación en el array
    * @param index Posición en el array (0-27)
    * @param dealId ID de la operación a registrar
    */   
   void SetDealId(int index, ulong dealId)
   {
      if (index >= 0 && index < 28) dealIds[index] = dealId;
   }
   /**
    * @brief Recupera ID de operación almacenada
    * @param index Posición en el array (0-27)
    * @return ID de operación o 0 si índice inválido
    */  
   ulong GetDealId(int index) const
   {
      if (index >= 0 && index < 28) return dealIds[index];
      return 0; 
   }
   
   
};


#endif 