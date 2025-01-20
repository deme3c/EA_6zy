#ifndef __ESTRATEGIAMANAGER6ZY_MQH__
#define __ESTRATEGIAMANAGER6ZY_MQH__

#include "Configuracion6ZY.mqh"
#include "TradeManager.mqh"

class C_EstrategiaManager
{
private:
   C_Configuracion     *m_config;
   C_TradeManager      *m_tradeManager;
   S_NivelesPhi         m_niveles;
   E_Estados6ZY         m_state;
   ulong                m_dealIds[28];

public: 
   C_EstrategiaManager(C_Configuracion6ZY &config, C_TradeManager &tradeMan)
   {
      m_config = &config;
      m_tradeManager = &tradeMan;
      m_state = ESTADO_ESPERANDO_PRIMERA_OP;
      ZeroMemory(m_dealIds); 
   }    
   
   void Inicializar()
   {
      m_config.CalcularNiveles(m_config->isBuy, m_config->phi0, m_config->phi6);
      m_niveles = m_config.Niveles();
   }
   
   
   
   
   
   
   
   
   
   void SetDealId(int index, ulong dealId)
   {
      if (index >= 0 && index < 28) m_dealIds[index] = dealId;
   }
   ulong GetDealId(int index) const
   {
      if (index >= 0 && index < 28) return m_dealIds[index];
      return 0; // por si el indice es invalido (no deberia)
   }
   
   
};

#endif 