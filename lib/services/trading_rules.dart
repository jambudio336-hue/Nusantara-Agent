class TradingRule {
  final double minPrice,maxPrice,tickSize,minQty,maxQty,stepSize,minNotional;
  const TradingRule({this.minPrice=0,this.maxPrice=double.infinity,this.tickSize=0,this.minQty=0,this.maxQty=double.infinity,this.stepSize=0,this.minNotional=0});
}
class RuleValidation { final bool valid; final List<String> errors; const RuleValidation(this.valid,this.errors); }
class TradingRules {
  static RuleValidation validate({required double price,required double quantity,required TradingRule rule}) {
    final e=<String>[];
    if(price<rule.minPrice)e.add('Harga di bawah minimum');
    if(price>rule.maxPrice)e.add('Harga di atas maksimum');
    if(rule.tickSize>0){final n=(price/rule.tickSize).roundToDouble();if((price-n*rule.tickSize).abs()>rule.tickSize*1e-8)e.add('Harga harus mengikuti tick size '+rule.tickSize.toString());}
    if(quantity<rule.minQty)e.add('Jumlah di bawah minimum');
    if(quantity>rule.maxQty)e.add('Jumlah melebihi maksimum');
    if(rule.stepSize>0){final n=(quantity/rule.stepSize).roundToDouble();if((quantity-n*rule.stepSize).abs()>rule.stepSize*1e-8)e.add('Jumlah harus mengikuti step size '+rule.stepSize.toString());}
    if(price*quantity<rule.minNotional)e.add('Nilai order minimum '+rule.minNotional.toString());
    return RuleValidation(e.isEmpty,e);
  }
}