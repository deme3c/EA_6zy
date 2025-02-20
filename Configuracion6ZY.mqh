#ifndef __CONFIGURACION6ZY_MQH__
#define __CONFIGURACION6ZY_MQH__

/**
 * @enum E_Estados6ZY
 * @brief Enumeración de estados de la estrategia de trading
 * @details Define los diferentes estados por los que puede pasar la estrategia durante su ejecución
 */
enum E_Estados6ZY
{
   ESTADO_ESPERANDO_PRIMERA_OP = 0,   ///< Estado inicial esperando colocación de primera operación
   ESTADO_PRIMERA_OP_EN_CURSO,        ///< Primera operación activa o pendiente de ejecución
   ESTADO_PRIMERA_OP_CERRADA,         ///< Primera operación cerrada (take profit o stoploss)
   ESTADO_SEGUNDO_TRAMO_EN_CURSO,     ///< Operaciones segundo tramo en curso
   ESTADO_TERMINADA                   ///< Estrategia finalizada (éxito o fracaso)                
};

/**
 * @class C_Configuracion
 * @brief Gestor de configuración y cálculos estratégicos
 * @details Calcula niveles Fibonacci, gestiona parámetros de riesgo y determina tamaños de posición
 */
class C_Configuracion
{

private:

   double phi0;
   double phi6;
   bool isBuy;
   double costeFigura;
   
   double phi[7];
   double u;
   double slBuy;
   double slSell;
   
   double loteInicial;
   double loteInicialIndv;


public:
    /**
     * @brief Constructor principal de la configuración
     * @param _phi0 Nivel phi0
     * @param _phi6 Nivel phi6
     * @param _isBuy Dirección de la primera operación
     * @param _costeFigura Riesgo máximo por figura
     * @note Inicializa valores y calcula lotes iniciales automáticamente
     */
   C_Configuracion(double _phi0, double _phi6, bool _isBuy, double _costeFigura)
   {
      phi0 = _phi0;
      phi6 = _phi6;
      isBuy = _isBuy;
      costeFigura = _costeFigura;
      
      for(int i = 0; i < 7; i++)
      {
         phi[i] = 0.0;
      }
         
      u      = 0.0;
      slBuy  = 0.0;
      slSell = 0.0;
      
      loteInicial = CalcularLoteSimple(costeFigura, phi0, slBuy);
      loteInicialIndv = loteInicial / 21;
   }   
   
   /**
    * @brief Valida los parámetros de entrada de la estrategia
    * @return true si los parámetros son válidos, false en caso contrario
    * @details Verifica:
    *          - Relación correcta entre phi0 y phi6 según dirección
    *          - Coste por figura positivo
    */
   bool ValidarParametros()
   {
      if(isBuy && phi6 <= phi0)
      {
         Print("Error: phi6 (", phi6, ") debe ser mayor que phi0 (", phi0, ") cuando isBuy es true.");
         return false;
      }
      if(!isBuy && phi6 >= phi0)
      {
         Print("Error: phi6 (", phi6, ") debe ser menor que phi0 (", phi0, ") cuando isBuy es false.");
         return false;
      }
      if(costeFigura <= 0)
      {
         Print("Error: costeFigura (", costeFigura, ") debe ser mayor que 0.");
         return false;
      }
      Print("Parámetros válidos: phi0 = ", phi0, ", phi6 = ", phi6, ", isBuy = ", isBuy, ", costeFigura = ", costeFigura);
      return true;
   }
   
   /**
    * @brief Calcula niveles Fibonacci y parámetros derivados
    * @details Calcula:
    *          - 7 niveles Fibonacci entre phi0 y phi6
    *          - Distancia de u
    *          - Niveles de stop loss iniciales, para phi0 y phi6
    */
   void CalcularNiveles()
   {
      double fibLevels[7] = {0.0, 23.6, 38.2, 50.0, 61.8, 76.4, 100.0};
      for(int i = 0; i < 7; i++)
      {
         phi[i] = phi0 - (phi0 - phi6) / 100.0 * fibLevels[i];
      }

      u = (phi6 - phi0) / 6.0;
      slBuy = phi0 - u;
      slSell = phi6 + u;
   }
   
   // Métodos de acceso básicos
   bool   GetIsBuy()        const { return isBuy;       }
   double GetPhi(int index) const { return phi[index];  }
   double GetSlBuy()        const { return slBuy;       }
   double GetSlSell()       const { return slSell;      }
   double GetCosteFigura()  const { return costeFigura; }
   
   /**
    * @brief Calcula el valor monetario de un pip
    * @return Valor por pip en divisa de la cuenta
    * @details Considera:
    *          - Símbolo actual y divisas de cuenta/cotización
    *          - Conversión entre divisas si es necesario
    */
   double ObtenerValorPorPip()
   {
      // 1. Obtener valores clave
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      string quoteCurrency = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
      string accountCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   
      // 2. Validación
      if(tickValue == 0 || tickSize == 0) 
      {
         Alert("Error: TickValue/TickSize no válidos");
         return 0.0;
      }
   
      // 3. Calcular pip según el símbolo
      double pip = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 3 || 
                   SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 2) ? 0.01 : 0.0001;
   
      // 4. Valor por pip en divisa de cotización
      double valorPorPip = (tickValue / tickSize) * pip;
   
      // 5. Conversión a divisa de la cuenta (si es necesario)
      if(quoteCurrency != accountCurrency)
      {
         string conversionSymbol = quoteCurrency + accountCurrency;
         double conversionRate = SymbolInfoDouble(conversionSymbol, SYMBOL_BID);
         
         if(conversionRate == 0) 
         {
            // Intentar par inverso
            conversionSymbol = accountCurrency + quoteCurrency;
            conversionRate = SymbolInfoDouble(conversionSymbol, SYMBOL_BID);
            if(conversionRate != 0) valorPorPip /= conversionRate;
            else Print("Error de conversión para ", conversionSymbol);
         }
         else 
         {
            valorPorPip *= conversionRate;
         }
      }
   
      return valorPorPip;
   }
 
   /**
    * @brief Calcula tamaño de lote basado en riesgo
    * @param costeFigura Pérdida máxima aceptable
    * @param precioEntrada Precio de entrada de la operación
    * @param stopLoss Nivel de stop loss
    * @return Tamaño de lote calculado normalizado
    * @note Considera:
    *       - Distancia en pips
    *       - Valor por pip actual
    *       - Lote mínimo del símbolo
    */  
   double CalcularLoteSimple(double costeFigura, double precioEntrada, double stopLoss)
   {
      // 1. Validación
      if(costeFigura <= 0 || precioEntrada == stopLoss) return 0.0;
   
      // 2. Calcular distancia en pips
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double distanciaPips = MathAbs(precioEntrada - stopLoss) / point * 0.1;
   
      // 3. Obtener valor por pip
      double valorPorPip = ObtenerValorPorPip();
      if(valorPorPip <= 0) return 0.0;
   
      // 4. Cálculo del lote
      double lote = costeFigura / (distanciaPips * valorPorPip);
   
      // 5. Ajustar al tamaño mínimo del lote
      double minLote = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      lote = MathMax(lote, minLote);
   
      // 6. Debug detallado
      Print(StringFormat(
         "[CÁLCULO] Entrada: %.5f | SL: %.5f | Pips: %.1f | Valor/Pip: %.2f %s | Lote: %.2f",
         precioEntrada, 
         stopLoss, 
         distanciaPips, 
         valorPorPip,
         AccountInfoString(ACCOUNT_CURRENCY),
         lote
      ));
   
      return NormalizeDouble(lote, 2);
   }
   
   
   
   
 ///// seguramente descartado
   double CalcularLoteAgrupado(double perdidaPorOperacion, int numeroOperaciones, double precioEntrada, double stopLoss)
   {
    double perdidaTotal = perdidaPorOperacion * numeroOperaciones; 
    double valorPorPip = ObtenerValorPorPip();
    if (valorPorPip <= 0) return 0.0;

    double distanciaSL = MathAbs(precioEntrada - stopLoss) / SymbolInfoDouble(_Symbol, SYMBOL_POINT); 
    return perdidaTotal / (distanciaSL * valorPorPip);
   }
   

};



#endif 