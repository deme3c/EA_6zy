
input double phi6 = 10;
input double phi0 = 0;
input bool compra = true;
input double costeFigura = 10; // En euros
double u = 0.0;
double fibLevels[7] = {0, 23.6, 38.2, 50, 61.8, 76.4, 100};
double phi[]; 
double slbuy = 0.0, slsell = 0.0;
double loteInicial = 0.0;

int OnInit()
{
   if (phi6 <= phi0) {
      Print("Error: phi6 debe ser mayor que phi0");
      return INIT_FAILED;
   }

   ArrayResize(phi, ArraySize(fibLevels));
   calcularNiveles();

   Print("EA iniciado");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   static bool printed = false;
   if (!printed)
   {
      PrintFormat("SL Buy: %.2f, SL Sell: %.2f, Lote Inicial: %.2f", slbuy, slsell, loteInicial);
      Print("SL Buy: %.2f, SL Sell: %.2f, Lote Inicial: %.2f", slbuy, slsell, loteInicial);
      printed = true;
   }
}

void OnDeinit(const int reason)
{
   Print("EA finalizado");
}

void calcularNiveles()
{
   for (int i = 0; i < ArraySize(fibLevels); i++)
   {
      phi[i] = phi0 - (phi0 - phi6) / 100.0 * fibLevels[i];
   }
   u = (phi6 - phi0) / 6.0;
   slbuy = phi0 - u;
   slsell = phi6 + u;
   loteInicial = (costeFigura / 21.0) / u;

   Print("Niveles calculados");
}