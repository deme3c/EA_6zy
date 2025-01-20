#ifndef __CALCULARPHI6ZY_MQH__
#define __CALCULARPHI6ZY_MQH__

struct S_NivelesPhi
{
   double phi[7];
   double u;
   double slBuy, slSell;
};

class C_CalcularPhi
{
private:
   S_NivelesPhi m_niveles;
   const double fibLevels[7] = {0.0, 23.6, 38.2, 50.0, 61.8, 76.4, 100.0};
   
public:
   C_CalcularPhi()
   {
      ZeroMemory(m_niveles);
   }
   
   void CalcularNiveles(bool isBuy, double phi0, double phi6)
   {
      for(int i=0; i<7; i++)
      {
         m_niveles.phi[i] = phi0 - (phi0 - phi6) / 100.0 * fibLevels[i];
      }
      
      m_niveles.u = (phi6 - phi0) / 6.0;
      m_niveles.slBuy = phi0 - m_niveles.u;
      m_niveles.slSell = phi6 + m_niveles.u;
   }
   
   const S_NivelesPhi& Niveles() const
   {
      return m_niveles;
   }   
};

#endif 