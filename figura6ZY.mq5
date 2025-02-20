//+------------------------------------------------------------------+
//|                                                  figura6ZY.mq5   |
//|                                   David Martín Terrones (deme3c) |
//|                                        https://github.com/deme3c |
//+------------------------------------------------------------------+
/**
 * @file figura6ZY.mq5
 * @brief Expert Advisor implementando estrategia de trading basada en figura 6ZY
 */
#include "Configuracion6ZY.mqh"
#include "TradeManager.mqh"
#include "EstrategiaManager6ZY.mqh"

// Parámetros de entrada del EA
input double phi0 = 0.0;
input double phi6 = 0.0;
input bool   isBuy = true;  
input double costeFigura = 10.0; 

// Instancias globales de los componentes principales
C_Configuracion      config(phi0, phi6, isBuy, costeFigura);  ///< Gestor de configuración y cálculos estratégicos
C_TradeManager       tradeManager;                            ///< Manejador de ejecución de órdenes
C_EstrategiaManager  estrategia(&config, &tradeManager);      ///< Controlador principal de la estrategia


/**
 * @brief Función de inicialización del Expert Advisor
 * @return INIT_SUCCEEDED si la inicialización es exitosa
 * @details Configura los componentes principales y coloca la primera operación
 */
int OnInit()
{

   estrategia.Inicializar();
   estrategia.ColocarPrimeraOperacion();
   
   return(INIT_SUCCEEDED);
}

/**
 * @brief Función principal ejecutada en cada tick de precio
 * @details Monitorea el estado de la estrategia y gestiona las transiciones entre estados
 */
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
         //meter Segundo tramo
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

