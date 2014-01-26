# https://github.com/auzroz/flightxml2-jsonclient-ruby

require 'rest-client'
require 'json'
require_relative './FlightXML2REST.rb'

class FlightXML2REST
	DefaultEndpointUrl = "http://flightxml.flightaware.com/json/FlightXML2/"
	attr_accessor :username, :apiKey, :endpoint_url

	def initialize(username, apiKey, endpoint_url = nil)
		endpoint_url ||= DefaultEndpointUrl
		$api = RestClient::Resource.new(endpoint_url, username, apiKey)
	end

	#Methods
	def AircraftType(aircraftTypeRequest)
		@aircraftTypeResult = AircraftTypeResults.new($api['AircraftType'].post aircraftTypeRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AirlineFlightInfo(airlineFlightInfoRequest)
		@airlineFlightInfoResult = AirlineFlightInfoResults.new($api['AirlineFlightInfo'].post airlineFlightInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AirlineFlightSchedules(airlineFlightSchedulesRequest)
		@airlineFlightSchedulesResult = AirlineFlightSchedulesResults.new($api['AirlineFlightSchedules'].post airlineFlightSchedulesRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AirlineInfo(airlineInfoRequest)
		@airlineInfoResult = AirlineInfoResults.new($api['AirlineInfo'].post airlineInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AirlineInsight(airlineInsightRequest)
		@airlineInsightResult = AirlineInsightResults.new($api['AirlineInsight'].post airlineInsightRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AirportInfo(airportInfoRequest)
		@airportInfoResult = AirportInfoResults.new($api['AirportInfo'].post airportInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AllAirlines(allAirlinesRequest)
		@allAirlinesResult = AllAirlinesResults.new($api['AllAirlines'].post allAirlinesRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def AllAirports(allAirportsRequest)
		@allAirportsResult = AllAirportsResults.new($api['AllAirports'].post allAirportsRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Arrived(arrivedRequest)
		@arrivedResult = ArrivedResults.new($api['Arrived'].post arrivedRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def BlockIdentCheck(blockIdentCheckRequest)
		@blockIdentCheckResult = BlockIdentCheckResults.new($api['BlockIdentCheck'].post blockIdentCheckRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def CountAirportOperations(countAirportOperationsRequest)
		@countAirportOperationsResult = CountAirportOperationsResults.new($api['CountAirportOperations'].post countAirportOperationsRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def CountAllEnrouteAirlineOperations(countAllEnrouteAirlineOperationsRequest)
		@countAllEnrouteAirlineOperationsResult = CountAllEnrouteAirlineOperationsResults.new($api['CountAllEnrouteAirlineOperations'].post countAllEnrouteAirlineOperationsRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def DecodeFlightRoute(decodeFlightRouteRequest)
		@decodeFlightRouteResult = DecodeFlightRouteResults.new($api['DecodeFlightRoute'].post decodeFlightRouteRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def DecodeRoute(decodeRouteRequest)
		@decodeRouteResult = DecodeRouteResults.new($api['DecodeRoute'].post decodeRouteRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def DeleteAlert(deleteAlertRequest)
		@deleteAlertResult = DeleteAlertResults.new($api['DeleteAlert'].post deleteAlertRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Departed(departedRequest)
		@departedResult = DepartedResults.new($api['Departed'].post departedRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Enroute(enrouteRequest)
		@enrouteResult = EnrouteResults.new($api['Enroute'].post enrouteRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def FleetArrived(fleetArrivedRequest)
		@fleetArrivedResult = FleetArrivedResults.new($api['FleetArrived'].post fleetArrivedRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def FleetScheduled(fleetScheduledRequest)
		@fleetScheduledResult = FleetScheduledResults.new($api['FleetScheduled'].post fleetScheduledRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def FlightInfo(flightInfoRequest)
		@flightInfoResult = FlightInfoResults.new($api['FlightInfo'].post flightInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def FlightInfoEx(flightInfoExRequest)
		@flightInfoExResult = FlightInfoExResults.new($api['FlightInfoEx'].post flightInfoExRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def GetAlerts(getAlertsRequest)
		@getAlertsResult = GetAlertsResults.new($api['GetAlerts'].post getAlertsRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def GetFlightID(getFlightIDRequest)
		@getFlightIDResult = GetFlightIDResults.new($api['GetFlightID'].post getFlightIDRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def GetHistoricalTrack(getHistoricalTrackRequest)
		@getHistoricalTrackResult = GetHistoricalTrackResults.new($api['GetHistoricalTrack'].post getHistoricalTrackRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def GetLastTrack(getLastTrackRequest)
		@getLastTrackResult = GetLastTrackResults.new($api['GetLastTrack'].post getLastTrackRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def InboundFlightInfo(inboundFlightInfoRequest)
		@inboundFlightInfoResult = InboundFlightInfoResults.new($api['InboundFlightInfo'].post inboundFlightInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def InFlightInfo(inFlightInfoRequest)
		@inFlightInfoResult = InFlightInfoResults.new($api['InFlightInfo'].post inFlightInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def LatLongsToDistance(latLongsToDistanceRequest)
		@latLongsToDistanceResult = LatLongsToDistanceResults.new($api['LatLongsToDistance'].post latLongsToDistanceRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def LatLongsToHeading(latLongsToHeadingRequest)
		@latLongsToHeadingResult = LatLongsToHeadingResults.new($api['LatLongsToHeading'].post latLongsToHeadingRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def MapFlight(mapFlightRequest)
		@mapFlightResult = MapFlightResults.new($api['MapFlight'].post mapFlightRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def MapFlightEx(mapFlightExRequest)
		@mapFlightExResult = MapFlightExResults.new($api['MapFlightEx'].post mapFlightExRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Metar(metarRequest)
		@metarResult = MetarResults.new($api['Metar'].post metarRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def MetarEx(metarExRequest)
		@metarExResult = MetarExResults.new($api['MetarEx'].post metarExRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def NTaf(nTafRequest)
		@nTafResult = NTafResults.new($api['NTaf'].post nTafRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def RegisterAlertEndpoint(registerAlertEndpointRequest)
		@registerAlertEndpointResult = RegisterAlertEndpointResults.new($api['RegisterAlertEndpoint'].post registerAlertEndpointRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def RoutesBetweenAirports(routesBetweenAirportsRequest)
		@routesBetweenAirportsResult = RoutesBetweenAirportsResults.new($api['RoutesBetweenAirports'].post routesBetweenAirportsRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def RoutesBetweenAirportsEx(routesBetweenAirportsExRequest)
		@routesBetweenAirportsExResult = RoutesBetweenAirportsExResults.new($api['RoutesBetweenAirportsEx'].post routesBetweenAirportsExRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Scheduled(scheduledRequest)
		@scheduledResult = ScheduledResults.new($api['Scheduled'].post scheduledRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Search(searchRequest)
		@searchResult = SearchResults.new($api['Search'].post searchRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def SearchBirdseyeInFlight(searchBirdseyeInFlightRequest)
		@searchBirdseyeInFlightResult = SearchBirdseyeInFlightResults.new($api['SearchBirdseyeInFlight'].post searchBirdseyeInFlightRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def SearchBirdseyePositions(searchBirdseyePositionsRequest)
		@searchBirdseyePositionsResult = SearchBirdseyePositionsResults.new($api['SearchBirdseyePositions'].post searchBirdseyePositionsRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def SearchCount(searchCountRequest)
		@searchCountResult = SearchCountResults.new($api['SearchCount'].post searchCountRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def SetAlert(setAlertRequest)
		@setAlertResult = SetAlertResults.new($api['SetAlert'].post setAlertRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def SetMaximumResultSize(setMaximumResultSizeRequest)
		@setMaximumResultSizeResult = SetMaximumResultSizeResults.new($api['SetMaximumResultSize'].post setMaximumResultSizeRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def Taf(tafRequest)
		@tafResult = TafResults.new($api['Taf'].post tafRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def TailOwner(tailOwnerRequest)
		@tailOwnerResult = TailOwnerResults.new($api['TailOwner'].post tailOwnerRequest.post, :content_type => "application/x-www-form-urlencoded")
	end

	def ZipcodeInfo(zipcodeInfoRequest)
		 @zipcodeInfoResult = ZipcodeInfoResults.new($api['ZipcodeInfo'].post zipcodeInfoRequest.post, :content_type => "application/x-www-form-urlencoded")
	end
end
