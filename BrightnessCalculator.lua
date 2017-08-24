function Initialize()	
	oMsVol = SKIN:GetMeasure('MeasureVol')

	tLow = init_table(
		10,
		function(i)
			return 11-i
		end,
		function(i)
			return 'MeasureLow' .. i
		end,
		0
	)
	tHigh = init_table(
		10,
		function(i)
			return i
		end,
		function(i)
			return 'MeasureHigh' .. i
		end,
		1
	)
end

function Update()
	local is_muted = oMsVol:GetValue() <= 0
	do_update(tLow, is_muted)
	do_update(tHigh, is_muted)
end

function init_table(count, calculateWeight, getMeasureName, wParam)
	local t = {}
	t.count = count
	t.wParam = wParam

	t.weight = {}
	for i=1,t.count do
		t.weight[i] = calculateWeight(i)
	end
	normalize(t.weight)

	t.measure = {}
	for i=1,10 do
		t.measure[i] = SKIN:GetMeasure(getMeasureName(i))
	end

	t.prev = 999
	t.cur = 0

	return t
end

function do_update(t, mute)
	t.cur = 0
	if not mute then
		for i=1,t.count do
			t.cur = t.cur + t.measure[i]:GetValue() * t.weight[i]
		end
	end

	t.cur = math.floor(map(math.pow(2, t.cur), 1, 2, 82, 8192))

	if t.cur ~= t.prev then
		SKIN:Bang('!CommandMeasure', 'MeasureKBWin', ('SendMessage 273 %d %d'):format(t.wParam, t.cur))
		t.prev = t.cur
	end

	return t.cur
end

function normalize(t)
	local tSum = 0
	for i=1,#t do
		tSum = tSum + t[i]
	end

	local max = 0
	for i=1,#t do
		t[i] = t[i] / tSum
		max = math.max(max, t[i])
	end
	t.max = max
end

function map(nVar, nMin1, nMax1, nMin2, nMax2)
	return nMin2 + (nMax2 - nMin2) * ((nVar - nMin1) / (nMax1 - nMin1))
end