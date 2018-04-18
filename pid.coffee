  class Controller
    constructor: (proportionalParm, integrationParm, derivativeParm, dt) ->
      if (typeof proportionalParm == 'object')
        options = proportionalParm
        proportionalParm = options.proportionalParm
        integrationParm = options.integrationParm
        derivativeParm = options.derivativeParm
        dt = options.dt || 0
        integrationLimit = options.integrationLimit
  
      # PID constants
      @proportionalParm = if typeof proportionalParm == 'number' then proportionalParm else 1
      @integrationParm = integrationParm || 0
      @derivativeParm = derivativeParm || 0
  
      # Interval of time between two updates
      # If not set, it will be automatically calculated
      @dt = dt || 0
  
      # Maximum absolute value of sumDelta
      @integrationLimit = integrationLimit || 0
      @sumDelta  = 0
      @lastDelta = 0
      @setTarget 0 # default value, can be modified with .setTarget
      return
  
    setTarget: (@target) ->
      @lastTime = Date.now()  # used only if dt is not explicit
      return
  
    update: (@currentValue) -> 
      # Calculate dt
      dt = @dt
      if !dt 
        currentTime = Date.now()
        dt = (currentTime - @lastTime) / 1000 # in seconds
        @lastTime = currentTime
      if (typeof dt != 'number' || dt == 0) 
        dt = 1
  
      delta = @target - @currentValue  #used as the Proportional factor
      
      @sumDelta = @sumDelta + delta*dt  #used as the Integral factor
      if @integrationLimit > 0 && Math.abs(@sumDelta) > @integrationLimit
        sumSign = if @sumDelta > 0 then 1 else -1
        @sumDelta = sumSign * @integrationLimit
  
      dDelta = (delta - @lastDelta)/dt # used as the Derivitive factor
      @lastDelta = delta
      return (@proportionalParm*delta) +
        (@integrationParm * @sumDelta) +
        (@derivativeParm * dDelta)
  
    reset:() ->
      @sumDelta  = 0
      @lastDelta = 0
      @setTarget 0
      return
