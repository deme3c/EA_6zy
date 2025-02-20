#ifndef __TRADEMANAGER_MQH__
#define __TRADEMANAGER_MQH__

#include <Trade/Trade.mqh>

/**
 * @class C_TradeManager
 * @brief Gestor de operaciones de trading con lógica de ejecución y manejo de errores
 * @details Wrapper de CTrade con funcionalidad extendida para:
 *          - Ejecución de diferentes tipos de órdenes
 *          - Registro detallado de errores
 *          - Seguimiento de resultados de operaciones
 */
class C_TradeManager
{
private:
   CTrade trade; ///< Instancia interna del objeto CTrade de MQL5

public:
   /**
    * @brief Constructor básico del gestor de operaciones
    * @note Inicializa el objeto CTrade interno
    */
   C_TradeManager() {}

   /**
    * @brief Ejecuta orden de compra a mercado
    * @param lote Tamaño de la posición en lotes
    * @param sl Nivel de stop loss (0 para desactivar)
    * @param tp Nivel de take profit (0 para desactivar)
    * @param comentario Comentario para la operación
    * @return true si la orden se envió correctamente
    * @note Precio de entrada determinado automáticamente por el mercado
    */
   bool OpenBuy(double lote, double sl, double tp, string comentario)
   {
      bool ok = trade.Buy(lote, _Symbol, 0.0, sl, tp, comentario);
      if(!ok) Print("Error al abrir buy a mercado (",comentario, " ):", GetLastError());
      return ok;  
   }

   /**
    * @brief Coloca orden limitada de compra
    * @param lote Tamaño de la posición en lotes
    * @param px Precio de activación de la orden
    * @param sl Nivel de stop loss
    * @param tp Nivel de take profit
    * @param comentario Comentario identificativo
    * @return true si la orden se colocó correctamente
    * @note Orden válida hasta cancelación (GTC)
    */   
   bool OpenBuyLimit(double lote,double px, double sl, double tp, string comentario)
   {
      bool ok = trade.BuyLimit(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir buyLimit (",comentario, "): ", GetLastError());
      return ok;
   }
   /**
    * @brief Coloca orden stop de compra
    * @param lote Tamaño de la posición en lotes
    * @param px Precio de activación de la orden
    * @param sl Stop loss después de la ejecución
    * @param tp Take profit después de la ejecución
    * @param comentario Comentario descriptivo
    * @return true si la orden se registró exitosamente
    * @warning El precio debe estar por encima del actual para compras
    */   
   bool OpenBuyStop(double lote, double px, double sl, double tp, string comentario)
   {
      bool ok = trade.BuyStop(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir buyStop (", comentario, "): ", GetLastError());
      return ok;
   }
   /**
    * @brief Ejecuta orden de venta a mercado
    * @param lote Cantidad en lotes a operar
    * @param sl Nivel de stop loss inicial
    * @param tp Nivel de take profit inicial
    * @param comentario Texto identificativo de la operación
    * @return true si la ejecución fue exitosa
    * @note Precio determinado por el mejor ask disponible
    */
   bool OpenSell(double lote, double sl, double tp, string comentario)
   {
      bool ok = trade.Sell(lote, _Symbol, 0.0, sl, tp, comentario);
      if(!ok) Print("Error al abrir sell a mercado (", comentario, "): ", GetLastError());
      return ok;
   }
   /**
    * @brief Coloca orden limitada de venta
    * @param lote Tamaño de la posición
    * @param px Precio objetivo de ejecución
    * @param sl Stop loss configurado
    * @param tp Take profit configurado
    * @param comentario Comentario para seguimiento
    * @return true si la orden se colocó en el servidor
    * @note Orden válida hasta su cancelación explícita
    */
   bool OpenSellLimit(double lote, double px, double sl, double tp, string comentario)
   {
      bool ok = trade.SellLimit(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir sellLimit (", comentario, "): ", GetLastError());
      return ok;
   }
   /**
    * @brief Coloca orden stop de venta
    * @param lote Cantidad en lotes
    * @param px Precio de activación
    * @param sl Nivel de stop loss post-ejecución
    * @param tp Nivel de take profit post-ejecución
    * @param comentario Identificador de operación
    * @return true si la orden se aceptó correctamente
    * @warning El precio debe estar por debajo del actual para ventas
    */
   bool OpenSellStop(double lote, double px, double sl, double tp, string comentario)
   {
      bool ok = trade.SellStop(lote, px, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comentario);
      if(!ok) Print("Error al abrir sellStop (", comentario, "): ", GetLastError());
      return ok;
   }
   
   /**
    * @brief Obtiene el identificador de la última operación ejecutada
    * @return Deal ID de la última operación exitosa
    * @note Devuelve 0 si no hay operaciones recientes
    */
   ulong GetResultDeal()
   {
      return trade.ResultDeal();
   }

};

#endif 