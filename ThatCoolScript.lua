-- This script does cool things
function Initialize()
	oMsKB = SKIN:GetMeasure('MeasureKBWin')
	oMsSub = SKIN:GetMeasure('MeasureSUB')
	
	oMsVol = SKIN:GetMeasure('MeasureVol')
	oMtString = SKIN:GetMeter('MeterString')
	
	timeoutController = class(function(o, nTimeOut, nTimeDecay, onChangeFunc, onTimeOutFunc, monitorFunc)
		o.nTimeDecay = nTimeDecay
		o.nCurTime = nTimeOut
		o.nTimeOut = nTimeOut
		o.onChangeFunc = onChangeFunc
		o.onTimeOutFunc = onTimeOutFunc
		o.monitorFunc = monitorFunc
		o.monFuncOld = nil
	end)
	function timeoutController:update()
		local mFuncRet = self.monitorFunc()
		if self.monFuncOld ~= mFuncRet then
			self.monFuncOld = mFuncRet
			self.nCurTime = self.nTimeOut

			self.onChangeFunc(mFuncRet)
		end

		if self.nCurTime > 0 then
			self.nCurTime = self.nCurTime - self.nTimeDecay
			if self.nCurTime <= 0 then
				self.onTimeOutFunc()
			end
		end
	end
	tc = timeoutController(math.floor(3600 / 25), 1, ShowMeter, HideMeter, TimerMon)

	iOldBr = 0
	iOldLv = 0
	iCurBr = 0
end

function Update()
	tc:update()

	local iBr = 0
	if oMsVol:GetValue() > 0 then
		--print(iCurBr)
		iBr = updateBr()

		iOldLv = oMsSub:GetValue()
	end
	if iOldBr ~= iBr then
		SKIN:Bang('!CommandMeasure', 'MeasureKBWin', "SendMessage 273 50331651 " .. iBr)
		iOldBr = iBr
	end
end

function updateBr()
	local val = oMsSub:GetValue()
	local diff = round(val - iOldLv, 3)
	if diff == 0 and val == 0 then
		return 1
	end

	if diff > 0 then
		diff = diff * 100
	elseif diff < 0 then
		diff = diff * 110
	end
	iCurBr = iCurBr + diff
	iCurBr = clip(iCurBr, 1, 100)

	local iMappedBr = map((val * 100) ^ 2, 0, 100^2, 2, 100)

	return math.floor(iCurBr/3 + iMappedBr/3*2)
end

function map(nVar, nMin1, nMax1, nMin2, nMax2)
	return nMin2 + (nMax2 - nMin2) * ((nVar - nMin1) / (nMax1 - nMin1))
end

function clip(nVar, nMin, nMax)
	if nVar > nMax then return nMax end
	if nVar < nMin then return nMin end
	return nVar
end

function TimerMon()
	return oMsVol:GetValue()
end

function HideMeter()
	oMtString:Hide()
	bMeterShown = false
	SKIN:Bang('!ZPos -2')
end

function ShowMeter(iOldVol)
	oMtString:Show()
	bMeterShown = true
	iMeterTimeOut = iMeterTime
	
	SKIN:Bang('!SetOption', 'MeterString', 'Text', iOldVol)
	SKIN:Bang('!ZPos 1')
end

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
   local c = {}    -- a new class instance
   if not init and type(base) == 'function' then
      init = base
      base = nil
   elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
      for i,v in pairs(base) do
         c[i] = v
      end
      c._base = base
   end
   -- the class will be the metatable for all its objects,
   -- and they will look up their methods in it.
   c.__index = c

   -- expose a constructor which can be called by <classname>(<args>)
   local mt = {}
   mt.__call = function(class_tbl, ...)
   local obj = {}
   setmetatable(obj,c)
   if init then
      init(obj,...)
   else 
      -- make sure that any stuff from the base class is initialized!
      if base and base.init then
      base.init(obj, ...)
      end
   end
   return obj
   end
   c.init = init
   c.is_a = function(self, klass)
      local m = getmetatable(self)
      while m do 
         if m == klass then return true end
         m = m._base
      end
      return false
   end
   setmetatable(c, mt)
   return c
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end