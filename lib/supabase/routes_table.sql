-- 5. ROUTES TABLE
-- Stores pre-calculated routes between stations
CREATE TABLE public.routes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  from_station_id TEXT REFERENCES public.stations(station_code),
  to_station_id TEXT REFERENCES public.stations(station_code),
  duration_minutes INTEGER NOT NULL,
  fare NUMERIC(10, 2) NOT NULL,
  intermediate_station_ids TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create an index for faster route lookups
CREATE INDEX routes_stations_idx ON public.routes (from_station_id, to_station_id);

-- Add trigger to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_routes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER routes_updated_at
  BEFORE UPDATE ON public.routes
  FOR EACH ROW
  EXECUTE FUNCTION update_routes_updated_at();

-- Function to calculate routes between stations
CREATE OR REPLACE FUNCTION calculate_route(
  from_code TEXT,
  to_code TEXT
) RETURNS TABLE (
  route_id UUID,
  duration_minutes INTEGER,
  fare NUMERIC(10, 2),
  intermediate_stations TEXT[]
) AS $$
DECLARE
  from_station public.stations%ROWTYPE;
  to_station public.stations%ROWTYPE;
  same_line BOOLEAN;
  distance_km NUMERIC;
  base_fare NUMERIC := 10.00; -- Base fare in currency
  per_km_fare NUMERIC := 2.00; -- Per kilometer fare
BEGIN
  -- Get station details
  SELECT * INTO from_station FROM public.stations WHERE station_code = from_code;
  SELECT * INTO to_station FROM public.stations WHERE station_code = to_code;
  
  -- Check if stations are on the same line
  same_line := from_station.line = to_station.line;
  
  -- Calculate straight-line distance (simplified)
  distance_km := sqrt(power(69.1 * (from_station.latitude - to_station.latitude), 2) +
                     power(69.1 * cos(from_station.latitude / 57.3) * (from_station.longitude - to_station.longitude), 2));
  
  -- Calculate fare based on distance
  fare := base_fare + (distance_km * per_km_fare);
  
  -- Calculate duration (simplified: assume 2 minutes per km on same line, 3 minutes per km if line change needed)
  duration_minutes := CASE 
    WHEN same_line THEN ceil(distance_km * 2)::INTEGER
    ELSE ceil(distance_km * 3)::INTEGER
  END;
  
  -- Create and return the route
  INSERT INTO public.routes (
    from_station_id,
    to_station_id,
    duration_minutes,
    fare,
    intermediate_station_ids
  ) VALUES (
    from_code,
    to_code,
    duration_minutes,
    fare,
    CASE 
      WHEN same_line THEN '{}'::TEXT[]
      ELSE ARRAY[from_code, to_code]
    END
  ) RETURNING id, duration_minutes, fare, intermediate_station_ids INTO route_id, duration_minutes, fare, intermediate_stations;
  
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Function to find or calculate routes between stations
CREATE OR REPLACE FUNCTION find_or_calculate_route(
  from_code TEXT,
  to_code TEXT
) RETURNS SETOF public.routes AS $$
BEGIN
  -- First try to find existing route
  RETURN QUERY 
  SELECT * FROM public.routes 
  WHERE from_station_id = from_code 
  AND to_station_id = to_code;
  
  -- If no rows returned, calculate new route
  IF NOT FOUND THEN
    RETURN QUERY 
    WITH new_route AS (
      SELECT * FROM calculate_route(from_code, to_code)
    )
    SELECT r.* 
    FROM public.routes r
    WHERE r.id = (SELECT route_id FROM new_route);
  END IF;
END;
$$ LANGUAGE plpgsql;