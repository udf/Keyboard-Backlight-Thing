function Initialize()	
	oMsVol = SKIN:GetMeasure('MeasureVol')

	tMsSub = {}
	tWeights = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
	normalize(tWeights)
	for i=1,10 do
		tMsSub[i] = SKIN:GetMeasure('MeasureSub' .. i)
	end

	iPrevBrightness = 999
end

function Update()
	local iCurrentBrightness = 0
	if oMsVol:GetValue() > 0 then
		for i=1,10 do
			iCurrentBrightness = iCurrentBrightness + tMsSub[i]:GetValue()*tWeights[i]
		end
		iCurrentBrightness = math.floor(iCurrentBrightness * 99) + 1
	end

	if iPrevBrightness ~= iCurrentBrightness then
		SKIN:Bang('!CommandMeasure', 'MeasureKBWin', 'SendMessage 273 50331651 ' .. iCurrentBrightness)
		iPrevBrightness = iCurrentBrightness
	end
end

function normalize(t)
	local tSum = 0
	for i=1,#t do
		tSum = tSum + t[i]
	end

	for i=1,#t do
		t[i] = t[i] / tSum
	end
end

function map(nVar, nMin1, nMax1, nMin2, nMax2)
	return nMin2 + (nMax2 - nMin2) * ((nVar - nMin1) / (nMax1 - nMin1))
end