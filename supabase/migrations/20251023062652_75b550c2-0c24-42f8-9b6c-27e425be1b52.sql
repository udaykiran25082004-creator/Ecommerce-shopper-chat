-- Create conversations table to store chat sessions
CREATE TABLE public.conversations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create messages table to store chat messages
CREATE TABLE public.messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create products table to store product comparison data
CREATE TABLE public.products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  store TEXT NOT NULL,
  rating DECIMAL(3,2),
  image_url TEXT,
  product_url TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- RLS Policies for conversations
CREATE POLICY "Users can view their own conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can create conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own conversations"
  ON public.conversations FOR UPDATE
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete their own conversations"
  ON public.conversations FOR DELETE
  USING (auth.uid() = user_id OR user_id IS NULL);

-- RLS Policies for messages
CREATE POLICY "Users can view messages in their conversations"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = messages.conversation_id
      AND (conversations.user_id = auth.uid() OR conversations.user_id IS NULL)
    )
  );

CREATE POLICY "Users can create messages in their conversations"
  ON public.messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE conversations.id = messages.conversation_id
      AND (conversations.user_id = auth.uid() OR conversations.user_id IS NULL)
    )
  );

-- RLS Policies for products (public read access)
CREATE POLICY "Anyone can view products"
  ON public.products FOR SELECT
  USING (true);

-- Create indexes for better performance
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at);
CREATE INDEX idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX idx_products_name ON public.products(name);
CREATE INDEX idx_products_price ON public.products(price);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatic timestamp updates
CREATE TRIGGER update_conversations_updated_at
  BEFORE UPDATE ON public.conversations
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Insert some sample product data
INSERT INTO public.products (name, price, store, rating, image_url, product_url, description) VALUES
('iPhone 15 Pro', 999.00, 'Amazon', 4.8, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400', 'https://amazon.com', 'Latest iPhone with A17 Pro chip'),
('iPhone 15 Pro', 1049.00, 'Best Buy', 4.7, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400', 'https://bestbuy.com', 'Pro model with titanium design'),
('Samsung Galaxy S24', 799.00, 'Amazon', 4.6, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400', 'https://amazon.com', 'Latest Samsung flagship'),
('Samsung Galaxy S24', 849.00, 'Walmart', 4.5, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400', 'https://walmart.com', 'Premium Android phone'),
('MacBook Pro M3', 1999.00, 'Apple Store', 4.9, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400', 'https://apple.com', 'Powerful laptop with M3 chip'),
('Dell XPS 15', 1699.00, 'Dell', 4.6, 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400', 'https://dell.com', 'High-performance Windows laptop'),
('Sony WH-1000XM5', 399.00, 'Amazon', 4.8, 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=400', 'https://amazon.com', 'Premium noise-canceling headphones'),
('AirPods Pro 2', 249.00, 'Apple Store', 4.7, 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400', 'https://apple.com', 'Active noise cancellation earbuds');
