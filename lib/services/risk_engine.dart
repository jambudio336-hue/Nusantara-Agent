class RiskEngine {
  static Map<String,double> positionSize({
    required double balance, required double riskPercent,
    required double entry, required double stop, required double takeProfit,
    required double pipValuePerLot, double lotStep=0.01, double minLot=0.01,
  }) {
    final risk = balance * riskPercent / 100;
    final distance = (entry-stop).abs();
    final pips = distance <= 0 ? 0 : distance / 0.0001;
    final raw = pips <= 0 || pipValuePerLot <= 0 ? 0 : risk / (pips * pipValuePerLot);
    final lot = raw <= 0 ? 0 : (raw / lotStep).floor() * lotStep;
    final rr = distance <= 0 ? 0 : (takeProfit-entry).abs()/distance;
    return {'riskAmount':risk,'stopDistance':distance,'pips':pips,'rawLot':raw,'lot':lot<minLot&&lot>0?minLot:lot,'rr':rr};
  }
  static Map<String,dynamic> guardian({required double balance, required double riskPercent, required double dailyPnl, required double dailyLimitPercent, required double openRisk, required double maxOpenRisk, required double rr, required double minRr, required bool highImpactNews}) {
    final dailyOk = dailyPnl.abs() < balance*dailyLimitPercent/100;
    final openOk = openRisk <= maxOpenRisk;
    final rrOk = rr >= minRr;
    final ready = dailyOk && openOk && rrOk;
    return {'ready':ready,'dailyOk':dailyOk,'openRiskOk':openOk,'rrOk':rrOk,'newsWarning':highImpactNews};
  }
}
