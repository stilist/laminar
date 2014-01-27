# Largely a port of http://www.esrl.noaa.gov/gmd/grad/solcalc/
# I don’t understand trig, but it works!

arc2deg = (degrees=0, minutes=0, seconds=0) ->
	degrees + (minutes / 60) + (seconds / 60 / 60)

abs = Math.abs
acos = Math.acos
asin = Math.asin
cos = Math.cos
# unsigned integer division
floor = (n) -> ~~n
pow = Math.pow
sin = Math.sin
tan = Math.tan

minutes_in_day = 24 * 60

Date::getAzimuthAndElevation or= (φ, λ) ->
	φRad = φ.deg2rad()

	EoT = @getEquationOfTime()
	δ = @getSolarDeclination()
	δRad = δ.deg2rad()
	tz = -(@getTimezoneOffset() / 60)

	solarTimeFix = EoT + 4 * λ - 60 * tz
	true_solar_time = @getMinuteOfDay() + solarTimeFix
	true_solar_time -= minutes_in_day while true_solar_time > minutes_in_day

	h = true_solar_time / 4 - 180
	h += 360 if h < -180

	csz = sin(φRad) * sin(δRad) + cos(φRad) * cos(δRad) * cos(h.deg2rad())
	csz = 1 if csz > 1
	csz = -1 if csz < -1

	ζRad = acos csz
	ζ = ζRad.rad2deg()
	α_denominator = cos(φRad) * sin(ζRad)

	if abs(α_denominator) > 0.001
		αRad = ((sin(φRad) * cos(ζRad)) - sin(δRad)) / α_denominator

		if abs(αRad) > 1
			αRad = if αRad < 0 then -1 else 1

		α = 180 - acos(αRad).rad2deg()
		α *= -1 if h > 0
	else
		α = if φ > 0 then 180 else 0

	α += 360 if α < 0

	α_s = 90 - ζ
	refraction_correction = @getRefractionCorrection α_s
	ζ_s = ζ - refraction_correction

	α_output = floor(α * 100 + 0.5) / 100
	γ_output = floor((90 - ζ_s) * 100 + 0.5) / 100

	[α_output, γ_output]

Date::getDayOfYearFromJulianDate or= (jd) ->
	z = floor(jd + 0.5)
	f = (jd + 0.5) - z
	if z < 2299161
		A = z
	else
		α = floor((z - 1867216.25) / 36524.25)
		A = z + 1 + α - floor(α / 4)

	B = A + 1524
	C = floor((B - 122.1) / 365.25)
	D = floor(365.25 * C)
	E = floor((B - D) / 30.6001)
	day = B - D - floor(30.6001 * E) + f
	month = if (E < 14) then E - 1 else E - 13
	year = if (month > 2) then C - 4716 else C - 4715

	k = if @isLeapYear(year) then 1 else 2
	floor((275 * month) / 9) - k * floor((month + 9) / 12) + day - 30

Date::getEarthOrbitalEccentricity or= ->
	T = @getJulianCentury()

	0.016708634 - 0.000042037 * T + 0.0000001267 * pow(T, 2) # unitless

# unclear where they got this
Date::getEquationOfTime or= ->
	ε = @getObliquityCorrection()

	L_0 = @getSolarMeanLongitude().deg2rad()
	sin2L_0 = sin L_0 * 2
	cos2L_0 = cos L_0 * 2
	sin4L_0 = sin L_0 * 4

	e = @getEarthOrbitalEccentricity()

	M = @getSolarMeanAnomaly().deg2rad()
	sinM = sin M
	sin2M = sin M * 2

	y = pow (tan ε.deg2rad() / 2), 2

	E_time = y * sin2L_0 -
			2 * e * sinM +
			4 * e * y * sinM * cos2L_0 -
			0.5 * y * y * sin4L_0 -
			1.25 * e * e * sin2M
	E_time.rad2deg() * 4 # minutes (time)

# Julian centuries since 1/1/2000 (J2000)
Date::getJulianCentury or= (day) ->
	day or= @getJulianDay()

	(day - 2451545) / 36525

Date::getJulianDay or= ->
	day = @getDate()
	month = @getMonth() + 1
	year = @getFullYear()

	a = floor((14 - month) / 12)
	y = year + 4800 - a
	m = month + 12 * a - 3

	day + floor((153 * m + 2) / 5) + 365 * y +
			floor(y / 4) - floor(y / 100) + floor(y / 400) - 32045

# per Astronomical Almanac 2010
Date::getMeanObliquityOfEcliptic or= ->
	T = @getJulianCentury()

	# J2000
	arc2deg(23, 26, 21.406) -
			# drift
			arc2deg(0, 0, 46.836769) * T -
			arc2deg(0, 0, 0.0001831) * pow(T, 2) -
			arc2deg(0, 0, 0.00200340) * pow(T, 3) -
			arc2deg(0, 0, 0.576e-6) * pow(T, 4) -
			arc2deg(0, 0, 4.34e-8) * pow(T, 5) # degrees

Date::getMinuteOfDay or= -> (@getHours() * 60) + @getMinutes() + (@getSeconds() / 60)

Date::getNextSolarTransit or= (next=true, rising, jd, φ, λ) ->
	mod = if next then 1 else -1
	tz = -(@getTimezoneOffset() / 60)

	transit = @getSolarTransitUTC rising, jd, φ, λ
	while _.isNaN transit
		jd += mod
		transit = @getSolarTransitUTC rising, jd, φ, λ

	timeLocal = transit + tz * 60 + (if dst then 60 else 0)
	while (timeLocal < 0) or (timeLocal >= minutes_in_day)
		mod = if (timeLocal < 0) then 1 else -1
		timeLocal += mod * minutes_in_day
		jd -= mod

	jd

Date::getNonDSTTimezoneOffset or= ->
	year = @getFullYear()
	jan = new Date year, 0, 1
	jul = new Date year, 6, 1

	Math.max jan.getTimezoneOffset(), jul.getTimezoneOffset()

Date::getObliquityCorrection or= ->
	ε_0 = @getMeanObliquityOfEcliptic()

	T = @getJulianCentury()
	Ω = 125.04 - 1934.136 * T

	ε_0 + 0.00256 * cos(Ω.deg2rad()) # degrees

Date::getRefractionCorrection or= (elevation) ->
	if elevation > 85
		0
	else
		tan_elevation = tan elevation.deg2rad()

		if elevation > 5
			correction = 58.1 / tan_elevation -
					0.07 / pow(tan_elevation, 3) +
					0.000086 / pow(tan_elevation, 5)
		else if elevation > -0.575
			correction = 1735 +
					-518.2 * elevation +
					103.4 * pow(elevation, 2) +
					-12.79 * pow(elevation, 3) +
					0.711 * pow(elevation, 4)
		else
			correction = -20.774 / tan_elevation

		correction / 3600 # ?

Date::getSolarApparentLongitude or= ->
	T = @getJulianCentury()

	o = @getSolarTrueLongitude()
	Ω = 125.04 - 1934.136 * T
	o - 0.00569 - 0.00478 * sin(Ω.deg2rad())

Date::getSolarDeclination or= ->
	ε = @getObliquityCorrection().deg2rad()
	λ = @getSolarApparentLongitude().deg2rad()

	sinT = sin(ε) * sin(λ)
	asin(sinT).rad2deg() # degrees

Date::getSolarEquationOfTheCenter or= ->
	T = @getJulianCentury()

	M = @getSolarMeanAnomaly()
	MRad = M.deg2rad()
	sinM = sin MRad
	sin2M = sin MRad * 2
	sin3M = sin MRad * 3
	sinM * (1.914602 - T * (0.004817 + 0.000014 * T)) +
			sin2M * (0.019993 - 0.000101 * T) +
			sin3M * 0.000289 # degrees

Date::getSolarMeanAnomaly or= ->
	T = @getJulianCentury()

	357.52911 + 35999.05029 * T - 0.0001537 * pow(T, 2) # degrees

# unclear what units the constants are in--degrees?
Date::getSolarMeanLongitude or= ->
	T = @getJulianCentury()

	L_0 = 280.46645 + 36000.76983 * T + 0.0003032 * pow(T, 2)
	L_0 -= 360 while L_0 > 360
	L_0 += 360 while L_0 < 0

	L_0 # degrees

Date::getSolarNoon or= (φ, λ) ->
	jd = @getJulianDay()
	tz = -(@getTimezoneOffset() / 60)

	T_noon = @getJulianCentury jd - λ / 360
	EoT_noon = @getEquationOfTime T_noon
	solar_noon_offset = 720 - (λ * 4) - EoT_noon # minutes (time)
	T_next = @getJulianCentury jd + solar_noon_offset / minutes_in_day
	next_offset = @getEquationOfTime T_next
	solar_noon = 720 - (λ * 4) - next_offset + (tz * 60) # minutes (time)

	solar_noon += 60 if @isDST()
	solar_noon += minutes_in_day while solar_noon < 0
	solar_noon -= minutes_in_day while solar_noon >= minutes_in_day

	moment(@).startOf("day").add("minutes", solar_noon).toDate()

Date::getSolarTransit or= (rising=true, φ, λ) ->
	jd = @getJulianDay()
	tz = -(@getTimezoneOffset() / 60)

	UTC = @getSolarTransitUTC rising, jd, φ, λ
	UTC_next = @getSolarTransitUTC rising, (jd + UTC / minutes_in_day), φ, λ

	time = UTC_next + (tz * 60)
	time += 60 if @isDST()

	moment(@).startOf("day").add("minutes", time).toDate()

Date::getSolarTransitHourAngle or= (φ, δ) ->
	φRad = φ.deg2rad()
	δRad = δ.deg2rad()

	h_arg = cos(90.833.deg2rad()) / (cos(φRad) * cos(δRad)) -
			tan(φRad) * tan(δRad)
	acos h_arg

Date::getSolarTransitUTC or= (rising=true, jd, φ, λ) ->
	T = @getJulianCentury jd
	EoT = @getEquationOfTime()
	δ = @getSolarDeclination()

	h = @getSolarTransitHourAngle φ, δ
	h *= -1 if not rising

	Δ = λ + h.rad2deg()
	720 - (4 * Δ) - EoT # minutes (time)

Date::getSolarTrueLongitude or= ->
	L_0 = @getSolarMeanLongitude()
	c = @getSolarEquationOfTheCenter()

	L_0 + c # degrees

# http://javascript.about.com/library/bldst.htm
Date::isDST or= -> @getTimezoneOffset() < @getNonDSTTimezoneOffset()

# http://stackoverflow.com/a/8175905
Date::isLeapYear or= -> new Date(@getFullYear(), 1, 29).getMonth() is 1
