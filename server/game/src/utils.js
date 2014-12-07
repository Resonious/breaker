// Generated by LiveScript 1.3.0
(function(){
  this.towards = curry$(function(current, target, amount){
    var increment, passed, result;
    switch (false) {
    case current !== target:
      return current;
    default:
      increment = null;
      passed = null;
      if (current > target) {
        increment = (function(it){
          return it - amount;
        });
        passed = curry$(function(x$, y$){
          return x$ < y$;
        });
      } else {
        increment = (function(it){
          return it + amount;
        });
        passed = curry$(function(x$, y$){
          return x$ > y$;
        });
      }
      result = increment(current);
      if (passed(result, target)) {
        return target;
      } else {
        return result;
      }
    }
  });
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
}).call(this);