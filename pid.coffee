PID = class PID
###
the PID style of controller is intended to track a quantity from the real world as detected by some sensor.
The sensor is assumed to be reliable as possible, consistent and acccurate.
the output of the controller is a single quantity that controls a single output device.
The output device is related in some fashion to changes in the real world that affect the sensor.
A PID controller ses the input values to compte an output variable by looking at three internally 
computed quantities.
1) the Proportial component, which simply is related to "How far away from our goal are we?"
2) the Integral component, which is related to "How far have we come to our goal?"
3) the Differential component, which asks "are we taking big steps, or tiny ones?"
###
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
if module.exports
  module.exports = PID
if window
  window.PID=PID

  
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
