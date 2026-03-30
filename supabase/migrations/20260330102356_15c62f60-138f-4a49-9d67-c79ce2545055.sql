-- Create registrations table
CREATE TABLE public.registrations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit registration"
  ON public.registrations FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Authenticated users can read registrations"
  ON public.registrations FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete registrations"
  ON public.registrations FOR DELETE
  TO authenticated
  USING (true);

-- Create pdf_template table
CREATE TABLE public.pdf_template (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL DEFAULT 'Career OS — Your Playbook',
  sections JSONB NOT NULL DEFAULT '[{"heading": "Introduction", "body": "Welcome to Career OS — your personal career playbook designed to help you navigate the modern job market.", "visible": true}, {"heading": "Career Tips", "body": "1. Build your personal brand online.\n2. Network strategically, not randomly.\n3. Focus on skills that compound over time.\n4. Always be learning.", "visible": true}, {"heading": "Resources", "body": "LinkedIn optimization guide, Resume templates, Interview preparation checklist, Salary negotiation scripts", "visible": true}, {"heading": "Call to Action", "body": "Ready to take your career to the next level? Follow RizMango for more insights and strategies.", "visible": true}]'::jsonb,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.pdf_template ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read pdf template"
  ON public.pdf_template FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can update pdf template"
  ON public.pdf_template FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert pdf template"
  ON public.pdf_template FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Insert default template
INSERT INTO public.pdf_template (title) VALUES ('Career OS — Your Playbook');

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_pdf_template_updated_at
  BEFORE UPDATE ON public.pdf_template
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();