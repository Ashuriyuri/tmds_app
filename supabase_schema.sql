-- TMDS Car Detailing Management System Schema

CREATE TABLE IF NOT EXISTS public.customers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    vehicle TEXT,
    plate_number TEXT,
    color TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.employees (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT,
    phone TEXT,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.bookings (
    id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    brand TEXT,
    model TEXT,
    vehicle TEXT,
    plate_number TEXT,
    color TEXT,
    notes TEXT,
    assigned_mechanic TEXT,
    actual_amount_paid NUMERIC DEFAULT 0,
    service_status TEXT DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    services JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS public.payments (
    id TEXT PRIMARY KEY,
    booking_id TEXT REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer TEXT NOT NULL,
    service TEXT,
    total NUMERIC NOT NULL,
    paid NUMERIC NOT NULL,
    method TEXT DEFAULT 'Cash',
    date TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Allow public access with anon key for this mobile demo
CREATE POLICY "Allow anon all customers" ON public.customers FOR ALL USING (true);
CREATE POLICY "Allow anon all employees" ON public.employees FOR ALL USING (true);
CREATE POLICY "Allow anon all bookings" ON public.bookings FOR ALL USING (true);
CREATE POLICY "Allow anon all payments" ON public.payments FOR ALL USING (true);

