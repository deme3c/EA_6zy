#ifndef __CONFIGURACION6ZY_MQH__
#define __CONFIGURACION6ZY_MQH__

enum E_Estados6ZY
{
   ESTADO_ESPERANDO_PRIMERA_OP = 0,   // 1a op sin colocar
   ESTADO_PRIMERA_OP_EN_CURSO,       // La 1a op abierta/pendiente
   ESTADO_PRIMERA_OP_CERRADA,        // 1a op ganada o perdida, colocar 21 ops si ha ganado
   ESTADO_SEGUNDO_TRAMO_EN_CURSO,    // 6 grupos (21 ops) en funcionamiento
   ESTADO_TERMINADA                  // Fin
};

struct S_NivelesPhi
{
   double phi[7];
   double u;
   double slBuy, slSell;
};

class C_Configuracion
{

private:

   double m_phi0;
   double m_phi6;
   bool m_isBuy;
   double m_costeFigura;
   
   S_NivelesPhi m_niveles;


public:
    
   C_Configuracion(double phi0, double phi6, bool isBuy, double costeFigura)
   {
      m_phi0 = phi0;
      m_phi6 = phi6;
      m_isBuy = isBuy;
      m_costeFigura = costeFigura;
      ZeroMemory(m_niveles);  
   }   
   
   bool ValidarParametros()
   {
      if(m_isBuy && m_phi6 <= m_phi0)
      {
         Print("Error: phi6 (", m_phi6, ") debe ser mayor que phi0 (", m_phi0, ") cuando isBuy es true.");
         return false;
      }
      if(!m_isBuy && m_phi6 >= m_phi0)
      {
         Print("Error: phi6 (", m_phi6, ") debe ser menor que phi0 (", m_phi0, ") cuando isBuy es false.");
         return false;
      }
      if(m_costeFigura <= 0)
      {
         Print("Error: costeFigura (", m_costeFigura, ") debe ser mayor que 0.");
         return false;
      }
      Print("Parámetros válidos: phi0 = ", m_phi0, ", phi6 = ", m_phi6, ", isBuy = ", m_isBuy, ", costeFigura = ", m_costeFigura);
      return true;
   }
   
   void CalcularNiveles()
   {
      double fibLevels[7] = {0.0, 23.6, 38.2, 50.0, 61.8, 76.4, 100.0};
      for(int i = 0; i < 7; i++)
      {
         m_niveles.phi[i] = m_phi0 - (m_phi0 - m_phi6) / 100.0 * fibLevels[i];
      }

      m_niveles.u = (m_phi6 - m_phi0) / 6.0;
      m_niveles.slBuy = m_phi0 - m_niveles.u;
      m_niveles.slSell = m_phi6 + m_niveles.u;
   }
   
   double ObtenerValorPorPip()
   {
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if (tickValue == 0 || tickSize == 0)
      {
        Print("Error: No se pudo obtener el valor por pip del instrumento.");
        return 0.0;
      }
    return tickValue / tickSize;
   }
   
   double CalcularLoteSimple(double perdidaDeseada, double precioEntrada, double stopLoss)
   {
      double valorPorPip = ObtenerValorPorPip();
      if (valorPorPip <= 0) return 0.0;

      double distanciaSL = MathAbs(precioEntrada - stopLoss) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      return perdidaDeseada / (distanciaSL * valorPorPip);
   }
   
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