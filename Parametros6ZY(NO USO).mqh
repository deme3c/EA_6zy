#ifndef __PARAMETROS6ZY_MQH__
#define __PARAMETROS6ZY_MQH__


enum E_Estados6ZY
{
   ESTADO_ESPERANDO_PRIMERA_OP = 0,   // 1a op sin colocar
   ESTADO_PRIMERA_OP_EN_CURSO,       // La 1a op abierta/pendiente
   ESTADO_PRIMERA_OP_CERRADA,        // 1a op ganada o perdida, colocar 21 ops si ha ganado
   ESTADO_SEGUNDO_TRAMO_EN_CURSO,    // 6 grupos (21 ops) en funcionamiento
   ESTADO_TERMINADA                  // Fin
};
 

class C_Configuracion6ZY
{

private:
   double m_phi0;
   double m_phi6;
   bool m_isBuy;
   double m_costeFigura;
   
public:
   
   C_Configuracion6ZY(double phi0, double phi6, bool isBuy, double costeFigura)
   {
      m_phi0 = phi0;
      m_phi6 = phi6;
      m_isBuy = isBuy;
      m_costeFigura = costeFigura;
    }

   bool ValidarParametros()
   {
      if(m_isBuy && m_phi6 <= m_phi0)
      {
         Print("Error: phi6 (", m_phi6, ") debe ser mayor que phi0 (", m_phi0, ") cuando isBuy es true.");
         return false;
      } 
      if(!m_isBuy && phi6 >= phi0)
      {
         Print("Error: phi6 (", m_phi6, ") debe ser menor que phi0 (", m_phi0, ") cuando isBuy es false.");
         return false;
      }
      if(costeFigura <= 0)
      {
         Print("Error: costeFigura (", m_costeFigura, ") debe ser mayor que 0.");
         return false;
      }
      Print("Parámetros válidos: phi0 = ", m_phi0, ", phi6 = ", m_phi6, ", isBuy = ", m_isBuy, ", costeFigura = ", m_costeFigura);
      return true;
   }
};   
   
 #endif